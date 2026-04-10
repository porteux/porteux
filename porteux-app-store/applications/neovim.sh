#!/bin/bash

isRoot() {
	[ "$(id -u)" -eq 0 ]
}

if ! isRoot; then
	echo "Please enter root's password below:"
	su -c "$0 $*"
	exit 0
fi

CURRENTPACKAGE=neovim
VERSION=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/neovim/neovim/releases/latest | rev | cut -d / -f 1 | rev)
APPLICATIONURL="https://github.com/neovim/neovim/releases/download/${VERSION}/nvim-linux-x86_64.tar.gz"
ARCH=$(uname -m)
OUTPUTDIR="$PORTDIR/modules/"
BUILDDIR="/tmp/$CURRENTPACKAGE-builder"
MODULEDIR="$BUILDDIR/$CURRENTPACKAGE-module"
ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

rm -fr "$BUILDDIR"
mkdir -p "$MODULEDIR" && cd "$BUILDDIR"

wget -T 15 "$APPLICATIONURL" -O - | tar -xz -C "$MODULEDIR" || exit 1

mv "$MODULEDIR/nvim-linux-x86_64" "$MODULEDIR/usr"

MODULEFILENAME="$CURRENTPACKAGE-${VERSION//v}-${ARCH}_porteux.xzm"

/opt/porteux-scripts/porteux-app-store/module-builder.sh "$MODULEDIR" "$OUTPUTDIR/$MODULEFILENAME" "$ACTIVATEMODULE"

# cleanup
rm -fr "$BUILDDIR" &>/dev/null
