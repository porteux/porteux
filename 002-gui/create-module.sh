#!/bin/bash

MODULE_NAME="002-gui"

source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../builder-utils/set-flags.sh"

set_flags "$MODULE_NAME"

source "$BUILDER_UTILS_PATH/cache-files.sh"
source "$BUILDER_UTILS_PATH/generic-strip.sh"
source "$BUILDER_UTILS_PATH/helper.sh"

elevate_if_needed "$0" "$@"

echo -e "Building ${MODULE_NAME} based on Slackware ${SLACKWARE_VERSION} ${ARCH}...\n"

### create module folder

mkdir -p $MODULE_PATH/packages > /dev/null 2>&1
cd $MODULE_PATH || exit 1

### download packages from slackware repository

bash $SCRIPT_PATH/download-packages.sh || exit 1

### critical libraries that need to be in sync with slackware repo before building

installpkg $MODULE_PATH/packages/gpgmepp*.txz || exit 1
installpkg $MODULE_PATH/packages/libbluray*.txz || exit 1
installpkg $MODULE_PATH/packages/libcdio-[0-9]*.txz || exit 1
installpkg $MODULE_PATH/packages/libdisplay-info*.txz || exit 1
installpkg $MODULE_PATH/packages/libvpx*.txz || exit 1
installpkg $MODULE_PATH/packages/poppler*.txz || exit 1

### packages outside slackware repository

[ ! -f /usr/bin/clang ] && { installpkg $MODULE_PATH/packages/llvm*.txz || exit 1; }

# required by appstream
installpkg $MODULE_PATH/packages/nghttp*.txz || exit 1
rm $MODULE_PATH/packages/nghttp*.txz
installpkg $MODULE_PATH/packages/ngtcp2*.txz || exit 1
rm $MODULE_PATH/packages/ngtcp2*.txz

# required by flatpak
installpkg $MODULE_PATH/packages/glib-networking*.txz || exit 1
installpkg $MODULE_PATH/packages/gnupg2*.txz || exit 1
installpkg $MODULE_PATH/packages/gperf*.txz || exit 1
rm $MODULE_PATH/packages/gperf*.txz
installpkg $MODULE_PATH/packages/libproxy*.txz || exit 1
installpkg $MODULE_PATH/packages/npth*.txz || exit 1
installpkg $MODULE_PATH/packages/pyparsing*.txz || exit 1
rm $MODULE_PATH/packages/pyparsing*.txz
installpkg $MODULE_PATH/packages/socat*.txz || exit 1
rm $MODULE_PATH/packages/socat*.txz

# required by gtk+3
installpkg $MODULE_PATH/packages/cups*.txz || exit 1
rm $MODULE_PATH/packages/cups*.txz

# required by libei
installpkg $MODULE_PATH/packages/python-Jinja2*.txz || exit 1
rm $MODULE_PATH/packages/python-Jinja2*.txz
installpkg $MODULE_PATH/packages/python-MarkupSafe*.txz || exit 1
rm $MODULE_PATH/packages/python-MarkupSafe*.txz

# required by xorg-server
installpkg $MODULE_PATH/packages/xtrans*.txz || exit 1
rm $MODULE_PATH/packages/xtrans*.txz

# required by librsvg
installpkg $MODULE_PATH/packages/cargo-c*.txz || exit 1
rm $MODULE_PATH/packages/cargo-c*

install_rust_toolchain

# gui deps
for package in \
	gdk-pixbuf2 \
	freetype \
	harfbuzz \
	xorg-server \
	libX11 \
	gsettings-desktop-schemas \
	gtk+3-classic \
	pipewire \
	cxxopts \
	imlib2 \
	libostree \
	libei \
	libfyaml \
	libxmlb \
	appstream \
	intel-gmmlib \
	librsvg \
; do
bash $SCRIPT_PATH/deps/${package}/${package}.SlackBuild || exit 1
installpkg $MODULE_PATH/packages/${package}*.txz || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# only required for building
rm $MODULE_PATH/packages/cxxopts*.txz

# gui extras
for package in \
	flatpak \
	galculator \
	intel-media-driver \
	intel-vaapi-driver \
	labwc \
	libjxl \
	openbox \
	pamixer \
	webp-pixbuf-loader \
	wireplumber \
	wlr-randr \
	xdg-desktop-portal \
	xdg-desktop-portal-gtk \
	xf86-input-libinput \
; do
bash $SCRIPT_PATH/extras/${package}/${package}.SlackBuild || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

### packages that require specific stripping

strip_package llvm \
	usr/lib${SYSTEM_BITS}/libLLVM*.so*

