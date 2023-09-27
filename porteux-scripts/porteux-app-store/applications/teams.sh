#!/bin/bash

CURRENTPACKAGE=teams
FRIENDLYNAME=Teams
CATEGORY=Network
FULLVERSION=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/IsmaelMartinez/teams-for-linux/releases/latest | rev | cut -d / -f 1 | rev)
VERSION="${FULLVERSION//[vV]}"
APPLICATIONURL="https://github.com/IsmaelMartinez/teams-for-linux/releases/latest/download/teams-for-linux-${VERSION}.AppImage"
ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

RESULT=$(/opt/porteux-scripts/porteux-app-store/appimage-builder.sh "$CURRENTPACKAGE" "$FRIENDLYNAME" "$CATEGORY" "$APPLICATIONURL" "$VERSION" "$ACTIVATEMODULE")

echo "$RESULT"
