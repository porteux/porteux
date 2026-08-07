#!/bin/bash

is_root() {
	[ "$(id -u)" -eq 0 ]
}

if ! is_root; then
	echo "Please enter root's password below:"
	su -c "$(printf '%q ' "$(realpath "$0")" "$@")"
	exit $?
fi

CURRENT_PACKAGE=etcher
FRIENDLY_NAME=Etcher
CATEGORY=Utility
versions=$(curl -s https://github.com/balena-io/${CURRENT_PACKAGE}/tags/ | grep "/balena-io/${CURRENT_PACKAGE}/releases/tag/" | grep -oP "(?<=/balena-io/${CURRENT_PACKAGE}/releases/tag/)[^\"]+" | uniq | grep -v "alpha" | grep -v "beta" | grep -v "rc[0-9]")
url="https://github.com/balena-io/etcher/releases/download/"
for version in $versions; do
	if wget --spider -q "$url/${version}/balenaEtcher-${version//[vV]}-x64.AppImage"; then
		VERSION="${version//[vV]}"
		break
	fi
done

[ "$VERSION" ] || { echo "Error: could not determine the latest version." >&2; exit 1; }

APPLICATION_URL="$url/${version}/balenaEtcher-${VERSION}-x64.AppImage"
ACTIVATE_MODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

RESULT=$(/opt/porteux-scripts/porteux-app-store/appimage-builder.sh "$CURRENT_PACKAGE" "$FRIENDLY_NAME" "$CATEGORY" "$APPLICATION_URL" "$VERSION" "$ACTIVATE_MODULE")

echo "$RESULT"
