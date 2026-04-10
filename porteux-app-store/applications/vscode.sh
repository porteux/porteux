#!/bin/bash

CURRENTPACKAGE=codium
FULLVERSION=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/VSCodium/vscodium/releases/latest | rev | cut -d / -f 1 | rev)
VERSION="${FULLVERSION//[vV]}"
APPLICATIONURL="https://github.com/VSCodium/vscodium/releases/latest/download/codium_${VERSION}_amd64.deb"
ARCH=$(uname -m)
OUTPUTDIR="$PORTDIR/modules"
BUILDDIR="/tmp/$CURRENTPACKAGE-builder"
MODULEFILENAME="$CURRENTPACKAGE-$VERSION-${ARCH}_porteux.xzm"
INPUTFILE="$BUILDDIR/codium_${VERSION}_amd64.deb"

rm -fr "$BUILDDIR"
mkdir "$BUILDDIR" && cd "$BUILDDIR"

wget -T 15 "$APPLICATIONURL" -P "$BUILDDIR" || exit 1

if [ ! -w "$OUTPUTDIR" ]; then
    deb2xzm "$INPUTFILE" -o="/tmp/$MODULEFILENAME" -q &>/dev/null
    echo "Destination $OUTPUTDIR is not writable. New module placed in /tmp and not activated."
elif [ ! -f "$OUTPUTDIR/$MODULEFILENAME" ]; then
    deb2xzm "$INPUTFILE" -o="$OUTPUTDIR/$MODULEFILENAME" -q &>/dev/null
    echo "Module placed in $OUTPUTDIR"
    if [[ "$@" == *"--activate-module"* ]] && [ ! -d "/mnt/live/memory/images/$MODULEFILENAME" ]; then
        activate "$OUTPUTDIR/$MODULEFILENAME" -q &>/dev/null
    fi
else
    deb2xzm "$INPUTFILE" -o="/tmp/$MODULEFILENAME" -q &>/dev/null
    echo "Module $MODULEFILENAME was already in $OUTPUTDIR. New module placed in /tmp and not activated."
fi

# cleanup
rm -fr "$BUILDDIR" &>/dev/null
