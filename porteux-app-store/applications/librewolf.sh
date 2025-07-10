#!/bin/bash

if [ "$(uname -m)" != "x86_64" ]; then
    echo "Unsupported system architecture"
    exit 1
fi

if [ `whoami` != root ]; then
    echo "Please enter root's password below:"
    su -c "/opt/porteux-scripts/porteux-app-store/applications/librewolf.sh $1 $2 $3"
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
APP="librewolf"
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

get_repo_version_librewolf(){
	local ver;
	if [ $CHANNEL = "stable" ]; then
		ver=$(curl -s https://gitlab.com/librewolf-community/browser/bsys6/-/releases.atom | grep "<title>" | grep -v "releases" | cut -d ">" -f 2 | cut -d "<" -f 1 | sort -Vr | head -1)
    fi

    echo "$ver"
}

make_module_librewolf(){
    if [ "$CHANNEL" != "stable" ]; then echo "Non-existent channel. Options: stable" && exit 1; fi

    local pkgver; pkgver=$(get_repo_version_librewolf "$CHANNEL")
    local pkg_name; pkg_name=$(get_module_name "$CHANNEL" "$pkgver" "x86_64")
    local package_extension="tar.xz"
    local major_version=$(echo $pkgver | cut -f 1 -d .)

    create_application_temp_dir "$APP"

    $WGET_WITH_TIME_OUT -O "$TMP/$APP/${pkg_name}.${package_extension}" "https://gitlab.com/api/v4/projects/44042130/packages/generic/librewolf/${pkgver}/librewolf-${pkgver}-linux-x86_64-package.${package_extension}" &&
    mkdir -p "$TMP/$APP/$pkg_name" &&
    tar -xvf "$TMP/$APP/${pkg_name}.${package_extension}" -C "$TMP/$APP/$pkg_name" &&
    mkdir -p "$TMP/$APP/$pkg_name/usr/bin" && mkdir -p "$TMP/$APP/$pkg_name/usr/lib64" && mkdir -p "$TMP/$APP/$pkg_name/usr/share/applications" &&

    mv -f "$TMP/$APP/$pkg_name/${APP}" "$TMP/$APP/$pkg_name/${APP}-${CHANNEL}" &&
    mv -f "$TMP/$APP/$pkg_name/${APP}-${CHANNEL}" $TMP/"$APP"/"$pkg_name"/usr/lib64 &&
    cd "$TMP/$APP/$pkg_name/usr/lib64" && ln -sf "${APP}-${CHANNEL}/" ${APP} &&
    cd "$TMP/$APP/$pkg_name/usr/bin" && ln -sf "../lib64/${APP}/${APP}" ${APP} &&
    
    mkdir -p "$TMP/$APP/$pkg_name/usr/lib64/${APP}/distribution" 2> /dev/null
    cat > "$TMP/$APP/$pkg_name/usr/share/applications/librewolf.desktop" << EOF
[Desktop Entry]
Exec=librewolf %u
Icon=librewolf
Type=Application
Categories=Network;WebBrowser;
Name=Librewolf
GenericName=Web Browser
MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;application/x-xpinstall;application/pdf;application/json;
EOF

    cat > "$TMP/$APP/$pkg_name/usr/lib64/librewolf/distribution/distribution.ini" << EOF
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
make_module_librewolf
