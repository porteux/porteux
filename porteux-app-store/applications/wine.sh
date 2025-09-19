#!/bin/bash

CURRENTPACKAGE=wine
BUILDDIR="/tmp/$CURRENTPACKAGE-builder"
rm -fr "$BUILDDIR"
mkdir "$BUILDDIR"

MODULEDIR="$BUILDDIR/$CURRENTPACKAGE-module"
mkdir "$MODULEDIR"

ARCH=$(uname -m)
OUTPUTDIR="$PORTDIR/optional/"
REPOSITORY="https://sourceforge.net/projects/wine/files/Slackware%20Packages"

# get latest version
VERSION=$(curl -s $REPOSITORY/ | grep "<tr title=" | grep -oP 'title="\K[^"]+(?=")' | grep -v "rc" | grep -v "name" | sort -Vr | head -n 1)

CURRENTTXZ="wine-$VERSION-x86_64-1sg.txz"
CURRENTTXZPATH="$BUILDDIR/$CURRENTTXZ"
wget -T 15 -P "$BUILDDIR" "$REPOSITORY/$VERSION/x86_64/$CURRENTTXZ" || exit 1

# strip
txz2dir "$CURRENTTXZPATH" -o="$MODULEDIR" -q || exit 1
rm -fr "$MODULEDIR/usr/doc"
rm -fr "$MODULEDIR/usr/include"
rm -fr "$MODULEDIR/usr/man"
find "$MODULEDIR" -name '*.a' -delete
find "$MODULEDIR" | xargs file | egrep ".exe|.dll" | cut -f 1 -d : | xargs strip -S --strip-unneeded --remove-section=.note.gnu.gold-version --remove-section=.comment --remove-section=.note --remove-section=.note.gnu.build-id --remove-section=.note.ABI-tag 2> /dev/null

MODULEFILENAME="$CURRENTPACKAGE-$VERSION-$ARCH_porteux.xzm"
ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

/opt/porteux-scripts/porteux-app-store/module-builder.sh "$MODULEDIR" "$OUTPUTDIR/$MODULEFILENAME" "$ACTIVATEMODULE"

# cleanup
rm -fr $BUILDDIR
