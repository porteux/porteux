#!/bin/bash

CURRENTPACKAGE="yt-dlp"
VERSION=$(curl -s "https://api.github.com/repos/yt-dlp/yt-dlp/releases/latest" | grep "\"tag_name\":" | cut -d \" -f 4)
APPLICATIONURL="https://github.com/yt-dlp/yt-dlp/releases/download/${VERSION}/yt-dlp"
ARCH=$(uname -m)
OUTPUTDIR="$PORTDIR/modules/"
BUILDDIR="/tmp/$CURRENTPACKAGE-builder"
MODULEDIR="$BUILDDIR"

rm -rf "$BUILDDIR"
mkdir -p "$BUILDDIR/usr/bin" || exit 1

eval wget -T 5 "$APPLICATIONURL" -P "$BUILDDIR/usr/bin" || exit 1
chmod 755 ${BUILDDIR}/usr/bin/* 2> /dev/null || exit 1

MODULEFILENAME="$CURRENTPACKAGE-$VERSION-noarch.xzm"
ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

/opt/porteux-scripts/porteux-app-store/module-builder.sh "$MODULEDIR" "$OUTPUTDIR/$MODULEFILENAME" "$ACTIVATEMODULE"

# cleanup
rm -rf "$BUILDDIR" 2> /dev/null
