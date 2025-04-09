#!/bin/bash

CURRENTPACKAGE=telegram
FRIENDLYPACKAGENAME="Telegram"
CATEGORY=Network
APPLICATIONURL=https://telegram.org/dl/desktop/linux
FULLVERSION=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/telegramdesktop/tdesktop/releases/latest | rev | cut -d / -f 1 | rev)
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

mkdir -p "$MODULEDIR/home/guest/.local/share/applications"

cat > "$MODULEDIR/home/guest/.local/share/applications/telegramdesktop.desktop" << EOF
[Desktop Entry]
Version=$VERSION
Name=Telegram Desktop
Comment=Official desktop version of Telegram messaging app
TryExec=/opt/telegram/$APPLICATIONFILENAME
Exec=/opt/$CURRENTPACKAGE/$APPLICATIONFILENAME %u
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
Exec=/opt/telegram/$APPLICATIONFILENAME -quit
Name=Quit Telegram
Icon=application-exit
EOF

cp "$BUILDDIR/$FRIENDLYPACKAGENAME/$FRIENDLYPACKAGENAME" "$MODULEDIR/opt/$CURRENTPACKAGE/$APPLICATIONFILENAME" || exit 1

chmod 755 -R "$MODULEDIR" 2> /dev/null || exit 1
chown -R guest: "$MODULEDIR/home/guest/"
chmod 644 "$MODULEDIR"/home/guest/.local/share/applications/* 2> /dev/null || exit

MODULEFILENAME="$CURRENTPACKAGE-$VERSION-$ARCH.xzm"
ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

/opt/porteux-scripts/porteux-app-store/module-builder.sh "$MODULEDIR" "$OUTPUTDIR/$MODULEFILENAME" "$ACTIVATEMODULE"

# cleanup
rm -fr "$BUILDDIR" 2> /dev/null
