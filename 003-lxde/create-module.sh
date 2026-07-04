#!/bin/bash

MODULE_NAME=003-lxde

source "$PWD/../builder-utils/set-flags.sh"

set_flags "$MODULE_NAME"

source "$BUILDER_UTILS_PATH/cache-files.sh"
source "$BUILDER_UTILS_PATH/generic-strip.sh"
source "$BUILDER_UTILS_PATH/helper.sh"
source "$BUILDER_UTILS_PATH/slackware-repository.sh"

if ! is_root; then
	echo "Please enter admin's password below:"
	su -c "$0 $1"
	exit
fi

LATESTVERSION="0.11.1"
echo -e "Building LXDE ${LATESTVERSION} based on Slackware ${SLACKWARE_VERSION} ${ARCH}...\n"
MODULE_NAME=$MODULE_NAME-${LATESTVERSION}

### create module folder

mkdir -p $MODULE_PATH/packages > /dev/null 2>&1
cd $MODULE_PATH

### download packages from slackware repository

sh $SCRIPT_PATH/download-packages.sh

### packages outside slackware repository

export SESSIONTEMPLATE=LXDE
export ICONTHEME=kora

# required by lightdm
installpkg $MODULE_PATH/packages/libxklavier*.txz || exit 1

# required from now on
installpkg $MODULE_PATH/packages/libappindicator*.txz || exit 1
installpkg $MODULE_PATH/packages/libdbusmenu*.txz || exit 1
installpkg $MODULE_PATH/packages/libindicator*.txz || exit 1

# lxde common
for package in \
	audacious \
	audacious-plugins \
	gpicview \
	ffmpegthumbnailer \
	lightdm \
	lightdm-gtk-greeter \
	vte \
	libnma \
	network-manager-applet \
	atril \
	xcape \
	engrampa \
	pavucontrol \
	gnome-screenshot \
	kora-icon-theme \
	libfm-extra \
	menu-cache \
; do
sh $SCRIPT_PATH/../common/${package}/${package}.SlackBuild || exit 1
installpkg $MODULE_PATH/packages/${package}*.txz || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# lxde extras
current_package=l3afpad
sh $SCRIPT_PATH/extras/${current_package}/${current_package}.SlackBuild || exit 1
rm -fr $MODULE_PATH/${current_package} && cd $MODULE_PATH

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
sh $SCRIPT_PATH/lxde/${package}/${package}.SlackBuild || exit 1
installpkg $MODULE_PATH/packages/${package}*.txz || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

### fake root

cd $MODULE_PATH/packages && ROOT=./ installpkg *.t?z
rm *.t?z

### install additional packages, including porteux utils

install_additional_packages

### copy build files to 05-devel

copy_to_devel

### copy language files to 08-multilanguage

copy_to_multilanguage

### module clean up

cd $MODULE_PATH/packages/

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

mv $MODULE_PATH/packages/usr/lib${SYSTEM_BITS}/libvte-* $MODULE_PATH/
generic_strip
aggressive_strip_all
mv $MODULE_PATH/libvte-* $MODULE_PATH/packages/usr/lib${SYSTEM_BITS}

### copy cache files

prepare_files_for_cache_de

### generate cache files

generate_caches_de

### finalize

finalize