#!/bin/bash

CURRENT_PACKAGE="$1"
FRIENDLY_NAME="$2"
CATEGORY="$3"
APPLICATION_URL="$4"
VERSION="$5"

ARCH=$(uname -m)
OUTPUT_DIR="$PORTDIR/modules/"
BUILD_DIR="/tmp/$CURRENT_PACKAGE-builder"
MODULE_DIR="$BUILD_DIR/$CURRENT_PACKAGE-module"
APPIMAGE_FILE_NAME="$CURRENT_PACKAGE-$VERSION-$ARCH.AppImage"

rm -fr "$BUILD_DIR"
mkdir "$BUILD_DIR" && cd "$BUILD_DIR" || exit 1

wget -T 15 "$APPLICATION_URL" -P "$BUILD_DIR" || exit 1

mkdir -p "$MODULE_DIR/opt/$CURRENT_PACKAGE"
mkdir -p "$MODULE_DIR/usr/share/applications"
mkdir -p "$MODULE_DIR/usr/share/pixmaps"

cat > "$MODULE_DIR/usr/share/applications/$CURRENT_PACKAGE.desktop" << EOF
[Desktop Entry]
Version=1.0
Name=$FRIENDLY_NAME
Exec=/opt/$CURRENT_PACKAGE/$APPIMAGE_FILE_NAME %u
Terminal=false
X-MultipleArgs=false
Type=Application
Icon=$CURRENT_PACKAGE
StartupNotify=true
Categories=$CATEGORY;
EOF

cp "$BUILD_DIR"/*.AppImage "$MODULE_DIR/opt/$CURRENT_PACKAGE/$APPIMAGE_FILE_NAME" || exit 1
cp /usr/share/pixmaps/"$CURRENT_PACKAGE".* "$MODULE_DIR/usr/share/pixmaps" 2> /dev/null

chmod 755 -R "$MODULE_DIR" 2> /dev/null || exit 1
chmod 644 "$MODULE_DIR"/usr/share/applications/* 2> /dev/null || exit 1
chmod 644 "$MODULE_DIR"/usr/share/pixmaps/* 2> /dev/null

MODULE_FILE_NAME="$CURRENT_PACKAGE-$VERSION-${ARCH}_porteux.xzm"
ACTIVATE_MODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

/opt/porteux-scripts/porteux-app-store/module-builder.sh "$MODULE_DIR" "$OUTPUT_DIR/$MODULE_FILE_NAME" "$ACTIVATE_MODULE" || exit 1

# cleanup
rm -fr "$BUILD_DIR" 2> /dev/null
