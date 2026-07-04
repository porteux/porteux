#!/bin/bash

is_root() {
	[ "$(id -u)" -eq 0 ]
}

if ! is_root; then
	echo "Please enter root's password below:"
	su -c "$(printf '%q ' "$(realpath "$0")" "$@")"
	exit 0
fi

CURRENT_PACKAGE=wine
ARCH=$(uname -m)
OUTPUT_DIR="$PORTDIR/optional/"
BUILD_DIR="/tmp/$CURRENT_PACKAGE-builder"
MODULE_DIR="$BUILD_DIR/$CURRENT_PACKAGE-module"
REPOSITORY="https://sourceforge.net/projects/wine/files/Slackware%20Packages"
ACTIVATE_MODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

VERSION=$(curl -s "$REPOSITORY/" | grep "<tr title=" | grep -oP 'title="\K[^"]+(?=")' | grep -v "rc" | grep -v "name" | sort -Vr | head -n 1)
[ "$VERSION" ] || { echo "Error: could not determine the latest version." >&2; exit 1; }

CURRENT_TXZ="wine-$VERSION-x86_64-1sg.txz"
CURRENT_TXZ_PATH="$BUILD_DIR/$CURRENT_TXZ"

rm -fr "$BUILD_DIR"
mkdir "$BUILD_DIR"
mkdir "$MODULE_DIR"

wget -T 15 -P "$BUILD_DIR" "$REPOSITORY/$VERSION/x86_64/$CURRENT_TXZ" || exit 1

# strip
txz2dir "$CURRENT_TXZ_PATH" -o="$MODULE_DIR" -q || exit 1
rm -fr "$MODULE_DIR/usr/doc"
rm -fr "$MODULE_DIR/usr/include"
rm -fr "$MODULE_DIR/usr/man"
find "$MODULE_DIR" -name '*.a' -delete
find "$MODULE_DIR" | xargs file | grep -E "\.exe|\.dll" | cut -f 1 -d : | xargs strip -S --strip-unneeded --remove-section=.note.gnu.gold-version --remove-section=.comment --remove-section=.note --remove-section=.note.gnu.build-id --remove-section=.note.ABI-tag &>/dev/null

MODULE_FILE_NAME="$CURRENT_PACKAGE-$VERSION-${ARCH}_porteux.xzm"

/opt/porteux-scripts/porteux-app-store/module-builder.sh "$MODULE_DIR" "$OUTPUT_DIR/$MODULE_FILE_NAME" "$ACTIVATE_MODULE" || exit 1

# cleanup
rm -fr "$BUILD_DIR" &>/dev/null
