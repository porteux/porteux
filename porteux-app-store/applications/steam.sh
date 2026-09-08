#!/bin/bash

is_root() {
	[ "$(id -u)" -eq 0 ]
}

if ! is_root; then
	echo "Please enter root's password below:"
	su -c "$(printf '%q ' "$(realpath "$0")" "$@")"
	exit $?
fi

CURRENT_PACKAGE=steam
APPLICATION_URL=https://repo.steampowered.com/steam/archive/precise/steam_latest.deb
ARCH=i586
OUTPUT_DIR="$PORTDIR/modules/"
BUILD_DIR=$(mktemp -d "/tmp/$CURRENT_PACKAGE-builder.XXXXXX") || exit 1
trap 'rm -fr "${BUILD_DIR:?}"' EXIT
MODULE_DIR="$BUILD_DIR/$CURRENT_PACKAGE-module"
INSTALL_DIR="$1"

# Parameter validation
if [ -z "$INSTALL_DIR" ]; then
	echo "Usage: $0 [installation_directory] [optional: --activate-module]"
	echo "Installation directory is required."
	exit 1
fi

CURRENT_USER=$(loginctl user-status | head -n 1 | cut -d" " -f1)
[ ! "$CURRENT_USER" ] && CURRENT_USER=guest
CURRENT_GROUP=$(id -gn "$CURRENT_USER")
ACTIVATE_MODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")
[[ $INSTALL_DIR = --* ]] && echo "Installation path can't be empty." && exit 1

case "$INSTALL_DIR" in
	/|/bin|/boot|/dev|/etc|/home|/lib|/lib64|/mnt|/opt|/proc|/root|/run|/sbin|/srv|/sys|/tmp|/usr|/var)
		echo "Refusing to install Steam into $INSTALL_DIR. Choose a dedicated folder." >&2
		exit 1
		;;
esac

if [ -d "$INSTALL_DIR" ] && [ -n "$(ls -A "$INSTALL_DIR" 2>/dev/null)" ] && [ ! -e "$INSTALL_DIR/steam.sh" ] && [ ! -d "$INSTALL_DIR/ubuntu12_32" ]; then
	echo "Directory $INSTALL_DIR is not empty. Choose an empty folder or an existing Steam installation." >&2
	exit 1
fi

mkdir -p "$INSTALL_DIR" 2>/dev/null
{ [ -d "$INSTALL_DIR" ] && [ -w "$INSTALL_DIR" ]; } || { echo "Directory $INSTALL_DIR is not a writable directory." >&2; exit 1; }
cd "$BUILD_DIR" || exit 1

wget -T 5 "$APPLICATION_URL" -P "$BUILD_DIR" || exit 1
DOWNLOADED_DEB=$(find "$BUILD_DIR" -maxdepth 1 -type f -name "*.deb" | head -1)
[ "$DOWNLOADED_DEB" ] || { echo "Error: nothing was downloaded." >&2; exit 1; }
ar p "$DOWNLOADED_DEB" data.tar.xz | tar xJv || exit 1
tar -xvf "$BUILD_DIR/usr/lib/steam/bootstraplinux_ubuntu12_32.tar.xz" -C "$INSTALL_DIR" || exit 1

# the process below is not required but it will speedup the first steam run significantly
mkdir -p "$INSTALL_DIR/ubuntu12_32/steam-runtime/pinned_libs_32"
touch "$INSTALL_DIR/ubuntu12_32/steam-runtime/pinned_libs_32/done"
mkdir -p "$INSTALL_DIR/ubuntu12_32/steam-runtime/pinned_libs_64"
touch "$INSTALL_DIR/ubuntu12_32/steam-runtime/pinned_libs_64/done"

chown -R "$CURRENT_USER":"$CURRENT_GROUP" "$INSTALL_DIR"

# handle xzm module
FULL_VERSION=$(cat "$INSTALL_DIR/ubuntu12_32/steam-runtime/version.txt")
VERSION=${FULL_VERSION#*_}
[ "$VERSION" ] || { echo "Error: could not determine the latest version." >&2; exit 1; }

mkdir -p "$MODULE_DIR/usr/share/applications"
cp "$BUILD_DIR/usr/share/applications/steam.desktop" "$MODULE_DIR/usr/share/applications"
ESCAPED_INSTALL_DIR=$(printf '%s' "$INSTALL_DIR" | sed 's/[|&\\]/\\&/g')
sed -i "s|Exec=/usr/bin/steam.*|Exec=$ESCAPED_INSTALL_DIR/steam.sh %U|g" "$MODULE_DIR/usr/share/applications/steam.desktop"
mkdir -p "$MODULE_DIR/usr/share/pixmaps"
cp "$BUILD_DIR"/usr/share/pixmaps/* "$MODULE_DIR/usr/share/pixmaps"

MODULE_FILE_NAME="$CURRENT_PACKAGE-$VERSION-$ARCH.xzm"

/opt/porteux-scripts/porteux-app-store/module-builder.sh "$MODULE_DIR" "$OUTPUT_DIR/$MODULE_FILE_NAME" "$ACTIVATE_MODULE" || exit 1
