#!/bin/bash

if [ "$ARCHIVE_DIR" ] && [ "$USER_PWD" ]; then
	INSTALLERPATH=$(cd "$USER_PWD" && cd "$ARCHIVE_DIR" && pwd -P)
else
	INSTALLERPATH="$1"
fi
EXTRACTEDFOLDER="$PWD"

isCpuSupported=$(cat /proc/cpuinfo | grep flags | head -n 1 | cut -d: -f2 | grep sse4_2)
if [ -z "$isCpuSupported" ]; then
	echo -e "\nYour CPU lacks SSE4.2 and PorteuX will fail to boot unless you build it from scratch to be compatible with your CPU."
fi

checkRoot() {
	[ "$(id -u)" -eq 0 ] && return 0

	echo -e "\nAdmin's password is required."
	sudo env ARCHIVE_DIR="$ARCHIVE_DIR" USER_PWD="$USER_PWD" bash -c "$(printf '%q ' "$0" "$INSTALLERPATH")"
	exit $?
}

checkRoot

CleanUp(){
	rm -fr "$EXTRACTEDFOLDER"
}

PressEnterToContinue(){
	echo "Press Enter to continue"
	read abook
}

Debug() {
cat << ENDOFTEXT > "$LOGFILEPATH"
installer path: $INSTALLERPATH
script path: $EXTRACTEDFOLDER
partition name: $PARTITIONNAME
dev partition: $DEVPARTITIONPATH
media name: $MEDIANAME
partition Number: $PARTITIONNUMBER
partition mount point: $PARTITIONMOUNTPATH
mount details: `grep -w "^$DEVPARTITIONPATH" /proc/mounts`
partition filesystem: $PARTITIONFILESYSTEM
partition table type: $PARTITIONTABLETYPE
error code: $1
system: `uname -a`
media storage partition scheme:
`fdisk -l $DEVMEDIANAME`

ENDOFTEXT
}

FailMessage() {
if [ $? -ne 0 ]; then
	echo
	echo 'Installation failed with error code '"'$1'"'.'
	echo 'A log file has been created: '$LOGFILEPATH''
	echo 'Make sure this storage media is not read-only and you have permission'
	echo 'to change files. Try to unplug/plug this storage media or reboot your'
	echo 'system and run the installer again. If the problem persists, try to'
	echo 'create a new partition from scratch.'
	echo
	Debug $1
	CleanUp
	exit $1
fi
}

for tool in sfdisk blockdev zstd cpio blkid lsblk; do
	if ! command -v "$tool" > /dev/null 2>&1; then
		echo "Could not find $tool"
		CleanUp
		PressEnterToContinue
		exit 1
	fi
done

