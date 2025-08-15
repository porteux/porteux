#!/bin/bash

MODULENAME=003-lxqt-1.4.0

source "$PWD/../builder-utils/setflags.sh"

SetFlags "$MODULENAME"

source "$BUILDERUTILSPATH/cachefiles.sh"
source "$BUILDERUTILSPATH/downloadfromslackware.sh"
source "$BUILDERUTILSPATH/genericstrip.sh"
source "$BUILDERUTILSPATH/helper.sh"
source "$BUILDERUTILSPATH/latestfromgithub.sh"

[ $SLACKWAREVERSION == "current" ] && echo "This module should be built in stable only" && exit 1

if ! isRoot; then
	echo "Please enter admin's password below:"
	su -c "$0 $1"
	exit
fi

### create module folder

mkdir -p $MODULEPATH/packages > /dev/null 2>&1
cd $MODULEPATH

### download packages from slackware repositories

DownloadFromSlackware

### packages that require specific stripping

currentPackage=qt5
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv $MODULEPATH/packages/${currentPackage}-[0-9]* .
installpkg ${currentPackage}*.txz || exit 1
version=`ls * -a | cut -d'-' -f2- | sed 's/\.txz$//'`
ROOT=./ installpkg ${currentPackage}-*.txz
mkdir ${currentPackage}-stripped-$version
cp --parents -P usr/lib$SYSTEMBITS/libQt5Concurrent.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5Core.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5DBus.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5Gui.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5Network.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5PrintSupport.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5Svg.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5Widgets.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5X11Extras.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5XcbQpa.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5Xml.* "${currentPackage}-stripped-$version"
cp --parents -f usr/lib$SYSTEMBITS/qt5/plugins/egldeviceintegrations/* "${currentPackage}-stripped-$version"
cp --parents -f usr/lib$SYSTEMBITS/qt5/plugins/bearer/* "${currentPackage}-stripped-$version"
cp --parents -f usr/lib$SYSTEMBITS/qt5/plugins/iconengines/* "${currentPackage}-stripped-$version"
cp --parents -f usr/lib$SYSTEMBITS/qt5/plugins/imageformats/* "${currentPackage}-stripped-$version"
cp --parents -f usr/lib$SYSTEMBITS/qt5/plugins/platforminputcontexts/* "${currentPackage}-stripped-$version"
cp --parents -f usr/lib$SYSTEMBITS/qt5/plugins/platforms/libqeglfs.so "${currentPackage}-stripped-$version"
cp --parents -f usr/lib$SYSTEMBITS/qt5/plugins/platforms/libqlinuxfb.so "${currentPackage}-stripped-$version"
cp --parents -f usr/lib$SYSTEMBITS/qt5/plugins/platforms/libqminimal.so "${currentPackage}-stripped-$version"
cp --parents -f usr/lib$SYSTEMBITS/qt5/plugins/platforms/libqminimalegl.so "${currentPackage}-stripped-$version"
cp --parents -f usr/lib$SYSTEMBITS/qt5/plugins/platforms/libqoffscreen.so "${currentPackage}-stripped-$version"
cp --parents -f usr/lib$SYSTEMBITS/qt5/plugins/platforms/libqvnc.so "${currentPackage}-stripped-$version"
cp --parents -f usr/lib$SYSTEMBITS/qt5/plugins/platforms/libqxcb.so "${currentPackage}-stripped-$version"
cp --parents -f usr/lib$SYSTEMBITS/qt5/plugins/platformthemes/* "${currentPackage}-stripped-$version"
cp --parents -f usr/lib$SYSTEMBITS/qt5/plugins/xcbglintegrations/* "${currentPackage}-stripped-$version"
rm "${currentPackage}-stripped-$version"/usr/lib$SYSTEMBITS/*.prl
cd ${currentPackage}-stripped-$version
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-stripped-$version-1.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

# required by xpdf
currentPackage=ghostscript-fonts-std
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv $MODULEPATH/packages/${currentPackage}-[0-9]* . || exit 1
version=`ls * -a | cut -d'-' -f4- | sed 's/\.txz$//'`
ROOT=./ installpkg ${currentPackage}-*.txz
mkdir ${currentPackage}-stripped-$version
cp --parents -P usr/share/fonts/Type1/d050000l.* "${currentPackage}-stripped-$version"
cp --parents -P usr/share/fonts/Type1/fonts.* "${currentPackage}-stripped-$version"
cp --parents -P usr/share/fonts/Type1/n019003l.* "${currentPackage}-stripped-$version"
cp --parents -P usr/share/fonts/Type1/n019004l.* "${currentPackage}-stripped-$version"
cp --parents -P usr/share/fonts/Type1/n019023l.* "${currentPackage}-stripped-$version"
cp --parents -P usr/share/fonts/Type1/n019024l.* "${currentPackage}-stripped-$version"
cp --parents -P usr/share/fonts/Type1/n021003l.* "${currentPackage}-stripped-$version"
cp --parents -P usr/share/fonts/Type1/n021004l.* "${currentPackage}-stripped-$version"
cp --parents -P usr/share/fonts/Type1/n021023l.* "${currentPackage}-stripped-$version"
cp --parents -P usr/share/fonts/Type1/n021024l.* "${currentPackage}-stripped-$version"
cp --parents -P usr/share/fonts/Type1/n022003l.* "${currentPackage}-stripped-$version"
cp --parents -P usr/share/fonts/Type1/n022004l.* "${currentPackage}-stripped-$version"
cp --parents -P usr/share/fonts/Type1/n022023l.* "${currentPackage}-stripped-$version"
cp --parents -P usr/share/fonts/Type1/n022024l.* "${currentPackage}-stripped-$version"
cp --parents -P usr/share/fonts/Type1/s050000l.* "${currentPackage}-stripped-$version"
cd "$MODULEPATH/${currentPackage}/${currentPackage}-stripped-$version/usr/share"
mkdir ghostscript && cd ghostscript
ln -s ../fonts/Type1 fonts
cd "$MODULEPATH/${currentPackage}/${currentPackage}-stripped-$version"
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-stripped-$version-1.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

### packages outside slackware repository

currentPackage=audacious
QT=5 sh $SCRIPTPATH/../common/audacious/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=audacious-plugins
QT=5 sh $SCRIPTPATH/../common/audacious/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

# required by lightdm
installpkg $MODULEPATH/packages/libxklavier-*.txz || exit 1

currentPackage=lightdm
SESSIONTEMPLATE=lxqt sh $SCRIPTPATH/../common/${currentPackage}/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=lightdm-gtk-greeter
ICONTHEME=kora sh $SCRIPTPATH/../common/${currentPackage}/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

# required by featherpad
installpkg $MODULEPATH/packages/hunspell*.txz || exit 1

# required by nm-tray
installpkg $MODULEPATH/packages/networkmanager-qt*.txz || exit 1

# lxqt extras
for package in \
	xcape \
	adwaita-qt \
	xpdf \
	featherpad \
	nm-tray \
	kora-icon-theme \
; do
sh $SCRIPTPATH/extras/${package}/${package}.SlackBuild || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# lxqt deps
for package in \
	muparser \
	extra-cmake-modules \
	kimageformats \
	libfm-extra \
	menu-cache \
	libstatgrab \
; do
sh $SCRIPTPATH/deps/${package}/${package}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${package}-*.txz || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# required by lxqt
installpkg $MODULEPATH/packages/libdbusmenu-qt*.txz || exit 1
installpkg $MODULEPATH/packages/libkscreen*.txz || exit 1
installpkg $MODULEPATH/packages/kidletime*.txz || exit 1
installpkg $MODULEPATH/packages/kwindowsystem*.txz || exit 1
installpkg $MODULEPATH/packages/polkit-qt*.txz || exit 1
installpkg $MODULEPATH/packages/solid*.txz || exit 1

# lxqt packages
for package in \
	lxqt-build-tools \
	libqtxdg \
	qtxdg-tools \
	liblxqt \
	libsysstat \
	lxqt-menu-data \
	libfm-qt \
	lxqt-themes \
	pavucontrol-qt \
	lxqt-about \
	lxqt-admin \
	lxqt-config \
	lxqt-globalkeys \
	lxqt-notificationd \
	lxqt-openssh-askpass \
	lxqt-policykit \
	lxqt-powermanagement \
	lxqt-qtplugin \
	lxqt-session \
	lxqt-sudo \
	pcmanfm-qt \
	lxqt-panel \
	lxqt-runner \
	lxqt-archiver \
	xdg-desktop-portal-lxqt \
	obconf-qt \
	lximage-qt \
	qtermwidget \
	qterminal \
	qps \
	screengrab \
; do
sh $SCRIPTPATH/lxqt/${package}/${package}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${package}-*.txz || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# only required for building
rm $MODULEPATH/packages/extra-cmake-modules*.txz
rm $MODULEPATH/packages/lxqt-build-tools*.txz

### fake root

cd $MODULEPATH/packages && ROOT=./ installpkg *.t?z
rm *.t?z

### install additional packages, including porteux utils

InstallAdditionalPackages

### fix some .desktop files

sed -i "s|image/x-tga|image/x-tga;image/heic;image/jxl|g" $MODULEPATH/packages/usr/share/applications/lximage-qt.desktop
sed -i "s|Icon=xpdfIcon|Icon=xpdf|g" $MODULEPATH/packages/usr/share/applications/xpdf.desktop

### copy build files to 05-devel

CopyToDevel

### copy language files to 08-multilanguage

CopyToMultiLanguage

### module clean up

cd $MODULEPATH/packages/

{
rm etc/xdg/autostart/blueman.desktop
rm usr/lib${SYSTEMBITS}/libdbusmenu-gtk.*
rm usr/share/nm-tray/nm-tray*.qm

rm -fr usr/lib${SYSTEMBITS}/gnome-settings-daemon-3.0/
rm -fr usr/lib${SYSTEMBITS}/gtk-2.0/
rm -fr usr/lib${SYSTEMBITS}/qt*/mkspecs
rm -fr usr/share/featherpad
rm -fr usr/share/gdm
rm -fr usr/share/gnome
rm -fr usr/share/libfm-qt/translations
rm -fr usr/share/lximage-qt
rm -fr usr/share/lxqt-archiver
rm -fr usr/share/lxqt/graphics
rm -fr usr/share/lxqt/panel
rm -fr usr/share/lxqt/translations
rm -fr usr/share/obconf-qt
rm -fr usr/share/pavucontrol-qt
rm -fr usr/share/pcmanfm-qt/translations
rm -fr usr/share/qlogging-categories*
rm -fr usr/share/qps
rm -fr usr/share/qterminal
rm -fr usr/share/qtermwidget*/translations
rm -fr usr/share/screengrab/translations
rm -fr usr/share/Thunar

find usr/share/lxqt/wallpapers -mindepth 1 -maxdepth 1 ! \( -name "simple_blue_widescreen*" \) -exec rm -rf '{}' \; 2>/dev/null
find usr/share/lxqt/themes -mindepth 1 -maxdepth 1 ! \( -name "Porteux-dark" -o -name "Clearlooks" \) -exec rm -rf '{}' \; 2>/dev/null

[ "$SYSTEMBITS" == 64 ] && find usr/lib/ -mindepth 1 -maxdepth 1 ! \( -name "python*" \) -exec rm -rf '{}' \; 2>/dev/null
} >/dev/null 2>&1

GenericStrip
AggressiveStripAll

### copy cache files

PrepareFilesForCacheDE

### generate cache files

GenerateCachesDE

### finalize

Finalize
