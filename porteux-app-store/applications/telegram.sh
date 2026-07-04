#!/bin/bash

is_root() {
	[ "$(id -u)" -eq 0 ]
}

if ! is_root; then
	echo "Please enter root's password below:"
	su -c "$(printf '%q ' "$(realpath "$0")" "$@")"
	exit 0
fi

CURRENT_PACKAGE=telegram
FRIENDLY_NAME="Telegram"
APPLICATION_URL=https://telegram.org/dl/desktop/linux
FULL_VERSION=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/telegramdesktop/tdesktop/releases/latest | rev | cut -d / -f 1 | rev)
VERSION="${FULL_VERSION//[vV]}"
[ "$VERSION" ] || { echo "Error: could not determine the latest version." >&2; exit 1; }
ARCH=$(uname -m)
OUTPUT_DIR="$PORTDIR/modules/"
BUILD_DIR="/tmp/$CURRENT_PACKAGE-builder"
MODULE_DIR="$BUILD_DIR/$CURRENT_PACKAGE-module"
BINARY_FILE_NAME="$CURRENT_PACKAGE-$VERSION-$ARCH"
ACTIVATE_MODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

rm -fr "$BUILD_DIR"
mkdir "$BUILD_DIR" && cd "$BUILD_DIR" || exit 1

wget -T 15 --content-disposition "$APPLICATION_URL" -P "$BUILD_DIR" || exit 1
tar xvf "$BUILD_DIR"/*.tar.xz -C "$BUILD_DIR" || exit 1

mkdir -p "$MODULE_DIR/opt/$CURRENT_PACKAGE"
mkdir -p "$MODULE_DIR/home/guest/.local/share/applications"

cat > "$MODULE_DIR/home/guest/.local/share/applications/telegramdesktop.desktop" << EOF
[Desktop Entry]
Version=$VERSION
Name=Telegram Desktop
Comment=Official desktop version of Telegram messaging app
TryExec=/opt/$CURRENT_PACKAGE/$BINARY_FILE_NAME
Exec=/opt/$CURRENT_PACKAGE/$BINARY_FILE_NAME %u
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
Exec=/opt/$CURRENT_PACKAGE/$BINARY_FILE_NAME -quit
Name=Quit Telegram
Icon=application-exit
EOF

cp "$BUILD_DIR/$FRIENDLY_NAME/$FRIENDLY_NAME" "$MODULE_DIR/opt/$CURRENT_PACKAGE/$BINARY_FILE_NAME" || exit 1

chmod 755 -R "$MODULE_DIR" &>/dev/null || exit 1
chown -R guest: "$MODULE_DIR/home/guest/"
chmod 644 "$MODULE_DIR/home/guest/.local/share/applications/"* &>/dev/null || exit 1

MODULE_FILE_NAME="$CURRENT_PACKAGE-$VERSION-${ARCH}_porteux.xzm"

/opt/porteux-scripts/porteux-app-store/module-builder.sh "$MODULE_DIR" "$OUTPUT_DIR/$MODULE_FILE_NAME" "$ACTIVATE_MODULE" || exit 1

# cleanup
rm -fr "$BUILD_DIR" &>/dev/null
