#!/bin/bash

is_root() {
	[ "$(id -u)" -eq 0 ]
}

if ! is_root; then
	echo "Please enter root's password below:"
	su -c "$(printf '%q ' "$(realpath "$0")" "$@")"
	exit 0
fi

CURRENT_PACKAGE=deno
VERSION=$(curl -s https://github.com/denoland/deno/releases/ | grep -oP "(?<=/denoland/deno/releases/tag/)[^\"]+" | uniq | grep -v "alpha" | grep -v "beta" | grep -v "rc[0-9]" | head -1)
[ "$VERSION" ] || { echo "Error: could not determine the latest version." >&2; exit 1; }
APPLICATION_URL="https://github.com/denoland/deno/releases/download/${VERSION}/deno-x86_64-unknown-linux-gnu.zip"
ARCH=$(uname -m)
OUTPUT_DIR="$PORTDIR/modules/"
BUILD_DIR="/tmp/$CURRENT_PACKAGE-builder"
MODULE_DIR="$BUILD_DIR"
ACTIVATE_MODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

rm -fr "$BUILD_DIR"
mkdir -p "$BUILD_DIR/usr/bin" || exit 1

wget -T 15 "$APPLICATION_URL" -P "$BUILD_DIR/usr/bin" || exit 1
unzip "$BUILD_DIR/usr/bin/"*.zip -d "$BUILD_DIR/usr/bin"
rm -f "$BUILD_DIR/usr/bin/"*.zip
chmod 755 "$BUILD_DIR/usr/bin/"* &>/dev/null || exit 1

MODULE_FILE_NAME="$CURRENT_PACKAGE-${VERSION//[vV]}-${ARCH}_porteux.xzm"

/opt/porteux-scripts/porteux-app-store/module-builder.sh "$MODULE_DIR" "$OUTPUT_DIR/$MODULE_FILE_NAME" "$ACTIVATE_MODULE" || exit 1

# cleanup
rm -fr "$BUILD_DIR" &>/dev/null
