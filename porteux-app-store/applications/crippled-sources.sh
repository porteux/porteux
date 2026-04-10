#!/bin/bash

CURRENTPACKAGE=crippled-sources
PORTEUXFULLVERSION=$(cat /etc/porteux-version)
PORTEUXVERSION=${PORTEUXFULLVERSION#*-}
PORTEUXVERSION=${PORTEUXVERSION%%-*}
APPLICATIONURL="https://github.com/porteux/porteux/releases/download/$PORTEUXVERSION/$CURRENTPACKAGE.zip"
OUTPUTDIR="$PORTDIR/optional/"
BUILDDIR="/tmp/$CURRENTPACKAGE-builder"

rm -fr "$BUILDDIR" &>/dev/null
mkdir "$BUILDDIR" &>/dev/null

wget -T 15 "$APPLICATIONURL" -P "$BUILDDIR" || exit 1
MODULEFILENAME=$(unzip -Z1 "$BUILDDIR/$CURRENTPACKAGE.zip") || exit 1
unzip "$BUILDDIR/$CURRENTPACKAGE.zip" -d "$BUILDDIR" &>/dev/null || exit 1

if [ ! -w "$OUTPUTDIR" ]; then
    mv "$BUILDDIR/$MODULEFILENAME" /tmp &>/dev/null
    echo "Destination $OUTPUTDIR is not writable. New module placed in /tmp and not activated."
elif [ ! -f "$OUTPUTDIR/$MODULEFILENAME" ]; then
    mv "$BUILDDIR/$MODULEFILENAME" "$OUTPUTDIR" &>/dev/null
    echo "Module placed in $OUTPUTDIR"
    if [[ "$@" == *"--activate-module"* ]] && [ ! -d "/mnt/live/memory/images/$MODULEFILENAME" ]; then
        activate "$OUTPUTDIR/$MODULEFILENAME" -q &>/dev/null
    fi
else
    mv "$BUILDDIR/$MODULEFILENAME" /tmp &>/dev/null
    echo "Module $MODULEFILENAME was already in $OUTPUTDIR. New module placed in /tmp and not activated."
fi

# cleanup
rm -fr "$BUILDDIR" &>/dev/null
