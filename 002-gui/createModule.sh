#!/bin/bash

MODULENAME=002-gui

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

installpkg $MODULEPATH/packages/gdk-pixbuf2*.txz || exit 1
[ ! -f /usr/bin/clang ] && (installpkg $MODULEPATH/packages/llvm*.txz || exit 1)

if [ $SLACKWAREVERSION != "current" ]; then
	# required by xorg but not included in slackware repo in stable
	currentPackage=libxcvt
	sh $SCRIPTPATH/deps/${currentPackage}/${currentPackage}.SlackBuild || exit 1
	installpkg $MODULEPATH/packages/${currentPackage}*.txz
	rm -fr $MODULEPATH/${currentPackage}
else
	installpkg $MODULEPATH/packages/libdisplay-info*.txz || exit 1

	installpkg $MODULEPATH/packages/cargo-c*.txz || exit 1
	rm $MODULEPATH/packages/cargo-c*

	# not using rust from slackware because it's much slower
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --profile minimal --default-toolchain stable -y
	rm -fr $HOME/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/share/doc 2>/dev/null
	export PATH=$HOME/.cargo/bin/:$PATH

	# building this because the slackware package in current depends on dav1d
	currentPackage=librsvg
	sh $SCRIPTPATH/deps/${currentPackage}/${currentPackage}.SlackBuild || exit 1
	installpkg $MODULEPATH/packages/librsvg*.txz || exit 1
	rm -fr $MODULEPATH/${currentPackage}
fi

installpkg $MODULEPATH/packages/libcanberra*.txz || exit 1
installpkg $MODULEPATH/packages/libtheora*.txz || exit 1

# required by gtk+3
installpkg $MODULEPATH/packages/cups*.txz || exit 1
rm $MODULEPATH/packages/cups*.txz

# required by xorg-server
installpkg $MODULEPATH/packages/xtrans*.txz || exit 1
rm $MODULEPATH/packages/xtrans*.txz

# gui deps
for package in \
	xorg-server \
	xf86-input-libinput \
	libX11 \
	gtk+3-classic \
	pipewire \
	wireplumber \
	cxxopts \
	imlib2 \
; do
sh $SCRIPTPATH/deps/${package}/${package}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${package}-*.txz || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# only required for building
rm $MODULEPATH/packages/cxxopts*.txz

# gui extras
for package in \
	galculator \
	libjxl \
	openbox \
	pamixer \
	webp-pixbuf-loader \
	wlr-randr \
	wlrctl \
	xdg-desktop-portal \
; do
sh $SCRIPTPATH/extras/${package}/${package}.SlackBuild || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

### packages that require specific stripping

