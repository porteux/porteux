#!/bin/bash

MODULENAME=003-lxqt

source "$PWD/../builder-utils/setflags.sh"

SetFlags "$MODULENAME"

source "$BUILDERUTILSPATH/cachefiles.sh"
source "$BUILDERUTILSPATH/genericstrip.sh"
source "$BUILDERUTILSPATH/helper.sh"
source "$BUILDERUTILSPATH/slackwarerepository.sh"

if ! isRoot; then
	echo "Please enter admin's password below:"
	su -c "$0 $1"
	exit
fi

LATESTVERSION=$(curl -s https://github.com/lxqt/lxqt-about/tags/ | grep "/lxqt/lxqt-about/releases/tag/" | grep -oP "(?<=/lxqt/lxqt-about/releases/tag/)[^\"]+" | uniq | grep -v "alpha" | grep -v "beta" | grep -v "rc[0-9]" | head -1)
echo -e "Building LXQt ${LATESTVERSION} based on Slackware ${SLACKWAREVERSION} ${ARCH}...\n"
MODULENAME=$MODULENAME-${LATESTVERSION}

### create module folder

mkdir -p $MODULEPATH/packages > /dev/null 2>&1
cd $MODULEPATH

### download packages from slackware repository

sh $SCRIPTPATH/downloadPackages.sh

### packages that require specific stripping

StripPackage qt6 \
	usr/lib$SYSTEMBITS/libQt6Concurrent.* \
	usr/lib$SYSTEMBITS/libQt6Core.* \
	usr/lib$SYSTEMBITS/libQt6DBus.* \
	usr/lib$SYSTEMBITS/libQt6Gui.* \
	usr/lib$SYSTEMBITS/libQt6Multimedia.* \
	usr/lib$SYSTEMBITS/libQt6Network.* \
	usr/lib$SYSTEMBITS/libQt6OpenGL.* \
	usr/lib$SYSTEMBITS/libQt6Pdf.* \
	usr/lib$SYSTEMBITS/libQt6PrintSupport.* \
	usr/lib$SYSTEMBITS/libQt6Svg.* \
	usr/lib$SYSTEMBITS/libQt6SvgWidgets.* \
	usr/lib$SYSTEMBITS/libQt6WaylandClient.* \
	usr/lib$SYSTEMBITS/libQt6Widgets.* \
	usr/lib$SYSTEMBITS/libQt6XcbQpa.* \
	usr/lib$SYSTEMBITS/libQt6Xml.* \
	usr/lib$SYSTEMBITS/qt6/plugins/egldeviceintegrations/* \
	usr/lib$SYSTEMBITS/qt6/plugins/iconengines/* \
	usr/lib$SYSTEMBITS/qt6/plugins/imageformats/* \
	usr/lib$SYSTEMBITS/qt6/plugins/platforminputcontexts/* \
	usr/lib$SYSTEMBITS/qt6/plugins/platforms/libqeglfs.so \
	usr/lib$SYSTEMBITS/qt6/plugins/platforms/libqlinuxfb.so \
	usr/lib$SYSTEMBITS/qt6/plugins/platforms/libqminimal.so \
	usr/lib$SYSTEMBITS/qt6/plugins/platforms/libqminimalegl.so \
	usr/lib$SYSTEMBITS/qt6/plugins/platforms/libqoffscreen.so \
	usr/lib$SYSTEMBITS/qt6/plugins/platforms/libqvnc.so \
	usr/lib$SYSTEMBITS/qt6/plugins/platforms/libqwayland*.so \
	usr/lib$SYSTEMBITS/qt6/plugins/platforms/libqxcb.so \
	usr/lib$SYSTEMBITS/qt6/plugins/platformthemes/* \
	usr/lib$SYSTEMBITS/qt6/plugins/wayland*/* \
	usr/lib$SYSTEMBITS/qt6/plugins/xcbglintegrations/*

# required by xpdf
currentPackage=ghostscript-fonts-std
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv $MODULEPATH/packages/${currentPackage}-[0-9]* . || exit 1
packageFileName=$(ls * -a | rev | cut -d . -f 2- | rev)
ROOT=./ installpkg ${currentPackage}*.txz
mkdir ${currentPackage}-stripped
cp --parents -P usr/share/fonts/Type1/d050000l.* "${currentPackage}-stripped"
cp --parents -P usr/share/fonts/Type1/fonts.* "${currentPackage}-stripped"
cp --parents -P usr/share/fonts/Type1/n019003l.* "${currentPackage}-stripped"
cp --parents -P usr/share/fonts/Type1/n019004l.* "${currentPackage}-stripped"
cp --parents -P usr/share/fonts/Type1/n019023l.* "${currentPackage}-stripped"
cp --parents -P usr/share/fonts/Type1/n019024l.* "${currentPackage}-stripped"
cp --parents -P usr/share/fonts/Type1/n021003l.* "${currentPackage}-stripped"
cp --parents -P usr/share/fonts/Type1/n021004l.* "${currentPackage}-stripped"
cp --parents -P usr/share/fonts/Type1/n021023l.* "${currentPackage}-stripped"
cp --parents -P usr/share/fonts/Type1/n021024l.* "${currentPackage}-stripped"
cp --parents -P usr/share/fonts/Type1/n022003l.* "${currentPackage}-stripped"
cp --parents -P usr/share/fonts/Type1/n022004l.* "${currentPackage}-stripped"
cp --parents -P usr/share/fonts/Type1/n022023l.* "${currentPackage}-stripped"
cp --parents -P usr/share/fonts/Type1/n022024l.* "${currentPackage}-stripped"
cp --parents -P usr/share/fonts/Type1/s050000l.* "${currentPackage}-stripped"
cd ${currentPackage}-stripped/usr/share
mkdir ghostscript && cd ghostscript
ln -s ../fonts/Type1 fonts
cd $MODULEPATH/${currentPackage}/${currentPackage}-stripped
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${packageFileName}_stripped.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage} && cd $MODULEPATH

### packages outside slackware repository

# required by lightdm
installpkg $MODULEPATH/packages/libxklavier*.txz || exit 1

# lxqt common
for package in \
	audacious \
	audacious-plugins \
	ffmpegthumbnailer \
	lightdm \
	lightdm-gtk-greeter \
	xcape \
; do
SESSIONTEMPLATE=lxqt ICONTHEME=kora QT=6 sh $SCRIPTPATH/../common/${package}/${package}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${package}*.txz || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# lxqt deps
for package in \
	muparser \
	polkit-qt6-1 \
	extra-cmake-modules \
	layer-shell-qt6 \
	plasma-wayland-protocols \
	kwindowsystem \
	kwayland \
	solid \
	kidletime \
	libkscreen \
	networkmanager-qt \
	kimageformats \
	libfm-extra \
	menu-cache \
	libstatgrab \
; do
sh $SCRIPTPATH/deps/${package}/${package}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${package}*.txz || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# required by featherpad
installpkg $MODULEPATH/packages/hunspell*.txz || exit 1

# lxqt extras
for package in \
	adwaita-qt \
	xpdf \
	featherpad \
	nm-tray \
	kora-icon-theme \
; do
sh $SCRIPTPATH/extras/${package}/${package}.SlackBuild || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# required by lxqt
installpkg $MODULEPATH/packages/libdbusmenu-qt*.txz || exit 1
installpkg $MODULEPATH/packages/polkit-qt*.txz || exit 1

# lxqt packages
for package in \
	lxqt-build-tools \
	libqtxdg \
	qtxdg-tools \
	liblxqt \
	libdbusmenu-lxqt \
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
	lxqt-wayland-session \
	xdg-desktop-portal-lxqt \
	obconf-qt \
	lximage-qt \
	qtermwidget \
	qterminal \
	qps \
	screengrab \
; do
sh $SCRIPTPATH/lxqt/${package}/${package}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${package}*.txz || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# only required for building
rm $MODULEPATH/packages/extra-cmake-modules*.txz
rm $MODULEPATH/packages/kwayland*.txz
rm $MODULEPATH/packages/lxqt-build-tools*.txz
rm $MODULEPATH/packages/plasma-wayland-protocols*.txz

### fake root

cd $MODULEPATH/packages && ROOT=./ installpkg *.t?z
rm *.t?z

### install additional packages, including porteux utils

InstallAdditionalPackages

### fix some .desktop files

sed -i "s|image/x-tga|image/x-tga;image/heic;image/jxl|g" $MODULEPATH/packages/usr/share/applications/lximage-qt.desktop
sed -i "s|Icon=pcmanfm-qt|Icon=system-file-manager|g" $MODULEPATH/packages/usr/share/applications/pcmanfm-qt.desktop
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

rm -fr usr/lib${SYSTEMBITS}/gtk-2.0/
rm -fr usr/lib${SYSTEMBITS}/qt*/mkspecs
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
