#!/bin/bash

isRoot() {
	[ "$(id -u)" -eq 0 ]
}

if ! isRoot; then
	echo "Please enter root's password below:"
	su -c "$0 $*"
	exit 0
fi

CURRENTPACKAGE=steam
APPLICATIONURL=https://repo.steampowered.com/steam/archive/precise/steam_latest.deb
ARCH=i586
OUTPUTDIR="$PORTDIR/modules/"
BUILDDIR="/tmp/$CURRENTPACKAGE-builder"
MODULEDIR="$BUILDDIR/$CURRENTPACKAGE-module"
INSTALLDIR="$1"

# Parameter validation
if [ -z "$INSTALLDIR" ]; then
	echo "Usage: $0 [installation_directory] [optional: --activate-module]"
	echo "Installation directory is required."
	exit 1
fi

# Check if directory exists and is writable
if [ ! -w "$INSTALLDIR" ] 2>/dev/null; then
	echo "Directory $INSTALLDIR is not writable. Cannot create $INSTALLDIR."
	exit 1
fi

CURRENTUSER=$(loginctl user-status | head -n 1 | cut -d" " -f1)
CURRENTGROUP=$(id -gn "$CURRENTUSER")
[ ! "$CURRENTUSER" ] && CURRENTUSER=guest
ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")
[[ $INSTALLDIR = --* ]] && echo "Installation path can't be empty." && exit 1

mkdir -p "$INSTALLDIR" || exit 1
rm -fr "$BUILDDIR"
mkdir "$BUILDDIR" && cd "$BUILDDIR"

wget -T 5 "$APPLICATIONURL" -P "$BUILDDIR" || exit 1
ar p "$BUILDDIR"/*.deb data.tar.xz | tar xJv
tar -xvf "$BUILDDIR/usr/lib/steam/bootstraplinux_ubuntu12_32.tar.xz" -C "$INSTALLDIR"

# the process below is not required but it will speedup the first steam run significantly
mkdir -p "$INSTALLDIR/ubuntu12_32/steam-runtime/pinned_libs_32"
touch "$INSTALLDIR/ubuntu12_32/steam-runtime/pinned_libs_32/done"
mkdir -p "$INSTALLDIR/ubuntu12_32/steam-runtime/pinned_libs_64"
touch "$INSTALLDIR/ubuntu12_32/steam-runtime/pinned_libs_64/done"

chown -R "$CURRENTUSER":"$CURRENTGROUP" "$INSTALLDIR"

# handle xzm module
FULLVERSION=$(cat "$INSTALLDIR/ubuntu12_32/steam-runtime/version.txt")
VERSION=${FULLVERSION#*_}

mkdir -p "$MODULEDIR/usr/share/applications"
cp "$BUILDDIR/usr/share/applications/steam.desktop" "$MODULEDIR/usr/share/applications"
sed -i "s|Exec=/usr/bin/steam.*|Exec=$INSTALLDIR/steam.sh %U|g" "$MODULEDIR/usr/share/applications/steam.desktop"
mkdir -p "$MODULEDIR/usr/share/pixmaps"
cp "$BUILDDIR"/usr/share/pixmaps/* "$MODULEDIR/usr/share/pixmaps"

MODULEFILENAME="$CURRENTPACKAGE-$VERSION-$ARCH.xzm"

/opt/porteux-scripts/porteux-app-store/module-builder.sh "$MODULEDIR" "$OUTPUTDIR/$MODULEFILENAME" "$ACTIVATEMODULE"

# cleanup
rm -fr "$BUILDDIR" &>/dev/null
