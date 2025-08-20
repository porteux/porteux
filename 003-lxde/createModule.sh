#!/bin/bash

MODULENAME=003-lxde-0.11.1

source "$PWD/../builder-utils/setflags.sh"

SetFlags "$MODULENAME"

source "$BUILDERUTILSPATH/cachefiles.sh"
source "$BUILDERUTILSPATH/downloadfromslackware.sh"
source "$BUILDERUTILSPATH/genericstrip.sh"
source "$BUILDERUTILSPATH/helper.sh"
source "$BUILDERUTILSPATH/latestfromgithub.sh"

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

currentPackage=audacious
sh $SCRIPTPATH/../common/audacious/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=audacious-plugins
sh $SCRIPTPATH/../common/audacious/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

# required by lightdm
installpkg $MODULEPATH/packages/libxklavier-*.txz || exit 1

currentPackage=lightdm
SESSIONTEMPLATE=LXDE sh $SCRIPTPATH/../common/${currentPackage}/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=lightdm-gtk-greeter
ICONTHEME=kora sh $SCRIPTPATH/../common/${currentPackage}/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

# temporary just to build engrampa
currentPackage=mate-common
sh $SCRIPTPATH/deps/${currentPackage}/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}
rm $MODULEPATH/packages/${currentPackage}*.txz

# lxde extras
for package in \
	xcape \
	atril \
	engrampa \
	pavucontrol \
	l3afpad \
	gnome-screenshot \
	kora-icon-theme \
; do
sh $SCRIPTPATH/extras/${package}/${package}.SlackBuild || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# required by lxterminal
installpkg $MODULEPATH/packages/vte*.txz || exit 1

# required by lxpanel
installpkg $MODULEPATH/packages/libwnck3-*.txz || exit 1
installpkg $MODULEPATH/packages/keybinder3*.txz || exit 1

# lxde packages
for package in \
	gpicview \
	libfm-extra \
	menu-cache \
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
sh $SCRIPTPATH/lxde/${package}/${package}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${package}-*.txz || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# only required to build menu-cache
rm $MODULEPATH/packages/libfm-extra*.txz

### fake root

cd $MODULEPATH/packages && ROOT=./ installpkg *.t?z
rm *.t?z

### install additional packages, including porteux utils

InstallAdditionalPackages

### fix some .desktop files

sed -i "s|Core;|Utility;|g" $MODULEPATH/packages/usr/share/applications/gpicview.desktop
sed -i "s|image/x-xpixmap|image/x-xpixmap;image/heic;image/jxl|g" $MODULEPATH/packages/usr/share/applications/gpicview.desktop
sed -i "s|;Settings;|;|g" $MODULEPATH/packages/usr/share/applications/pavucontrol.desktop
sed -i "s|System;|Utility;|g" $MODULEPATH/packages/usr/share/applications/pcmanfm.desktop

### copy build files to 05-devel

CopyToDevel

### copy language files to 08-multilanguage

CopyToMultiLanguage

### module clean up

cd $MODULEPATH/packages/

{
rm etc/xdg/autostart/blueman.desktop
rm usr/bin/vte-*-gtk4
rm usr/lib${SYSTEMBITS}/libappindicator.*
rm usr/lib${SYSTEMBITS}/libdbusmenu-gtk.*
rm usr/lib${SYSTEMBITS}/libindicator.*
rm usr/lib${SYSTEMBITS}/libkeybinder.*
rm usr/lib${SYSTEMBITS}/libvte-*-gtk4*
rm usr/libexec/indicator-loader
rm usr/share/applications/org.gnome.Vte*.desktop
rm usr/share/lxde/wallpapers/lxde_green.jpg
rm usr/share/lxde/wallpapers/lxde_red.jpg

rm -fr usr/share/engrampa
rm -fr usr/share/gdm
rm -fr usr/share/gnome
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