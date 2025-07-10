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
    echo "Channels available: stable | esr | beta"
    echo ""
    echo "Example: $0 esr en-US"
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
    rm -f "$TMP/${1}-${2}-x86_64.txz"
    rm -rf "${TMP:?}/package-${1}"
}

get_module_name(){
    local pkgver; pkgver="$2"
    local arch; arch="$3"

    echo "${APP}-${CHANNEL}-${pkgver}-${arch}-${LANGUAGE}"
}

finisher(){
    /opt/porteux-scripts/porteux-app-store/module-builder.sh $TMP/"$APP"/"$1" "$TARGET_DIR/${1}.xzm" "$ACTIVATEMODULE" || exit 1
    remove_application_temp_dir "$APP" "$2"
}

get_repo_version_firefox(){
	local ver;
	if [ $CHANNEL = "stable" ]; then
		ver=$(curl -s "https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=${LANGUAGE}" | grep -oP 'releases/\K[^/]*')
	elif [ $CHANNEL = "esr" ]; then
		ver=$(curl -s https://ftp.mozilla.org/pub/firefox/releases/ | grep -oP '(?<=releases/)\d[^/]+(?=/")' | grep 'esr' | sort -V -r | head -1)
	elif [ $CHANNEL = "beta" ]; then
		ver=$(curl -s https://ftp.mozilla.org/pub/firefox/releases/ | grep -oP '(?<=releases/)\d[^/]+(?=/")' | grep 'b[0-9]$' | sort -V -r | head -1)
    fi

    echo "$ver"
}

make_module_firefox(){
    if [ "$CHANNEL" != "stable" ] && [ "$CHANNEL" != "esr" ] && [ "$CHANNEL" != "beta" ]; then echo "Non-existent channel. Options: stable | esr | beta" && exit 1; fi

    local pkgver; pkgver=$(get_repo_version_firefox "$CHANNEL")
    local pkg_name; pkg_name=$(get_module_name "$CHANNEL" "$pkgver" "x86_64")
    local package_extension="tar.xz"
    local major_version=$(echo $pkgver | cut -f 1 -d .)
    
    if [ "$major_version" -le 128 ]; then
        package_extension="tar.bz2"
    fi

    create_application_temp_dir "$APP"

    $WGET_WITH_TIME_OUT -O "$TMP/$APP/${pkg_name}.${package_extension}" "https://ftp.mozilla.org/pub/firefox/releases/${pkgver}/linux-x86_64/${LANGUAGE}/firefox-${pkgver}.${package_extension}" &&

    mkdir -p "$TMP/$APP/$pkg_name" &&
    tar -xvf "$TMP/$APP/${pkg_name}.${package_extension}" -C "$TMP/$APP/$pkg_name" &&
    mkdir -p "$TMP/$APP/$pkg_name/usr/bin" && mkdir -p "$TMP/$APP/$pkg_name/usr/lib64" && mkdir -p "$TMP/$APP/$pkg_name/usr/share/applications" &&

    mv -f "$TMP/$APP/$pkg_name/firefox" "$TMP/$APP/$pkg_name/firefox-${CHANNEL}" &&
    mv -f "$TMP/$APP/$pkg_name/firefox-${CHANNEL}" $TMP/"$APP"/"$pkg_name"/usr/lib64 &&
    cd "$TMP/$APP/$pkg_name/usr/lib64" && ln -sf "firefox-${CHANNEL}/" firefox &&
    cd "$TMP/$APP/$pkg_name/usr/bin" && ln -sf "../lib64/firefox/firefox" firefox &&
    cat > "$TMP/$APP/$pkg_name/usr/share/applications/firefox.desktop" << EOF    
[Desktop Entry]
Exec=firefox %u
Icon=firefox
Type=Application
Categories=Network;WebBrowser;
Name=Firefox
GenericName=Web Browser
MimeType=text/html;text/xml;application/xhtml+xml;application/vnd.mozilla.xul+xml;text/mml;x-scheme-handler/http;x-scheme-handler/https;
EOF

    if [ "$CHANNEL" != "stable" ]; then
        if [ "$CHANNEL" = "esr" ]; then
            sed -i "s/^Name.*/& ${CHANNEL^^}/" "$TMP/$APP/$pkg_name/usr/share/applications/firefox.desktop"
        else
            sed -i "s/^Name.*/& ${CHANNEL^}/" "$TMP/$APP/$pkg_name/usr/share/applications/firefox.desktop"
        fi
        mv "$TMP/$APP/$pkg_name/usr/share/applications/firefox.desktop" "$TMP/$APP/$pkg_name/usr/share/applications/firefox-${CHANNEL}.desktop"
    fi
    
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