LOGFILEPATH="/tmp/porteux-installer-debug.txt"
read -r DEVPARTITIONPATH PARTITIONFILESYSTEM PARTITIONMOUNTPATH < <(df --output=source,fstype,target "$INSTALLERPATH" | tail -n1)
PARTITIONNAME=${DEVPARTITIONPATH#/dev/}
MEDIANAME=$(lsblk -ndo pkname $DEVPARTITIONPATH)
DEVMEDIANAME=/dev/"$MEDIANAME"
PARTITIONNUMBER=$(echo ${DEVPARTITIONPATH#"$DEVMEDIANAME"} | sed 's/[^0-9]*//g')

if [ -z "$MEDIANAME" ]; then
	echo "This storage media $PARTITIONMOUNTPATH is not mounted correctly. Please plug it again or reboot your system"
	CleanUp
	exit 1
fi

PARTITIONTABLETYPE=$(blkid -o value -s PTTYPE $DEVMEDIANAME)

if ! echo "$PARTITIONFILESYSTEM" | grep -qE 'ext|vfat|msdos|exfat|ntfs|fuseblk|btrfs|xfs'; then
	echo "Partition filesystem not supported by the bootloader: $PARTITIONFILESYSTEM"
	echo "The partition holding /boot must be ext2/3/4, FAT, exFAT, NTFS, btrfs or XFS."
	Debug 1
	CleanUp
	exit 1
elif [ ! -f "$PARTITIONMOUNTPATH"/boot/syslinux/porteux.cfg ]; then
	echo "PorteuX cfg file couldn't be found in $PARTITIONMOUNTPATH/boot/syslinux"
	Debug 1
	CleanUp
	exit 1
elif [ ! -f "$PARTITIONMOUNTPATH"/boot/syslinux/initrd.zst ]; then
	echo "Couldn't find $PARTITIONMOUNTPATH/boot/syslinux/initrd.zst"
	Debug 1
	CleanUp
	exit 1
elif [ ! -f "$PARTITIONMOUNTPATH"/boot/grub/boot.img ] || [ ! -f "$PARTITIONMOUNTPATH"/boot/grub/core.img ]; then
	echo "Couldn't find the bootloader files in $PARTITIONMOUNTPATH/boot/grub"
	Debug 1
	CleanUp
	exit 1
elif [ "$PARTITIONTABLETYPE" != "dos" ] && [ "$PARTITIONTABLETYPE" != "gpt" ]; then
	echo "Only 'dos', 'msdos' or 'gpt' partition tables are supported."
	echo "Format your storage media using one of these partition tables and try again."
	Debug 1
	CleanUp
	exit 1
fi

clear
echo "PorteuX is going to be installed in $DEVPARTITIONPATH (mounted at $PARTITIONMOUNTPATH)"
if [ "$PARTITIONTABLETYPE" = "gpt" ]; then
	echo
	echo "This media uses a GPT partition table: it will boot in UEFI mode only."
	echo "For legacy BIOS boot the media must use an MS-DOS partition table."
fi
echo
PressEnterToContinue

echo "Flushing filesystem buffers..."
sync

if [ "$PARTITIONTABLETYPE" = "dos" ]; then
	echo "Installing GRUB bootloader..."
	if [ "$(blockdev --getss "$DEVMEDIANAME" 2>/dev/null)" != "512" ]; then
		echo "Only storage media with 512-byte sectors are supported by the bootloader."
		Debug 5
		CleanUp
		exit 5
	fi
	CORESECTORS=$(( ($(stat -c %s "$PARTITIONMOUNTPATH"/boot/grub/core.img) + 511) / 512 ))
	FIRSTPARTITIONSTART=$(sfdisk -d "$DEVMEDIANAME" 2>/dev/null | sed -n 's/.*start= *\([0-9]*\).*/\1/p' | sort -n | head -n1)
	if [ -z "$FIRSTPARTITIONSTART" ] || [ "$FIRSTPARTITIONSTART" -le "$CORESECTORS" ]; then
		echo "Not enough free space before the first partition to install the bootloader."
		echo "The first partition must start at sector $((CORESECTORS + 1)) or later (2048 is recommended)."
		Debug 5
		CleanUp
		exit 5
	fi

	dd if="$DEVMEDIANAME" of="$EXTRACTEDFOLDER"/mbr.bin bs=512 count=1 >/dev/null 2>&1
	FailMessage 1
	dd if="$PARTITIONMOUNTPATH"/boot/grub/boot.img of="$EXTRACTEDFOLDER"/mbr.bin bs=1 count=3 conv=notrunc >/dev/null 2>&1
	FailMessage 1
	dd if="$PARTITIONMOUNTPATH"/boot/grub/boot.img of="$EXTRACTEDFOLDER"/mbr.bin bs=1 skip=90 seek=90 count=350 conv=notrunc >/dev/null 2>&1
	FailMessage 1
	printf '\x90\x90' | dd of="$EXTRACTEDFOLDER"/mbr.bin bs=1 seek=102 conv=notrunc >/dev/null 2>&1
	FailMessage 1

	dd if="$PARTITIONMOUNTPATH"/boot/grub/core.img of="$DEVMEDIANAME" bs=512 seek=1 conv=notrunc,fsync >/dev/null 2>&1
	FailMessage 1
	dd if="$EXTRACTEDFOLDER"/mbr.bin of="$DEVMEDIANAME" bs=440 count=1 conv=notrunc,fsync >/dev/null 2>&1
	FailMessage 1

	# make partition active
	sfdisk -A "$DEVMEDIANAME" "$PARTITIONNUMBER" >/dev/null 2>&1
	FailMessage 2
fi

# find porteux mount path
if [ -f "$PARTITIONMOUNTPATH"/porteux/porteux.cfg ]; then
	PORTEUXMOUNTPATH="$PARTITIONMOUNTPATH"
	PORTEUXUUID=$(blkid -o value -s UUID $DEVPARTITIONPATH)
else
	UUIDSDEVMEDIA=$(lsblk -no UUID "$DEVMEDIANAME")
	for i in $UUIDSDEVMEDIA; do
		currentMountPath=$(findmnt -fno TARGET -S UUID="$i")
		if [ -f "$currentMountPath"/porteux/porteux.cfg ]; then
			PORTEUXMOUNTPATH="$currentMountPath"
			PORTEUXUUID="$i"
			break
		fi
	done
fi

if [ -d "$PORTEUXMOUNTPATH" ]; then
	echo "Updating initrd with Porteux partition unique ID..."
	mkdir "$EXTRACTEDFOLDER"/initrd >/dev/null 2>&1
	cd "$EXTRACTEDFOLDER"/initrd
	FailMessage 4
	zstd -dc "$PARTITIONMOUNTPATH"/boot/syslinux/initrd.zst | cpio -i --quiet >/dev/null 2>&1
	[ -e linuxrc ]
	FailMessage 4
	echo "$PORTEUXUUID" > uuid
	find . | cpio -H newc -o --quiet 2>/dev/null | zstd -19 --check > "$EXTRACTEDFOLDER"/initrd.zst.new
	[ -s "$EXTRACTEDFOLDER"/initrd.zst.new ] && zstd -t "$EXTRACTEDFOLDER"/initrd.zst.new >/dev/null 2>&1
	FailMessage 4
	cp -f "$EXTRACTEDFOLDER"/initrd.zst.new "$PARTITIONMOUNTPATH"/boot/syslinux/initrd.zst.new
	FailMessage 4
	sync
	mv -f "$PARTITIONMOUNTPATH"/boot/syslinux/initrd.zst.new "$PARTITIONMOUNTPATH"/boot/syslinux/initrd.zst
	FailMessage 4
	sync

	echo "Setting permissions..."
	chmod 755 "$PORTEUXMOUNTPATH"/boot >/dev/null 2>&1
	chmod 755 "$PORTEUXMOUNTPATH"/porteux >/dev/null 2>&1
	chmod 755 "$PORTEUXMOUNTPATH"/porteux/* >/dev/null 2>&1
fi

CleanUp
clear

echo "Installation finished successfully"
echo

if [ ! "$PORTEUXMOUNTPATH" ]; then
	echo "However, the installer couldn't find /porteux/porteux.cfg. Make sure"
	echo "this storage media has a partition containing /porteux folder"
	echo "with the required files and that this folder has 'guest' ownership." 
fi

echo
echo "You may reboot your system now and start using PorteuX."
echo "Don't forget to set your BIOS to boot from this storage media."
