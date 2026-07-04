#!/bin/bash

is_root() {
	[ "$(id -u)" -eq 0 ]
}

if ! is_root; then
	echo "Please enter root's password below:"
	su -c "$(printf '%q ' "$(realpath "$0")" "$@")"
	exit 0
fi

CURRENT_PACKAGE=neovim
VERSION=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/neovim/neovim/releases/latest | rev | cut -d / -f 1 | rev)
[ "$VERSION" ] || { echo "Error: could not determine the latest version." >&2; exit 1; }
APPLICATION_URL="https://github.com/neovim/neovim/releases/download/${VERSION}/nvim-linux-x86_64.tar.gz"
ARCH=$(uname -m)
OUTPUT_DIR="$PORTDIR/modules/"
BUILD_DIR="/tmp/$CURRENT_PACKAGE-builder"
MODULE_DIR="$BUILD_DIR/$CURRENT_PACKAGE-module"
ACTIVATE_MODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

rm -fr "$BUILD_DIR"
mkdir -p "$MODULE_DIR" && cd "$BUILD_DIR" || exit 1

wget -T 15 "$APPLICATION_URL" -O - | tar -xz -C "$MODULE_DIR" || exit 1

mv "$MODULE_DIR/nvim-linux-x86_64" "$MODULE_DIR/usr"

MODULE_FILE_NAME="$CURRENT_PACKAGE-${VERSION//v}-${ARCH}_porteux.xzm"

/opt/porteux-scripts/porteux-app-store/module-builder.sh "$MODULE_DIR" "$OUTPUT_DIR/$MODULE_FILE_NAME" "$ACTIVATE_MODULE" || exit 1

# cleanup
rm -fr "$BUILD_DIR" &>/dev/null
