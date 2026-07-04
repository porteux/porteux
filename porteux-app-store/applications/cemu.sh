#!/bin/bash

is_root() {
	[ "$(id -u)" -eq 0 ]
}

if ! is_root; then
	echo "Please enter root's password below:"
	su -c "$(printf '%q ' "$(realpath "$0")" "$@")"
	exit 0
fi

CURRENT_PACKAGE=cemu
FRIENDLY_NAME="Cemu (Wii U)"
CATEGORY=Game
APPLICATION_URL=$(curl -s https://api.github.com/repos/cemu-project/Cemu/releases | grep "AppImage" | grep "download_url" | head -1 | cut -d \" -f 4)
FULL_VERSION=$(curl -s https://api.github.com/repos/cemu-project/Cemu/tags | grep "\"name\":" | cut -d \" -f 4 | sort -Vr | head -n 1)
VERSION="${FULL_VERSION//[vV]}"
[ "$VERSION" ] || { echo "Error: could not determine the latest version." >&2; exit 1; }
ACTIVATE_MODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

RESULT=$(/opt/porteux-scripts/porteux-app-store/appimage-builder.sh "$CURRENT_PACKAGE" "$FRIENDLY_NAME" "$CATEGORY" "$APPLICATION_URL" "$VERSION" "$ACTIVATE_MODULE")

echo "$RESULT"