current_package=mesa
mkdir $MODULE_PATH/${current_package} && cd $MODULE_PATH/${current_package} || exit 1
mv $MODULE_PATH/packages/${current_package}-[0-9]* .
package_file_name=$(ls ${current_package}-[0-9]*.t?z | head -n1)
package_file_name=${package_file_name%.*}
ROOT=./ installpkg ${current_package}*.txz || exit 1
rm ${current_package}*.txz
rm -fr etc/OpenCL
rm usr/lib${SYSTEM_BITS}/dri/i830*
rm usr/lib${SYSTEM_BITS}/dri/i965*
rm usr/lib${SYSTEM_BITS}/dri/nouveau_vieux*
rm usr/lib${SYSTEM_BITS}/dri/r200*
rm usr/lib${SYSTEM_BITS}/dri/radeon_dri*
rm usr/lib${SYSTEM_BITS}/*OpenCL*
rm -fr var/lib/pkgtools
rm -f var/log/packages
rm -fr var/log/pkgtools
rm -f var/log/setup
rm -f var/log/scripts
mkdir ${current_package}-stripped
find . -mindepth 1 -maxdepth 1 ! -name "${current_package}-stripped" -exec mv -t "${current_package}-stripped" {} +
cd ${current_package}-stripped || exit 1
makepkg ${MAKEPKG_FLAGS} $MODULE_PATH/packages/${package_file_name}_stripped.txz > /dev/null 2>&1 || exit 1
rm -fr "${MODULE_PATH:?}/${current_package}" && cd "$MODULE_PATH" || exit 1

strip_package dejavu-fonts-ttf \
	usr/share/fonts/TTF/DejaVuSans-Bold.ttf \
	usr/share/fonts/TTF/DejaVuSans.ttf \
	usr/share/fonts/TTF/DejaVuSansMono-Bold.ttf \
	usr/share/fonts/TTF/DejaVuSansMono-BoldOblique.ttf \
	usr/share/fonts/TTF/DejaVuSansMono.ttf \
	usr/share/fonts/TTF/DejaVuSerif-Bold.ttf \
	usr/share/fonts/TTF/DejaVuSerif.ttf

strip_package noto-fonts-ttf \
	usr/share/fonts/TTF/NotoSansSymbols*-Regular.ttf

strip_package pulseaudio \
	usr/bin/pactl \
	usr/include/* \
	usr/lib${SYSTEM_BITS}/cmake/* \
	usr/lib${SYSTEM_BITS}/libpulse-mainloop-glib.so* \
	usr/lib${SYSTEM_BITS}/libpulse-simple.so* \
	usr/lib${SYSTEM_BITS}/libpulse.so* \
	usr/lib${SYSTEM_BITS}/pkgconfig/* \
	usr/lib${SYSTEM_BITS}/pulseaudio/libpulsecommon*.so*
	
strip_package sound-theme-freedesktop \
	usr/share/sounds/freedesktop/stereo/audio-channel* \
	usr/share/sounds/freedesktop/stereo/audio-test-signal* \
	usr/share/sounds/freedesktop/index.theme

strip_package vulkan-sdk \
	usr/bin/vulkaninfo \
	usr/include/spirv-tools \
	usr/include/vk_video \
	usr/include/vulkan/* \
	usr/lib${SYSTEM_BITS}/cmake \
	usr/lib${SYSTEM_BITS}/libSPIRV-Tools.so* \
	usr/lib${SYSTEM_BITS}/libvulkan.so* \
	usr/lib${SYSTEM_BITS}/pkgconfig/SPIRV-Tools* \
	usr/lib${SYSTEM_BITS}/pkgconfig/vulkan.pc

### fake root

install_packages

### install additional packages, including porteux utils

install_additional_packages

### fix applications shortcuts

sed -i "s|^Exec=.*|Exec=psu /usr/bin/gparted %f|g" $MODULE_PATH/packages/usr/share/applications/gparted.desktop

### add xzm to freedesktop.org.xml

patch --no-backup-if-mismatch -d $MODULE_PATH/packages -p1 < $SCRIPT_PATH/extras/freedesktop/freedesktop.org.xml.patch || exit 1

### fix gtk2 adwaita theme cursor click on text box having wrong offset

sed -i "s|GtkEntry::inner-border = {7, 7, 4, 5}|GtkEntry::inner-border = {2, 2, 7, 7}|g" $MODULE_PATH/packages/usr/share/themes/Adwaita-dark/gtk-2.0/main.rc
sed -i "s|GtkEntry::inner-border = {7, 7, 4, 5}|GtkEntry::inner-border = {2, 2, 7, 7}|g" $MODULE_PATH/packages/usr/share/themes/Adwaita/gtk-2.0/main.rc

### update version

sed -i "s|version|v${PORTEUX_VERSION}|" $MODULE_PATH/packages/etc/issue-wm

### copy build files to 05-devel

copy_to_devel

### copy language files to 08-multilanguage

copy_to_multilanguage

### module clean up

cd $MODULE_PATH/packages/ || exit 1

{
rm etc/asound.state
rm etc/rc_maps.cfg
rm etc/xdg/autostart/at-spi-dbus-bus.desktop
rm usr/bin/canberra*
rm usr/bin/qv4l2
rm usr/bin/qvidcap
rm usr/bin/Xdmx
rm usr/lib${SYSTEM_BITS}/gtk-2.0/modules/libcanberra-gtk-module.*
rm usr/lib${SYSTEM_BITS}/libbd_vdo.*
rm usr/lib${SYSTEM_BITS}/libcanberra-gtk.*
rm usr/lib${SYSTEM_BITS}/libpoppler-cpp*
rm usr/lib${SYSTEM_BITS}/libpoppler-qt5*
rm usr/lib${SYSTEM_BITS}/libxatracker*
rm usr/lib${SYSTEM_BITS}/libXaw.so.6*
rm usr/lib${SYSTEM_BITS}/libXaw6*
rm usr/share/applications/gcr-prompter.desktop
rm usr/share/applications/gcr-viewer.desktop
rm usr/share/applications/mimeinfo.cache
rm usr/share/applications/qv4l2.desktop
rm usr/share/applications/qvidcap.desktop
rm usr/share/applications/xterm.desktop
rm usr/share/icons/hicolor/scalable/apps/qv4l2.svg
rm usr/share/icons/hicolor/scalable/apps/qvidcap.svg
rm usr/share/xsessions/xwmconfig.desktop

rm -fr etc/gnupg
rm -fr etc/pam.d
rm -fr etc/rc_keymaps
rm -fr etc/xdg/Xwayland-session.d
rm -fr usr/lib${SYSTEM_BITS}/atkmm-*
rm -fr usr/lib${SYSTEM_BITS}/cairomm-*
rm -fr usr/lib${SYSTEM_BITS}/clang
rm -fr usr/lib${SYSTEM_BITS}/gdkmm-*
rm -fr usr/lib${SYSTEM_BITS}/giomm-*
rm -fr usr/lib${SYSTEM_BITS}/glibmm-*
rm -fr usr/lib${SYSTEM_BITS}/gnome-settings-daemon-*
rm -fr usr/lib${SYSTEM_BITS}/graphene-*
rm -fr usr/lib${SYSTEM_BITS}/gtkmm-*
rm -fr usr/lib${SYSTEM_BITS}/libxslt-plugins
rm -fr usr/lib${SYSTEM_BITS}/openjpeg-*
rm -fr usr/lib${SYSTEM_BITS}/pangomm-*
rm -fr usr/lib${SYSTEM_BITS}/sigc++-*
rm -fr usr/lib${SYSTEM_BITS}/xmms
rm -fr usr/libexec/upower/tests
rm -fr usr/share/gdm
rm -fr usr/share/gnupg
rm -fr usr/share/gobject-introspection*/tests
rm -fr usr/share/graphite2
rm -fr usr/share/gst-plugins-base
rm -fr usr/share/gstreamer*/gdb
rm -fr usr/share/gtk-*
rm -fr usr/share/imlib2
rm -fr usr/share/libgphoto2/*/konica/french
rm -fr usr/share/libgphoto2/*/konica/german
rm -fr usr/share/libgphoto2/*/konica/japanese
rm -fr usr/share/libgphoto2/*/konica/korean
rm -fr usr/share/libgphoto2/*/konica/spanish
rm -fr usr/share/libgphoto2_port
rm -fr usr/share/sounds/alsa
rm -fr usr/share/svgalib-demos
rm -fr usr/share/themes/Artwiz-boxed
rm -fr usr/share/themes/Bear2
rm -fr usr/share/themes/Clearlooks-3.4
rm -fr usr/share/themes/Clearlooks-Olive
rm -fr usr/share/themes/Mikachu
rm -fr usr/share/themes/Natura
rm -fr usr/share/themes/Orang
rm -fr usr/share/X11/locale/am*
rm -fr usr/share/X11/locale/cs*
rm -fr usr/share/X11/locale/el*
rm -fr usr/share/X11/locale/fi*
rm -fr usr/share/X11/locale/georgian*
rm -fr usr/share/X11/locale/ja*
rm -fr usr/share/X11/locale/km*
rm -fr usr/share/X11/locale/ko*
rm -fr usr/share/X11/locale/mulelao*
rm -fr usr/share/X11/locale/nokhchi*
rm -fr usr/share/X11/locale/pt*
rm -fr usr/share/X11/locale/ru*
rm -fr usr/share/X11/locale/sr*
rm -fr usr/share/X11/locale/tatar-cyr
rm -fr usr/share/X11/locale/th*
rm -fr usr/share/X11/locale/vi*
rm -fr usr/share/X11/locale/zh*
rm -fr usr/X11R6/include
rm -fr usr/X11R6/man
} >/dev/null 2>&1

find usr/share/icons/hicolor -name 'image-vnd.djvu.png' -delete

find $MODULE_PATH/packages/usr/lib${SYSTEM_BITS}/dri -name '*.la' -delete

mv $MODULE_PATH/packages/usr/share/sounds $MODULE_PATH/
strip_clean --exceptions='*/dri/*,gpartedbin,libgallium*,libunwind*,libvulkan*,libX11.so*'
strip_hard_all --exceptions='*/dri/*,gpartedbin,libgallium*,libunwind*,libvulkan*,libX11.so*'
mv $MODULE_PATH/sounds $MODULE_PATH/packages/usr/share

### copy cache files

prepare_files_for_cache

### generate cache files

generate_caches

### finalize

finalize
