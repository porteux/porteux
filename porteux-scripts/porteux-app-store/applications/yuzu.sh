#!/bin/bash

CURRENTPACKAGE=yuzu
FRIENDLYNAME="Yuzu (Switch)"
CATEGORY=Game
APPLICATIONURL=$(curl -s https://api.github.com/repos/yuzu-emu/yuzu-mainline/releases/latest | grep "AppImage" | grep "download_url" | head -1 | cut -d \" -f 4)
FILENAME=$(echo $APPLICATIONURL | rev | cut -d / -f 1 | rev)
FULLVERSION=${FILENAME%.*}
VERSION=${FULLVERSION/#yuzu-}
ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

RESULT=$(/opt/porteux-scripts/porteux-app-store/appimage-builder.sh "$CURRENTPACKAGE" "$FRIENDLYNAME" "$CATEGORY" "$APPLICATIONURL" "$VERSION" "$ACTIVATEMODULE")

echo "$RESULT"
