#!/bin/bash

CURRENTPACKAGE=libreoffice
FRIENDLYNAME=LibreOffice
CATEGORY=Office
VERSION=$(wget -q "http://download.documentfoundation.org/libreoffice/stable/" -O - 2>/dev/null | grep "[0-9].[0-9].[0-9]" | sed -n 's/.*href="\([^"]*\).*/\1/p' | tr -d / | tail -1)
APPLICATIONURL="https://appimages.libreitalia.org/LibreOffice-fresh.standard-x86_64.AppImage"
ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

RESULT=$(/opt/porteux-scripts/porteux-app-store/appimage-builder.sh "$CURRENTPACKAGE" "$FRIENDLYNAME" "$CATEGORY" "$APPLICATIONURL" "$VERSION" "$ACTIVATEMODULE")

echo "$RESULT"