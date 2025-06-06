#!/bin/bash

CURRENTPACKAGE=etcher
FRIENDLYNAME=Etcher
CATEGORY=Utility
versions=$(curl -s https://github.com/balena-io/${CURRENTPACKAGE}/tags/ | grep "/balena-io/${CURRENTPACKAGE}/releases/tag/" | grep -oP "(?<=/balena-io/${CURRENTPACKAGE}/releases/tag/)[^\"]+" | uniq | grep -v "alpha" | grep -v "beta" | grep -v "rc[0-9]")
url="https://github.com/balena-io/etcher/releases/download/"
for version in $versions; do
	if wget --spider -q "$url/${version}/balenaEtcher-${version//[vV]}-x64.AppImage"; then
		VERSION="${version//[vV]}"
		break
	fi
done

APPLICATIONURL="$url/${version}/balenaEtcher-${VERSION}-x64.AppImage"
ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

RESULT=$(/opt/porteux-scripts/porteux-app-store/appimage-builder.sh "$CURRENTPACKAGE" "$FRIENDLYNAME" "$CATEGORY" "$APPLICATIONURL" "$VERSION" "$ACTIVATEMODULE")

echo "$RESULT"
