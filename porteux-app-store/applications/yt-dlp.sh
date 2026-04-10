#!/bin/bash

isRoot() {
    [ "$(id -u)" -eq 0 ]
}

if ! isRoot; then
    echo "Please enter root's password below:"
    su -c "/opt/porteux-scripts/porteux-app-store/applications/yt-dlp.sh $*"
    exit 0
fi


CURRENTPACKAGE=yt-dlp
VERSION=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/yt-dlp/yt-dlp/releases/latest | rev | cut -d / -f 1 | rev)
APPLICATIONURL="https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp"
ARCH=$(uname -m)
OUTPUTDIR="$PORTDIR/modules/"
BUILDDIR="/tmp/$CURRENTPACKAGE-builder"
MODULEDIR="$BUILDDIR"
ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

rm -fr "$BUILDDIR"
mkdir -p "$BUILDDIR/usr/bin" || exit 1

wget -T 15 "$APPLICATIONURL" -P "$BUILDDIR/usr/bin" || exit 1
chmod 755 "$BUILDDIR/usr/bin/"* &>/dev/null || exit 1

MODULEFILENAME="$CURRENTPACKAGE-$VERSION-noarch_porteux.xzm"

/opt/porteux-scripts/porteux-app-store/module-builder.sh "$MODULEDIR" "$OUTPUTDIR/$MODULEFILENAME" "$ACTIVATEMODULE"

# cleanup
rm -fr "$BUILDDIR" &>/dev/null
