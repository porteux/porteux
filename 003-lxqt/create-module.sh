#!/bin/bash

MODULE_NAME="003-lxqt"

source "$PWD/../builder-utils/set-flags.sh"

set_flags "$MODULE_NAME"

source "$BUILDER_UTILS_PATH/cache-files.sh"
source "$BUILDER_UTILS_PATH/generic-strip.sh"
source "$BUILDER_UTILS_PATH/helper.sh"

elevate_if_needed "$0" "$@"

LATEST_VERSION=$(curl -s https://github.com/lxqt/lxqt-about/tags/ | grep "/lxqt/lxqt-about/releases/tag/" | grep -oP "(?<=/lxqt/lxqt-about/releases/tag/)[^\"]+" | uniq | grep -Ev "alpha|beta|rc[0-9]" | sort -Vr | head -1)
[ "$LATEST_VERSION" ] || { echo "Error: could not detect LXQt version." >&2; exit 1; }
echo -e "Building LXQt ${LATEST_VERSION} based on Slackware ${SLACKWARE_VERSION} ${ARCH}...\n"
MODULE_NAME="$MODULE_NAME-${LATEST_VERSION}"

### create module folder

mkdir -p $MODULE_PATH/packages > /dev/null 2>&1
cd $MODULE_PATH || exit 1

### download packages from slackware repository

bash $SCRIPT_PATH/download-packages.sh || exit 1

### packages that require specific stripping

installpkg $MODULE_PATH/packages/qt6-[0-9]*.txz || exit 1

strip_package qt6 \
	usr/lib${SYSTEM_BITS}/libQt6Concurrent.so* \
	usr/lib${SYSTEM_BITS}/libQt6Core.so* \
	usr/lib${SYSTEM_BITS}/libQt6DBus.so* \
	usr/lib${SYSTEM_BITS}/libQt6Gui.so* \
	usr/lib${SYSTEM_BITS}/libQt6Multimedia.so* \
	usr/lib${SYSTEM_BITS}/libQt6Network.so* \
	usr/lib${SYSTEM_BITS}/libQt6OpenGL.so* \
	usr/lib${SYSTEM_BITS}/libQt6Pdf.so* \
	usr/lib${SYSTEM_BITS}/libQt6PrintSupport.so* \
	usr/lib${SYSTEM_BITS}/libQt6Svg.so* \
	usr/lib${SYSTEM_BITS}/libQt6SvgWidgets.so* \
	usr/lib${SYSTEM_BITS}/libQt6WaylandClient.so* \
	usr/lib${SYSTEM_BITS}/libQt6Widgets.so* \
	usr/lib${SYSTEM_BITS}/libQt6XcbQpa.so* \
	usr/lib${SYSTEM_BITS}/libQt6Xml.so* \
	usr/lib${SYSTEM_BITS}/qt6/plugins/egldeviceintegrations/* \
	usr/lib${SYSTEM_BITS}/qt6/plugins/iconengines/* \
	usr/lib${SYSTEM_BITS}/qt6/plugins/imageformats/* \
	usr/lib${SYSTEM_BITS}/qt6/plugins/platforminputcontexts/* \
	usr/lib${SYSTEM_BITS}/qt6/plugins/platforms/libqeglfs.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/platforms/libqlinuxfb.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/platforms/libqminimal.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/platforms/libqminimalegl.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/platforms/libqoffscreen.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/platforms/libqvnc.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/platforms/libqwayland*.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/platforms/libqxcb.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/platformthemes/* \
	usr/lib${SYSTEM_BITS}/qt6/plugins/wayland*/* \
	usr/lib${SYSTEM_BITS}/qt6/plugins/xcbglintegrations/*

# required by xpdf
current_package=ghostscript-fonts-std
rm -rf $MODULE_PATH/${current_package}
mkdir $MODULE_PATH/${current_package} && cd $MODULE_PATH/${current_package} || exit 1
mv $MODULE_PATH/packages/${current_package}-[0-9]* . || exit 1
package_file_name=$(ls * -a | rev | cut -d . -f 2- | rev)
ROOT=./ installpkg ${current_package}*.txz
mkdir ${current_package}-stripped
cp --parents -P usr/share/fonts/Type1/d050000l.* "${current_package}-stripped"
cp --parents -P usr/share/fonts/Type1/fonts.* "${current_package}-stripped"
cp --parents -P usr/share/fonts/Type1/n019003l.* "${current_package}-stripped"
cp --parents -P usr/share/fonts/Type1/n019004l.* "${current_package}-stripped"
cp --parents -P usr/share/fonts/Type1/n019023l.* "${current_package}-stripped"
cp --parents -P usr/share/fonts/Type1/n019024l.* "${current_package}-stripped"
cp --parents -P usr/share/fonts/Type1/n021003l.* "${current_package}-stripped"
cp --parents -P usr/share/fonts/Type1/n021004l.* "${current_package}-stripped"
cp --parents -P usr/share/fonts/Type1/n021023l.* "${current_package}-stripped"
cp --parents -P usr/share/fonts/Type1/n021024l.* "${current_package}-stripped"
cp --parents -P usr/share/fonts/Type1/n022003l.* "${current_package}-stripped"
cp --parents -P usr/share/fonts/Type1/n022004l.* "${current_package}-stripped"
cp --parents -P usr/share/fonts/Type1/n022023l.* "${current_package}-stripped"
cp --parents -P usr/share/fonts/Type1/n022024l.* "${current_package}-stripped"
cp --parents -P usr/share/fonts/Type1/s050000l.* "${current_package}-stripped"
cd ${current_package}-stripped/usr/share || exit 1
mkdir ghostscript && cd ghostscript || exit 1
ln -s ../fonts/Type1 fonts
cd $MODULE_PATH/${current_package}/${current_package}-stripped || exit 1
makepkg ${MAKEPKG_FLAGS} $MODULE_PATH/packages/${package_file_name}_stripped.txz > /dev/null 2>&1
rm -fr $MODULE_PATH/${current_package} && cd $MODULE_PATH || exit 1

### packages outside slackware repository

export SESSION_TEMPLATE=lxqt
export ICON_THEME=kora
export QT=6

# required by lightdm
installpkg $MODULE_PATH/packages/libxklavier*.txz || exit 1

# required by featherpad
installpkg $MODULE_PATH/packages/hunspell*.txz || exit 1

# lxqt common deps
for package in \
	audacious \
	lightdm \
	extra-cmake-modules \
	libfm-extra \
	menu-cache \
; do
bash $SCRIPT_PATH/../common/deps/${package}/${package}.SlackBuild || exit 1
installpkg $MODULE_PATH/packages/${package}*.txz || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# lxqt common extras
for package in \
	audacious-plugins \
	featherpad \
	ffmpegthumbnailer \
	kimageformats \
	kora-icon-theme \
	lightdm-gtk-greeter \
	xcape \
; do
bash $SCRIPT_PATH/../common/extras/${package}/${package}.SlackBuild || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# lxqt deps
for package in \
	muparser \
	polkit-qt6-1 \
	layer-shell-qt6 \
	plasma-wayland-protocols \
	libstatgrab \
; do
bash $SCRIPT_PATH/deps/${package}/${package}.SlackBuild || exit 1
installpkg $MODULE_PATH/packages/${package}*.txz || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# kde frameworks required by lxqt
for package in \
	kwindowsystem \
	kwayland \
	solid \
	kidletime \
	libkscreen \
	networkmanager-qt \
; do
bash $SCRIPT_PATH/../common/deps/${package}/${package}.SlackBuild || exit 1
installpkg $MODULE_PATH/packages/${package}*.txz || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# lxqt extras
for package in \
	adwaita-qt \
	xpdf \
	nm-tray \
; do
bash $SCRIPT_PATH/extras/${package}/${package}.SlackBuild || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# required by lxqt
installpkg $MODULE_PATH/packages/libdbusmenu-qt*.txz || exit 1

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
bash $SCRIPT_PATH/lxqt/${package}/${package}.SlackBuild || exit 1
installpkg $MODULE_PATH/packages/${package}*.txz || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# only required for building
rm $MODULE_PATH/packages/extra-cmake-modules*.txz
rm $MODULE_PATH/packages/kwayland*.txz
rm $MODULE_PATH/packages/lxqt-build-tools*.txz
rm $MODULE_PATH/packages/plasma-wayland-protocols*.txz

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
rm usr/lib${SYSTEM_BITS}/libdbusmenu-gtk.*
rm usr/share/nm-tray/nm-tray*.qm

rm -fr usr/lib${SYSTEM_BITS}/gtk-2.0/
rm -fr usr/lib${SYSTEM_BITS}/qt*/mkspecs
rm -fr usr/share/gdm
rm -fr usr/share/gnome
rm -fr usr/share/lximage-qt
rm -fr usr/share/lxqt-archiver
rm -fr usr/share/lxqt/graphics
rm -fr usr/share/lxqt/panel
rm -fr usr/share/obconf-qt
rm -fr usr/share/pavucontrol-qt
rm -fr usr/share/qlogging-categories*
rm -fr usr/share/qps
rm -fr usr/share/qterminal
rm -fr usr/share/Thunar

find usr/share/lxqt/wallpapers -mindepth 1 -maxdepth 1 ! \( -name "simple_blue_widescreen*" \) -exec rm -rf '{}' \; 2>/dev/null
find usr/share/lxqt/themes -mindepth 1 -maxdepth 1 ! \( -name "Porteux-dark" -o -name "Clearlooks" \) -exec rm -rf '{}' \; 2>/dev/null

[ "$SYSTEM_BITS" == 64 ] && find usr/lib/ -mindepth 1 -maxdepth 1 ! \( -name "python*" \) -exec rm -rf '{}' \; 2>/dev/null
} >/dev/null 2>&1

strip_clean
strip_hard_all

### copy cache files

prepare_files_for_cache_de

### generate cache files

generate_caches_de

### finalize

finalize
