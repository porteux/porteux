#!/bin/bash

isRoot() {
	[ "$(id -u)" -eq 0 ]
}

if ! isRoot; then
	echo "Please enter root's password below:"
	su -c "$0 $1 $2 $3"
	exit 0
fi

if [ "$#" -lt 1 ]; then
	echo "Usage: $0 [channel] [language] [optional: --activate-module]"
	echo "If no language is specified, en-US will be set"
	echo "Channels available: stable"
	echo ""
	echo "Example: $0 stable pt-BR"
	exit 1
fi

# Global variables
APP="brave-browser"
FRIENDLYPACKAGENAME="brave"
CHANNEL=$([ "$1" ] && echo "$1" || echo "stable")
LANGUAGE=$([ "$2" ] && echo "$2" || echo "en-US")
ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")
TARGET_DIR="$PORTDIR/modules"
TMP="/tmp"
WGET_WITH_TIME_OUT="wget -T 15"

# Functions
create_application_temp_dir() {
	rm -fr "${TMP:?}/$1"
	mkdir -p "$TMP/$1"
}

locale_striptease() {
	find "$MODULEDIR/opt/brave.com/brave/locales" -mindepth 1 -maxdepth 1 \( -type f -o -type d \) ! \( -name "en-US.*" -o -name "en_US.*" -o -name "${LANGUAGE}.*" \) -delete
	find "$MODULEDIR/opt/brave.com/brave/resources/brave_extension/_locales" -mindepth 1 -maxdepth 1 -type d ! \( -name "en" -o -name "${LANGUAGE//-/_}" \) -exec rm -fr {} +
}

striptease() {
	rm -fr "$MODULEDIR/usr/share/man"
	locale_striptease
}

get_module_name() {
	local pkgver="$2"
	local arch="$3"

	echo "${FRIENDLYPACKAGENAME}-${CHANNEL}-${pkgver}-${arch}-${LANGUAGE}_porteux"
}

finisher() {
	striptease

	/opt/porteux-scripts/porteux-app-store/module-builder.sh "$MODULEDIR" "$TARGET_DIR/${1}.xzm" "$ACTIVATEMODULE" || exit 1
	rm -fr "${TMP:?}/$APP"
}

make_module_brave() {
	if [ "$CHANNEL" != "stable" ]; then
		echo "Non-existent channel. Options: stable" && exit 1
	fi

	local FULLVERSION=$(curl -s https://api.github.com/repos/brave/${APP}/releases/latest | grep "\"tag_name\":" | cut -d \" -f 4 | head -n 1)
	local pkgver="${FULLVERSION//[vV]}"
	local pkg_name=$(get_module_name "$CHANNEL" "$pkgver" "x86_64")
	MODULEDIR="$TMP/$APP/$pkg_name"

	create_application_temp_dir "$APP"

	$WGET_WITH_TIME_OUT --content-disposition "https://github.com/brave/${APP}/releases/download/v${pkgver}/${APP}-${pkgver}-1.x86_64.rpm" -P "$TMP/$APP" || exit 1
	mkdir -p "$MODULEDIR"
	rpm2cpio "$TMP/$APP/${APP}-${pkgver}-1.x86_64.rpm" | cpio -idmv -D "$MODULEDIR" || exit 1
	chmod 755 "$MODULEDIR"
	sed -i "s|Exec=|Exec=env LANGUAGE=${LANGUAGE} |g" "$MODULEDIR/usr/share/applications/${APP}.desktop"

	finisher "$pkg_name"
}

# Main Code
make_module_brave
