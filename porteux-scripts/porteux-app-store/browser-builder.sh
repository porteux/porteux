#!/bin/bash

if [ "$(uname -m)" != "x86_64" ]; then
    echo "Unsupported system architecture"
    exit 1
fi

if [ `whoami` != root ]; then
	echo "Please enter root's password below:"
	su -c "/opt/porteux-scripts/porteux-app-store/browser-builder.sh $1 $2 $3 $4"
	exit 0
fi

if [ "$#" -lt 2 ]; then
    echo "Usage:   $0 [application] [channel] [language] [optional: --activate-module]"
    echo "If no language is specified, en-US will be set"
    echo "Channels available:"
    echo "chromium: developer | stable"
    echo "firefox: beta-latest | latest | esr-latest"
    echo "google-chrome: unstable | beta | stable"
    echo "opera: developer | beta | stable"
    echo "palemoon: stable"
    echo "vivaldi: snapshot | stable"
    echo ""
    echo "Example: $0 chromium stable pt-BR"
    echo "Example: $0 firefox esr-latest en-US"
    echo "Example: $0 palemoon stable"
    exit 1
fi

# Global variables
APP=$1
CHANNEL=$2
LANGUAGE=$([ "$3" ] && echo "$3" || echo "en-US")
ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")
TARGET_DIR="$PORTDIR/modules"
TMP="/tmp"
WGET_WITH_TIME_OUT="wget -T 5"

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

    if [ "$1" == "chromium" ]; then
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
    elif [ "$1" == "firefox" ]; then
        echo "Striptease not implement."
    elif [ "$1" == "google-chrome" ]; then
        find "$pkg_dir/usr/share" -mindepth 1 -maxdepth 1 -type d -not -name applications -exec rm -rf '{}' \;
        rm -rf "${pkg_dir:?}/etc"
        chromium_family_locale_striptease "$pkg_dir"/opt/google/chrome*/locales
    elif [ "$1" == "opera" ]; then
        rm -rf "$pkg_dir"/usr/lib/
        rm -rf "$pkg_dir"/usr/lib64/opera*/opera_autoupdate*
        chromium_family_locale_striptease "$pkg_dir"/usr/lib64/opera*/localization
    elif [ "$1" == "palemoon" ]; then
        rm -fv "$pkg_dir"/usr/lib64/palemoon/update*
    elif [ "$1" == "vivaldi" ]; then
        rm -rf "$pkg_dir/opt/vivaldi*/resources/vivaldi/default-bookmarks"
        chromium_family_locale_striptease "$pkg_dir"/opt/vivaldi*/locales
        find "$pkg_dir"/opt/vivaldi*/resources/vivaldi/_locales -mindepth 1 -maxdepth 1 -type d ! \( -name "en" -o -name "${LANGUAGE//-/_}" \) -exec rm -rf {} +
    else
        exit 1
    fi
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

get_repo_version_firefox(){
    local temp; temp=$(curl -s "https://download.mozilla.org/?product=firefox-${CHANNEL}-ssl&os=linux64&lang=${LANGUAGE}") || exit 1
    local ver; ver=$(echo "$temp" | grep -oP "releases/\K[^/]*")

    echo "$ver"
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
        echo "${ver[1]}"
    elif [ "$1" == "unstable" ]; then
        echo "${ver[2]}"
    else
        exit 1
    fi
}

get_repo_version_palemoon(){
    local temp; temp=$(curl -s "https://www.palemoon.org/download.shtml" | grep "linux-x86_64-gtk3") || exit 1
    local ver; ver=$(echo "$temp" | cut -d'-' -f2 | sed 's/\.linux//')

    echo "$ver"
}

