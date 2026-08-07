#!/bin/bash

is_root() {
	[ "$(id -u)" -eq 0 ]
}

if ! is_root; then
	echo "Please enter root's password below:"
	su -c "$(printf '%q ' "$(realpath "$0")" "$@")"
	exit $?
fi

CURRENT_PACKAGE=onlyoffice
FRIENDLY_NAME="OnlyOffice - Desktop Editors"
CATEGORY=Office
FULL_VERSION=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/ONLYOFFICE/appimage-desktopeditors/releases/latest | rev | cut -d / -f 1 | rev)
VERSION="${FULL_VERSION//[vV]}"
[[ "$VERSION" == *[0-9]* ]] || { echo "Error: could not determine the latest version." >&2; exit 1; }
APPLICATION_URL="https://github.com/ONLYOFFICE/appimage-desktopeditors/releases/latest/download/DesktopEditors-x86_64.AppImage"
ACTIVATE_MODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

RESULT=$(/opt/porteux-scripts/porteux-app-store/appimage-builder.sh "$CURRENT_PACKAGE" "$FRIENDLY_NAME" "$CATEGORY" "$APPLICATION_URL" "$VERSION" "$ACTIVATE_MODULE")

echo "$RESULT"
