#!/bin/bash

is_root() {
	[ "$(id -u)" -eq 0 ]
}

if ! is_root; then
	echo "Please enter root's password below:"
	su -c "$(printf '%q ' "$(realpath "$0")" "$@")"
	exit 0
fi

CURRENT_PACKAGE=lunacy
CATEGORY=Graphics
APPLICATION_URL="https://lcdn.icons8.com/setup/Lunacy.deb"
ACTIVATE_MODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

ARCH=$(uname -m)
OUTPUT_DIR="$PORTDIR/modules"
BUILD_DIR="/tmp/$CURRENT_PACKAGE-builder"
TMP_MODULE_FILE_NAME="$CURRENT_PACKAGE.xzm"
INPUT_FILE="$BUILD_DIR/Lunacy.deb"

rm -fr "$BUILD_DIR"
mkdir "$BUILD_DIR" && cd "$BUILD_DIR" || exit 1

wget -T 15 "$APPLICATION_URL" -P "$BUILD_DIR" || exit 1

deb2xzm "$INPUT_FILE" -o="$BUILD_DIR/$TMP_MODULE_FILE_NAME" -q &>/dev/null
VERSION=$(unsquashfs -cat "$BUILD_DIR/$TMP_MODULE_FILE_NAME" "usr/share/applications/*.desktop" | grep Version | cut -d= -f2)
[ "$VERSION" ] || { echo "Error: could not determine the latest version." >&2; exit 1; }
MODULE_FILE_NAME="$CURRENT_PACKAGE-$VERSION-${ARCH}_porteux.xzm"

if [ ! -w "$OUTPUT_DIR" ]; then
	mv "$BUILD_DIR/$TMP_MODULE_FILE_NAME" "/tmp/$MODULE_FILE_NAME"
	echo "Destination $OUTPUT_DIR is not writable. New module placed in /tmp and not activated."
elif [ ! -f "$OUTPUT_DIR/$MODULE_FILE_NAME" ]; then
	mv "$BUILD_DIR/$TMP_MODULE_FILE_NAME" "$OUTPUT_DIR/$MODULE_FILE_NAME"
	echo "Module placed in $OUTPUT_DIR"

	if [[ "$@" == *"--activate-module"* ]] && [ ! -d "/mnt/live/memory/images/$MODULE_FILE_NAME" ]; then
		activate "$OUTPUT_DIR/$MODULE_FILE_NAME" -q &>/dev/null
	fi
else
	mv "$BUILD_DIR/$TMP_MODULE_FILE_NAME" "/tmp/$MODULE_FILE_NAME"
	echo "Module $MODULE_FILE_NAME was already in $OUTPUT_DIR. New module placed in /tmp and not activated."
fi

# cleanup
rm -fr "$BUILD_DIR" &>/dev/null