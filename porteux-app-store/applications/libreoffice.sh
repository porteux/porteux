#!/bin/bash

is_root() {
	[ "$(id -u)" -eq 0 ]
}

if ! is_root; then
	echo "Please enter root's password below:"
	su -c "$(printf '%q ' "$(realpath "$0")" "$@")"
	exit $?
fi

CURRENT_PACKAGE=libreoffice
ARCH=$(uname -m)
CHANNEL=$([ "$1" ] && [ "${1#--}" = "$1" ] && echo "$1" || echo "stable")
LANGUAGE=$([ "$2" ] && [ "${2#--}" = "$2" ] && echo "$2" || echo "en-US")
ACTIVATE_MODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")
DOMAIN="https://download.documentfoundation.org"
MAJOR_VERSION=$(curl -sf "$DOMAIN/libreoffice/$CHANNEL/" | grep -oP 'a href="[0-9].*' | cut -d '"' -f 2 | cut -d / -f 1 | sort -V -r | head -1)
REPOSITORY="$DOMAIN/libreoffice/$CHANNEL/$MAJOR_VERSION/rpm/$ARCH"
LATEST_PACKAGE=$(curl -sf "$REPOSITORY/" | grep -oP 'LibreOffice_.*' | cut -d '"' -f 1 | grep -oP ".*_Linux_x86-64_rpm.tar.gz$" | head -1)
VERSION=$(echo "$LATEST_PACKAGE" | cut -d _ -f 2)
[ "$VERSION" ] || { echo "Error: could not determine the latest version." >&2; exit 1; }
OUTPUT_DIR="$PORTDIR/modules"
BUILD_DIR=$(mktemp -d "/tmp/$CURRENT_PACKAGE-builder.XXXXXX") || exit 1
trap 'rm -fr "${BUILD_DIR:?}"' EXIT
MODULE_DIR="$BUILD_DIR/$CURRENT_PACKAGE-module"
MODULE_FILE_NAME="$CURRENT_PACKAGE-$CHANNEL-$VERSION-$ARCH-${LANGUAGE}_porteux.xzm"

CURRENT_USER=$(loginctl user-status | head -n 1 | cut -d" " -f1)
[ ! "$CURRENT_USER" ] && CURRENT_USER=guest
CURRENT_GROUP=$(id -gn "$CURRENT_USER")
USER_HOME_FOLDER=$(getent passwd "$CURRENT_USER" | cut -d: -f6)
[ ! -e "$USER_HOME_FOLDER" ] && USER_HOME_FOLDER=home/guest

mkdir -p "$MODULE_DIR" || exit 1
cd "$BUILD_DIR" || exit 1

# the tarballs are served by third-party mirrors, so verify them against the
# checksum published by The Document Foundation itself
download_and_verify() {
	wget -T 15 -q --show-progress "$REPOSITORY/$1" || return 1
	wget -T 15 -q -O "$1.sha256" "$REPOSITORY/$1.sha256" || return 1
	local expected_checksum=$(cut -d' ' -f1 < "$1.sha256")
	local actual_checksum=$(sha256sum "$1" | cut -d' ' -f1)
	[ "$expected_checksum" = "$actual_checksum" ] || { echo "Error: checksum mismatch for $1." >&2; return 1; }
	rm -f "$1.sha256"
}

# download LibreOffice
download_and_verify "$LATEST_PACKAGE" || exit 1
tar -xf LibreOffice_"$VERSION"*_Linux_x86-64_rpm.tar.gz || exit 1
mv "$BUILD_DIR"/LibreOffice_"$VERSION"*_Linux_x86-64_rpm/RPMS/* "$MODULE_DIR"
rm -f "$BUILD_DIR"/LibreOffice_"$VERSION"*_Linux_x86-64_rpm.tar.gz

# download helppack
download_and_verify "LibreOffice_${VERSION}_Linux_x86-64_rpm_helppack_${LANGUAGE}.tar.gz" || exit 1
tar -xf LibreOffice_"$VERSION"*_Linux_x86-64_rpm_helppack_"$LANGUAGE".tar.gz || exit 1
mv "$BUILD_DIR"/LibreOffice_"$VERSION"*_Linux_x86-64_rpm_helppack_"$LANGUAGE"/RPMS/* "$MODULE_DIR"
rm -fr "$BUILD_DIR"/LibreOffice_"$VERSION"*_Linux_x86-64_rpm_helppack_"$LANGUAGE"
rm -f "$BUILD_DIR"/LibreOffice_"$VERSION"*_Linux_x86-64_rpm_helppack_"$LANGUAGE".tar.gz

if [[ "$LANGUAGE" != 'en-US' ]]; then
	# download langpack
	download_and_verify "LibreOffice_${VERSION}_Linux_x86-64_rpm_langpack_${LANGUAGE}.tar.gz" || exit 1
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
find . -type f -name "*.rpm" | sort | while IFS= read -r i; do
	rpm2cpio "$i" | cpio -idmv &>/dev/null || { echo "Error: could not extract $i." >&2; exit 1; }
done || exit 1
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