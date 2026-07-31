#!/bin/bash

MODULE_NAME="003-mate"

source "$PWD/../builder-utils/set-flags.sh"

set_flags "$MODULE_NAME"

source "$BUILDER_UTILS_PATH/cache-files.sh"
source "$BUILDER_UTILS_PATH/generic-strip.sh"
source "$BUILDER_UTILS_PATH/helper.sh"

elevate_if_needed "$0" "$@"

LATEST_VERSION=$(curl -s https://github.com/mate-desktop/mate-desktop/tags/ | grep "/mate-desktop/mate-desktop/releases/tag/" | grep -oP "(?<=/mate-desktop/mate-desktop/releases/tag/)[^\"]+" | uniq | sed 's|^v||' | grep -Ev "alpha|beta|rc[0-9]" | sort -Vr | {
	while read -r version; do
		minor=$(echo "$version" | cut -d. -f2)
		if (( minor % 2 == 0 )); then
			echo "$version"
			break
		fi
	done
})
[ "$LATEST_VERSION" ] || { echo "Error: could not detect MATE version." >&2; exit 1; }
echo -e "Building MATE ${LATEST_VERSION} based on Slackware ${SLACKWARE_VERSION} ${ARCH}...\n"
MODULE_NAME="$MODULE_NAME-${LATEST_VERSION}"

### create module folder

mkdir -p $MODULE_PATH/packages > /dev/null 2>&1
cd $MODULE_PATH || exit 1

### download packages from slackware repository

bash $SCRIPT_PATH/download-packages.sh || exit 1

### packages outside slackware repository

export SESSION_TEMPLATE=mate
export ICON_THEME=elementary-xfce-dark
export CAJA_ACTIONS=true

# required by lightdm
installpkg $MODULE_PATH/packages/libxklavier*.txz || exit 1

# required from now on
installpkg $MODULE_PATH/packages/iso-codes*.txz || exit 1
installpkg $MODULE_PATH/packages/libappindicator*.txz || exit 1
installpkg $MODULE_PATH/packages/libdbusmenu*.txz || exit 1
installpkg $MODULE_PATH/packages/libindicator*.txz || exit 1

# mate common deps
for package in \
	audacious \
	lightdm \
	vte \
	libnma \
	mate-common \
	gtk-layer-shell \
	libpeas \
	libgxps \
; do
bash $SCRIPT_PATH/../common/deps/${package}/${package}.SlackBuild || exit 1
installpkg $MODULE_PATH/packages/${package}*.txz || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# mate common extras
for package in \
	atril \
	audacious-plugins \
	ffmpegthumbnailer \
	lightdm-gtk-greeter \
	mate-polkit \
	network-manager-applet \
	xcape \
	zenity \
; do
bash $SCRIPT_PATH/../common/extras/${package}/${package}.SlackBuild || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# required from now on
installpkg $MODULE_PATH/packages/libgtop*.txz || exit 1
installpkg $MODULE_PATH/packages/dconf*.txz || exit 1
installpkg $MODULE_PATH/packages/enchant*.txz || exit 1
installpkg $MODULE_PATH/packages/libwnck*.txz || exit 1
installpkg $MODULE_PATH/packages/libsoup-2*.txz || exit 1

rm $MODULE_PATH/packages/mate-common*.txz
installpkg $MODULE_PATH/packages/xtrans*.txz || exit 1
rm $MODULE_PATH/packages/xtrans*.txz

# mate deps
current_package=gtksourceview4
bash $SCRIPT_PATH/../common/deps/${current_package}/${current_package}.SlackBuild || exit 1
installpkg $MODULE_PATH/packages/${current_package}*.txz || exit 1
rm -fr $MODULE_PATH/${current_package} && cd $MODULE_PATH || exit 1

# mate packages
for package in \
	mate-desktop \
	libmatekbd \
	caja \
	caja-extensions \
	marco \
	libmatemixer \
	mate-settings-daemon \
	mate-session-manager \
	mate-menus \
	mate-terminal \
	libmateweather \
	mate-panel \
	mate-notification-daemon \
	eom \
	mate-control-center \
	mate-utils \
; do
bash $SCRIPT_PATH/mate/${package}/${package}.SlackBuild || exit 1
installpkg $MODULE_PATH/packages/${package}*.txz || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# engrampa from common, must be built after caja because of caja actions
current_package=engrampa
bash $SCRIPT_PATH/../common/extras/${current_package}/${current_package}.SlackBuild || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null

# mate packages
for package in \
	mate-media \
	mate-power-manager \
	mate-system-monitor \
	mozo \
	pluma \
; do
bash $SCRIPT_PATH/mate/${package}/${package}.SlackBuild || exit 1
installpkg $MODULE_PATH/packages/${package}*.txz || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

### packages that require specific stripping

strip_package iso-codes \
	usr/share/xml/iso-codes/iso_3166-1.xml \
	usr/share/xml/iso-codes/iso_3166.xml

### fake root

install_packages

### install additional packages, including porteux utils

install_additional_packages

### copy build files to 05-devel

copy_to_devel

### copy language files to 08-multilanguage

copy_to_multilanguage

### module clean up

cd $MODULE_PATH/packages/ || exit 1

{
rm etc/xdg/autostart/blueman.desktop
rm usr/lib${SYSTEM_BITS}/girepository-1.0/SoupGNOME*
rm usr/lib${SYSTEM_BITS}/libappindicator.*
rm usr/lib${SYSTEM_BITS}/libdbusmenu-gtk.*
rm usr/lib${SYSTEM_BITS}/libindicator.*
rm usr/lib${SYSTEM_BITS}/libkeybinder.*
rm usr/lib${SYSTEM_BITS}/libsoup-gnome*
rm usr/libexec/indicator-loader

rm -fr run/
rm -fr usr/lib*/python*/site-packages/pip*
rm -fr usr/share/gdm
rm -fr usr/share/gnome
rm -fr usr/share/libindicator/
rm -fr usr/share/Thunar

[ "$SYSTEM_BITS" == 64 ] && find usr/lib/ -mindepth 1 -maxdepth 1 ! \( -name "python*" \) -exec rm -rf '{}' \; 2>/dev/null
find usr/share/libmateweather -mindepth 1 -maxdepth 1 ! \( -name "Locations.xml" -o -name "locations.dtd" \) -exec rm -rf '{}' \; 2>/dev/null
find usr/share/themes -mindepth 1 -maxdepth 1 ! \( -name "Adwaita" -o -name "Adwaita-dark" -o -name "DustBlue" \) -exec rm -rf '{}' \; 2>/dev/null
} >/dev/null 2>&1

strip_clean
strip_hard_all --exceptions='libvte-*,mate-system-monitor'

### copy cache files

prepare_files_for_cache_de

### generate cache files

generate_caches_de

### finalize

finalize
