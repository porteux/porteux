#!/bin/bash

if [ "$(uname -m)" != "x86_64" ]; then
    echo "Unsupported system architecture"
    exit 1
fi

if [ `whoami` != root ]; then
    echo "Please enter root's password below:"
    su -c "/opt/porteux-scripts/porteux-app-store/applications/chrome.sh $1 $2 $3"
    exit 0
fi

if [ "$#" -lt 1 ]; then
    echo "Usage:   $0 [channel] [language] [optional: --activate-module]"
    echo "If no language is specified, en-US will be set"
    echo "Channels available: stable | unstable | beta"
    echo ""
    echo "Example: $0 stable pt-BR"
    exit 1
fi

# Global variables
APP="google-chrome"
FRIENDLYPACKAGENAME="chrome"
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

        find "$pkg_dir/usr/share" -mindepth 1 -maxdepth 1 -type d -not -name applications -exec rm -rf '{}' \;
        rm -rf "${pkg_dir:?}/etc"
        chromium_family_locale_striptease "$pkg_dir"/opt/google/chrome*/locales
}

get_module_name(){
    local pkgver; pkgver="$2"
    local arch; arch="$3"

    echo "${FRIENDLYPACKAGENAME}-${CHANNEL}-${LANGUAGE}-${pkgver}-${arch}_porteux"
}

finisher(){
    striptease "$APP" "$1"

    /opt/porteux-scripts/porteux-app-store/module-builder.sh $TMP/"$APP"/"$1" "$TARGET_DIR/${1}.xzm" "$ACTIVATEMODULE" || exit 1
    remove_application_temp_dir "$APP" "$2"
}

get_repo_version_google_chrome(){
    local ver=()

    local versions; versions=$(curl -s https://dl.google.com/linux/chrome/rpm/stable/x86_64/repodata/other.xml.gz | \
        gzip -df | grep -o 'ver="[^"]*"') || exit 1
    for version in $versions; do
        temp=$(echo "$version" | sed -r 's/ver="([^"]*)"/\1/')
        ver+=("$temp")
    done

    if [ "$1" == "beta" ]; then
        echo "${ver[0]}"
    elif [ "$1" == "stable" ]; then
        echo "${ver[2]}"
    elif [ "$1" == "unstable" ]; then
        echo "${ver[3]}"
    else
        exit 1
    fi
}

make_module_google_chrome(){
    if [ "$CHANNEL" != "unstable" ] && [ "$CHANNEL" != "beta" ] && [ "$CHANNEL" != "stable" ]; then echo "Non-existent channel. Options: unstable | beta | stable" && exit 1; fi

    local pkgver; pkgver=$(get_repo_version_google_chrome "$CHANNEL")
    local pkg_name; pkg_name=$(get_module_name "$CHANNEL" "$pkgver" "x86_64")
    local product_name; product_name=$([ "$CHANNEL" == "stable" ] && echo "$APP" || echo "$APP-$CHANNEL")
    local product_folder; product_folder=$([ "$CHANNEL" == "stable" ] && echo "chrome" || echo "chrome-$CHANNEL")
    local icon_channel=''
    if [ "$CHANNEL" == "beta" ]; then
        icon_channel="_beta"
    elif [ "$CHANNEL" == "unstable" ]; then
        icon_channel="_dev"
    fi

    create_application_temp_dir "$APP"

    mkdir -p "$TMP/$APP/$pkg_name" &&
    $WGET_WITH_TIME_OUT -O "$TMP/$APP/$pkg_name.deb" "https://dl.google.com/linux/direct/${APP}-${CHANNEL}_current_amd64.deb" &&
    ar p "$TMP/$APP/$pkg_name.deb" data.tar.xz | tar xJv -C "$TMP/$APP/$pkg_name" || exit 1
    sed -i "s|TryExec=.*||g" "$TMP/$APP/$pkg_name/usr/share/applications/$product_name.desktop" &&
    sed -i "s|Exec=/usr/bin/|Exec=|g" "$TMP/$APP/$pkg_name/usr/share/applications/$product_name.desktop" &&
    sed -i "s|Exec=$APP-$CHANNEL|Exec=env LANGUAGE=$LANGUAGE $APP-$CHANNEL|g" "$TMP/$APP/$pkg_name/usr/share/applications/$product_name.desktop" &&
    sed -i "s|Icon=.*|Icon=/opt/google/$product_folder/product_logo_128$icon_channel.png|g" "$TMP/$APP/$pkg_name/usr/share/applications/$product_name.desktop" &&

    finisher "$pkg_name" "$pkgver"
}

# Main Code
make_module_google_chrome
