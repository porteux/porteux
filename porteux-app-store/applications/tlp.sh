#!/bin/bash

is_root() {
	[ "$(id -u)" -eq 0 ]
}

if [ ! "$(find /mnt/live/memory/images/ -maxdepth 1 -name "*05-devel*")" ]; then
	echo "The 'devel' module needs to be activated to build and run TLP."
	exit 1
fi

if ! is_root; then
	echo "Please enter root's password below:"
	su -c "$(printf '%q ' "$(realpath "$0")" "$@")"
	exit $?
fi

CURRENT_PACKAGE=TLP
ARCH="noarch"
ACTIVATE_MODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")
FULL_VERSION=$(curl -s https://api.github.com/repos/linrunner/${CURRENT_PACKAGE}/releases/latest | grep "\"tag_name\":" | cut -d \" -f 4 | head -n 1)
VERSION="${FULL_VERSION//[vV]}"
[ "$VERSION" ] || { echo "Error: could not determine the latest version." >&2; exit 1; }
APPLICATION_URL="https://github.com/linrunner/${CURRENT_PACKAGE}/archive/refs/tags/${VERSION}.tar.gz"
OUTPUT_DIR="$PORTDIR/modules/"
BUILD_DIR="/tmp/$CURRENT_PACKAGE-builder"
MODULE_DIR="$BUILD_DIR/$CURRENT_PACKAGE-$VERSION-1.$ARCH"

striptease() {
	rm -fr "$MODULE_DIR/usr/lib/systemd"
	rm -fr "$MODULE_DIR/usr/share/bash-completion"
	rm -fr "$MODULE_DIR/usr/share/fish"
	rm -fr "$MODULE_DIR/usr/share/metainfo"
	rm -fr "$MODULE_DIR/usr/share/zsh"
}

rm -fr "$BUILD_DIR"
mkdir "$BUILD_DIR" && cd "$BUILD_DIR" || exit 1

wget -T 15 --content-disposition "$APPLICATION_URL" -P "$BUILD_DIR" || exit 1
tar xvf "$CURRENT_PACKAGE-$VERSION.tar.gz" || exit 1
cd "$CURRENT_PACKAGE-$VERSION" || exit 1
make install DESTDIR="$MODULE_DIR" || exit 1

striptease

/opt/porteux-scripts/porteux-app-store/module-builder.sh "$MODULE_DIR" "$OUTPUT_DIR/tlp-$VERSION-${ARCH}_porteux.xzm" "$ACTIVATE_MODULE" || exit 1

# cleanup
rm -fr "$BUILD_DIR" &>/dev/null
