#!/bin/sh

MODULENAME=002-gui

source "$PWD/../builder-utils/setflags.sh"

SetFlags "$MODULENAME"

source "$PWD/../builder-utils/cachefiles.sh"
source "$PWD/../builder-utils/downloadfromslackware.sh"
source "$PWD/../builder-utils/genericstrip.sh"
source "$PWD/../builder-utils/helper.sh"
source "$PWD/../builder-utils/latestfromgithub.sh"

### create module folder

mkdir -p $MODULEPATH/packages > /dev/null 2>&1

### download packages from slackware repositories

DownloadFromSlackware

### packages outside slackware repository

currentPackage=archivemount
version=0.9.1
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/system/${currentPackage}/ -A * || exit 1
wget --no-check-certificate https://www.cybernoia.de/software/${currentPackage}/${currentPackage}-$version.tar.gz || exit 1
mv $MODULEPATH/packages/fuse-*.txz .
installpkg fuse-*.txz || exit 1
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" ${currentPackage}.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" ${currentPackage}.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" ${currentPackage}.SlackBuild
sed -i "s|-O2 |$GCCFLAGS -flto |g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
rm -fr $MODULEPATH/${currentPackage}

if [ $SLACKWAREVERSION != "current" ]; then
	currentPackage=meson
	sh $SCRIPTPATH/../extras/${currentPackage}/${currentPackage}.SlackBuild || exit 1
	/sbin/upgradepkg --install-new --reinstall $MODULEPATH/packages/${currentPackage}-*.txz
	rm -fr $MODULEPATH/${currentPackage}
	rm $MODULEPATH/packages/meson-*.txz
fi

currentPackage=gtk+3
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget https://github.com/lah7/gtk3-classic/archive/refs/heads/master.tar.gz || exit 1
tar xvf master.tar.gz && rm master.tar.gz || exit 1
rm gtk3-classic*/gtk+-atk-bridge-meson.build.patch
rm gtk3-classic*/gtk+-atk-bridge-meson_options.txt.patch
rm gtk3-classic*/appearance__disable-backdrop.patch
sed -i "s|+++ .*/gtk/|+++ gtk/|g" gtk3-classic*/*.patch
sed -i "s|+++ .*/gdk/|+++ gdk/|g" gtk3-classic*/*.patch
wget -r -nd --no-parent -l1 $SOURCEREPOSITORY/l/${currentPackage}/ || exit 1
sed -i "s|# Configure, build, and install:|cp -r $PWD/gtk3-classic*/* /tmp/gtk+-\$VERSION/\nfor i in *.patch; do patch -p0 < \$i; done\n\n# Configure, build, and install:|g" ${currentPackage}.SlackBuild
sed -i "s|Ddemos=true|Ddemos=false|g" ${currentPackage}.SlackBuild
sed -i "s|Dgtk_doc=true|Dgtk_doc=false|g" ${currentPackage}.SlackBuild
sed -i "s|Dman=true|Dman=false|g" ${currentPackage}.SlackBuild
sed -i "s|-\${VERSION}-\$ARCH-\${BUILD}|-classic-\${VERSION}-\$ARCH-\${BUILD}|g" ${currentPackage}.SlackBuild
sed -i "s|-O2 |$GCCFLAGS -flto |g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
rm -fr $MODULEPATH/${currentPackage}

