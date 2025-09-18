#!/bin/bash

CURRENTPACKAGE=neovim
FRIENDLYNAME="Neovim"
CATEGORY=Development
VERSION=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/neovim/neovim/releases/latest | rev | cut -d / -f 1 | rev)
APPLICATIONURL="https://github.com/neovim/neovim/releases/download/${VERSION}/nvim-linux-x86_64.tar.gz"
ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

ARCH=$(uname -m)
OUTPUTDIR="$PORTDIR/modules/"
BUILDDIR="/tmp/$CURRENTPACKAGE-builder"
MODULEDIR="$BUILDDIR/$CURRENTPACKAGE-module"

rm -fr "$BUILDDIR"
mkdir -p "$MODULEDIR" && cd "$BUILDDIR"

wget -T 15 "$APPLICATIONURL" -O - | tar -xz -C "$MODULEDIR" || exit 1

mv "$MODULEDIR/nvim-linux-x86_64" "$MODULEDIR/usr"

MODULEFILENAME="$CURRENTPACKAGE-${VERSION//v}-$ARCH_porteux.xzm"
ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

/opt/porteux-scripts/porteux-app-store/module-builder.sh "$MODULEDIR" "$OUTPUTDIR/$MODULEFILENAME" "$ACTIVATEMODULE"

# cleanup
rm -fr "$BUILDDIR" 2> /dev/null
