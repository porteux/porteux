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
	echo "Channels available: stable | unstable | beta"
	echo ""
	echo "Example: $0 stable pt-BR"
	exit 1
fi

# Global variables
APP="google-chrome"
FRIENDLY_PACKAGE_NAME="chrome"
CHANNEL=$1
LANGUAGE=$([ "$2" ] && [ "${2#--}" = "$2" ] && echo "$2" || echo "en-US")
ACTIVATE_MODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")
TARGET_DIR="$PORTDIR/modules"
TMP="/tmp"
WGET_WITH_TIME_OUT="wget -T 15"

# Functions
create_application_temp_dir() {
	rm -fr "${TMP:?}/$1"
	mkdir -p "$TMP/$1"
}

chromium_family_locale_striptease() {
	local locale_dir="$1"

	find "$locale_dir" -mindepth 1 -maxdepth 1 \( -type f -o -type d \) ! \( -name "en-US.*" -o -name "en_US.*" -o -name "$LANGUAGE.*" \) -delete
}

striptease() {
	local pkg_dir="$TMP/$1/$2"

	find "$pkg_dir/usr/share" -mindepth 1 -maxdepth 1 -type d -not -name applications -exec rm -fr '{}' \;
	rm -fr "${pkg_dir:?}/etc"
	chromium_family_locale_striptease "$pkg_dir"/opt/google/chrome*/locales
}

get_module_name() {
	local pkgver="$2"
	local arch="$3"

	echo "${FRIENDLY_PACKAGE_NAME}-${CHANNEL}-${pkgver}-${arch}-${LANGUAGE}_porteux"
}

finisher() {
	striptease "$APP" "$1"

	/opt/porteux-scripts/porteux-app-store/module-builder.sh "$TMP/$APP/$1" "$TARGET_DIR/${1}.xzm" "$ACTIVATE_MODULE" || exit 1
	rm -fr "${TMP:?}/$APP"
}

get_repo_version_google_chrome() {
	local ver=$(curl -s https://dl.google.com/linux/chrome/rpm/stable/x86_64/repodata/other.xml.gz | \
		gzip -df | tr -d '\n' | tr '<' '\n' | grep -A 1 "name=\"$APP-$1\"" | grep -o 'ver="[^"]*"' | \
		sed -r 's/ver="([^"]*)"/\1/' | sort -Vr | head -n 1)

	echo "$ver"
}

make_module_google_chrome() {
	if [ "$CHANNEL" != "unstable" ] && [ "$CHANNEL" != "beta" ] && [ "$CHANNEL" != "stable" ]; then
		echo "Non-existent channel. Options: unstable | beta | stable" && exit 1
	fi

	local pkgver=$(get_repo_version_google_chrome "$CHANNEL")
	[ "$pkgver" ] || { echo "Error: could not determine the latest version." >&2; exit 1; }
	local pkg_name=$(get_module_name "$CHANNEL" "$pkgver" "x86_64")
	local product_name=$([ "$CHANNEL" == "stable" ] && echo "$APP" || echo "$APP-$CHANNEL")
	local product_folder=$([ "$CHANNEL" == "stable" ] && echo "chrome" || echo "chrome-$CHANNEL")
	local icon_channel;
	if [ "$CHANNEL" == "beta" ]; then
		icon_channel="_beta"
	elif [ "$CHANNEL" == "unstable" ]; then
		icon_channel="_dev"
	fi

	create_application_temp_dir "$APP"

	mkdir -p "$TMP/$APP/$pkg_name"

	$WGET_WITH_TIME_OUT -O "$TMP/$APP/$pkg_name.deb" "https://dl.google.com/linux/direct/${APP}-${CHANNEL}_current_amd64.deb" || exit 1
	ar p "$TMP/$APP/$pkg_name.deb" data.tar.xz | tar xJv -C "$TMP/$APP/$pkg_name" || exit 1
	chmod 755 "$TMP/$APP/$pkg_name"

	sed -i "s|TryExec=.*||g" "$TMP/$APP/$pkg_name/usr/share/applications/$product_name.desktop"
	sed -i "s|Exec=/usr/bin/|Exec=|g" "$TMP/$APP/$pkg_name/usr/share/applications/$product_name.desktop"
	sed -i "s|Exec=$APP-$CHANNEL|Exec=env LANGUAGE=$LANGUAGE $APP-$CHANNEL|g" "$TMP/$APP/$pkg_name/usr/share/applications/$product_name.desktop"
	sed -i "s|Icon=.*|Icon=/opt/google/$product_folder/product_logo_128$icon_channel.png|g" "$TMP/$APP/$pkg_name/usr/share/applications/$product_name.desktop"

	finisher "$pkg_name"
}

# Main Code
make_module_google_chrome
