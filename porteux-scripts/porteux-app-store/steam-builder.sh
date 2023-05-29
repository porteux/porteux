#!/bin/bash

CURRENTPACKAGE=steam
APPLICATIONURL=https://repo.steampowered.com/steam/archive/precise/steam_latest.deb
ARCH=i586
OUTPUTDIR="$PORTDIR/modules/"
TEMPDIR="/tmp/$CURRENTPACKAGE-builder"
MODULEDIR="$TEMPDIR/$CURRENTPACKAGE-module"
INSTALLDIR="$1"
CURRENTUSER=$(loginctl user-status | head -n 1 | cut -d" " -f1)
[ ! $CURRENTUSER ] && CURRENTUSER=guest
[[ $INSTALLDIR = --* ]] && echo "Installation path can't be empty." && exit 1

mkdir -p "$INSTALLDIR" || exit 1
rm -fr "$TEMPDIR"	
mkdir "$TEMPDIR" && cd "$TEMPDIR"

wget -T 5 "$APPLICATIONURL" -P "$TEMPDIR" || exit 1
ar p "$TEMPDIR"/*.deb data.tar.xz | tar xJv
tar -xvf "$TEMPDIR/usr/lib/steam/bootstraplinux_ubuntu12_32.tar.xz" -C "$INSTALLDIR"

# the process below is not required but it will speedup the first steam run significantly
mkdir -p "$INSTALLDIR/ubuntu12_32/steam-runtime/pinned_libs_32"
touch "$INSTALLDIR/ubuntu12_32/steam-runtime/pinned_libs_32/done"
mkdir -p "$INSTALLDIR/ubuntu12_32/steam-runtime/pinned_libs_64"
touch "$INSTALLDIR/ubuntu12_32/steam-runtime/pinned_libs_64/done"

echo "$CURRENTUSER" | sudo -S chown -R "$CURRENTUSER":users "$INSTALLDIR"

# handle xzm module
FULLVERSION=$(cat $INSTALLDIR/ubuntu12_32/steam-runtime/version.txt)
VERSION=${FULLVERSION#*.}
VERSION=${VERSION%%.*}

mkdir -p "$MODULEDIR/usr/share/applications"
cp "$TEMPDIR"/usr/share/applications/steam.desktop "$MODULEDIR"/usr/share/applications
sed -i "s|Exec=/usr/bin/steam.*|Exec=$INSTALLDIR/steam.sh %U|g" "$MODULEDIR"/usr/share/applications/steam.desktop
mkdir -p "$MODULEDIR/usr/share/pixmaps"
cp "$TEMPDIR"/usr/share/pixmaps/* "$MODULEDIR/usr/share/pixmaps"

MODULEFILENAME="$CURRENTPACKAGE-$VERSION-$ARCH.xzm"
ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

/opt/porteux-scripts/porteux-app-store/module-builder.sh "$MODULEDIR" "$OUTPUTDIR/$MODULEFILENAME" "$ACTIVATEMODULE"

# cleanup
rm -fr "$TEMPDIR" 2> /dev/null