currentPackage=galculator
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/academic/${currentPackage}/ -A * || exit 1
info=$(DownloadLatestFromGithub "${currentPackage}" "${currentPackage}")
version=${info#* }
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" ${currentPackage}.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" ${currentPackage}.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" ${currentPackage}.SlackBuild
sed -i "s|-O2 |$GCCFLAGS -flto |g" ${currentPackage}.SlackBuild
sed -i "s|--prefix=/usr |--prefix=/usr --disable-quadmath |g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
rm -fr $MODULEPATH/${currentPackage}

currentPackage=imlib2
version="1.12.1"
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/libraries/${currentPackage}/ -A * || exit 1
wget https://sourceforge.net/projects/enlightenment/files/${currentPackage}-src/$version/${currentPackage}-$version.tar.xz || exit 1
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" ${currentPackage}.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" ${currentPackage}.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" ${currentPackage}.SlackBuild
sed -i "s|-O2 |$GCCFLAGS -flto |g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
rm -fr $MODULEPATH/${currentPackage}

currentPackage=openbox
version="3.6.1"
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/desktop/${currentPackage}/ -A * || exit 1
wget http://openbox.org/dist/${currentPackage}/${currentPackage}-$version.tar.xz || exit 1
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" ${currentPackage}.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" ${currentPackage}.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" ${currentPackage}.SlackBuild
sed -i "s|patch -p1 < \$CWD/py2-to-py3.patch|cp \$CWD/*.patch .|g" ${currentPackage}.SlackBuild
sed -i "s|\$CWD/patches/\*|\*.patch|g" ${currentPackage}.SlackBuild
sed -i "s|-O2 |$GCCFLAGS -flto |g" ${currentPackage}.SlackBuild
sed -z -i "s|make\n|make -j${NUMBERTHREADS}\n|g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
rm -fr $MODULEPATH/${currentPackage}

currentPackage=webp-pixbuf-loader
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/graphics/${currentPackage}/ -A * || exit 1
info=$(DownloadLatestFromGithub "aruiz" "${currentPackage}")
version=${info#* }
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" ${currentPackage}.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" ${currentPackage}.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" ${currentPackage}.SlackBuild
sed -i "s|-O2 |$GCCFLAGS -flto |g" ${currentPackage}.SlackBuild
sed -i "s|cp -a LICENSE|#cp -a LICENSE|g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
rm -fr $MODULEPATH/${currentPackage}

currentPackage=libjxl
sh $SCRIPTPATH/extras/${currentPackage}/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=pipewire
sh $SCRIPTPATH/extras/${currentPackage}/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=wireplumber
sh $SCRIPTPATH/extras/${currentPackage}/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=paper-icon-theme
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget https://github.com/snwh/${currentPackage}/archive/refs/heads/master.tar.gz || exit 1
tar xvf master.tar.gz && rm master.tar.gz || exit 1
cd ${currentPackage}-master
version=$(date -r . +%Y%m%d)
iconRootFolder=../${currentPackage}-$version-noarch/usr/share/icons/Paper
mkdir -p $iconRootFolder
cp -r Paper/cursors $iconRootFolder
cp -r Paper/cursor.theme $iconRootFolder
cd ../${currentPackage}-$version-noarch
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-$version-noarch-1.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

### packages that require specific stripping

currentPackage=llvm
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv ../packages/${currentPackage}*.txz .
version=`ls * -a | cut -d'-' -f2- | sed 's/\.txz$//'`
ROOT=./ installpkg ${currentPackage}-*.txz
mkdir ${currentPackage}-stripped-$version
cp --parents -P usr/lib$SYSTEMBITS/libLLVM*.so* ${currentPackage}-stripped-$version
cd ${currentPackage}-stripped-$version
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-stripped-$version-1.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=vulkan-sdk
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv ../packages/${currentPackage}*.txz .
version=`ls * -a | cut -d'-' -f3- | sed 's/\.txz$//'`
ROOT=./ installpkg ${currentPackage}-*.txz
mkdir ${currentPackage}-stripped-$version
cp --parents -P usr/lib$SYSTEMBITS/libvulkan.so* ${currentPackage}-stripped-$version
cp --parents -P usr/bin/vulkaninfo ${currentPackage}-stripped-$version
cd ${currentPackage}-stripped-$version
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-stripped-$version-1.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=pulseaudio
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv ../packages/${currentPackage}*.txz .
version=`ls * -a | cut -d'-' -f3- | sed 's/\.txz$//'`
ROOT=./ installpkg ${currentPackage}-*.txz
mkdir ${currentPackage}-stripped-$version
cp --parents -P usr/lib$SYSTEMBITS/libpulse.so* ${currentPackage}-stripped-$version
cp --parents -P usr/lib$SYSTEMBITS/libpulse-mainloop-glib.so* ${currentPackage}-stripped-$version
cp --parents -P usr/lib$SYSTEMBITS/libpulse-simple.so* ${currentPackage}-stripped-$version
cp --parents -P usr/lib$SYSTEMBITS/pulseaudio/libpulsecommon* ${currentPackage}-stripped-$version
cp --parents -P -r usr/lib$SYSTEMBITS/cmake/* $MODULEPATH/../05-devel/packages
cp --parents -P -r usr/lib$SYSTEMBITS/pkgconfig/* $MODULEPATH/../05-devel/packages
cp --parents -P -r usr/include/* $MODULEPATH/../05-devel/packages
cd ${currentPackage}-stripped-$version
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-stripped-$version-1.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

### install poppler so it can be used by the further modules

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

mv $MODULEPATH/packages/usr/lib${SYSTEMBITS}/gobject-introspection $PORTEUXBUILDERPATH/05-devel/packages/usr/lib${SYSTEMBITS}

### module clean up

cd $MODULEPATH/packages/

rm -R etc/OpenCL
rm -R etc/pam.d
rm -R etc/rc_keymaps
rm -R etc/X11/xorg.conf.d
rm -R etc/xdg/Xwayland-session.d
rm -R usr/lib${SYSTEMBITS}/atkmm-*
rm -R usr/lib${SYSTEMBITS}/cairomm-*
rm -R usr/lib${SYSTEMBITS}/clang
rm -R usr/lib${SYSTEMBITS}/dri/*.la
rm -R usr/lib${SYSTEMBITS}/gdkmm-*
rm -R usr/lib${SYSTEMBITS}/giomm-*
rm -R usr/lib${SYSTEMBITS}/glibmm-*
rm -R usr/lib${SYSTEMBITS}/gnome-settings-daemon-*
rm -R usr/lib${SYSTEMBITS}/graphene-1.0
rm -R usr/lib${SYSTEMBITS}/gtkmm-*
rm -R usr/lib${SYSTEMBITS}/libxslt-plugins
rm -R usr/lib${SYSTEMBITS}/openjpeg-*
rm -R usr/lib${SYSTEMBITS}/pangomm-*
rm -R usr/lib${SYSTEMBITS}/python2*
rm -R usr/lib${SYSTEMBITS}/sigc++-*
rm -R usr/lib${SYSTEMBITS}/xmms
rm -R usr/share/gnome
rm -R usr/share/gnome-session
rm -R usr/share/gobject-introspection-1.0/tests
rm -R usr/share/graphite2
rm -R usr/share/gst-plugins-base
rm -R usr/share/gstreamer-1.0/gdb
rm -R usr/share/gtk-*
rm -R usr/share/imlib2
rm -R usr/share/libcaca
rm -R usr/share/libgphoto2/*/konica/french
rm -R usr/share/libgphoto2/*/konica/german
rm -R usr/share/libgphoto2/*/konica/japanese
rm -R usr/share/libgphoto2/*/konica/korean
rm -R usr/share/libgphoto2/*/konica/spanish
rm -R usr/share/libgphoto2_port
rm -R usr/share/svgalib-demos
rm -R usr/share/themes/Artwiz-boxed
rm -R usr/share/themes/Bear2
rm -R usr/share/themes/Clearlooks-3.4
rm -R usr/share/themes/Clearlooks-Olive
rm -R usr/share/themes/Mikachu
rm -R usr/share/themes/Natura
rm -R usr/share/themes/Orang
rm -R usr/share/X11/locale/am*
rm -R usr/share/X11/locale/cs*
rm -R usr/share/X11/locale/el*
rm -R usr/share/X11/locale/fi*
rm -R usr/share/X11/locale/georgian*
rm -R usr/share/X11/locale/ja*
rm -R usr/share/X11/locale/km*
rm -R usr/share/X11/locale/ko*
rm -R usr/share/X11/locale/mulelao*
rm -R usr/share/X11/locale/nokhchi*
rm -R usr/share/X11/locale/pt*
rm -R usr/share/X11/locale/ru*
rm -R usr/share/X11/locale/sr*
rm -R usr/share/X11/locale/tatar-cyr
rm -R usr/share/X11/locale/th*
rm -R usr/share/X11/locale/vi*
rm -R usr/share/X11/locale/zh*
rm -R usr/X11R6/include
rm -R usr/X11R6/man

rm etc/profile.d/vte.csh
rm etc/profile.d/vte.sh
rm etc/rc_maps.cfg
rm etc/xdg/autostart/at-spi-dbus-bus.desktop
rm usr/bin/cacaclock
rm usr/bin/cacademo
rm usr/bin/cacafire
rm usr/bin/gdm-control
rm usr/bin/gnome-panel-control
rm usr/bin/gtk3-demo
rm usr/bin/gtk3-demo-application
rm usr/bin/qv4l2
rm usr/bin/qvidcap
rm usr/bin/rsvg-convert
rm usr/bin/Xdmx
rm usr/lib${SYSTEMBITS}/libbd_vdo.*
rm usr/lib${SYSTEMBITS}/libLLVMExtensions*
rm usr/lib${SYSTEMBITS}/libLLVMLTO*
rm usr/lib${SYSTEMBITS}/libMesaOpenCL*
rm usr/lib${SYSTEMBITS}/libpoppler-cpp*
rm usr/lib${SYSTEMBITS}/libRusticlOpenCL*
rm usr/share/applications/gcr-prompter.desktop
rm usr/share/applications/gcr-viewer.desktop
rm usr/share/applications/gtk3-demo.desktop
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
rm usr/share/xsessions/openbox-gnome.desktop
rm usr/share/xsessions/openbox-kde.desktop

find usr/share/icons/hicolor -name 'image-vnd.djvu.png' -delete

# move out things that don't support stripping
mv $MODULEPATH/packages/usr/lib${SYSTEMBITS}/dri $MODULEPATH/
mv $MODULEPATH/packages/usr/lib${SYSTEMBITS}/libgallium* $MODULEPATH/
mv $MODULEPATH/packages/usr/libexec/gpartedbin $MODULEPATH/
GenericStrip
AggressiveStrip
mv $MODULEPATH/dri $MODULEPATH/packages/usr/lib${SYSTEMBITS}/
mv $MODULEPATH/libgallium* $MODULEPATH/packages/usr/lib${SYSTEMBITS}/
mv $MODULEPATH/gpartedbin $MODULEPATH/packages/usr/libexec

### copy cache files

PrepareFilesForCache

### generate cache files

GenerateCaches

### finalize

Finalize
