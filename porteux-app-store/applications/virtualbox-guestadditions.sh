#!/bin/bash

is_root() {
	[ "$(id -u)" -eq 0 ]
}

if ! is_root; then
	echo "Please enter root's password below:"
	su -c "$(printf '%q ' "$(realpath "$0")" "$@")"
	exit 0
fi

if [ ! "$(find /mnt/live/memory/images/ -maxdepth 1 -name "*05-devel*")" ] || [ ! "$(find /mnt/live/memory/images/ -maxdepth 1 -name "*06-crippled?sources*")" ]; then
	echo "Both 'devel' and 'crippled-sources' modules need to be activated."
	exit 1
fi

CURRENT_PACKAGE=virtualbox-guestadditions
ARCH=$(uname -m)
OUTPUT_DIR="$PORTDIR/optional"
BUILD_DIR="/tmp/$CURRENT_PACKAGE-builder"
MODULE_DIR="$BUILD_DIR/$CURRENT_PACKAGE-module"
MOUNT_DIR="/mnt/$CURRENT_PACKAGE"
ACTIVATE_MODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

rm -fr "$BUILD_DIR"
rm -fr "$MOUNT_DIR"
mkdir "$BUILD_DIR"
mkdir "$MOUNT_DIR"
mkdir "$MODULE_DIR"

if [[ ! "$1" || "$1" == "--activate-module" ]]; then
	# download the latest version
	REPOSITORY="http://download.virtualbox.org/virtualbox"
	wget -T 15 -P "$BUILD_DIR" "$REPOSITORY/LATEST.TXT"
	CURRENT_VERSION=$(cat "$BUILD_DIR/LATEST.TXT")
	LATEST_FILE="VBoxGuestAdditions_${CURRENT_VERSION}.iso"
	wget -T 15 -P "$BUILD_DIR" "$REPOSITORY/$CURRENT_VERSION/$LATEST_FILE"
	INSTALLER_PATH="$BUILD_DIR/$LATEST_FILE"
else
	# use file provided by the user
	INSTALLER_PATH="$1"
	CURRENT_VERSION=$(find "$INSTALLER_PATH" -name "*.[0-9]*" | sort -V | tail -n 1)
fi

[ "$CURRENT_VERSION" ] || { echo "Error: could not determine the latest version." >&2; exit 1; }

# mount and install
mount "$INSTALLER_PATH" "$MOUNT_DIR"
if grep -q "clang" /proc/version; then
	export LLVM=1
fi
sh "$MOUNT_DIR/VBoxLinuxAdditions.run" --nox11

# set configuration
cp -r --parents /etc/rc.d/{rc.vboxadd,rc.vboxadd-service,rc.vboxadd-x11} "$MODULE_DIR/" &>/dev/null
cp -r --parents /etc/rc.d/init.d/{vboxdrv,vboxballoonctrl-service,vboxautostart-service,vboxweb-service} "$MODULE_DIR/" &>/dev/null
for a in $(seq 0 6); do
	cp -r --parents /etc/rc.d/rc${a}.d/{K[0-9][0-9]vbox*,S[0-9][0-9]vbox*} "$MODULE_DIR/" &>/dev/null
done
cp -r --parents /etc/vbox/vbox.cfg "$MODULE_DIR/" &>/dev/null
cp -r --parents /etc/vbox/filelist "$MODULE_DIR/" &>/dev/null
cp -r --parents /etc/udev/rules.d/60-vbox* "$MODULE_DIR/" &>/dev/null
cp -r --parents /etc/xdg/autostart/vboxclient.desktop "$MODULE_DIR/" &>/dev/null
cp -r --parents "/lib/modules/$(uname -r)/misc/"/{vboxguest.ko,vboxsf.ko,vboxvideo.ko,vboxpci.ko,vboxnetadp.ko,vboxnetflt.ko,vboxdrv.ko} "$MODULE_DIR/" &>/dev/null
cp -r --parents /opt/VBoxGuestAdditions-* "$MODULE_DIR/" &>/dev/null
cp -r --parents /sbin/mount.vboxsf "$MODULE_DIR/" &>/dev/null
cp -r --parents /usr/bin/{VBoxClient,VBoxClient-all,VBoxControl} "$MODULE_DIR/" &>/dev/null
cp -r --parents /usr/sbin/VBoxService "$MODULE_DIR/" &>/dev/null
cp -r --parents /var/lib/VBoxGuestAdditions "$MODULE_DIR/" &>/dev/null

# strip
rm -fr "$MODULE_DIR/opt/VBoxGuestAdditions-${CURRENT_VERSION}/src"
rm -fr "$MODULE_DIR/opt/VBoxGuestAdditions-${CURRENT_VERSION}/LICENSE"

# build the xzm module
KERNEL_VERSION=$(uname -r | awk -F- '{print$1}')
MODULE_FILE_NAME="$CURRENT_PACKAGE-$CURRENT_VERSION-k.$KERNEL_VERSION-${ARCH}_porteux.xzm"

/opt/porteux-scripts/porteux-app-store/module-builder.sh "$MODULE_DIR" "$OUTPUT_DIR/$MODULE_FILE_NAME" "$ACTIVATE_MODULE" || exit 1

# cleanup
umount "$MOUNT_DIR"
rm -fr "$MOUNT_DIR"
rm -fr "$BUILD_DIR" &>/dev/null
