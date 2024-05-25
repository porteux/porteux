#!/bin/bash

if [ "$(uname -m)" != "x86_64" ]; then
    echo "Unsupported system architecture"
    exit 1
fi

if [ `whoami` != root ]; then
    echo "Please enter root's password below:"
    su -c "/opt/porteux-scripts/porteux-app-store/applications/palemoon.sh $1 $2 $3"
    exit 0
fi

if [ "$#" -lt 1 ]; then
    echo "Usage:   $0 [channel] [language] [optional: --activate-module]"
    echo "If no language is specified, en-US will be set"
    echo "Channels available: stable"
    echo ""
    echo "Example: $0 stable en-US"
    exit 1
fi

# Global variables
APP="palemoon"
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

striptease(){
    local pkg_dir="$TMP/$1/$2"

    rm -fv "$pkg_dir"/usr/lib64/palemoon/update*
}

get_module_name(){
    local pkgver; pkgver="$2"
    local arch; arch="$3"

    echo "${APP}-${CHANNEL}-${pkgver}-${arch}"
}

set_sane_defaults(){
    local pkg_dir="$TMP/$1/$2"
    local porteux_version=$(cat /etc/os-release | grep VERSION= | cut -d \" -f 2)

    mkdir -p "$pkg_dir"/usr/lib64/${APP}/distribution/
    cat >> "$pkg_dir"/usr/lib64/${APP}/distribution/distribution.ini << EOF
[Global]
id=PorteuX
version=${porteux_version}
about=Palemoon for PorteuX

[Preferences]
app.update.auto=false
app.update.enabled=false
EOF
}

add_language_pack(){
    if [ ! ${LANGUAGE} = "en-US" ]; then
        local pkg_dir="$TMP/$1/$2"
        mkdir -p "$pkg_dir"/usr/lib64/${APP}/distribution/extensions

        curl --silent --user-agent 'PaleMoon' --output "$pkg_dir/usr/lib64/${APP}/distribution/extensions/langpack-${LANGUAGE}@palemoon.org.xpi" "https://addons.palemoon.org/?component=download&id=langpack-${LANGUAGE}@palemoon.org"
        chmod 644 "$pkg_dir/usr/lib64/${APP}/distribution/extensions/langpack-${LANGUAGE}@palemoon.org.xpi"

        cat >> "$pkg_dir"/usr/lib64/${APP}/distribution/distribution.ini << EOF
general.useragent.locale="${LANGUAGE}"
EOF
    fi
}

finisher(){
    striptease "$APP" "$1"

    /opt/porteux-scripts/porteux-app-store/module-builder.sh $TMP/"$APP"/"$1" "$TARGET_DIR/${1}.xzm" "$ACTIVATEMODULE" || exit 1
    remove_application_temp_dir "$APP" "$2"
}

get_repo_version_palemoon(){
    local temp; temp=$(curl -s "https://www.palemoon.org/download.shtml" | grep "linux-x86_64-gtk3") || exit 1
    local ver; ver=$(echo "$temp" | cut -d'-' -f2 | sed 's/\.linux//')

    echo "$ver"
}

make_module_palemoon(){
    if [ "$CHANNEL" != "stable" ]; then echo "Non-existent channel. Options: stable" && exit 1; fi

    local pkgver; pkgver=$(get_repo_version_palemoon "$CHANNEL")
    local pkg_name; pkg_name=$(get_module_name "$CHANNEL" "$pkgver" "x86_64")

    create_application_temp_dir "$APP" || exit 1

    $WGET_WITH_TIME_OUT -O "$TMP/$APP/${pkg_name}.tar.xz" "https://rm-us.palemoon.org/release/palemoon-${pkgver}.linux-x86_64-gtk3.tar.xz" &&
    mkdir -p "$TMP/$APP/$pkg_name" &&
    tar -xvf "$TMP/$APP/${pkg_name}.tar.xz" -C "$TMP/$APP/$pkg_name" &&
    mkdir -p "$TMP/$APP/$pkg_name/usr/bin" && mkdir -p "$TMP/$APP/$pkg_name/usr/lib64" && mkdir -p "$TMP/$APP/$pkg_name/usr/share/applications" &&

    mv -f "$TMP/$APP/$pkg_name/palemoon" "$TMP/$APP/$pkg_name/palemoon-${pkgver}" &&
    mv -f "$TMP/$APP/$pkg_name/palemoon-${pkgver}" $TMP/"$APP"/"$pkg_name"/usr/lib64 &&
    cd "$TMP/$APP/$pkg_name/usr/lib64" && ln -sf "palemoon-${pkgver}/" palemoon &&
    cd "$TMP/$APP/$pkg_name/usr/bin" && ln -sf "../lib64/palemoon/palemoon" palemoon &&

    set_sane_defaults "$APP" "$pkg_name"

    add_language_pack "$APP" "$pkg_name"

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

# Main Code
make_module_palemoon
