#!/bin/bash

isRoot() {
	[ "$(id -u)" -eq 0 ]
}

if ! isRoot; then
	echo "Please enter root's password below:"
	su -c "$0 $*"
	exit 0
fi

CURRENTPACKAGE=deno
VERSION=$(curl -s https://github.com/denoland/deno/releases/ | grep -oP "(?<=/denoland/deno/releases/tag/)[^\"]+" | uniq | grep -v "alpha" | grep -v "beta" | grep -v "rc[0-9]" | head -1)
APPLICATIONURL="https://github.com/denoland/deno/releases/download/${VERSION}/deno-x86_64-unknown-linux-gnu.zip"
ARCH=$(uname -m)
OUTPUTDIR="$PORTDIR/modules/"
BUILDDIR="/tmp/$CURRENTPACKAGE-builder"
MODULEDIR="$BUILDDIR"
ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

rm -fr "$BUILDDIR"
mkdir -p "$BUILDDIR/usr/bin" || exit 1

wget -T 15 "$APPLICATIONURL" -P "$BUILDDIR/usr/bin" || exit 1
unzip "$BUILDDIR/usr/bin/"*.zip -d "$BUILDDIR/usr/bin"
rm -f "$BUILDDIR/usr/bin/"*.zip
chmod 755 "$BUILDDIR/usr/bin/"* &>/dev/null || exit 1

MODULEFILENAME="$CURRENTPACKAGE-${VERSION//[vV]}-${ARCH}_porteux.xzm"

/opt/porteux-scripts/porteux-app-store/module-builder.sh "$MODULEDIR" "$OUTPUTDIR/$MODULEFILENAME" "$ACTIVATEMODULE"

# cleanup
rm -fr "$BUILDDIR" &>/dev/null
