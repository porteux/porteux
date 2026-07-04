#!/bin/bash

is_root() {
	[ "$(id -u)" -eq 0 ]
}

if ! is_root; then
	echo "Please enter root's password below:"
	su -c "$(printf '%q ' "$(realpath "$0")" "$@")"
	exit 0
fi

CURRENT_PACKAGE=libreoffice
ARCH=$(uname -m)
CHANNEL=$([ "$1" ] && echo "$1" || echo "stable")
LANGUAGE=$([ "$2" ] && echo "$2" || echo "en-US")
ACTIVATE_MODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")
MAJOR_VERSION=$(curl -s "http://download.documentfoundation.org/libreoffice/$CHANNEL/" | grep -oP 'a href="[0-9].*' | cut -d '"' -f 2 | cut -d / -f 1 | sort -V -r | head -1)
LATEST_PACKAGE=$(curl -s "https://download.documentfoundation.org/libreoffice/$CHANNEL/$MAJOR_VERSION/rpm/$ARCH/" | grep -oP 'LibreOffice_.*' | cut -d '"' -f 1 | grep -oP ".*_Linux_x86-64_rpm.tar.gz$")
VERSION=$(echo "$LATEST_PACKAGE" | cut -d _ -f 2)
[ "$VERSION" ] || { echo "Error: could not determine the latest version." >&2; exit 1; }
OUTPUT_DIR="$PORTDIR/modules"
BUILD_DIR="/tmp/$CURRENT_PACKAGE-builder"
MODULE_DIR="$BUILD_DIR/$CURRENT_PACKAGE-module"
MODULE_FILE_NAME="$CURRENT_PACKAGE-$CHANNEL-$VERSION-$ARCH-${LANGUAGE}_porteux.xzm"

CURRENT_USER=$(loginctl user-status | head -n 1 | cut -d" " -f1)
CURRENT_GROUP=$(id -gn "$CURRENT_USER")
[ ! "$CURRENT_USER" ] && CURRENT_USER=guest
USER_HOME_FOLDER=$(getent passwd "$CURRENT_USER" | cut -d: -f6)
[ ! -e "$USER_HOME_FOLDER" ] && USER_HOME_FOLDER=home/guest

rm -fr "$BUILD_DIR"
mkdir -p "$BUILD_DIR" "$MODULE_DIR"
cd "$BUILD_DIR"

# download LibreOffice
wget -T 15 -q --show-progress "http://download.documentfoundation.org/libreoffice/$CHANNEL/$MAJOR_VERSION/rpm/$ARCH/$LATEST_PACKAGE" || exit 1
tar -xf LibreOffice_"$VERSION"*_Linux_x86-64_rpm.tar.gz || exit 1
mv "$BUILD_DIR"/LibreOffice_"$VERSION"*_Linux_x86-64_rpm/RPMS/* "$MODULE_DIR"
rm -f "$BUILD_DIR"/LibreOffice_"$VERSION"*_Linux_x86-64_rpm.tar.gz

# download helppack
wget -T 15 -q --show-progress "http://download.documentfoundation.org/libreoffice/$CHANNEL/$MAJOR_VERSION/rpm/$ARCH/LibreOffice_${VERSION}_Linux_x86-64_rpm_helppack_${LANGUAGE}.tar.gz" || exit 1
tar -xf LibreOffice_"$VERSION"*_Linux_x86-64_rpm_helppack_"$LANGUAGE".tar.gz || exit 1
mv "$BUILD_DIR"/LibreOffice_"$VERSION"*_Linux_x86-64_rpm_helppack_"$LANGUAGE"/RPMS/* "$MODULE_DIR"
rm -fr "$BUILD_DIR"/LibreOffice_"$VERSION"*_Linux_x86-64_rpm_helppack_"$LANGUAGE"
rm -f "$BUILD_DIR"/LibreOffice_"$VERSION"*_Linux_x86-64_rpm_helppack_"$LANGUAGE".tar.gz

if [[ "$LANGUAGE" != 'en-US' ]]; then
	# download langpack
	wget -T 15 -q --show-progress "http://download.documentfoundation.org/libreoffice/$CHANNEL/$MAJOR_VERSION/rpm/$ARCH/LibreOffice_${VERSION}_Linux_x86-64_rpm_langpack_${LANGUAGE}.tar.gz" || exit 1
	tar -xf LibreOffice_"$VERSION"*_Linux_x86-64_rpm_langpack_"$LANGUAGE".tar.gz || exit 1
	mv "$BUILD_DIR"/LibreOffice_"$VERSION"*_Linux_x86-64_rpm_langpack_"$LANGUAGE"/RPMS/* "$MODULE_DIR"
	rm -fr "$BUILD_DIR"/LibreOffice_"$VERSION"*_Linux_x86-64_rpm_langpack_"$LANGUAGE"
	rm -f "$BUILD_DIR"/LibreOffice_"$VERSION"*_Linux_x86-64_rpm_langpack_"$LANGUAGE".tar.gz

	mkdir -p "$MODULE_DIR/root/.config/libreoffice/4/user/"
	cat > "$MODULE_DIR/root/.config/libreoffice/4/user/registrymodifications.xcu" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<oor:items xmlns:oor="http://openoffice.org/2001/registry" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<item oor:path="/org.openoffice.Office.Linguistic/General"><prop oor:name="UILocale" oor:op="fuse"><value>${LANGUAGE}</value></prop></item>
</oor:items>
EOF

	mkdir -p "$MODULE_DIR/${USER_HOME_FOLDER}/.config/libreoffice/4/user"
	cp "$MODULE_DIR/root/.config/libreoffice/4/user/registrymodifications.xcu" "$MODULE_DIR/${USER_HOME_FOLDER}/.config/libreoffice/4/user"

	chown -R "$CURRENT_USER":"$CURRENT_GROUP" "$MODULE_DIR/${USER_HOME_FOLDER}"
fi

# extract all rpm
cd "$MODULE_DIR"
for i in $(find . -type f -name "*.rpm" | sort); do rpm2cpio "$i" | cpio -idmv &>/dev/null; done
rm -f *.rpm

# strip
rm -fr "$MODULE_DIR/var"
rm -fr "$MODULE_DIR"/opt/libreoffice*/{readmes,CREDITS.fodt,LICENSE,LICENSE.fodt,LICENSE.html,NOTICE}

# fix double menu entries
find "$MODULE_DIR/usr/share/applications/" -name "*.desktop" -delete
mv -f "$MODULE_DIR"/opt/libreoffice*/share/xdg/*.desktop "$MODULE_DIR/usr/share/applications"

# set SAL_USE_VCLPLUGIN=gtk
LO=$(find "$MODULE_DIR"/opt/libreoffice*/program -name soffice | awk 'NR==1 {print $0}')
sed -i -e '/^#\ restore/i# Prefer GTK2\nexport SAL_USE_VCLPLUGIN=${SAL_USE_VCLPLUGIN:-gtk}\n' "$LO"

# to open PDFs LibreOffice needs libavahi libs, but it works if we create symlinks to any existing lib
cd "$(echo "$LO" | sed 's|soffice||')"
ln -s ./libabplo.so libavahi-client.so.3
ln -s ./libabplo.so libavahi-common.so.3

/opt/porteux-scripts/porteux-app-store/module-builder.sh "$MODULE_DIR" "$OUTPUT_DIR/$MODULE_FILE_NAME" "$ACTIVATE_MODULE" || exit 1

# cleanup
rm -fr "$BUILD_DIR" &>/dev/null