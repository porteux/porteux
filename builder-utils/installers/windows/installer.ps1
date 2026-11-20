param([string]$DriveLetter)

$ErrorActionPreference = 'Stop'

function Fail([string]$Message) {
	Write-Host $Message
	exit 1
}

try {
	$root = $DriveLetter + ':\'
	$bootImagePath = $root + 'boot\grub\boot.img'
	$coreImagePath = $root + 'boot\grub\core.img'

	if (-not (Test-Path ($root + 'boot\syslinux\porteux.cfg'))) {
		Fail "PorteuX cfg file couldn't be found in ${root}boot\syslinux"
	}
	if (-not (Test-Path $bootImagePath) -or -not (Test-Path $coreImagePath)) {
		Fail "Couldn't find the bootloader files in ${root}boot\grub"
	}

	$logicalDisk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='${DriveLetter}:'"
	$partition = $logicalDisk.GetRelated('Win32_DiskPartition') | Select-Object -First 1
	if (-not $partition) {
		Fail "Couldn't find the partition of ${DriveLetter}:"
	}

	if ($partition.Type -like 'GPT*') {
		if ($logicalDisk.FileSystem -notlike 'FAT*') {
			Fail "This media uses a GPT partition table, so it can only boot in UEFI mode.`r`nUEFI can only read FAT, so the partition holding \boot and \EFI must be FAT32."
		}
		if (-not (Test-Path ($root + 'EFI\BOOT\bootx64.efi')) -or -not (Test-Path ($root + 'EFI\BOOT\bootia32.efi'))) {
			Fail "Couldn't find bootx64.efi and bootia32.efi in ${root}EFI\BOOT`r`nCopy the \EFI folder from the ISO onto this partition and try again."
		}
		Write-Host 'This media uses a GPT partition table: it will boot in UEFI mode only.'
		Write-Host 'For legacy BIOS boot the media must use an MS-DOS partition table.'
		exit 0
	}

	$diskIndex = $partition.DiskIndex
	$partitionStart = [uint64]$partition.StartingOffset / 512
	if ($partitionStart -eq 0) {
		Fail "Only 'MS-DOS' or 'GPT' partition tables are supported. Format your storage media using one of these partition tables and try again."
	}

	$diskDrive = Get-WmiObject Win32_DiskDrive -Filter "Index=$diskIndex"
	if ($diskDrive.BytesPerSector -and $diskDrive.BytesPerSector -ne 512) {
		Fail "Only disks with 512-byte sectors are supported by the bootloader."
	}

	$bootImage = [IO.File]::ReadAllBytes($bootImagePath)
	$coreImage = [IO.File]::ReadAllBytes($coreImagePath)
	$coreSectors = [int][math]::Ceiling($coreImage.Length / 512)
	$coreBuffer = New-Object byte[] ($coreSectors * 512)
	[Array]::Copy($coreImage, $coreBuffer, $coreImage.Length)

	Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using Microsoft.Win32.SafeHandles;
public static class RawDisk {
	[DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
	public static extern SafeFileHandle CreateFile(string name, uint access, uint share, IntPtr security, uint creation, uint flags, IntPtr template);
}
"@

	$handle = [RawDisk]::CreateFile("\\.\PhysicalDrive$diskIndex", [uint32]3221225472, 3, [IntPtr]::Zero, 3, 0, [IntPtr]::Zero)
	if ($handle.IsInvalid) {
		Fail ("Couldn't open disk $diskIndex (error " + [Runtime.InteropServices.Marshal]::GetLastWin32Error() + ")")
	}
	$disk = New-Object IO.FileStream($handle, [IO.FileAccess]::ReadWrite)
	try {
		$mbr = New-Object byte[] 512
		if ($disk.Read($mbr, 0, 512) -ne 512 -or $mbr[510] -ne 0x55 -or $mbr[511] -ne 0xAA) {
			Fail "Couldn't read a valid MBR from disk $diskIndex"
		}

		$firstPartitionStart = [uint64]::MaxValue
		$activeEntry = -1
		for ($i = 0; $i -lt 4; $i++) {
			$entry = 446 + 16 * $i
			if ($mbr[$entry + 4] -ne 0) {
				$entryStart = [BitConverter]::ToUInt32($mbr, $entry + 8)
				if ($entryStart -gt 0 -and $entryStart -lt $firstPartitionStart) {
					$firstPartitionStart = $entryStart
				}
				if ($entryStart -eq $partitionStart) {
					$activeEntry = $i
				}
			}
		}

		if ($firstPartitionStart -le $coreSectors) {
			Fail ("Not enough free space before the first partition to install the bootloader.`r`nThe first partition must start at sector " + ($coreSectors + 1) + " or later (2048 is recommended).")
		}

		[Array]::Copy($bootImage, 0, $mbr, 0, 3)
		[Array]::Copy($bootImage, 90, $mbr, 90, 350)
		$mbr[102] = 0x90
		$mbr[103] = 0x90

		if ($activeEntry -ge 0) {
			for ($i = 0; $i -lt 4; $i++) {
				$mbr[446 + 16 * $i] = 0x00
			}
			$mbr[446 + 16 * $activeEntry] = 0x80
		}

		Write-Host 'Installing GRUB bootloader...'
		$disk.Position = 512
		$disk.Write($coreBuffer, 0, $coreBuffer.Length)
		$disk.Position = 0
		$disk.Write($mbr, 0, 512)
		$disk.Flush()
	}
	finally {
		$disk.Close()
	}
}
catch {
	Fail $_.Exception.Message
}

exit 0
