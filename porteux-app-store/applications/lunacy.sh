#!/bin/bash

CURRENTPACKAGE=lunacy
CATEGORY=Graphics
APPLICATIONURL="https://lcdn.icons8.com/setup/Lunacy.deb"
ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

ARCH=$(uname -m)
OUTPUTDIR="$PORTDIR/modules"
BUILDDIR="/tmp/$CURRENTPACKAGE-builder"
TMPMODULEFILENAME="$CURRENTPACKAGE.xzm"
INPUTFILE="$BUILDDIR/Lunacy.deb"

rm -fr "$BUILDDIR"
mkdir "$BUILDDIR" && cd "$BUILDDIR"

wget -T 15 "$APPLICATIONURL" -P "$BUILDDIR" || exit 1

deb2xzm "$INPUTFILE" -o="$BUILDDIR/$TMPMODULEFILENAME" -q &>/dev/null
VERSION=$(unsquashfs -cat "$BUILDDIR/$TMPMODULEFILENAME" "usr/share/applications/*.desktop" | grep Version | cut -d= -f2)
MODULEFILENAME="$CURRENTPACKAGE-$VERSION-${ARCH}_porteux.xzm"

if [ ! -w "$OUTPUTDIR" ]; then
    mv "$BUILDDIR/$TMPMODULEFILENAME" "/tmp/$MODULEFILENAME"
    echo "Destination $OUTPUTDIR is not writable. New module placed in /tmp and not activated."
elif [ ! -f "$OUTPUTDIR/$MODULEFILENAME" ]; then
    mv "$BUILDDIR/$TMPMODULEFILENAME" "$OUTPUTDIR/$MODULEFILENAME"
    echo "Module placed in $OUTPUTDIR"

    if [[ "$@" == *"--activate-module"* ]] && [ ! -d "/mnt/live/memory/images/$MODULEFILENAME" ]; then
        activate "$OUTPUTDIR/$MODULEFILENAME" -q &>/dev/null
    fi
else
    mv "$BUILDDIR/$TMPMODULEFILENAME" "/tmp/$MODULEFILENAME"
    echo "Module $MODULEFILENAME was already in $OUTPUTDIR. New module placed in /tmp and not activated."
fi

ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

# cleanup
rm -fr "$BUILDDIR" 2> /dev/null