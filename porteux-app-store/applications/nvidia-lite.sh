#!/bin/bash

is_root() {
	[ "$(id -u)" -eq 0 ]
}

if ! is_root; then
	echo "Please enter root's password below:"
	su -c "$(printf '%q ' "$(realpath "$0")" "$@")"
	exit $?
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
ACTIVATE_MODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")
BUILD_DIR=$(mktemp -d "/tmp/$CURRENT_PACKAGE-builder.XXXXXX") || exit 1
trap 'rm -fr "${BUILD_DIR:?}"' EXIT


wget -T 15 "$APPLICATION_URL" -P "$BUILD_DIR" || exit 1
MODULE_PATH_IN_ZIP=$(unzip -Z1 "$BUILD_DIR/$ZIP_FILE_NAME" | grep -m1 '\.xzm$')
[ "$MODULE_PATH_IN_ZIP" ] || { echo "Error: no module found inside $ZIP_FILE_NAME." >&2; exit 1; }
MODULE_FILE_NAME="${MODULE_PATH_IN_ZIP##*/}"
unzip "$BUILD_DIR/$ZIP_FILE_NAME" -d "$BUILD_DIR" &>/dev/null || exit 1

MODULE_DIR="${MODULE_FILE_NAME%.xzm}"
xzm2dir -q "$BUILD_DIR/$MODULE_PATH_IN_ZIP" -o="$BUILD_DIR/$MODULE_DIR" || exit 1
rm "$BUILD_DIR/$MODULE_PATH_IN_ZIP"
EXTRACTED_MODULE_PATH="$BUILD_DIR/$MODULE_DIR"
if [ ! -d "$EXTRACTED_MODULE_PATH" ]; then
	MODULE_DIR=$(basename "$(echo "$BUILD_DIR"/08-nvidia-*)")
	EXTRACTED_MODULE_PATH="$BUILD_DIR/$MODULE_DIR"
fi

find "$EXTRACTED_MODULE_PATH" \( -type f -name "libnvidia-compiler*" -o -name "libcudadebugger*" -o -name "*nvoptix*" -o -name "libnvidia-gtk2*" \) -delete

MODULE_FILE_NAME="${MODULE_FILE_NAME/nvidia/nvidia-lite}"

/opt/porteux-scripts/porteux-app-store/module-builder.sh "$BUILD_DIR/$MODULE_DIR" "$OUTPUT_DIR/$MODULE_FILE_NAME" "$ACTIVATE_MODULE" || exit 1
