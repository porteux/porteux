#!/bin/bash

MODULE_NAME="003-lxde"

source "$PWD/../builder-utils/set-flags.sh"

set_flags "$MODULE_NAME"

source "$BUILDER_UTILS_PATH/cache-files.sh"
source "$BUILDER_UTILS_PATH/generic-strip.sh"
source "$BUILDER_UTILS_PATH/helper.sh"

elevate_if_needed "$0" "$@"

LATEST_VERSION="0.11.1"
echo -e "Building LXDE ${LATEST_VERSION} based on Slackware ${SLACKWARE_VERSION} ${ARCH}...\n"
MODULE_NAME="$MODULE_NAME-${LATEST_VERSION}"

### create module folder

mkdir -p $MODULE_PATH/packages > /dev/null 2>&1
cd $MODULE_PATH || exit 1

### download packages from slackware repository

bash $SCRIPT_PATH/download-packages.sh || exit 1

### packages outside slackware repository

export SESSION_TEMPLATE=LXDE
export ICON_THEME=kora

# required by lightdm
installpkg $MODULE_PATH/packages/libxklavier*.txz || exit 1

# required from now on
installpkg $MODULE_PATH/packages/libappindicator*.txz || exit 1
installpkg $MODULE_PATH/packages/libdbusmenu*.txz || exit 1
installpkg $MODULE_PATH/packages/libindicator*.txz || exit 1

# lxde common deps
for package in \
	audacious \
	lightdm \
	vte \
	libnma \
	libfm-extra \
	menu-cache \
; do
bash $SCRIPT_PATH/../common/deps/${package}/${package}.SlackBuild || exit 1
installpkg $MODULE_PATH/packages/${package}*.txz || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# lxde common extras
for package in \
	atril \
	audacious-plugins \
	engrampa \
	ffmpegthumbnailer \
	gnome-screenshot \
	gpicview \
	kora-icon-theme \
	lightdm-gtk-greeter \
	network-manager-applet \
	pavucontrol \
	xcape \
; do
bash $SCRIPT_PATH/../common/extras/${package}/${package}.SlackBuild || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# lxde extras
current_package=l3afpad
bash $SCRIPT_PATH/extras/${current_package}/${current_package}.SlackBuild || exit 1
rm -fr $MODULE_PATH/${current_package} && cd $MODULE_PATH || exit 1

# required by lxpanel
installpkg $MODULE_PATH/packages/libwnck3*.txz || exit 1
installpkg $MODULE_PATH/packages/keybinder3*.txz || exit 1

# only required to build menu-cache
rm $MODULE_PATH/packages/libfm-extra*.txz

# lxde packages
for package in \
	libfm \
	pcmanfm \
	lxterminal \
	lxtask \
	lxrandr \
	lxsession \
	lxmenu-data \
	lxlauncher \
	lxinput \
	lxhotkey \
	lxde-common \
	lxappearance \
	lxappearance-obconf \
	lxpanel \
; do
bash $SCRIPT_PATH/lxde/${package}/${package}.SlackBuild || exit 1
installpkg $MODULE_PATH/packages/${package}*.txz || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

### fake root

cd $MODULE_PATH/packages && ROOT=./ installpkg *.t?z || exit 1
rm *.t?z

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
rm usr/lib${SYSTEM_BITS}/libappindicator.*
rm usr/lib${SYSTEM_BITS}/libdbusmenu-gtk.*
rm usr/lib${SYSTEM_BITS}/libindicator.*
rm usr/lib${SYSTEM_BITS}/libkeybinder.*
rm usr/libexec/indicator-loader

rm -fr usr/share/gdm
rm -fr usr/share/gnome
rm -fr usr/share/Thunar

[ "$SYSTEM_BITS" == 64 ] && find usr/lib/ -mindepth 1 -maxdepth 1 ! \( -name "python*" \) -exec rm -rf '{}' \; 2>/dev/null
} >/dev/null 2>&1

strip_clean --exceptions='libvte-*'
strip_hard_all --exceptions='libvte-*'

### copy cache files

prepare_files_for_cache_de

### generate cache files

generate_caches_de

### finalize

finalize