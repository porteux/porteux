#!/bin/bash

is_root() {
	[ "$(id -u)" -eq 0 ]
}

if ! is_root; then
	echo "Please enter root's password below:"
	su -c "$(printf '%q ' "$(realpath "$0")" "$@")"
	exit 0
fi

CURRENT_PACKAGE=codium
FULL_VERSION=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/VSCodium/vscodium/releases/latest | rev | cut -d / -f 1 | rev)
VERSION="${FULL_VERSION//[vV]}"
[ "$VERSION" ] || { echo "Error: could not determine the latest version." >&2; exit 1; }
APPLICATION_URL="https://github.com/VSCodium/vscodium/releases/latest/download/codium_${VERSION}_amd64.deb"
ARCH=$(uname -m)
OUTPUT_DIR="$PORTDIR/modules"
BUILD_DIR="/tmp/$CURRENT_PACKAGE-builder"
MODULE_FILE_NAME="$CURRENT_PACKAGE-$VERSION-${ARCH}_porteux.xzm"
INPUT_FILE="$BUILD_DIR/codium_${VERSION}_amd64.deb"

rm -fr "$BUILD_DIR"
mkdir "$BUILD_DIR" && cd "$BUILD_DIR" || exit 1

wget -T 15 "$APPLICATION_URL" -P "$BUILD_DIR" || exit 1

if [ ! -w "$OUTPUT_DIR" ]; then
	deb2xzm "$INPUT_FILE" -o="/tmp/$MODULE_FILE_NAME" -q &>/dev/null
	echo "Destination $OUTPUT_DIR is not writable. New module placed in /tmp and not activated."
elif [ ! -f "$OUTPUT_DIR/$MODULE_FILE_NAME" ]; then
	deb2xzm "$INPUT_FILE" -o="$OUTPUT_DIR/$MODULE_FILE_NAME" -q &>/dev/null
	echo "Module placed in $OUTPUT_DIR"
	if [[ "$@" == *"--activate-module"* ]] && [ ! -d "/mnt/live/memory/images/$MODULE_FILE_NAME" ]; then
		activate "$OUTPUT_DIR/$MODULE_FILE_NAME" -q &>/dev/null
	fi
else
	deb2xzm "$INPUT_FILE" -o="/tmp/$MODULE_FILE_NAME" -q &>/dev/null
	echo "Module $MODULE_FILE_NAME was already in $OUTPUT_DIR. New module placed in /tmp and not activated."
fi

# cleanup
rm -fr "$BUILD_DIR" &>/dev/null
