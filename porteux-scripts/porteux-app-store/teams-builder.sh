#!/bin/bash

CURRENTPACKAGE=teams
FRIENDLYNAME=Teams
CATEGORY=Network
APPLICATIONURL=$(curl -s https://api.github.com/repos/IsmaelMartinez/teams-for-linux/releases/latest | grep "http" | grep "AppImage\"" | grep -v 'arm' | cut -d \" -f 4)
FULLVERSION=$(curl -s https://api.github.com/repos/IsmaelMartinez/teams-for-linux/releases/latest | grep "\"tag_name\":" | cut -d \" -f 4 | head -n 1)
VERSION="${FULLVERSION//[vV]}"
ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

RESULT=$(/opt/porteux-scripts/porteux-app-store/appimage-builder.sh "$CURRENTPACKAGE" "$FRIENDLYNAME" "$CATEGORY" "$APPLICATIONURL" "$VERSION" "$ACTIVATEMODULE")

echo "$RESULT"
