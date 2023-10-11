#!/bin/bash

CURRENTPACKAGE=onlyoffice
FRIENDLYNAME="OnlyOffice - Desktop Editors"
CATEGORY=Office
FULLVERSION=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/ONLYOFFICE/DesktopEditors/releases/latest | rev | cut -d / -f 1 | rev)
VERSION="${FULLVERSION//[vV]}"
APPLICATIONURL="https://github.com/ONLYOFFICE/DesktopEditors/releases/latest/download/DesktopEditors-x86_64.AppImage"
ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

RESULT=$(/opt/porteux-scripts/porteux-app-store/appimage-builder.sh "$CURRENTPACKAGE" "$FRIENDLYNAME" "$CATEGORY" "$APPLICATIONURL" "$VERSION" "$ACTIVATEMODULE")

echo "$RESULT"
