#!/bin/bash

MODULENAME=003-xfce

source "$PWD/../builder-utils/setflags.sh"

SetFlags "$MODULENAME"

source "$BUILDERUTILSPATH/cachefiles.sh"
source "$BUILDERUTILSPATH/downloadfromslackware.sh"
source "$BUILDERUTILSPATH/genericstrip.sh"
source "$BUILDERUTILSPATH/helper.sh"

if ! isRoot; then
	echo "Please enter admin's password below:"
	su -c "$0 $1"
	exit
fi

### create module folder

mkdir -p $MODULEPATH/packages > /dev/null 2>&1
cd $MODULEPATH

### download packages from slackware repository

DownloadFromSlackware

### packages outside slackware repository

# required by lightdm
installpkg $MODULEPATH/packages/libxklavier*.txz || exit 1

# lxde common
for package in \
	audacious \
	audacious-plugins \
	gpicview \
	ffmpegthumbnailer \
	lightdm \
	lightdm-gtk-greeter \
	mate-common \
	mate-polkit \
	xcape \
; do
SESSIONTEMPLATE=xfce sh $SCRIPTPATH/../common/${package}/${package}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${package}*.txz || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

currentPackage=wlr-protocols
sh $SCRIPTPATH/deps/${currentPackage}/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=gtk-layer-shell
sh $SCRIPTPATH/deps/${currentPackage}/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

# required from now on
installpkg $MODULEPATH/packages/libappindicator*.txz || exit 1
installpkg $MODULEPATH/packages/libdbusmenu*.txz || exit 1
installpkg $MODULEPATH/packages/libgtop*.txz || exit 1
installpkg $MODULEPATH/packages/libindicator*.txz || exit 1
installpkg $MODULEPATH/packages/libnma*.txz || exit 1

# xfce extras
for package in \
	atril \
	engrampa \
	pavucontrol \
	mate-search-tool \
	network-manager-applet \
; do
sh $SCRIPTPATH/extras/${package}/${package}.SlackBuild || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# required by libxfce4ui
installpkg $MODULEPATH/packages/glade*.txz || exit 1
rm $MODULEPATH/packages/glade*.txz || exit 1

# required by mousepad
installpkg $MODULEPATH/packages/enchant*.txz || exit 1
installpkg $MODULEPATH/packages/gspell*.txz || exit 1
installpkg $MODULEPATH/packages/gtksourceview*.txz || exit 1

# required by xfce4-panel
installpkg $MODULEPATH/packages/libwnck3*.txz || exit 1

# required by xfce4-pulseaudio-plugin
installpkg $MODULEPATH/packages/keybinder3*.txz || exit 1

# required by xfce4-terminal
installpkg $MODULEPATH/packages/icu4c*.txz || exit 1
rm $MODULEPATH/packages/icu4c*.txz
installpkg $MODULEPATH/packages/vte*.txz || exit 1

# required by xfdesktop
installpkg $MODULEPATH/packages/libyaml*.txz || exit 1

