#!/bin/bash

CURRENTPACKAGE="yt-dlp"
VERSION=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/yt-dlp/yt-dlp/releases/latest | rev | cut -d / -f 1 | rev)
APPLICATIONURL="https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp"
ARCH=$(uname -m)
OUTPUTDIR="$PORTDIR/modules/"
BUILDDIR="/tmp/$CURRENTPACKAGE-builder"
MODULEDIR="$BUILDDIR"

rm -rf "$BUILDDIR"
mkdir -p "$BUILDDIR/usr/bin" || exit 1

eval wget -T 15 "$APPLICATIONURL" -P "$BUILDDIR/usr/bin" || exit 1
chmod 755 ${BUILDDIR}/usr/bin/* 2> /dev/null || exit 1

MODULEFILENAME="$CURRENTPACKAGE-$VERSION-noarch_porteux.xzm"
ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

/opt/porteux-scripts/porteux-app-store/module-builder.sh "$MODULEDIR" "$OUTPUTDIR/$MODULEFILENAME" "$ACTIVATEMODULE"

# cleanup
rm -rf "$BUILDDIR" 2> /dev/null
