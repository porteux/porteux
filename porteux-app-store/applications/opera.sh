#!/bin/bash

if [ "$(uname -m)" != "x86_64" ]; then
    echo "Unsupported system architecture"
    exit 1
fi

if [ `whoami` != root ]; then
    echo "Please enter root's password below:"
    su -c "/opt/porteux-scripts/porteux-app-store/applications/opera.sh $1 $2 $3"
    exit 0
fi

if [ "$#" -lt 1 ]; then
    echo "Usage:   $0 [channel] [language] [optional: --activate-module]"
    echo "If no language is specified, en-US will be set"
    echo "Channels available: developer | beta | stable"
    echo ""
    echo "Example: $0 stable pt-BR"
    exit 1
fi

# Global variables
APP="opera"
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

    rm -rf "$pkg_dir"/usr/lib/
    rm -rf "$pkg_dir"/usr/lib64/opera*/opera_autoupdate*
    chromium_family_locale_striptease "$pkg_dir"/usr/lib64/opera*/localization
}

get_module_name(){
    local pkgver; pkgver="$2"
    local arch; arch="$3"

    echo "${APP}-${CHANNEL}-${pkgver}-${arch}-${LANGUAGE}_porteux"
}

finisher(){
    striptease "$APP" "$1"

    /opt/porteux-scripts/porteux-app-store/module-builder.sh $TMP/"$APP"/"$1" "$TARGET_DIR/${1}.xzm" "$ACTIVATEMODULE" || exit 1
    remove_application_temp_dir "$APP" "$2"
}

make_module_opera(){
    if [ "$CHANNEL" != "developer" ] && [ "$CHANNEL" != "beta" ] && [ "$CHANNEL" != "stable" ]; then echo "Non-existent channel. Options: developer | beta | stable" && exit 1; fi

    local pkg_name
    local pkg_name
    local product_name; product_name=$([ "$CHANNEL" == "stable" ] && echo "$APP" || echo "$APP-$CHANNEL")

    create_application_temp_dir "$APP" || exit 1

    $WGET_WITH_TIME_OUT -P $TMP/"$APP"/ -r -nd --no-parent https://rpm.opera.com/rpm/ -A opera_"$CHANNEL"-*.rpm || exit 1
    pkgver=$(find $TMP/"$APP" -name "opera_*.rpm" -exec basename {} \; | cut -d '-' -f2)
    pkg_name=$(get_module_name "$CHANNEL" "$pkgver" "x86_64")

    mv $TMP/"$APP"/opera_*.rpm $TMP/"$APP"/"$pkg_name".rpm
    mkdir -p "$TMP/$APP/$pkg_name" &&
    rpm2cpio "$TMP/$APP/${pkg_name}.rpm" | cpio -idmv -D "$TMP/$APP/$pkg_name" &&
    sed -i "s|TryExec=.*||g" "$TMP/$APP/$pkg_name/usr/share/applications/$product_name.desktop" &&
    sed -i "s|Exec=$product_name|Exec=$product_name --lang=$LANGUAGE|g" "$TMP/$APP/$pkg_name/usr/share/applications/$product_name.desktop" &&

    finisher "$pkg_name" "$pkgver"
}

# Main Code
make_module_opera
