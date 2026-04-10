#!/bin/bash

isRoot() {
    [ "$(id -u)" -eq 0 ]
}

if ! isRoot; then
    echo "Please enter root's password below:"
    su -c "/opt/porteux-scripts/porteux-app-store/applications/whatsapp.sh $*"
    exit 0
fi


CURRENTPACKAGE=whatsapp
FRIENDLYNAME="WhatsApp (WALC)"
CATEGORY=Network
FULLVERSION=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/WAClient/WALC/releases/latest | rev | cut -d / -f 1 | rev)
VERSION="${FULLVERSION//[vV]}"
APPLICATIONURL="https://github.com/WAClient/WALC/releases/latest/download/WALC-${VERSION}.AppImage"
ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

RESULT=$(/opt/porteux-scripts/porteux-app-store/appimage-builder.sh "$CURRENTPACKAGE" "$FRIENDLYNAME" "$CATEGORY" "$APPLICATIONURL" "$VERSION" "$ACTIVATEMODULE")

echo "$RESULT"
