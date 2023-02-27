#!/bin/bash

CURRENTPACKAGE=steam
APPLICATIONURL=https://repo.steampowered.com/steam/archive/precise/steam_latest.deb
ARCH=i586
OUTPUTDIR="$PORTDIR/modules/"
BUILDDIR="/tmp/$CURRENTPACKAGE-builder"
MODULEDIR="$BUILDDIR/$CURRENTPACKAGE-module"

rm -fr "$BUILDDIR"
mkdir "$BUILDDIR" && cd "$BUILDDIR"
mkdir -p "$MODULEDIR/home/guest/.local/share/Steam/"

wget -T 5 "$APPLICATIONURL" -P "$BUILDDIR" || exit 1
ar p "$BUILDDIR"/*.deb data.tar.xz | tar xJv -C "$MODULEDIR"

# the process below is not required but it will speedup the first steam run significantly
tar -xvf "$MODULEDIR/usr/lib/steam/bootstraplinux_ubuntu12_32.tar.xz" -C "$MODULEDIR/home/guest/.local/share/Steam/"
mkdir -p "$MODULEDIR/home/guest/.local/share/Steam/ubuntu12_32/steam-runtime/pinned_libs_32"
mkdir -p "$MODULEDIR/home/guest/.local/share/Steam/ubuntu12_32/steam-runtime/pinned_libs_64"
echo guest | sudo -S chown -R guest:users "$MODULEDIR/home/guest"

FULLVERSION=$(cat $MODULEDIR/home/guest/.local/share/Steam/ubuntu12_32/steam-runtime/version.txt)
VERSION=${FULLVERSION#*.}
VERSION=${VERSION%%.*}

MODULEFILENAME="$CURRENTPACKAGE-$VERSION-$ARCH.xzm"
ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

/opt/porteux-scripts/porteux-app-store/module-builder.sh "$MODULEDIR" "$OUTPUTDIR/$MODULEFILENAME" "$ACTIVATEMODULE"

# cleanup
rm -fr "$BUILDDIR" 2> /dev/null
