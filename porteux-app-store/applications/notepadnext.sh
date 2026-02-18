#!/bin/bash

CURRENTPACKAGE=notepadnext
FRIENDLYNAME="Notepad++ (Next)"
CATEGORY=Utility
FULLVERSION=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/dail8859/NotepadNext/releases/latest | rev | cut -d / -f 1 | rev)
VERSION="${FULLVERSION//[vV]}"
APPLICATIONURL="https://github.com/dail8859/NotepadNext/releases/latest/download/NotepadNext-${FULLVERSION}-x86_64.AppImage"
ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

RESULT=$(/opt/porteux-scripts/porteux-app-store/appimage-builder.sh "$CURRENTPACKAGE" "$FRIENDLYNAME" "$CATEGORY" "$APPLICATIONURL" "$VERSION" "$ACTIVATEMODULE")

echo "$RESULT"
