#!/bin/bash

if [ "$(uname -m)" != "x86_64" ]; then
    echo "Unsupported system architecture"
    exit 1
fi

if [ `whoami` != root ]; then
    echo "Please enter root's password below:"
    su -c "/opt/porteux-scripts/porteux-app-store/applications/firefox.sh $1 $2 $3"
    exit 0
fi

if [ "$#" -lt 1 ]; then
    echo "Usage:   $0 [channel] [language] [optional: --activate-module]"
    echo "If no language is specified, en-US will be set"
    echo "Channels available: beta-latest | latest | esr-latest"
    echo ""
    echo "Example: $0 esr-latest en-US"
    exit 1
fi

# Global variables
APP="firefox"
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

get_module_name(){
    local pkgver; pkgver="$2"
    local arch; arch="$3"
    local build; build="$4"

    echo "${APP}-${CHANNEL}-${pkgver}-${arch}-${build}"
}

finisher(){
    /opt/porteux-scripts/porteux-app-store/module-builder.sh $TMP/"$APP"/"$1" "$TARGET_DIR/${1}.xzm" "$ACTIVATEMODULE" || exit 1
    remove_application_temp_dir "$APP" "$2"
}

get_repo_version_firefox(){
    local temp; temp=$(curl -s "https://download.mozilla.org/?product=firefox-${CHANNEL}-ssl&os=linux64&lang=${LANGUAGE}") || exit 1
    local ver; ver=$(echo "$temp" | grep -oP "releases/\K[^/]*")

    echo "$ver"
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

# Main Code
make_module_firefox
