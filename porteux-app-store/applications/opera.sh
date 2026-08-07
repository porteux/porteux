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
	echo "Channels available: developer | beta | stable"
	echo ""
	echo "Example: $0 stable pt-BR"
	exit 1
fi

# Global variables
APP="opera"
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

	rm -fr "$pkg_dir/usr/lib/"
	rm -fr "$pkg_dir"/usr/lib64/opera*/opera_autoupdate*
	chromium_family_locale_striptease "$pkg_dir"/usr/lib64/opera*/localization
}

get_module_name() {
	local pkgver="$2"
	local arch="$3"

	echo "${APP}-${CHANNEL}-${pkgver}-${arch}-${LANGUAGE}_porteux"
}

finisher() {
	striptease "$APP" "$1"

	/opt/porteux-scripts/porteux-app-store/module-builder.sh "$TMP/$APP/$1" "$TARGET_DIR/${1}.xzm" "$ACTIVATE_MODULE" || exit 1
	rm -fr "${TMP:?}/$APP"
}

make_module_opera() {
	if [ "$CHANNEL" != "developer" ] && [ "$CHANNEL" != "beta" ] && [ "$CHANNEL" != "stable" ]; then
		echo "Non-existent channel. Options: developer | beta | stable" && exit 1
	fi

	local pkg_name
	local product_name; product_name=$([ "$CHANNEL" == "stable" ] && echo "$APP" || echo "$APP-$CHANNEL")

	create_application_temp_dir "$APP" || exit 1

	$WGET_WITH_TIME_OUT -P "$TMP/$APP/" -r -nd --no-parent https://rpm.opera.com/rpm/ -A "opera_$CHANNEL-*x64*.rpm" || exit 1
	pkgver=$(find "$TMP/$APP" -name "opera_$CHANNEL-*.rpm" -exec basename {} \; | cut -d '-' -f2 | sort -Vr | head -n 1)
	[ "$pkgver" ] || { echo "Error: could not determine the latest version." >&2; exit 1; }
	pkg_name=$(get_module_name "$CHANNEL" "$pkgver" "x86_64")

	mv "$TMP/$APP"/opera_"$CHANNEL"-"$pkgver"-*.rpm "$TMP/$APP/$pkg_name.rpm" || exit 1
	mkdir -p "$TMP/$APP/$pkg_name"
	rpm2cpio "$TMP/$APP/${pkg_name}.rpm" | cpio -idmv -D "$TMP/$APP/$pkg_name"
	chmod 755 "$TMP/$APP/$pkg_name"
	sed -i "s|TryExec=.*||g" "$TMP/$APP/$pkg_name/usr/share/applications/$product_name.desktop"
	sed -i "s|Exec=$product_name|Exec=$product_name --lang=$LANGUAGE|g" "$TMP/$APP/$pkg_name/usr/share/applications/$product_name.desktop"

	finisher "$pkg_name"
}

# Main Code
make_module_opera