get_repo_version_vivaldi(){
    local ver; ver=$(curl -s "https://repo.vivaldi.com/${CHANNEL}/rpm/x86_64/" | grep 'href=' | awk -F '"' '{print $2}' | \
    grep "$CHANNEL" | tail -n 1 | rev | cut -d '.' -f3- | rev | cut -d '-' -f3-) || exit 1

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

make_module_firefox(){
    if [ "$CHANNEL" != "beta-latest" ] && [ "$CHANNEL" != "latest" ] && [ "$CHANNEL" != "esr-latest" ]; then echo "Non-existent channel. Options: beta-latest | latest | esr-latest" && exit 1; fi

    local pkgver; pkgver=$(get_repo_version_firefox "$CHANNEL")
    local pkg_name; pkg_name=$(get_module_name "$CHANNEL" "$pkgver" "x86_64" "1")

    create_application_temp_dir "$APP"

    $WGET_WITH_TIME_OUT -O "$TMP/$APP/${pkg_name}.tar.bz2" "https://download.mozilla.org/?product=firefox-${CHANNEL}-ssl&os=linux64&lang=${LANGUAGE}" &&
    $WGET_WITH_TIME_OUT -P $TMP/"$APP" "http://ftp.slackware.com/pub/slackware/slackware64-current/source/xap/mozilla-firefox/mozilla-firefox.desktop" &&
    mkdir -p "$TMP/$APP/$pkg_name" &&
    tar -xvf "$TMP/$APP/${pkg_name}.tar.bz2" -C "$TMP/$APP/$pkg_name" &&
    mkdir -p "$TMP/$APP/$pkg_name/usr/bin" && mkdir -p "$TMP/$APP/$pkg_name/usr/lib64" && mkdir -p "$TMP/$APP/$pkg_name/usr/share/applications" &&

    mv -f "$TMP/$APP/$pkg_name/firefox" "$TMP/$APP/$pkg_name/firefox-${pkgver}" &&
    mv -f "$TMP/$APP/$pkg_name/firefox-${pkgver}" $TMP/"$APP"/"$pkg_name"/usr/lib64 &&
    cd "$TMP/$APP/$pkg_name/usr/lib64" && ln -sf "firefox-${pkgver}/" firefox &&
    cd "$TMP/$APP/$pkg_name/usr/bin" && ln -sf "../lib64/firefox/firefox" firefox &&
    mv -f "$TMP/$APP/mozilla-firefox.desktop" "$TMP/$APP/$pkg_name/usr/share/applications" &&
    mkdir -p "$TMP/$APP/$pkg_name/usr/lib64/firefox/distribution" 2> /dev/null
    cat > "$TMP/$APP/$pkg_name/usr/lib64/firefox/distribution/policies.json" << EOF
{
"policies": 
{
"DisableAppUpdate": true,
"DisableTelemetry": true,
"DisablePocket": true
}
}
EOF

    cat > "$TMP/$APP/$pkg_name/usr/lib64/firefox/distribution/distribution.ini" << EOF
[Preferences]
app.update.auto=false
app.update.enabled=false
browser.startup.firstrunSkipsHomepage=false
browser.shell.checkDefaultBrowser=false
app.shield.optoutstudies.enabled=false
EOF

    finisher "$pkg_name" "$pkgver"
}

make_module_google_chrome(){
    if [ "$CHANNEL" != "unstable" ] && [ "$CHANNEL" != "beta" ] && [ "$CHANNEL" != "stable" ]; then echo "Non-existent channel. Options: unstable | beta | stable" && exit 1; fi

    local pkgver; pkgver=$(get_repo_version_google_chrome "$CHANNEL")
    local pkg_name; pkg_name=$(get_module_name "$CHANNEL" "$pkgver" "x86_64" "1")
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
    $WGET_WITH_TIME_OUT -O "$TMP/$APP/$pkg_name.deb" "https://dl.google.com/linux/chrome/deb/pool/main/g/${APP}-${CHANNEL}/${APP}-${CHANNEL}_${pkgver}-1_amd64.deb" &&
    ar p "$TMP/$APP/$pkg_name.deb" data.tar.xz | tar xJv -C "$TMP/$APP/$pkg_name" || exit 1
    sed -i "s|TryExec=.*||g" "$TMP/$APP/$pkg_name/usr/share/applications/$product_name.desktop" &&
    sed -i "s|Exec=/usr/bin/|Exec=|g" "$TMP/$APP/$pkg_name/usr/share/applications/$product_name.desktop" &&
    sed -i "s|Exec=$APP-$CHANNEL|Exec=env LANGUAGE=$LANGUAGE $APP-$CHANNEL|g" "$TMP/$APP/$pkg_name/usr/share/applications/$product_name.desktop" &&
    sed -i "s|Icon=.*|Icon=/opt/google/$product_folder/product_logo_128$icon_channel.png|g" "$TMP/$APP/$pkg_name/usr/share/applications/$product_name.desktop" &&

    finisher "$pkg_name" "$pkgver"
}

make_module_opera(){
    if [ "$CHANNEL" != "developer" ] && [ "$CHANNEL" != "beta" ] && [ "$CHANNEL" != "stable" ]; then echo "Non-existent channel. Options: developer | beta | stable" && exit 1; fi

    local pkg_name
    local pkg_name
    local product_name; product_name=$([ "$CHANNEL" == "stable" ] && echo "$APP" || echo "$APP-$CHANNEL")

    create_application_temp_dir "$APP" || exit 1
    
    $WGET_WITH_TIME_OUT -P $TMP/"$APP"/ -r -nd --no-parent https://rpm.opera.com/rpm/ -A opera_"$CHANNEL"-*.rpm || exit 1
    pkgver=$(find $TMP/"$APP" -name "opera_*.rpm" -exec basename {} \; | cut -d '-' -f2)
    pkg_name=$(get_module_name "$CHANNEL" "$pkgver" "x86_64" "1")
    
    mv $TMP/"$APP"/opera_*.rpm $TMP/"$APP"/"$pkg_name".rpm
    mkdir -p "$TMP/$APP/$pkg_name" &&
    rpm2cpio "$TMP/$APP/${pkg_name}.rpm" | cpio -idmv -D "$TMP/$APP/$pkg_name" &&
    sed -i "s|TryExec=.*||g" "$TMP/$APP/$pkg_name/usr/share/applications/$product_name.desktop" &&
    sed -i "s|Exec=$product_name|Exec=$product_name --lang=$LANGUAGE|g" "$TMP/$APP/$pkg_name/usr/share/applications/$product_name.desktop" &&

    finisher "$pkg_name" "$pkgver"
}

make_module_palemoon(){
    if [ "$CHANNEL" != "stable" ]; then echo "Non-existent channel. Options: stable" && exit 1; fi

    local pkgver; pkgver=$(get_repo_version_palemoon "$CHANNEL")
    local pkg_name; pkg_name=$(get_module_name "$CHANNEL" "$pkgver" "x86_64" "1")

    create_application_temp_dir "$APP" || exit 1

    $WGET_WITH_TIME_OUT -O "$TMP/$APP/${pkg_name}.tar.xz" "https://rm-us.palemoon.org/release/palemoon-${pkgver}.linux-x86_64-gtk3.tar.xz" &&
    mkdir -p "$TMP/$APP/$pkg_name" &&
    tar -xvf "$TMP/$APP/${pkg_name}.tar.xz" -C "$TMP/$APP/$pkg_name" &&
    mkdir -p "$TMP/$APP/$pkg_name/usr/bin" && mkdir -p "$TMP/$APP/$pkg_name/usr/lib64" && mkdir -p "$TMP/$APP/$pkg_name/usr/share/applications" &&

    mv -f "$TMP/$APP/$pkg_name/palemoon" "$TMP/$APP/$pkg_name/palemoon-${pkgver}" &&
    mv -f "$TMP/$APP/$pkg_name/palemoon-${pkgver}" $TMP/"$APP"/"$pkg_name"/usr/lib64 &&
    cd "$TMP/$APP/$pkg_name/usr/lib64" && ln -sf "palemoon-${pkgver}/" palemoon &&
    cd "$TMP/$APP/$pkg_name/usr/bin" && ln -sf "../lib64/palemoon/palemoon" palemoon &&

    cat > "$TMP/$APP/$pkg_name/usr/share/applications/$APP.desktop" << EOF
[Desktop Entry]
Version=1.0
Name=Pale Moon Web Browser
Comment=Browse the World Wide Web
Keywords=Internet;WWW;Browser;Web;Explorer
Exec=palemoon %u
Terminal=false
X-MultipleArgs=false
Type=Application
Icon=palemoon
Categories=Network;WebBrowser;Internet;GTK;
MimeType=text/html;application/xhtml+xml;application/xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;x-scheme-handler/chrome;video/webm;application/x-xpinstall;
StartupNotify=true
EOF

    finisher "$pkg_name" "$pkgver"
}

make_module_vivaldi(){
    if [ "$CHANNEL" != "snapshot" ] && [ "$CHANNEL" != "stable" ]; then echo "Non-existent channel. Options: snapshot | stable" && exit 1; fi

    local pkgver; pkgver=$(get_repo_version_vivaldi "$CHANNEL")
    local pkg_name; pkg_name=$(get_module_name "$CHANNEL" "$pkgver" "x86_64" "1")
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
if [ "$APP" == "chromium" ]; then
    make_module_chromium
elif [ "$APP" == "firefox" ]; then
    make_module_firefox
elif [ "$APP" == "google-chrome" ]; then
    make_module_google_chrome
elif [ "$APP" == "opera" ]; then
    make_module_opera
elif [ "$APP" == "palemoon" ]; then
    make_module_palemoon
elif [ "$APP" == "vivaldi" ]; then
    make_module_vivaldi
else
    echo "Invalid application. Please choose chromium, firefox, google-chrome, opera, palemoon or vivaldi."
    exit 1
fi
