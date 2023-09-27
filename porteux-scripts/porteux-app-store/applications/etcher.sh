#!/bin/bash

CURRENTPACKAGE=etcher
FRIENDLYNAME=Etcher
CATEGORY=Utility
FULLVERSION=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/balena-io/etcher/releases/latest | rev | cut -d / -f 1 | rev)
VERSION="${FULLVERSION//[vV]}"
APPLICATIONURL="https://github.com/balena-io/etcher/releases/latest/download/balenaEtcher-${VERSION}-x64.AppImage"
ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

RESULT=$(/opt/porteux-scripts/porteux-app-store/appimage-builder.sh "$CURRENTPACKAGE" "$FRIENDLYNAME" "$CATEGORY" "$APPLICATIONURL" "$VERSION" "$ACTIVATEMODULE")

echo "$RESULT"
