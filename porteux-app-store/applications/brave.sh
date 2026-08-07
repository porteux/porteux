#!/bin/bash

is_root() {
	[ "$(id -u)" -eq 0 ]
}

if ! is_root; then
	echo "Please enter root's password below:"
	su -c "$(printf '%q ' "$(realpath "$0")" "$@")"
	exit $?
fi

if [ "$#" -lt 1 ]; then
	echo "Usage: $0 [channel] [language] [optional: --activate-module]"
	echo "If no language is specified, en-US will be set"
	echo "Channels available: stable | origin"
	echo ""
	echo "Example: $0 stable pt-BR"
	exit 1
fi

# Global variables
REPO="brave-browser"
FRIENDLY_PACKAGE_NAME="brave"
CHANNEL=$([ "$1" ] && echo "$1" || echo "stable")
LANGUAGE=$([ "$2" ] && echo "$2" || echo "en-US")
ACTIVATE_MODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")
TARGET_DIR="$PORTDIR/modules"
TMP="/tmp"
WGET_WITH_TIME_OUT="wget -T 15"

# Channel-dependent package name and install folder (origin and stable share the brave-browser repo/release)
APP=$([ "$CHANNEL" == "origin" ] && echo "brave-origin" || echo "brave-browser")
OPT_FOLDER=$([ "$CHANNEL" == "origin" ] && echo "brave-origin" || echo "brave")

# Functions
create_application_temp_dir() {
	rm -fr "${TMP:?}/$1"
	mkdir -p "$TMP/$1"
}

locale_striptease() {
	find "$MODULE_DIR/opt/brave.com/$OPT_FOLDER/locales" -mindepth 1 -maxdepth 1 \( -type f -o -type d \) ! \( -name "en-US.*" -o -name "en_US.*" -o -name "${LANGUAGE}.*" \) -delete
	find "$MODULE_DIR/opt/brave.com/$OPT_FOLDER/resources/brave_extension/_locales" -mindepth 1 -maxdepth 1 -type d ! \( -name "en" -o -name "${LANGUAGE//-/_}" \) -exec rm -fr {} +
}

striptease() {
	rm -fr "$MODULE_DIR/usr/share/appdata"
	rm -fr "$MODULE_DIR/usr/share/gnome-control-center"
	rm -fr "$MODULE_DIR/usr/share/man"
	locale_striptease
}

get_module_name() {
	local pkgver="$2"
	local arch="$3"

	echo "${FRIENDLY_PACKAGE_NAME}-${CHANNEL}-${pkgver}-${arch}-${LANGUAGE}_porteux"
}

finisher() {
	striptease

	/opt/porteux-scripts/porteux-app-store/module-builder.sh "$MODULE_DIR" "$TARGET_DIR/${1}.xzm" "$ACTIVATE_MODULE" || exit 1
	rm -fr "${TMP:?}/$APP"
}

make_module_brave() {
	if [ "$CHANNEL" != "stable" ] && [ "$CHANNEL" != "origin" ]; then
		echo "Non-existent channel. Options: stable | origin" && exit 1
	fi

	local FULL_VERSION=$(curl -s https://api.github.com/repos/brave/${REPO}/releases/latest | grep "\"tag_name\":" | cut -d \" -f 4 | head -n 1)
	local pkgver="${FULL_VERSION//[vV]}"
	[ "$pkgver" ] || { echo "Error: could not determine the latest version." >&2; exit 1; }
	local pkg_name=$(get_module_name "$CHANNEL" "$pkgver" "x86_64")
	MODULE_DIR="$TMP/$APP/$pkg_name"

	create_application_temp_dir "$APP"

	$WGET_WITH_TIME_OUT --content-disposition "https://github.com/brave/${REPO}/releases/download/v${pkgver}/${APP}-${pkgver}-1.x86_64.rpm" -P "$TMP/$APP" || exit 1
	mkdir -p "$MODULE_DIR"
	rpm2cpio "$TMP/$APP/${APP}-${pkgver}-1.x86_64.rpm" | cpio -idmv -D "$MODULE_DIR" || exit 1
	chmod 755 "$MODULE_DIR"
	sed -i "s|Exec=|Exec=env LANGUAGE=${LANGUAGE} |g" "$MODULE_DIR/usr/share/applications/${APP}.desktop"

	mkdir -p "$MODULE_DIR/usr/share/icons/hicolor/256x256/apps"
	cp "$MODULE_DIR/opt/brave.com/$OPT_FOLDER/product_logo_256.png" "$MODULE_DIR/usr/share/icons/hicolor/256x256/apps/${APP}.png"

	finisher "$pkg_name"
}

# Main Code
make_module_brave
