#!/bin/bash

CURRENTPACKAGE=keepassxc
FRIENDLYNAME="KeePassXC"
CATEGORY=Security
VERSION=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/keepassxreboot/keepassxc/releases/latest | rev | cut -d / -f 1 | rev)
APPLICATIONURL="https://github.com/keepassxreboot/keepassxc/releases/latest/download/KeePassXC-${VERSION}-x86_64.AppImage"
ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

RESULT=$(/opt/porteux-scripts/porteux-app-store/appimage-builder.sh "$CURRENTPACKAGE" "$FRIENDLYNAME" "$CATEGORY" "$APPLICATIONURL" "$VERSION" "$ACTIVATEMODULE")

echo "$RESULT"