currentPackage=llvm
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv ../packages/${currentPackage}*.txz .
packageFileName=$(ls * -a | rev | cut -d . -f 2- | rev)
ROOT=./ installpkg ${currentPackage}-*.txz
mkdir ${currentPackage}-stripped
cp --parents -P usr/lib$SYSTEMBITS/libLLVM*.so* ${currentPackage}-stripped
cd ${currentPackage}-stripped
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${packageFileName}_stripped.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=mesa
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv ../packages/${currentPackage}-[0-9]* .
packageFileName=$(ls * -a | rev | cut -d . -f 2- | rev)
ROOT=./ installpkg ${currentPackage}-*.txz && rm ${currentPackage}-*.txz
rm -fr etc/OpenCL
rm usr/lib${SYSTEMBITS}/dri/i830*
rm usr/lib${SYSTEMBITS}/dri/i965*
rm usr/lib${SYSTEMBITS}/dri/nouveau_vieux*
rm usr/lib${SYSTEMBITS}/dri/r200*
rm usr/lib${SYSTEMBITS}/dri/radeon_dri*
rm usr/lib${SYSTEMBITS}/libMesaOpenCL*
rm usr/lib${SYSTEMBITS}/libRusticlOpenCL*
rm -fr var/lib/pkgtools
rm -fr var/log
mkdir ${currentPackage}-stripped
rsync -av * ${currentPackage}-stripped/ --exclude=${currentPackage}-stripped/
cd ${currentPackage}-stripped
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${packageFileName}_stripped.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=pulseaudio
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv ../packages/${currentPackage}*.txz .
packageFileName=$(ls * -a | rev | cut -d . -f 2- | rev)
ROOT=./ installpkg ${currentPackage}-*.txz
mkdir ${currentPackage}-stripped
cp --parents -P usr/bin/pactl ${currentPackage}-stripped
cp --parents -P usr/lib$SYSTEMBITS/libpulse.so* ${currentPackage}-stripped
cp --parents -P usr/lib$SYSTEMBITS/libpulse-mainloop-glib.so* ${currentPackage}-stripped
cp --parents -P usr/lib$SYSTEMBITS/libpulse-simple.so* ${currentPackage}-stripped
cp --parents -P usr/lib$SYSTEMBITS/pulseaudio/libpulsecommon* ${currentPackage}-stripped
cp --parents -Pr usr/lib$SYSTEMBITS/cmake/* ${currentPackage}-stripped
cp --parents -Pr usr/lib$SYSTEMBITS/pkgconfig/* ${currentPackage}-stripped
cp --parents -Pr usr/include/* ${currentPackage}-stripped
cd ${currentPackage}-stripped
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${packageFileName}_stripped.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=vulkan-sdk
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv ../packages/${currentPackage}*.txz .
packageFileName=$(ls * -a | rev | cut -d . -f 2- | rev)
ROOT=./ installpkg ${currentPackage}-*.txz
mkdir ${currentPackage}-stripped
cp --parents -Pr usr/include/vk_video ${currentPackage}-stripped
cp --parents -P usr/include/vulkan/* ${currentPackage}-stripped > /dev/null 2>&1
cp --parents -Pr usr/lib$SYSTEMBITS/cmake ${currentPackage}-stripped
cp --parents -P usr/lib$SYSTEMBITS/pkgconfig/vulkan.pc ${currentPackage}-stripped
cp --parents -P usr/lib$SYSTEMBITS/libvulkan.so* ${currentPackage}-stripped
if [ $SLACKWAREVERSION == "current" ]; then
	cp --parents -Pr usr/include/spirv-tools ${currentPackage}-stripped
	cp --parents -P usr/lib$SYSTEMBITS/pkgconfig/SPIRV-Tools* ${currentPackage}-stripped
	cp --parents -P usr/lib$SYSTEMBITS/libSPIRV-Tools.so* ${currentPackage}-stripped
fi
cp --parents -P usr/bin/vulkaninfo ${currentPackage}-stripped
cd ${currentPackage}-stripped
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${packageFileName}_stripped.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

### install poppler so it can be used by next modules

installpkg $MODULEPATH/packages/poppler*.txz

### fake root

cd $MODULEPATH/packages && ROOT=./ installpkg *.t?z
rm *.t?z

### install additional packages, including porteux utils

InstallAdditionalPackages

### fix applications shortcuts

sed -i "s|Exec=.*|Exec=psu /usr/bin/gparted %f|g" $MODULEPATH/packages/usr/share/applications/gparted.desktop

### fix symlinks

cd $MODULEPATH/packages/etc/X11/xinit/
cp -fs xinitrc.openbox-session xinitrc

### add xzm to freedesktop.org.xml

patch --no-backup-if-mismatch -d $MODULEPATH/packages -p0 < $SCRIPTPATH/extras/freedesktop/freedesktop.org.xml.patch || exit 1

### fix gtk2 adwaita theme cursor click on text box having wrong offset

sed -i "s|GtkEntry::inner-border = {7, 7, 4, 5}|GtkEntry::inner-border = {2, 2, 7, 7}|g" $MODULEPATH/packages/usr/share/themes/Adwaita-dark/gtk-2.0/main.rc
sed -i "s|GtkEntry::inner-border = {7, 7, 4, 5}|GtkEntry::inner-border = {2, 2, 7, 7}|g" $MODULEPATH/packages/usr/share/themes/Adwaita/gtk-2.0/main.rc

### copy build files to 05-devel

CopyToDevel

### copy language files to 08-multilanguage

CopyToMultiLanguage

### module clean up

cd $MODULEPATH/packages/

{
rm etc/rc_maps.cfg
rm etc/xdg/autostart/at-spi-dbus-bus.desktop
rm usr/bin/canberra*
rm usr/bin/qv4l2
rm usr/bin/qvidcap
rm usr/bin/Xdmx

rm usr/lib${SYSTEMBITS}/gtk-2.0/modules/libcanberra-gtk-module.*
rm usr/lib${SYSTEMBITS}/libbd_vdo.*
rm usr/lib${SYSTEMBITS}/libcanberra-gtk.*
rm usr/lib${SYSTEMBITS}/libpoppler-cpp*
rm usr/lib${SYSTEMBITS}/libxatracker*
rm usr/lib${SYSTEMBITS}/libXaw.so.6*
rm usr/lib${SYSTEMBITS}/libXaw6*
rm usr/share/applications/gcr-prompter.desktop
rm usr/share/applications/gcr-viewer.desktop
rm usr/share/applications/gtk3-icon-browser.desktop
rm usr/share/applications/gtk3-widget-factory.desktop
rm usr/share/applications/mimeinfo.cache
rm usr/share/applications/qv4l2.desktop
rm usr/share/applications/qvidcap.desktop
rm usr/share/applications/xterm.desktop
rm usr/share/fonts/TTF/Deja*Condensed*
rm usr/share/fonts/TTF/Deja*Italic*
rm usr/share/fonts/TTF/DejaVuMathTeXGyre.ttf
rm usr/share/fonts/TTF/DejaVuSans-BoldOblique.ttf
rm usr/share/fonts/TTF/DejaVuSans-ExtraLight.ttf
rm usr/share/fonts/TTF/DejaVuSansMono-Oblique.ttf
rm usr/share/fonts/TTF/DejaVuSans-Oblique.ttf
rm usr/share/icons/hicolor/scalable/apps/qv4l2.svg
rm usr/share/icons/hicolor/scalable/apps/qvidcap.svg

rm -fr etc/pam.d
rm -fr etc/rc_keymaps
rm -fr etc/X11/xorg.conf.d
rm -fr etc/xdg/Xwayland-session.d
rm -fr usr/lib${SYSTEMBITS}/atkmm-*
rm -fr usr/lib${SYSTEMBITS}/cairomm-*
rm -fr usr/lib${SYSTEMBITS}/clang
rm -fr usr/lib${SYSTEMBITS}/gdkmm-*
rm -fr usr/lib${SYSTEMBITS}/giomm-*
rm -fr usr/lib${SYSTEMBITS}/glibmm-*
rm -fr usr/lib${SYSTEMBITS}/gnome-settings-daemon-*
rm -fr usr/lib${SYSTEMBITS}/graphene-*
rm -fr usr/lib${SYSTEMBITS}/gtkmm-*
rm -fr usr/lib${SYSTEMBITS}/libxslt-plugins
rm -fr usr/lib${SYSTEMBITS}/openjpeg-*
rm -fr usr/lib${SYSTEMBITS}/pangomm-*
rm -fr usr/lib${SYSTEMBITS}/sigc++-*
rm -fr usr/lib${SYSTEMBITS}/xmms
rm -fr usr/libexec/upower/tests
rm -fr usr/share/gdm
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

[ $SLACKWAREVERSION == "current" ] && rm usr/lib${SYSTEMBITS}/libpoppler-qt5*

find usr/share/icons/hicolor -name 'image-vnd.djvu.png' -delete

find $MODULEPATH/packages/usr/lib${SYSTEMBITS}/dri -name '*.la' -delete

# move out things that don't support stripping
mv $MODULEPATH/packages/usr/lib${SYSTEMBITS}/dri $MODULEPATH/
mv $MODULEPATH/packages/usr/lib${SYSTEMBITS}/libgallium* $MODULEPATH/
mv $MODULEPATH/packages/usr/lib${SYSTEMBITS}/libvulkan* $MODULEPATH/
mv $MODULEPATH/packages/usr/lib${SYSTEMBITS}/libX11.so* $MODULEPATH/
mv $MODULEPATH/packages/usr/libexec/gpartedbin $MODULEPATH/
GenericStrip
AggressiveStrip
mv $MODULEPATH/dri $MODULEPATH/packages/usr/lib${SYSTEMBITS}/
mv $MODULEPATH/libgallium* $MODULEPATH/packages/usr/lib${SYSTEMBITS}/
mv $MODULEPATH/libvulkan* $MODULEPATH/packages/usr/lib${SYSTEMBITS}/
mv $MODULEPATH/libX11.so* $MODULEPATH/packages/usr/lib${SYSTEMBITS}/
mv $MODULEPATH/gpartedbin $MODULEPATH/packages/usr/libexec

# specific strip
mkdir $MODULEPATH/tostrip
mv $MODULEPATH/packages/usr/lib${SYSTEMBITS}/libLLVM* $MODULEPATH/tostrip
cd $MODULEPATH/tostrip
AggressiveStripAll
mv $MODULEPATH/tostrip/libLLVM* $MODULEPATH/packages/usr/lib${SYSTEMBITS}
rm -fr $MODULEPATH/tostrip

### copy cache files

PrepareFilesForCache

### generate cache files

GenerateCaches

### finalize

Finalize
