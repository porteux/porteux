#!/bin/bash

is_root() {
	[ "$(id -u)" -eq 0 ]
}

if ! is_root; then
	echo "Please enter root's password below:"
	su -c "$(printf '%q ' "$(realpath "$0")" "$@")"
	exit 0
fi

CURRENT_PACKAGE=nvidia-driver
PORTEUX_FULL_VERSION=$(cat /etc/porteux-version)
PORTEUX_VERSION=${PORTEUX_FULL_VERSION#*-}
PORTEUX_VERSION=${PORTEUX_VERSION%%-*}
SLACKWARE_FULL_VERSION=$(cat /etc/slackware-version)
SLACKWARE_VERSION=${SLACKWARE_FULL_VERSION//* }

if [[ $SLACKWARE_VERSION == *"+" ]]; then
	PORTEUX_BUILD=current
else
	PORTEUX_BUILD=stable
fi

ZIP_FILE_NAME="$CURRENT_PACKAGE-$PORTEUX_BUILD.zip"
APPLICATION_URL="https://github.com/porteux/porteux/releases/download/$PORTEUX_VERSION/$ZIP_FILE_NAME"
OUTPUT_DIR="$PORTDIR/modules/"
BUILD_DIR="/tmp/$CURRENT_PACKAGE-builder"

rm -fr "$BUILD_DIR" &>/dev/null
mkdir "$BUILD_DIR" &>/dev/null

wget -T 15 "$APPLICATION_URL" -P "$BUILD_DIR" || exit 1
MODULE_FILE_NAME=$(unzip -Z1 "$BUILD_DIR/$ZIP_FILE_NAME" | rev | cut -d "/" -f 1 | rev) || exit 1
unzip "$BUILD_DIR/$ZIP_FILE_NAME" -d "$BUILD_DIR" &>/dev/null

if [ ! -w "$OUTPUT_DIR" ]; then
	mv "$BUILD_DIR/$MODULE_FILE_NAME" /tmp &>/dev/null
	echo "Destination $OUTPUT_DIR is not writable. New module placed in /tmp and not activated."
elif [ ! -f "$OUTPUT_DIR/$MODULE_FILE_NAME" ]; then
	mv "$BUILD_DIR/$MODULE_FILE_NAME" "$OUTPUT_DIR" &>/dev/null
	echo "Module placed in $OUTPUT_DIR"
	if [[ "$@" == *"--activate-module"* ]] && [ ! -d "/mnt/live/memory/images/$MODULE_FILE_NAME" ]; then
		activate "$OUTPUT_DIR/$MODULE_FILE_NAME" -q &>/dev/null
	fi
else
	mv "$BUILD_DIR/$MODULE_FILE_NAME" /tmp &>/dev/null
	echo "Module $MODULE_FILE_NAME was already in $OUTPUT_DIR. New module placed in /tmp and not activated."
fi

# cleanup
rm -fr "$BUILD_DIR" &>/dev/null
