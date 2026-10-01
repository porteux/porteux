#!/bin/bash
# Script to create bootable ISO in Linux

ISONAME=$(readlink -f "$1")

cd "$(dirname "$(realpath "$0")")" || exit 1

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
	main_folder=$(readlink -f $PWD/..)
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

echo "Fixing permissions..."
chmod 755 -R ../* || exit 1

if id guest > /dev/null 2>&1; then
	chown -R guest:users ../ || exit 1
fi

echo "Generating '$ISONAME'..."
rm -f "$ISONAME"
mkisofs -o "$ISONAME" -v -l -J -joliet-long -R -D -A "$CDLABEL" \
-V "$CDLABEL" -no-emul-boot -boot-info-table -boot-load-size 4 \
-b boot/syslinux/isolinux.bin -c boot/syslinux/isolinux.boot ../. > /dev/null 2>&1 || { echo "Error creating ISO."; rm -f "$ISONAME"; exit 1; }

if [ ! -e "$ISONAME" ]; then
	echo "Error creating ISO."
	exit 1
fi

echo "Writing boot partition..."
if ../boot/syslinux/isohybrid --partok "$ISONAME"; then
	echo "Finished successfully."
else
	echo "Error writing boot partition. '$ISONAME' has been created and it might work in some cases."
fi