LATESTVERSION=$(curl -s https://gitlab.xfce.org/xfce/libxfce4util/-/tags?format=atom | grep -oPm 20 '(?<= <title>)[^<]+' | grep -Ev '^xfce-|pre' | sort -Vr | {
	if [[ "$ALLOWTEST" == "yes" ]]; then
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

echo "Building Xfce ${LATESTVERSION}..."
MODULENAME=$MODULENAME-${LATESTVERSION}

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
sh $SCRIPTPATH/xfce/${package}/${package}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${package}*.txz || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# only required for building not for run-time
rm $MODULEPATH/packages/xfce4-dev-tools*

### fake root

cd $MODULEPATH/packages && ROOT=./ installpkg *.t?z
rm *.t?z

### install additional packages, including porteux utils

InstallAdditionalPackages

### fix some .desktop files

sed -i "s|Core;||g" $MODULEPATH/packages/usr/share/applications/gpicview.desktop
sed -i "s|Graphics;|Utility;|g" $MODULEPATH/packages/usr/share/applications/gpicview.desktop
sed -i "s|image/x-xpixmap|image/x-xpixmap;image/heic;image/jxl|g" $MODULEPATH/packages/usr/share/applications/gpicview.desktop
sed -z -i "s|OnlyShowIn=MATE;\\n||g" $MODULEPATH/packages/usr/share/applications/mate-search-tool.desktop
sed -i "s|MATE;||g" $MODULEPATH/packages/usr/share/applications/mate-search-tool.desktop
sed -i "s|MATE ||g" $MODULEPATH/packages/usr/share/applications/mate-search-tool.desktop
sed -i "s| MATE||g" $MODULEPATH/packages/usr/share/applications/mate-search-tool.desktop
sed -i "s|Categories=System;|Categories=|g" $MODULEPATH/packages/usr/share/applications/thunar.desktop
sed -i "s|System;||g" $MODULEPATH/packages/usr/share/applications/thunar-bulk-rename.desktop
sed -i "s|System;||g" $MODULEPATH/packages/usr/share/applications/xfce4-sensors.desktop
sed -i "s|Utility;||g" $MODULEPATH/packages/usr/share/applications/xfce4-taskmanager.desktop

### copy build files to 05-devel

CopyToDevel

### copy language files to 08-multilanguage

CopyToMultiLanguage

### module clean up

cd $MODULEPATH/packages/

{
rm usr/bin/vte-*-gtk4
rm etc/xdg/autostart/blueman.desktop
rm etc/xdg/autostart/xfce4-clipman-plugin-autostart.desktop
rm etc/xdg/autostart/xscreensaver.desktop
rm usr/lib${SYSTEMBITS}/girepository-1.0/SoupGNOME*
rm usr/lib${SYSTEMBITS}/libappindicator.*
rm usr/lib${SYSTEMBITS}/libdbusmenu-gtk.*
rm usr/lib${SYSTEMBITS}/libindicator.*
rm usr/lib${SYSTEMBITS}/libkeybinder.*
rm usr/lib${SYSTEMBITS}/libsoup-gnome*
rm usr/lib${SYSTEMBITS}/libvte-*-gtk4*
rm usr/libexec/indicator-loader
rm usr/share/applications/org.gnome.Vte*.desktop
rm usr/share/applications/xfce4-file-manager.desktop
rm usr/share/applications/xfce4-mail-reader.desktop
rm usr/share/applications/xfce4-terminal-emulator.desktop
rm usr/share/applications/xfce4-web-browser.desktop
rm usr/share/backgrounds/xfce/xfce-leaves.svg
rm usr/share/backgrounds/xfce/xfce-light.svg
rm usr/share/backgrounds/xfce/xfce-mouserace.svg
rm usr/share/backgrounds/xfce/xfce-shapes.svg
rm usr/share/icons/hicolor/scalable/status/computer.svg
rm usr/share/icons/hicolor/scalable/status/keyboard.svg
rm usr/share/icons/hicolor/scalable/status/phone.svg

rm -fr usr/lib${SYSTEMBITS}/gnome-settings-daemon-3.0
rm -fr usr/share/engrampa
rm -fr usr/share/gdm
rm -fr usr/share/gnome
rm -fr usr/share/themes/Default/balou
rm -fr usr/share/Thunar

[ "$SYSTEMBITS" == 64 ] && find usr/lib/ -mindepth 1 -maxdepth 1 ! \( -name "python*" \) -exec rm -rf '{}' \; 2>/dev/null
} >/dev/null 2>&1

mv $MODULEPATH/packages/usr/lib${SYSTEMBITS}/libvte-* $MODULEPATH/
GenericStrip
AggressiveStripAll
mv $MODULEPATH/libvte-* $MODULEPATH/packages/usr/lib${SYSTEMBITS}

### copy cache files

PrepareFilesForCacheDE

### generate cache files

GenerateCachesDE

### finalize

Finalize