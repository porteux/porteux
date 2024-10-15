#!/bin/bash

if [ "$(uname -m)" != "x86_64" ]; then
    echo "Unsupported system architecture"
    exit 1
fi

if [ "$(whoami)" != root ]; then
    echo "Please enter root's password below:"
    su -c "/opt/porteux-scripts/porteux-app-store/applications/tor.sh $1 $2 $3"
    exit 0
fi

if [ "$#" -lt 1 ]; then
    echo "Usage:   $0 [channel] [language] [optional: --activate-module]"
    echo "If no language is specified, en-US will be set"
    echo "Channels available: stable | alpha"
    echo ""
    echo "Example: $0 stable en-US"
    exit 1
fi

# Global variables
CURRENTUSER=$(loginctl user-status | head -n 1 | cut -d" " -f1)
CURRENTGROUP=$(id -gn "$CURRENTUSER")
APP="tor"
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

get_module_name(){
    local pkgver; pkgver="$2"
    local arch; arch="$3"

    echo "${APP}-${CHANNEL}-${pkgver}-${arch}-${LANGUAGE}"
}

striptease(){
    rm -rf "$TMP/$APP/$pkg_name/opt/${tor_folder}/Browser/TorBrowser/Docs"
    find "$TMP/$APP/$pkg_name/opt/${tor_folder}/Browser/fonts" -mindepth 1 -maxdepth 1 ! \( -name "TwemojiMozilla.ttf" -o -name "Arimo-Regular.ttf" \) -exec rm -rf '{}' \; 2>/dev/null

    local prefs_file="$TMP/$APP/$pkg_name/opt/${tor_folder}/Browser/TorBrowser/Data/Browser/profile.default/prefs.js"

    echo 'user_pref("app.update.enabled", false);' | sudo -u "$CURRENTUSER" tee -a "$prefs_file" > /dev/null
    echo 'user_pref("app.update.auto", false);' | sudo -u "$CURRENTUSER" tee -a "$prefs_file" > /dev/null
    echo 'user_pref("intl.language_notification.shown", true);' | sudo -u "$CURRENTUSER" tee -a "$prefs_file" > /dev/null
    
    cat > "$TMP/$APP/$pkg_name/opt/${tor_folder}/Browser/distribution/policies.json" << EOF
{
"policies":
{
"DisableAppUpdate": true,
"DisableTelemetry": true,
"DisablePocket": true
}
}
EOF
}

finisher(){
    /opt/porteux-scripts/porteux-app-store/module-builder.sh $TMP/"$APP"/"$1" "$TARGET_DIR/${1}.xzm" "$ACTIVATEMODULE" || exit 1
    remove_application_temp_dir "$APP" "$2"
}

get_repo_version_tor(){
    local ver;
    local url="https://archive.torproject.org/tor-package-archive/torbrowser/"

    if [ "$CHANNEL" = "stable" ]; then
        ver=$(curl -s "$url" | grep -oP '(?<=<a href=")[0-9]+\.[0-9]+\.[0-9]+(?=/)' | sort -Vr | head -n 1)
    elif [ "$CHANNEL" = "alpha" ]; then
        ver=$(curl -s "$url" | grep -oP '(?<=<a href=")[^"]*a[0-9]+(?=/")' | sort -Vr | head -n 1)
    fi

    echo "$ver"
}

make_module_tor(){
    if [ "$CHANNEL" != "stable" ] && [ "$CHANNEL" != "alpha" ]; then echo "Non-existent channel. Options: stable | alpha" && exit 1; fi

    local pkgver; pkgver=$(get_repo_version_tor "$CHANNEL")
    local pkg_name; pkg_name=$(get_module_name "$CHANNEL" "$pkgver" "x86_64")
    local tor_folder; tor_folder="tor-browser-${CHANNEL}"

    create_application_temp_dir "$APP"

    $WGET_WITH_TIME_OUT -O "$TMP/$APP/${pkg_name}.tar.xz" "https://archive.torproject.org/tor-package-archive/torbrowser/${pkgver}/tor-browser-linux-x86_64-${pkgver}.tar.xz" &&
    mkdir -p "$TMP/$APP/$pkg_name" && mkdir -p "$TMP/$APP/$pkg_name/usr/share/applications" && mkdir -p "$TMP/$APP/$pkg_name/opt" &&
    tar -xvf "$TMP/$APP/${pkg_name}.tar.xz" -C "$TMP/$APP/$pkg_name/opt" &&
    mv "$TMP/$APP/$pkg_name/opt/tor-browser" "$TMP/$APP/$pkg_name/opt/${tor_folder}" &&
    chown -R "$CURRENTUSER":"$CURRENTGROUP" "$TMP/$APP/$pkg_name/opt/${tor_folder}" &&
    
    if [ "$CHANNEL" = "stable" ]; then
        sed -i "/^Name=/c\Name=Tor Browser" "$TMP/$APP/$pkg_name/opt/${tor_folder}/start-tor-browser.desktop"
    else
        sed -i "/^Name=/c\Name=Tor Browser ${CHANNEL^}" "$TMP/$APP/$pkg_name/opt/${tor_folder}/start-tor-browser.desktop"
    fi

    sed -i "/^Exec=/c\Exec=sh -c '/opt/${tor_folder}/Browser/firefox --detach'" "$TMP/$APP/$pkg_name/opt/${tor_folder}/start-tor-browser.desktop" &&
    sed -i "/^Icon=/c\Icon=/opt/${tor_folder}/Browser/browser/chrome/icons/default/default128.png" "$TMP/$APP/$pkg_name/opt/${tor_folder}/start-tor-browser.desktop" &&
    ln -s "/opt/${tor_folder}/start-tor-browser.desktop" "$TMP/$APP/$pkg_name/usr/share/applications/start-tor-browser-${CHANNEL}.desktop" &&
    
    striptease &&
    finisher "$pkg_name" "$pkgver"
}

# Main Code
make_module_tor
