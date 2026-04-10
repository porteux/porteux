#!/bin/bash

CURRENTPACKAGE=telegram
FRIENDLYNAME="Telegram"
APPLICATIONURL=https://telegram.org/dl/desktop/linux
FULLVERSION=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/telegramdesktop/tdesktop/releases/latest | rev | cut -d / -f 1 | rev)
VERSION="${FULLVERSION//[vV]}"
ARCH=$(uname -m)
OUTPUTDIR="$PORTDIR/modules/"
BUILDDIR="/tmp/$CURRENTPACKAGE-builder"
MODULEDIR="$BUILDDIR/$CURRENTPACKAGE-module"
BINARYFILENAME="$CURRENTPACKAGE-$VERSION-$ARCH"
ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

rm -fr "$BUILDDIR"
mkdir "$BUILDDIR" && cd "$BUILDDIR"

wget -T 15 --content-disposition "$APPLICATIONURL" -P "$BUILDDIR" || exit 1
tar xvf "$BUILDDIR"/*.tar.xz -C "$BUILDDIR" || exit 1

mkdir -p "$MODULEDIR/opt/$CURRENTPACKAGE"
mkdir -p "$MODULEDIR/home/guest/.local/share/applications"

cat > "$MODULEDIR/home/guest/.local/share/applications/telegramdesktop.desktop" << EOF
[Desktop Entry]
Version=$VERSION
Name=Telegram Desktop
Comment=Official desktop version of Telegram messaging app
TryExec=/opt/$CURRENTPACKAGE/$BINARYFILENAME
Exec=/opt/$CURRENTPACKAGE/$BINARYFILENAME %u
Icon=telegram
Terminal=false
StartupWMClass=TelegramDesktop
Type=Application
Categories=Chat;Network;InstantMessaging;Qt;
MimeType=x-scheme-handler/tg;
Keywords=tg;chat;im;messaging;messenger;sms;tdesktop;
Actions=quit;
SingleMainWindow=true
X-GNOME-UsesNotifications=true
X-GNOME-SingleWindow=true

[Desktop Action quit]
Exec=/opt/$CURRENTPACKAGE/$BINARYFILENAME -quit
Name=Quit Telegram
Icon=application-exit
EOF

cp "$BUILDDIR/$FRIENDLYNAME/$FRIENDLYNAME" "$MODULEDIR/opt/$CURRENTPACKAGE/$BINARYFILENAME" || exit 1

chmod 755 -R "$MODULEDIR" &>/dev/null || exit 1
chown -R guest: "$MODULEDIR/home/guest/"
chmod 644 "$MODULEDIR/home/guest/.local/share/applications/"* &>/dev/null || exit 1

MODULEFILENAME="$CURRENTPACKAGE-$VERSION-${ARCH}_porteux.xzm"

/opt/porteux-scripts/porteux-app-store/module-builder.sh "$MODULEDIR" "$OUTPUTDIR/$MODULEFILENAME" "$ACTIVATEMODULE"

# cleanup
rm -fr "$BUILDDIR" &>/dev/null
