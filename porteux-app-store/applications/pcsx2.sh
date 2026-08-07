#!/bin/bash

is_root() {
	[ "$(id -u)" -eq 0 ]
}

if ! is_root; then
	echo "Please enter root's password below:"
	su -c "$(printf '%q ' "$(realpath "$0")" "$@")"
	exit $?
fi

CURRENT_PACKAGE=pcsx2
FRIENDLY_NAME="PCSX2 (PS2)"
CATEGORY=Game
APPLICATION_URL=$(curl -s https://api.github.com/repos/PCSX2/pcsx2/releases | grep "AppImage" | grep "download_url" | head -1 | cut -d \" -f 4)
[ "$APPLICATION_URL" ] || { echo "Error: could not determine the latest version." >&2; exit 1; }
FULL_VERSION=$(echo "$APPLICATION_URL" | rev | cut -d / -f 2 | rev)
VERSION="${FULL_VERSION//[vV]}"
[[ "$VERSION" == *[0-9]* ]] || { echo "Error: could not determine the latest version." >&2; exit 1; }
ACTIVATE_MODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

RESULT=$(/opt/porteux-scripts/porteux-app-store/appimage-builder.sh "$CURRENT_PACKAGE" "$FRIENDLY_NAME" "$CATEGORY" "$APPLICATION_URL" "$VERSION" "$ACTIVATE_MODULE") || exit 1

echo "$RESULT"
