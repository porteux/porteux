#!/bin/bash

CURRENTPACKAGE=nvidia
PORTEUXFULLVERSION=$(cat /etc/porteux-version)
PORTEUXVERSION=${PORTEUXFULLVERSION//*-}

systemFullVersion=$(cat /etc/slackware-version)
SLACKWAREVERSION=${systemFullVersion//* }

if [[ "$SLACKWAREVERSION" == *"+" ]]; then
	SLACKWAREVERSION=current
fi

APPLICATIONURL="https://github.com/porteux/porteux/releases/download/$PORTEUXVERSION/$CURRENTPACKAGE-$SLACKWAREVERSION.zip"
OUTPUTDIR="$PORTDIR/modules/"
BUILDDIR="/tmp/$CURRENTPACKAGE-builder"
MODULEDIR="$BUILDDIR/$CURRENTPACKAGE-module"

rm -fr "$BUILDDIR" &>/dev/null
mkdir "$BUILDDIR" &>/dev/null

wget -T 5 "$APPLICATIONURL" -P "$BUILDDIR" || exit 1
MODULEFILENAME=$(unzip -Z1 $BUILDDIR/$CURRENTPACKAGE.zip)
unzip $BUILDDIR/$CURRENTPACKAGE.zip &>/dev/null

if [ ! -w "$OUTPUTDIR" ]; then
    mv "$BUILDDIR"/"$MODULEFILENAME" /tmp &>/dev/null
    echo "Destination $OUTPUTDIR is not writable. New module placed in /tmp and not activated."
elif [ ! -f "$OUTPUTFILEPATH" ]; then
    mv "$BUILDDIR"/"$MODULEFILENAME" -o="$OUTPUTDIR" -q &>/dev/null
    echo "Module placed in $OUTPUTDIR"
else
    mv "$BUILDDIR"/"$MODULEFILENAME" /tmp &>/dev/null
    echo "Module $MODULEFILENAME was already in $OUTPUTDIR. New module placed in /tmp and not activated."
fi

# cleanup
rm -fr "$BUILDDIR" 2> /dev/null
