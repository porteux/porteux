#!/bin/bash
# Script to create bootable ISO in Linux

if [ "$1" = "--help" -o "$1" = "-h" ]; then
	mainFolder=$(readlink -f $PWD/..)
	echo "Create bootable ISO from files in '$mainFolder'."
	echo "usage: $0 <option>"
	echo "By default the ISO is created in /tmp folder."
	echo
	echo "example: $0 /mnt/sda1/porteux.iso"
	exit
fi

CDLABEL="PorteuX"
ISONAME=$(readlink -f "$1")

if [ "$ISONAME" = "" ]; then
	ISONAME=/tmp/${CDLABEL,,}.iso
fi

echo "Fixing permissions..."
chmod 755 -R ../* || exit 1
echo guest | chown -R guest:users ../ || exit 1

echo "Generating '$ISONAME'..."
mkisofs -o "$ISONAME" -v -l -J -joliet-long -R -D -A "$CDLABEL" \
-V "$CDLABEL" -no-emul-boot -boot-info-table -boot-load-size 4 \
-b boot/syslinux/isolinux.bin -c boot/syslinux/isolinux.boot ../. > /dev/null 2>&1

if [ ! -e "$ISONAME" ]; then
	echo "Error creating ISO."
	exit 1
fi

echo "Writing boot partition..."
../boot/syslinux/isohybrid --partok "$ISONAME"

if [ $? -eq 0 ]; then
	echo "Finished successfully."
else
	echo "Error writing boot partition. '$ISONAME' has been created and it might work in some cases."
fi
