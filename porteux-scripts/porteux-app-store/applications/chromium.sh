#!/bin/bash

if [ "$(uname -m)" != "x86_64" ]; then
    echo "Unsupported system architecture"
    exit 1
fi

if [ `whoami` != root ]; then
	echo "Please enter root's password below:"
	su -c "/opt/porteux-scripts/porteux-app-store/applications/chromium.sh $1 $2 $3"
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
APP="chromium"
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
    rm -f "$TMP/${1}-${2}-x86_64-1.txz"
    rm -rf "${TMP:?}/package-${1}"
}

chromium_family_locale_striptease(){
    local locale_dir="$1"
    
    find "$locale_dir" -mindepth 1 -maxdepth 1 \( -type f -o -type d \) ! \( -name "en-US.*" -o -name "en_US.*" -o -name "$LANGUAGE.*" \) -delete
}

striptease(){
    local pkg_dir="$TMP/$1/$2"

		declare -a targets=("executable" "shared object")
		for target in "${targets[@]}"
		do
				find "$pkg_dir" -print0 | xargs -0 file | grep "$target" | grep ELF | cut -f 1 -d : | \
						xargs strip -S --strip-unneeded --remove-section=.note.gnu.gold-version --remove-section=.comment \
						--remove-section=.note --remove-section=.note.gnu.build-id --remove-section=.note.ABI-tag 2> /dev/null
				find "$pkg_dir" -exec file {} +
		done
		find "$pkg_dir" -name "chromedriver" -type f -delete
		rm "$pkg_dir"/usr/lib64/chromium/locales/*.info
		chromium_family_locale_striptease "$pkg_dir"/usr/lib64/chromium*/locales
}

get_module_name(){
    local pkgver; pkgver="$2"    
    local arch; arch="$3"
    local build; build="$4"

    echo "${APP}-${CHANNEL}-${pkgver}-${arch}-${build}"
}

finisher(){
    striptease "$APP" "$1"

    /opt/porteux-scripts/porteux-app-store/module-builder.sh $TMP/"$APP"/"$1" "$TARGET_DIR/${1}.xzm" "$ACTIVATEMODULE" || exit 1
    remove_application_temp_dir "$APP" "$2"
}

get_repo_version_chromium(){
    if [ "$CHANNEL" == "stable" ]; then
        local repo_id='clickot/ungoogled-chromium-binaries'
        local ver; ver=$(curl -s "https://api.github.com/repos/${repo_id}/releases/latest" | grep "\"tag_name\":" | cut -d \" -f 4) || exit 1
    elif [ "$CHANNEL" == "developer" ]; then
        local ver; ver=$(curl -s "https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2FLAST_CHANGE?alt=media") || exit 1
    else
        exit 1
    fi
    
    echo "$ver"
}

make_module_chromium(){
    if [ "$CHANNEL" != "developer" ] && [ "$CHANNEL" != "stable" ]; then echo "Non-existent channel. Options: developer | stable" && exit 1; fi

    local pkgver; pkgver=$(get_repo_version_chromium "$CHANNEL")
    local pkg_name; pkg_name=$(get_module_name "$CHANNEL" "$pkgver" "x86_64" "1")
    local product_name; product_name=$([ "$CHANNEL" == "stable" ] && echo "$APP" || echo "$APP-$CHANNEL")

    create_application_temp_dir "$APP" && mkdir -p "$TMP/$APP/$pkg_name" || exit 1

    if [ "$CHANNEL" == "developer" ]; then
        $WGET_WITH_TIME_OUT -O "$TMP/$APP/${pkg_name}.zip" "https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F${pkgver}%2Fchrome-linux.zip?alt=media" &&
        unzip -a "$TMP/$APP/${pkg_name}.zip" -d "$TMP/$APP/$pkg_name" &&
        mv -f "$TMP/$APP/$pkg_name/chrome-linux" "$TMP/$APP/$pkg_name/$APP-$CHANNEL-${pkgver}" || exit 1
    elif [ "$CHANNEL" == "stable" ]; then
        $WGET_WITH_TIME_OUT -O "$TMP/$APP/${pkg_name}.tar.xz" "https://github.com/clickot/ungoogled-chromium-binaries/releases/download/${pkgver}/ungoogled-chromium_${pkgver}.1_linux.tar.xz" &&
        tar -xvf "$TMP/$APP/${pkg_name}.tar.xz" -C "$TMP/$APP/$pkg_name" &&
        mv -f "$TMP/$APP/$pkg_name/ungoogled-chromium_${pkgver}.1_linux" "$TMP/$APP/$pkg_name/$APP-$CHANNEL-${pkgver}" || exit 1
    else
        exit 1
    fi
    
    mkdir -p "$TMP/$APP/$pkg_name/usr/bin" && mkdir -p "$TMP/$APP/$pkg_name/usr/lib64" && mkdir -p "$TMP/$APP/$pkg_name/usr/share/applications" &&
    mv -f "$TMP/$APP/$pkg_name/$APP-$CHANNEL-${pkgver}" "$TMP/$APP/$pkg_name/usr/lib64" &&
    cd "$TMP/$APP/$pkg_name/usr/lib64" && ln -sf "$APP-$CHANNEL-${pkgver}/" "$product_name" &&
    cd "$TMP/$APP/$pkg_name/usr/bin" && ln -sf "../lib64/$product_name/chrome" "$product_name" &&
    $WGET_WITH_TIME_OUT -O "$TMP/$APP/$pkg_name/usr/share/applications/$product_name.desktop" "https://slackware.nl/people/alien/slackbuilds/chromium/build/chromium.desktop" &&
    sed -i "s|TryExec=.*||g" "$TMP/$APP/$pkg_name/usr/share/applications/$product_name.desktop" &&
    sed -i "s|Exec=$APP|Exec=env LANGUAGE=$LANGUAGE $product_name|g" "$TMP/$APP/$pkg_name/usr/share/applications/$product_name.desktop" &&

    finisher "$pkg_name" "$pkgver"
}

make_module_chromium