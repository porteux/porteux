#!/bin/bash

MAKESELF_VERSION="2.5.0"

SCRIPT_PATH="$(dirname "$(readlink -f "$0")")"
ISO_BOOT_PATH="$(readlink -f "$SCRIPT_PATH/../../iso/boot")"
BUILD_PATH="$(mktemp -d)"
trap 'rm -rf "$BUILD_PATH"' EXIT

for tool in 7z wget zstd; do
	command -v $tool > /dev/null 2>&1 || { echo "Required tool not found: $tool"; exit 1; }
done

cd "$BUILD_PATH" || exit 1

echo "Creating Linux installer..."
wget -q "https://github.com/megastep/makeself/releases/download/release-${MAKESELF_VERSION}/makeself-${MAKESELF_VERSION}.run" || { echo "Failed to download makeself."; exit 1; }
sh makeself-${MAKESELF_VERSION}.run --noexec --target makeself > /dev/null 2>&1 || { echo "Failed to extract makeself."; exit 1; }
mkdir linux
cp "$SCRIPT_PATH/linux/installer.sh" linux/ || exit 1
chmod 755 linux/installer.sh
makeself/makeself.sh -q --zstd --threads 8 --chown linux porteux-installer-for-linux.run "PorteuX Installer" ./installer.sh \$PWD || { echo "Failed to create Linux installer."; exit 1; }

echo "Creating Windows installer..."
mkdir -p windows/Installer
cp "$SCRIPT_PATH/windows/installer.bat" "$SCRIPT_PATH/windows/installer.ps1" windows/Installer/ || exit 1
(cd windows && 7z a -t7z -m0=LZMA2 -mx=9 ../installer.7z Installer > /dev/null) || { echo "Failed to create Windows archive."; exit 1; }
cat "$SCRIPT_PATH/windows/sfx-module.bin" installer.7z > porteux-installer-for-windows.exe || exit 1

cp porteux-installer-for-linux.run porteux-installer-for-windows.exe "$ISO_BOOT_PATH/" || exit 1
chmod 755 "$ISO_BOOT_PATH"/porteux-installer-for-*

echo "Finished successfully."
