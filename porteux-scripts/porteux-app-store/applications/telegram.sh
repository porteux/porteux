#!/bin/bash

CURRENTPACKAGE=telegram
FRIENDLYPACKAGENAME="Telegram"
CATEGORY=Network
APPLICATIONURL=https://telegram.org/dl/desktop/linux
FULLVERSION=$(curl -s https://api.github.com/repos/telegramdesktop/tdesktop/releases/latest | grep "\"tag_name\":" | cut -d \" -f 4 | head -n 1)
VERSION="${FULLVERSION//[vV]}"
ARCH=$(uname -m)
OUTPUTDIR="$PORTDIR/modules/"
BUILDDIR="/tmp/$CURRENTPACKAGE-builder"
MODULEDIR="$BUILDDIR/$CURRENTPACKAGE-module"
APPLICATIONFILENAME="$CURRENTPACKAGE-$VERSION-$ARCH"

rm -fr "$BUILDDIR"
mkdir "$BUILDDIR" && cd "$BUILDDIR"

wget -T 15 --content-disposition "$APPLICATIONURL" -P "$BUILDDIR" || exit 1
tar xvf $BUILDDIR/*.tar.xz -C $BUILDDIR || exit 1

mkdir -p "$MODULEDIR/opt/$CURRENTPACKAGE"
mkdir -p "$MODULEDIR/usr/share/applications"
mkdir -p "$MODULEDIR/usr/share/pixmaps"

cat > "$MODULEDIR/usr/share/applications/$CURRENTPACKAGE.desktop" << EOF
[Desktop Entry]
Version=$VERSION
Name=$FRIENDLYPACKAGENAME
Exec=sh -c /opt/$CURRENTPACKAGE/$APPLICATIONFILENAME %u
Terminal=false
X-MultipleArgs=false
Type=Application
Icon=$CURRENTPACKAGE
StartupNotify=true
Categories=$CATEGORY;
EOF

cp "$BUILDDIR/$FRIENDLYPACKAGENAME/$FRIENDLYPACKAGENAME" "$MODULEDIR/opt/$CURRENTPACKAGE/$APPLICATIONFILENAME" || exit 1

chmod 755 -R "$MODULEDIR" 2> /dev/null || exit 1
chmod 644 "$MODULEDIR"/usr/share/applications/* 2> /dev/null || exit 1

MODULEFILENAME="$CURRENTPACKAGE-$VERSION-$ARCH.xzm"
ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

/opt/porteux-scripts/porteux-app-store/module-builder.sh "$MODULEDIR" "$OUTPUTDIR/$MODULEFILENAME" "$ACTIVATEMODULE"

# cleanup
rm -fr "$BUILDDIR" 2> /dev/null
