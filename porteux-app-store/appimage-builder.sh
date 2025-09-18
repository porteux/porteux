#!/bin/bash

CURRENTPACKAGE="$1"
FRIENDLYNAME="$2"
CATEGORY="$3"
APPLICATIONURL="$4"
VERSION="$5"

ARCH=$(uname -m)
OUTPUTDIR="$PORTDIR/modules/"
BUILDDIR="/tmp/$CURRENTPACKAGE-builder"
MODULEDIR="$BUILDDIR/$CURRENTPACKAGE-module"
APPIMAGEFILENAME="$CURRENTPACKAGE-$VERSION-$ARCH.AppImage"

rm -fr "$BUILDDIR"
mkdir "$BUILDDIR" && cd "$BUILDDIR"

wget -T 15 "$APPLICATIONURL" -P "$BUILDDIR" || exit 1

mkdir -p "$MODULEDIR/opt/$CURRENTPACKAGE"
mkdir -p "$MODULEDIR/usr/share/applications"
mkdir -p "$MODULEDIR/usr/share/pixmaps"

cat > "$MODULEDIR/usr/share/applications/$CURRENTPACKAGE.desktop" << EOF
[Desktop Entry]
Version=1.0
Name=$FRIENDLYNAME
Exec=sh -c /opt/$CURRENTPACKAGE/$APPIMAGEFILENAME %u
Terminal=false
X-MultipleArgs=false
Type=Application
Icon=$CURRENTPACKAGE
StartupNotify=true
Categories=$CATEGORY;
EOF

cp "$BUILDDIR"/*.AppImage "$MODULEDIR/opt/$CURRENTPACKAGE/$APPIMAGEFILENAME" || exit 1

chmod 755 -R "$MODULEDIR" 2> /dev/null || exit 1
chmod 644 "$MODULEDIR"/usr/share/applications/* 2> /dev/null || exit 1

MODULEFILENAME="$CURRENTPACKAGE-$VERSION-$ARCH_porteux.xzm"
ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

/opt/porteux-scripts/porteux-app-store/module-builder.sh "$MODULEDIR" "$OUTPUTDIR/$MODULEFILENAME" "$ACTIVATEMODULE"

# cleanup
rm -fr "$BUILDDIR" 2> /dev/null
