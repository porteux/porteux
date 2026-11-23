#!/bin/bash
# Script to create bootable ISO in Linux

ISONAME=$(readlink -f "$1")

cd "$(dirname "$(realpath "$0")")" || exit 1

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
	main_folder=$(dirname "$PWD")
	echo "Create bootable ISO from files in '$main_folder'."
	echo "usage: $0 <option>"
	echo "By default the ISO is created in /tmp folder."
	echo
	echo "example: $0 /mnt/sda1/porteux.iso"
	exit
fi

CDLABEL="PorteuX"

if [ "$ISONAME" = "" ]; then
	ISONAME=/tmp/${CDLABEL,,}.iso
fi

if ! command -v xorriso > /dev/null 2>&1; then
	echo "xorriso is required to create the ISO."
	exit 1
fi

echo "Fixing permissions..."
chmod 755 -R ../* || exit 1

if id guest > /dev/null 2>&1; then
	chown -R guest:users ../ || exit 1
fi

echo "Generating '$ISONAME'..."
rm -f "$ISONAME"
xorriso -as mkisofs -o "$ISONAME" -l -J -joliet-long -R -D -A "$CDLABEL" -V "$CDLABEL" \
-b boot/grub/eltorito.img -no-emul-boot -boot-load-size 4 -boot-info-table --boot-catalog-hide \
--grub2-boot-info --grub2-mbr ../boot/grub/boot_hybrid.img \
--efi-boot boot/grub/efi.img -efi-boot-part --efi-boot-image \
-hide ../boot/grub/eltorito.img -hide-joliet ../boot/grub/eltorito.img -hide ../boot/grub/efi.img -hide-joliet ../boot/grub/efi.img \
-hide ../boot/grub/boot_hybrid.img -hide-joliet ../boot/grub/boot_hybrid.img \
-hide ../porteux/create-iso.sh -hide-joliet ../porteux/create-iso.sh \
--protective-msdos-label ../. > /dev/null 2>&1 || { echo "Error creating ISO."; rm -f "$ISONAME"; exit 1; }

if [ ! -e "$ISONAME" ]; then
	echo "Error creating ISO."
	exit 1
fi

echo "Finished successfully."
