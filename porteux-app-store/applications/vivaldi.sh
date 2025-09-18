#!/bin/bash

if [ "$(uname -m)" != "x86_64" ]; then
    echo "Unsupported system architecture"
    exit 1
fi

if [ `whoami` != root ]; then
    echo "Please enter root's password below:"
    su -c "/opt/porteux-scripts/porteux-app-store/applications/vivaldi.sh $1 $2 $3"
    exit 0
fi

if [ "$#" -lt 1 ]; then
    echo "Usage:   $0 [channel] [language] [optional: --activate-module]"
    echo "If no language is specified, en-US will be set"
    echo "Channels available: developer | stable"
    echo ""
    echo "Example: $0 stable pt-BR"
    exit 1
fi

# Global variables
APP="vivaldi"
CHANNEL=$1
LANGUAGE=$([ "$2" ] && echo "$2" || echo "en-US")
ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")
TARGET_DIR="$PORTDIR/modules"
TMP="/tmp"
WGET_WITH_TIME_OUT="wget -T 15"

# Functions
create_application_temp_dir(){
    mkdir -p $TMP/"$1" && rm -rf "${TMP:?}/$1" && mkdir -p $TMP/"$1" || exit 1
}

remove_application_temp_dir(){
    rm -rf "${TMP:?}/$1"
    rm -f "$TMP/${1}-${2}-x86_64.txz"
    rm -rf "${TMP:?}/package-${1}"
}

chromium_family_locale_striptease(){
    local locale_dir="$1"

    find "$locale_dir" -mindepth 1 -maxdepth 1 \( -type f -o -type d \) ! \( -name "en-US.*" -o -name "en_US.*" -o -name "$LANGUAGE.*" \) -delete
}

striptease(){
    local pkg_dir="$TMP/$1/$2"

    rm -rf "$pkg_dir/opt/vivaldi*/resources/vivaldi/default-bookmarks"
    chromium_family_locale_striptease "$pkg_dir"/opt/vivaldi*/locales
    find "$pkg_dir"/opt/vivaldi*/resources/vivaldi/_locales -mindepth 1 -maxdepth 1 -type d ! \( -name "en" -o -name "${LANGUAGE//-/_}" \) -exec rm -rf {} +
}

get_module_name(){
    local pkgver; pkgver="$2"
    local arch; arch="$3"

    echo "${APP}-${CHANNEL}-${LANGUAGE}-${pkgver}-${arch}_porteux"
}

finisher(){
    striptease "$APP" "$1"

    /opt/porteux-scripts/porteux-app-store/module-builder.sh $TMP/"$APP"/"$1" "$TARGET_DIR/${1}.xzm" "$ACTIVATEMODULE" || exit 1
    remove_application_temp_dir "$APP" "$2"
}

get_repo_version_vivaldi(){
    local ver; ver=$(curl -s "https://repo.vivaldi.com/${CHANNEL}/rpm/x86_64/" | grep 'href=' | awk -F '"' '{print $2}' | \
    grep "$CHANNEL" | tail -n 1 | rev | cut -d '.' -f3- | rev | cut -d '-' -f3-) || exit 1

    echo "$ver"
}

make_module_vivaldi(){
    if [ "$CHANNEL" != "snapshot" ] && [ "$CHANNEL" != "stable" ]; then echo "Non-existent channel. Options: snapshot | stable" && exit 1; fi

    local pkgver; pkgver=$(get_repo_version_vivaldi "$CHANNEL")
    local pkg_name; pkg_name=$(get_module_name "$CHANNEL" "$pkgver" "x86_64")
    local product_name; product_name=$([ "$CHANNEL" == "stable" ] && echo "$APP" || echo "$APP-$CHANNEL")

    create_application_temp_dir "$APP" &&

    $WGET_WITH_TIME_OUT -O "$TMP/$APP/${pkg_name}.rpm" "https://repo.vivaldi.com/${CHANNEL}/rpm/x86_64/vivaldi-${CHANNEL}-${pkgver}.x86_64.rpm" &&
    mkdir -p "$TMP/$APP/$pkg_name" &&
    rpm2cpio "$TMP/$APP/${pkg_name}.rpm" | cpio -idmv -D "$TMP/$APP/$pkg_name" &&
    sed -i "s|Exec=/usr/bin/|Exec=|g" "$TMP/$APP/$pkg_name/usr/share/applications/$APP-$CHANNEL.desktop"
    sed -i "s|Icon=.*|Icon=/opt/$product_name/product_logo_128.png|g" "$TMP/$APP/$pkg_name/usr/share/applications/$APP-$CHANNEL.desktop" &&
    sed -i "s|Exec=$APP-$CHANNEL|Exec=env LANGUAGE=$LANGUAGE $APP-$CHANNEL|g" "$TMP/$APP/$pkg_name/usr/share/applications/$APP-$CHANNEL.desktop" &&

    finisher "$pkg_name" "$pkgver"
}

# Main Code
make_module_vivaldi
