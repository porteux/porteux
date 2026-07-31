#!/bin/bash

MODULE_NAME="003-gnome"

source "$PWD/../builder-utils/set-flags.sh"

set_flags "$MODULE_NAME"

source "$BUILDER_UTILS_PATH/cache-files.sh"
source "$BUILDER_UTILS_PATH/generic-strip.sh"
source "$BUILDER_UTILS_PATH/helper.sh"

elevate_if_needed "$0" "$@"

### create module folder

mkdir -p $MODULE_PATH/packages > /dev/null 2>&1
cd $MODULE_PATH || exit 1

### download packages from slackware repository

bash $SCRIPT_PATH/download-packages.sh || exit 1

### packages outside slackware repository

if [[ ${ALLOW_TEST:-no} == no ]]; then
	export TEST_RELEASES="grep -Ev '\.(alpha|beta|rc)|-dev' | sed -E 's/\.(alpha|beta|rc)/~\1/' | sort -Vr | sed 's/~/\./'"
else
	export TEST_RELEASES="sort -Vr"
fi

LATEST_VERSION=$(curl -s https://gitlab.gnome.org/GNOME/gnome-shell/-/tags?format=atom | grep -oPm 20 '(?<= <title>)[^<]+' | eval "${TEST_RELEASES:-sort -Vr}" | head -1)
[ "$LATEST_VERSION" ] || { echo "Error: could not detect GNOME version." >&2; exit 1; }
echo -e "Building GNOME ${LATEST_VERSION} based on Slackware ${SLACKWARE_VERSION} ${ARCH}...\n"
MODULE_NAME="$MODULE_NAME-${LATEST_VERSION}"

# required from now on
installpkg $MODULE_PATH/packages/*.txz || exit 1

# only required for building not for run-time
rm $MODULE_PATH/packages/boost*
rm $MODULE_PATH/packages/c-ares*
rm $MODULE_PATH/packages/cups*
rm $MODULE_PATH/packages/dbus-python*
rm $MODULE_PATH/packages/egl-wayland*
rm $MODULE_PATH/packages/krb5*
rm $MODULE_PATH/packages/libsass*
rm $MODULE_PATH/packages/libwnck3*
rm $MODULE_PATH/packages/llvm*
rm $MODULE_PATH/packages/openldap*
rm $MODULE_PATH/packages/python-pip*
rm $MODULE_PATH/packages/sassc*
rm $MODULE_PATH/packages/vulkan-sdk*
rm $MODULE_PATH/packages/xtrans*

# required by mutter 45+
cd $MODULE_PATH || exit 1
pip install argcomplete || exit 1
pip install attrs || exit 1
pip install jinja2 || exit 1
pip install pygments || exit 1

install_rust_toolchain

# gnome extras
for package in \
	dash-to-dock \
	desktop-icons-ng \
; do
bash $SCRIPT_PATH/extras/${package}/${package}.SlackBuild || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# gnome common deps
for package in \
	audacious \
	dart-sass \
	exiv2 \
	gsound \
; do
bash $SCRIPT_PATH/../common/deps/${package}/${package}.SlackBuild || exit 1
installpkg $MODULE_PATH/packages/${package}*.txz || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# gnome common extras
for package in \
	adw-gtk3 \
	audacious-plugins \
	ffmpegthumbnailer \
; do
bash $SCRIPT_PATH/../common/extras/${package}/${package}.SlackBuild || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# gnome deps
for package in \
	bubblewrap \
	geoclue2 \
	colord-gtk \
	libportal \
	libcloudproviders \
	glycin \
	exempi \
	blueprint-compiler \
	gweather-locations \
; do
bash $SCRIPT_PATH/deps/${package}/${package}.SlackBuild || exit 1
installpkg $MODULE_PATH/packages/${package}*.txz || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# only required for building
rm $MODULE_PATH/packages/blueprint-compiler*
rm $MODULE_PATH/packages/dart-sass*.txz

# gnome packages
for package in \
	libadwaita \
	gnome-online-accounts \
	gtksourceview5 \
	geocode-glib \
	libgweather \
	gnome-autoar \
	gnome-desktop \
	gnome-settings-daemon \
	gnome-tweaks \
	gnome-bluetooth \
	libnma-gtk4 \
	gnome-control-center \
	mutter \
	gjs \
	gnome-shell \
	gnome-session \
	gexiv2 \
	tinysparql \
	localsearch \
	nautilus \
	nautilus-python \
	gdm \
	gspell \
	libspelling \
	gnome-text-editor \
	loupe \
	papers \
	gnome-system-monitor \
	vte-gtk4 \
	ptyxis \
	gnome-user-share \
	gnome-backgrounds \
	gnome-browser-connector \
	file-roller \
	adwaita-icon-theme \
	xdg-desktop-portal-gnome \
; do
bash $SCRIPT_PATH/gnome/${package}/${package}.SlackBuild || exit 1
installpkg $MODULE_PATH/packages/${package}*.txz || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

### packages that require specific stripping

# required by gnome-control-center and ibus
strip_package iso-codes \
	usr/share/xml/iso-codes/iso_3166-1.xml \
	usr/share/xml/iso-codes/iso_3166.xml \
	usr/share/xml/iso-codes/iso_639-2.xml \
	usr/share/xml/iso-codes/iso_639-3.xml \
	usr/share/xml/iso-codes/iso_639.xml \
	usr/share/xml/iso-codes/iso_639_3.xml

current_package=ibus
mkdir $MODULE_PATH/${current_package} && cd $MODULE_PATH/${current_package} || exit 1
mv $MODULE_PATH/packages/${current_package}-[0-9]* .
package_file_name=$(ls ${current_package}-[0-9]*.t?z | head -n1)
package_file_name=${package_file_name%.*}
ROOT=./ installpkg ${current_package}-[0-9]*.t?z && rm ${current_package}-[0-9]*.t?z
rm usr/share/applications/org.freedesktop.IBus.Setup.desktop
rm -fr usr/share/ibus/dicts
rm -fr var/lib/pkgtools
rm -f var/log/packages
rm -fr var/log/pkgtools
rm -f var/log/setup
rm -f var/log/scripts
mkdir ${current_package}-stripped
find . -mindepth 1 -maxdepth 1 ! -name "${current_package}-stripped" -exec mv -t "${current_package}-stripped" {} +
cd ${current_package}-stripped || exit 1
makepkg ${MAKEPKG_FLAGS} $MODULE_PATH/packages/${package_file_name}_stripped.txz > /dev/null 2>&1
rm -fr $MODULE_PATH/${current_package} && cd $MODULE_PATH || exit 1

### fake root

cd $MODULE_PATH/packages && ROOT=./ installpkg *.t?z || exit 1
rm *.t?z

### install additional packages, including porteux utils

install_additional_packages

### remove some useless services

echo "Hidden=true" >> $MODULE_PATH/packages/etc/xdg/autostart/localsearch-3.desktop
echo "Hidden=true" >> $MODULE_PATH/packages/etc/xdg/autostart/org.gnome.SettingsDaemon.Rfkill.desktop

### copy build files to 05-devel

copy_to_devel

### copy language files to 08-multilanguage

copy_to_multilanguage

### update icon cache

gtk-update-icon-cache $MODULE_PATH/packages/usr/share/icons/Adwaita

### module clean up

cd $MODULE_PATH/packages/ || exit 1

{
rm etc/xdg/autostart/blueman.desktop
rm usr/bin/gtk4-builder-tool
rm usr/bin/gtk4-demo
rm usr/bin/gtk4-demo-application
rm usr/bin/gtk4-encode-symbolic-svg
rm usr/bin/gtk4-icon-browser
rm usr/bin/gtk4-icon-editor
rm usr/bin/gtk4-launch
rm usr/bin/gtk4-print-editor
rm usr/bin/gtk4-widget-factory
rm usr/bin/js[0-9]*
rm usr/lib${SYSTEM_BITS}/gstreamer-1.0/libgstfluidsynthmidi.*
rm usr/lib${SYSTEM_BITS}/gstreamer-1.0/libgstneonhttpsrc.*
rm usr/lib${SYSTEM_BITS}/gstreamer-1.0/libgstopencv.*
rm usr/lib${SYSTEM_BITS}/gstreamer-1.0/libgstopenexr.*
rm usr/lib${SYSTEM_BITS}/gstreamer-1.0/libgstqmlgl.*
rm usr/lib${SYSTEM_BITS}/gstreamer-1.0/libgstqroverlay.*
rm usr/lib${SYSTEM_BITS}/gstreamer-1.0/libgsttaglib.*
rm usr/lib${SYSTEM_BITS}/gstreamer-1.0/libgstwebrtc.*
rm usr/lib${SYSTEM_BITS}/gstreamer-1.0/libgstzxing.*
rm usr/lib${SYSTEM_BITS}/libcanberra-gtk.*
rm usr/lib${SYSTEM_BITS}/libgstopencv-1.0.*
rm usr/lib${SYSTEM_BITS}/libgstwebrtcnice.*
rm usr/share/applications/org.freedesktop.IBus*.desktop
rm usr/share/applications/org.gtk.Demo4.desktop
rm usr/share/applications/org.gtk.gtk4.NodeEditor.desktop
rm usr/share/applications/org.gtk.PrintEditor4.desktop
rm usr/share/applications/org.gtk.Shaper.desktop
rm usr/share/applications/org.gtk.WidgetFactory4.desktop
rm usr/share/dbus-1/services/org.freedesktop.ColorHelper.service
rm usr/share/glib-2.0/schemas/org.gtk.Demo4.gschema.xml
rm usr/share/icons/hicolor/symbolic/apps/org.gtk.Demo4-symbolic.svg
rm usr/share/icons/hicolor/scalable/apps/org.gtk.Demo4.svg

rm -fr etc/dbus-1/system.d
rm -fr etc/dconf
rm -fr etc/opt
rm -fr usr/lib${SYSTEM_BITS}/aspell
rm -fr usr/lib${SYSTEM_BITS}/glade
rm -fr usr/lib${SYSTEM_BITS}/graphene-1.0
rm -fr usr/lib${SYSTEM_BITS}/gtk-2.0
rm -fr usr/lib${SYSTEM_BITS}/python*/site-packages/pip*
rm -fr usr/share/glade/pixmaps
rm -fr usr/share/gnome
rm -fr usr/share/gtk-4.0
rm -fr usr/share/pixmaps
rm -fr var/lib/AccountsService

[ "$SYSTEM_BITS" == 64 ] && find usr/lib/ -mindepth 1 -maxdepth 1 ! \( -name "python*" \) -exec rm -rf '{}' \; 2>/dev/null

} >/dev/null 2>&1

strip_clean --exceptions='libexiv2.so*,libmozjs-*,libvte-*'
strip_hard_all --exceptions='libexiv2.so*,libmozjs-*,libvte-*'

### copy cache files

prepare_files_for_cache_de

### generate cache files

generate_caches_de

### finalize

finalize
