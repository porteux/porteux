#!/bin/bash

MODULE_NAME="003-xfce"

source "$PWD/../builder-utils/set-flags.sh"

set_flags "$MODULE_NAME"

source "$BUILDER_UTILS_PATH/cache-files.sh"
source "$BUILDER_UTILS_PATH/generic-strip.sh"
source "$BUILDER_UTILS_PATH/helper.sh"
source "$BUILDER_UTILS_PATH/slackware-repository.sh"

elevate_if_needed "$0" "$@"

LATEST_VERSION=$(curl -s https://gitlab.xfce.org/xfce/libxfce4util/-/tags?format=atom | grep -oPm 20 '(?<= <title>)[^<]+' | grep -Ev '^xfce-|pre' | sort -Vr | {
	if [[ "$ALLOW_TEST" == "yes" ]]; then
		version=$(head -1)
		echo "$version" | cut -d '-' -f 2 | cut -d '.' -f-2
	else
		while read -r version; do
			minor=$(echo "$version" | cut -d. -f2)
			if (( minor % 2 == 0 )); then
				echo "$version" | cut -d '-' -f 2 | cut -d '.' -f-2
				break
			fi
		done
	fi
})
[ "$LATEST_VERSION" ] || { echo "Error: could not detect Xfce version." >&2; exit 1; }
echo -e "Building Xfce ${LATEST_VERSION} based on Slackware ${SLACKWARE_VERSION} ${ARCH}...\n"
MODULE_NAME="$MODULE_NAME-${LATEST_VERSION}"

### create module folder

mkdir -p $MODULE_PATH/packages > /dev/null 2>&1
cd $MODULE_PATH || exit 1

### download packages from slackware repository

bash $SCRIPT_PATH/download-packages.sh || exit 1

### packages outside slackware repository

export SESSION_TEMPLATE=xfce
export ICON_THEME=elementary-xfce

# required by lightdm
installpkg $MODULE_PATH/packages/libxklavier*.txz || exit 1

# required from now on
installpkg $MODULE_PATH/packages/libappindicator*.txz || exit 1
installpkg $MODULE_PATH/packages/libdbusmenu*.txz || exit 1
installpkg $MODULE_PATH/packages/libgtop*.txz || exit 1
installpkg $MODULE_PATH/packages/libindicator*.txz || exit 1

# xfce common
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
	mate-common \
	mate-polkit \
	atril \
	xcape \
	gtk-layer-shell \
	engrampa \
	pavucontrol \
	gtksourceview4 \
; do
bash $SCRIPT_PATH/../common/${package}/${package}.SlackBuild || exit 1
installpkg $MODULE_PATH/packages/${package}*.txz || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

current_package=wlr-protocols
bash $SCRIPT_PATH/deps/${current_package}/${current_package}.SlackBuild || exit 1
rm -fr $MODULE_PATH/${current_package} && cd $MODULE_PATH || exit 1

current_package=mate-search-tool
bash $SCRIPT_PATH/extras/${current_package}/${current_package}.SlackBuild || exit 1
rm -fr $MODULE_PATH/${current_package} && cd $MODULE_PATH || exit 1

# required by mousepad
installpkg $MODULE_PATH/packages/enchant*.txz || exit 1
installpkg $MODULE_PATH/packages/gspell*.txz || exit 1

# required by xfce4-panel
installpkg $MODULE_PATH/packages/libwnck3*.txz || exit 1

# required by xfce4-pulseaudio-plugin
installpkg $MODULE_PATH/packages/keybinder3*.txz || exit 1

# required by xfdesktop
installpkg $MODULE_PATH/packages/libyaml*.txz || exit 1

# xfce packages
for package in \
	xfce4-dev-tools \
	libxfce4windowing \
	libxfce4util \
	xfconf \
	libxfce4ui \
	exo \
	garcon \
	xfce4-panel \
	thunar \
	thunar-volman \
	tumbler \
	xfce4-appfinder \
	xfce4-power-manager \
	xfce4-settings \
	xfdesktop \
	xfwm4 \
	xfce4-session \
	xfce4-taskmanager \
	xfce4-terminal \
	xfce4-screenshooter \
	xfce4-notifyd \
	mousepad \
	xfce4-clipman-plugin \
	xfce4-cpugraph-plugin \
	xfce4-pulseaudio-plugin \
	xfce4-sensors-plugin \
	xfce4-systemload-plugin \
	xfce4-whiskermenu-plugin \
	xfce4-xkb-plugin \
; do
bash $SCRIPT_PATH/xfce/${package}/${package}.SlackBuild || exit 1
installpkg $MODULE_PATH/packages/${package}*.txz || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# only required for building not for run-time
rm $MODULE_PATH/packages/xfce4-dev-tools*.txz
rm $MODULE_PATH/packages/mate-common*.txz

if [[ "$ALLOW_TEST" == "yes" ]]; then
	rm $MODULE_PATH/packages/exo*.txz # deprecated since xfce 4.21
fi

### fake root

cd $MODULE_PATH/packages && ROOT=./ installpkg *.t?z || exit 1
rm *.t?z

### install additional packages, including porteux utils

install_additional_packages

### fix some .desktop files

sed -i "s|Core;||g" $MODULE_PATH/packages/usr/share/applications/gpicview.desktop
sed -i "s|Graphics;|Utility;|g" $MODULE_PATH/packages/usr/share/applications/gpicview.desktop
sed -z -i "s|OnlyShowIn=MATE;\\n||g" $MODULE_PATH/packages/usr/share/applications/mate-search-tool.desktop
sed -i "s|MATE;||g" $MODULE_PATH/packages/usr/share/applications/mate-search-tool.desktop
sed -i "s|MATE ||g" $MODULE_PATH/packages/usr/share/applications/mate-search-tool.desktop
sed -i "s| MATE||g" $MODULE_PATH/packages/usr/share/applications/mate-search-tool.desktop
sed -i "s|Categories=System;|Categories=|g" $MODULE_PATH/packages/usr/share/applications/thunar.desktop
sed -i "s|System;||g" $MODULE_PATH/packages/usr/share/applications/thunar-bulk-rename.desktop
sed -i "s|System;||g" $MODULE_PATH/packages/usr/share/applications/xfce4-sensors.desktop
sed -i "s|Utility;||g" $MODULE_PATH/packages/usr/share/applications/xfce4-taskmanager.desktop

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
rm usr/share/applications/org.gnome.Vte*.desktop
rm usr/share/icons/hicolor/scalable/status/computer.svg
rm usr/share/icons/hicolor/scalable/status/keyboard.svg
rm usr/share/icons/hicolor/scalable/status/phone.svg

rm -fr usr/share/gdm
rm -fr usr/share/gnome
rm -fr usr/share/libindicator
rm -fr usr/share/themes/Default/balou
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