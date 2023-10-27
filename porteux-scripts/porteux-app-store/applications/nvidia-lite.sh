#!/bin/bash

CURRENTPACKAGE=nvidia-driver
PORTEUXFULLVERSION=$(cat /etc/porteux-version)
PORTEUXVERSION=${PORTEUXFULLVERSION//*-}

systemFullVersion=$(cat /etc/slackware-version)
SLACKWAREVERSION=${systemFullVersion//* }

if [[ "$SLACKWAREVERSION" == *"+" ]]; then
	SLACKWAREVERSION=current
else
	SLACKWAREVERSION=stable
fi

APPLICATIONURL="https://github.com/porteux/porteux/releases/download/$PORTEUXVERSION/$CURRENTPACKAGE-$SLACKWAREVERSION.zip"
OUTPUTDIR="$PORTDIR/modules/"
BUILDDIR="/tmp/$CURRENTPACKAGE-builder"
MODULEDIR="$BUILDDIR/$CURRENTPACKAGE-module"
[ `getconf LONG_BIT` = "64" ] && SYSTEMBITS=64

rm -fr "$BUILDDIR" &>/dev/null
mkdir "$BUILDDIR" &>/dev/null

wget -T 15 "$APPLICATIONURL" -P "$BUILDDIR" || exit 1
MODULEFILENAME=$(unzip -Z1 $BUILDDIR/$CURRENTPACKAGE-$SLACKWAREVERSION.zip) || exit 1
unzip $BUILDDIR/$CURRENTPACKAGE-$SLACKWAREVERSION.zip -d "$BUILDDIR" &>/dev/null || exit 1

MODULEDIR=$(basename -s .xzm ${BUILDDIR}/${MODULEFILENAME})
xzm2dir -q ${BUILDDIR}/${MODULEFILENAME} -o=${BUILDDIR}/${MODULEDIR}
rm ${BUILDDIR}/${MODULEFILENAME}
EXTRACTEDMODULEPATH=${BUILDDIR}/${MODULEDIR}
[ ! $EXTRACTEDMODULEPATH ] && MODULEDIR=${BUILDDIR}/08-nvidia-*

rm -f $EXTRACTEDMODULEPATH/usr/lib/libnvidia-compiler.so*
rm -f $EXTRACTEDMODULEPATH/usr/lib$SYSTEMBITS/libcudadebugger.so*
rm -f $EXTRACTEDMODULEPATH/usr/lib$SYSTEMBITS/libnvidia-compiler.so*
rm -f $EXTRACTEDMODULEPATH/usr/lib$SYSTEMBITS/libnvoptix.so*
rm -f $EXTRACTEDMODULEPATH/usr/lib$SYSTEMBITS/libnvidia-gtk2*
rm -f $EXTRACTEDMODULEPATH/usr/share/nvidia/nvoptix.bin

MODULEFILENAME="${MODULEFILENAME/nvidia/nvidia-lite}"

if [ ! -w "$OUTPUTDIR" ]; then
    dir2xzm -q ${BUILDDIR}/${MODULEDIR} -o=/tmp/${MODULEFILENAME}
    echo "Destination $OUTPUTDIR is not writable. New module placed in /tmp and not activated."
elif [ ! -f "$OUTPUTDIR"/"$MODULEFILENAME" ]; then
	dir2xzm -q ${BUILDDIR}/${MODULEDIR} -o="$OUTPUTDIR"/${MODULEFILENAME}
    echo "Module placed in $OUTPUTDIR"
    if [[ "$@" == *"--activate-module"* ]] && [ ! -d "/mnt/live/memory/images/$MODULEFILENAME" ]; then
        activate "$OUTPUTDIR"/"$MODULEFILENAME" -q &>/dev/null
    fi
else
    dir2xzm -q ${BUILDDIR}/${MODULEDIR} -o=/tmp/${MODULEFILENAME}
    echo "Module $MODULEFILENAME was already in $OUTPUTDIR. New module placed in /tmp and not activated."
fi

# cleanup
rm -fr "$BUILDDIR" 2> /dev/null
