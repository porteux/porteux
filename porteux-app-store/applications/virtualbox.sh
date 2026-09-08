#!/bin/bash

is_root() {
	[ "$(id -u)" -eq 0 ]
}

if ! is_root; then
	echo "Please enter root's password below:"
	su -c "$(printf '%q ' "$(realpath "$0")" "$@")"
	exit $?
fi

if [ ! "$(find /mnt/live/memory/images/ -maxdepth 1 -name "*05-devel*")" ] || [ ! "$(find /mnt/live/memory/images/ -maxdepth 1 -name "*06-crippled?sources*")" ]; then
	echo "Both 'devel' and 'crippled-sources' modules need to be activated."
	exit 1
fi

CURRENT_PACKAGE=virtualbox
ARCH=$(uname -m)
OUTPUT_DIR="$PORTDIR/optional"
BUILD_DIR=$(mktemp -d "/tmp/$CURRENT_PACKAGE-builder.XXXXXX") || exit 1
trap 'rm -fr "${BUILD_DIR:?}"' EXIT
MODULE_DIR="$BUILD_DIR/$CURRENT_PACKAGE-module"
ACTIVATE_MODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

CURRENT_USER=$(loginctl user-status | head -n 1 | cut -d" " -f1)
[ ! "$CURRENT_USER" ] && CURRENT_USER=guest
CURRENT_GROUP=$(id -gn "$CURRENT_USER")
USER_HOME_FOLDER=$(getent passwd "$CURRENT_USER" | cut -d: -f6)
[ ! -e "$USER_HOME_FOLDER" ] && USER_HOME_FOLDER=home/guest

mkdir "$MODULE_DIR" || exit 1

if [[ ! "$1" || "$1" == "--activate-module" ]]; then
	# download the latest version
	REPOSITORY="https://download.virtualbox.org/virtualbox"
	wget -T 15 -P "$BUILD_DIR" "$REPOSITORY/LATEST.TXT" || exit 1
	CURRENT_VERSION=$(cat "$BUILD_DIR/LATEST.TXT")
	[ "$CURRENT_VERSION" ] || { echo "Error: could not determine the latest version." >&2; exit 1; }
	LATEST_FILE=$(curl -sf "$REPOSITORY/$CURRENT_VERSION/" | grep -oE '"[^"]+_amd64\.run"' | tr -d '"' | sort -V | tail -n1)
	[ "$LATEST_FILE" ] || { echo "Error: could not find the installer for version $CURRENT_VERSION." >&2; exit 1; }
	wget -T 15 -P "$BUILD_DIR" "$REPOSITORY/$CURRENT_VERSION/$LATEST_FILE" || exit 1
	INSTALLER_PATH="$BUILD_DIR/$LATEST_FILE"

	# the installer runs as root, so make sure it is the file Oracle published
	wget -T 15 -P "$BUILD_DIR" "$REPOSITORY/$CURRENT_VERSION/SHA256SUMS" || exit 1
	EXPECTED_CHECKSUM=$(grep " \*\?$LATEST_FILE\$" "$BUILD_DIR/SHA256SUMS" | cut -d' ' -f1)
	ACTUAL_CHECKSUM=$(sha256sum "$INSTALLER_PATH" | cut -d' ' -f1)
	[ "$EXPECTED_CHECKSUM" = "$ACTUAL_CHECKSUM" ] || { echo "Error: checksum mismatch for $LATEST_FILE." >&2; exit 1; }
else
	# use file provided by the user
	INSTALLER_PATH="$1"
	CURRENT_VERSION=$(basename "$INSTALLER_PATH" | cut -d'-' -f2)
fi

[ "$CURRENT_VERSION" ] || { echo "Error: could not determine the latest version." >&2; exit 1; }

# install
if grep -q "clang" /proc/version; then
	export LLVM=1
fi
sh "$INSTALLER_PATH" --nox11 || exit 1

# set configuration
mkdir -p "$MODULE_DIR/etc/rc.d/init.d" "$MODULE_DIR/etc/rc.d/rc4.d"
cat > "$MODULE_DIR/etc/rc.d/init.d/rc.virtualbox" << EOF
#!/bin/sh
# VirtualBox Linux kernel modules init script
/sbin/depmod -a
/sbin/modprobe vboxdrv
/sbin/modprobe vboxnetadp
/sbin/modprobe vboxnetflt
EOF
chmod +x "$MODULE_DIR/etc/rc.d/init.d/rc.virtualbox"
ln -sf /etc/rc.d/init.d/rc.virtualbox "$MODULE_DIR/etc/rc.d/rc4.d/S99virtualbox"
find /etc /lib /usr /sbin | grep -E "vbox|virtualbox|VBox|VirtualBox" | xargs -i cp -r --parents {} "$MODULE_DIR/"
cp -r --parents /sbin/{vbox*,rcvbox*} "$MODULE_DIR/"
cp -r --parents /opt/VirtualBox "$MODULE_DIR/"
for a in $(seq 0 6); do
	cp -r --parents /etc/rc.d/rc${a}.d/{K[0-9][0-9]vbox*,S[0-9][0-9]vbox*} "$MODULE_DIR/" &>/dev/null
done
mkdir -p "$MODULE_DIR/${USER_HOME_FOLDER}/.config/VirtualBox/"
cat > "$MODULE_DIR/${USER_HOME_FOLDER}/.config/VirtualBox/VirtualBox.xml" << EOF
<?xml version="1.0"?>
<VirtualBox xmlns="http://www.virtualbox.org/" version="1.12-linux">
 <Global>
	<ExtraData>
	 <ExtraDataItem name="GUI/UpdateDate" value="never"/>
	</ExtraData>
 </Global>
</VirtualBox>
EOF
chown -R "$CURRENT_USER":"$CURRENT_GROUP" "$MODULE_DIR/${USER_HOME_FOLDER}"

# strip
rm -fr "$MODULE_DIR/opt/VirtualBox/additions"
rm -fr "$MODULE_DIR/opt/VirtualBox/src"
rm -fr "$MODULE_DIR/usr/include"
rm -fr "$MODULE_DIR/usr/src"
find "$MODULE_DIR/opt/VirtualBox/nls" -mindepth 1 -maxdepth 1 -type f ! \( -name "qt_en.qm" -o -name "VirtualBox_en.qm" \) -delete

# remove virtualbox from the machine
/opt/VirtualBox/uninstall.sh &>/dev/null

# build the xzm module
find "$MODULE_DIR" -type d -exec chmod 755 {} +
chown root:root "$MODULE_DIR/opt/VirtualBox/VirtualBox"
chmod -s "$MODULE_DIR/opt/VirtualBox/VirtualBox"
chmod +s "$MODULE_DIR/opt/VirtualBox/VirtualBoxVM"
KERNEL_VERSION=$(uname -r | awk -F- '{print$1}')
MODULE_FILE_NAME="$CURRENT_PACKAGE-$CURRENT_VERSION-k.$KERNEL_VERSION-${ARCH}_porteux.xzm"

/opt/porteux-scripts/porteux-app-store/module-builder.sh "$MODULE_DIR" "$OUTPUT_DIR/$MODULE_FILE_NAME" "$ACTIVATE_MODULE" || exit 1
