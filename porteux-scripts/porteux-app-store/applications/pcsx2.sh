#!/bin/bash

CURRENTPACKAGE=pcsx2
FRIENDLYNAME="PCSX2 (PS2)"
CATEGORY=Game
APPLICATIONURL=$(curl -s https://api.github.com/repos/PCSX2/pcsx2/releases | grep "AppImage" | grep "download_url" | head -1 | cut -d \" -f 4)
FULLVERSION=$(curl -s https://api.github.com/repos/PCSX2/pcsx2/tags | grep "\"name\":" | cut -d \" -f 4 | sort -Vr | head -n 1)
VERSION="${FULLVERSION//[vV]}"
ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

RESULT=$(/opt/porteux-scripts/porteux-app-store/appimage-builder.sh "$CURRENTPACKAGE" "$FRIENDLYNAME" "$CATEGORY" "$APPLICATIONURL" "$VERSION" "$ACTIVATEMODULE")

echo "$RESULT"
