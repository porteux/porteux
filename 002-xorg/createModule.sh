#!/bin/sh
MODULENAME=002-xorg

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

### packages that require specific stripping

currentPackage=boost
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv ../packages/${currentPackage}-[0-9]* .
version=`ls * -a | cut -d'-' -f2- | sed 's/\.txz$//'`
ROOT=./ installpkg ${currentPackage}-*.txz
mkdir ${currentPackage}-stripped-$version
cp --parents -P usr/lib$SYSTEMBITS/libboost_atomic.so.* ${currentPackage}-stripped-$version
cp --parents -P usr/lib$SYSTEMBITS/libboost_program_options.so.* ${currentPackage}-stripped-$version
cd $MODULEPATH/${currentPackage}/${currentPackage}-stripped-$version
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-stripped-$version.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=llvm
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv ../packages/${currentPackage}-[0-9]* .
version=`ls * -a | cut -d'-' -f2- | sed 's/\.txz$//'`
ROOT=./ installpkg ${currentPackage}-*.txz
mkdir ${currentPackage}-stripped-$version
cp --parents -P usr/lib$SYSTEMBITS/LLVMgold.so ${currentPackage}-stripped-$version
cp --parents -P usr/lib$SYSTEMBITS/libLLVM*.so* ${currentPackage}-stripped-$version
cd ${currentPackage}-stripped-$version
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-stripped-$version.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=vulkan-sdk
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv ../packages/${currentPackage}-[0-9]* .
version=`ls * -a | cut -d'-' -f3- | sed 's/\.txz$//'`
ROOT=./ installpkg ${currentPackage}-*.txz
mkdir ${currentPackage}-stripped-$version
cp --parents -P usr/lib$SYSTEMBITS/libvulkan.so* ${currentPackage}-stripped-$version
cd ${currentPackage}-stripped-$version
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-stripped-$version.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

### packages outside slackware repository ###

currentPackage=archivemount
version=0.9.1
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/system/${currentPackage}/ -A * || exit 1
wget --no-check-certificate https://www.cybernoia.de/software/archivemount/archivemount-$version.tar.gz || exit 1
mv $MODULEPATH/packages/fuse-*.txz .
installpkg fuse-*.txz || exit 1
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" ${currentPackage}.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" ${currentPackage}.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
rm -fr $MODULEPATH/${currentPackage}

# todo: get gtk version from slackware and use it to download the matched gtk classic version
currentPackage=gtk+3
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
#version=`ls *.tar.?z -a | cut -d'-' -f2- | cut -d'-' -f1`
#wget https://github.com/lah7/gtk3-classic/releases/download/$version/gtk3-classic-$version-1-x86_64.pkg.tar.zst
info=$(DownloadLatestSourceFromGithub "lah7" "gtk3-classic")
filename=${info% *}
tar xvf "$filename" && rm "$filename" || exit 1
sed -i "s|+++ .*/gtk/|+++ gtk/|g" gtk3-classic*/*.patch
sed -i "s|+++ .*/gdk/|+++ gdk/|g" gtk3-classic*/*.patch
rm gtk3-classic*/gtk+-atk-bridge-meson.build.patch
rm gtk3-classic*/gtk+-atk-bridge-meson_options.txt.patch
wget -r -nd --no-parent -l1 $SOURCEREPOSITORY/l/${currentPackage}/ || exit 1
sed -i "s|# Configure, build, and install:|cp -r $PWD/gtk3-classic*/* /tmp/gtk+-\$VERSION/\nfor i in *.patch; do patch -p0 < \$i; done\n\n# Configure, build, and install:|g" ${currentPackage}.SlackBuild
sed -i "s|Ddemos=true|Ddemos=false|g" ${currentPackage}.SlackBuild
sed -i "s|Dgtk_doc=true|Dgtk_doc=false|g" ${currentPackage}.SlackBuild
sed -i "s|-\${VERSION}-\$ARCH-\${BUILD}|-classic-\${VERSION}-\$ARCH-\${BUILD}|g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
rm -fr $MODULEPATH/${currentPackage}

currentPackage=galculator
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/academic/${currentPackage}/ -A * || exit 1
info=$(DownloadLatestFromGithub "galculator" "galculator")
version=${info#* }
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" ${currentPackage}.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" ${currentPackage}.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" ${currentPackage}.SlackBuild
sed -i "s|--prefix=/usr |--prefix=/usr --disable-quadmath |g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
rm -fr $MODULEPATH/${currentPackage}

currentPackage=imlib2
version=1.7.4
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/libraries/${currentPackage}/ -A * || exit 1
wget https://netactuate.dl.sourceforge.net/project/enlightenment/imlib2-src/$version/imlib2-$version.tar.bz2 || exit 1
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" ${currentPackage}.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" ${currentPackage}.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
rm -fr $MODULEPATH/${currentPackage}

currentPackage=libdaemon
version=0.14
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/libraries/${currentPackage}/ -A * || exit 1
wget http://0pointer.de/lennart/projects/libdaemon/${currentPackage}-$version.tar.gz || exit 1
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" ${currentPackage}.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" ${currentPackage}.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
rm -fr $MODULEPATH/${currentPackage}

currentPackage=nss-mdns
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/network/${currentPackage}/ -A * || exit 1
info=$(DownloadLatestFromGithub "lathiat" "nss-mdns")
version=${info#* }
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" ${currentPackage}.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" ${currentPackage}.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
rm -fr $MODULEPATH/${currentPackage}

currentPackage=openbox
version=3.6.1
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/desktop/${currentPackage}/ -A * || exit 1
wget http://openbox.org/dist/openbox/openbox-$version.tar.xz || exit 1
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" ${currentPackage}.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" ${currentPackage}.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" ${currentPackage}.SlackBuild
sed -z -i "s|make\n|make -j8\n|g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
rm -fr $MODULEPATH/${currentPackage}

currentPackage=webp-pixbuf-loader
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/graphics/${currentPackage}/ -A * || exit 1
info=$(DownloadLatestFromGithub "aruiz" "webp-pixbuf-loader")
version=${info#* }
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" ${currentPackage}.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" ${currentPackage}.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" ${currentPackage}.SlackBuild
sed -i "s|cp -a LICENSE|#cp -a LICENSE|g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
rm -fr $MODULEPATH/${currentPackage}

currentPackage=xclip
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/misc/${currentPackage}/ -A * || exit 1
info=$(DownloadLatestFromGithub "astrand" "xclip")
version=${info#* }
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" ${currentPackage}.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" ${currentPackage}.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
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
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-$version-noarch.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

### install poppler so it can be used by the further modules

installpkg $MODULEPATH/packages/poppler*.txz

### fake root

cd $MODULEPATH/packages && ROOT=./ installpkg *.t?z
rm *.t?z

### install additional packages, including porteux utils

InstallAdditionalPackages

### fix symlinks

cd $MODULEPATH/packages/etc/X11/xinit/
cp -fs xinitrc.openbox-session xinitrc

### add xzm to freedesktop.org.xml

patch --no-backup-if-mismatch -d $MODULEPATH/packages -p0 < $SCRIPTPATH/extras/freedesktop/freedesktop.org.xml.patch

### copy build files to 05-devel

CopyToDevel

### module clean up

cd $MODULEPATH/packages/

rm -R etc/OpenCL
rm -R etc/X11/xorg.conf.d
rm -R etc/pam.d
rm -R etc/rc_keymaps
rm -R etc/xdg/Xwayland-session.d
rm -R usr/lib
rm -R usr/lib64/atkmm-*
rm -R usr/lib64/cairomm-*
rm -R usr/lib64/clang
rm -R usr/lib64/dri/*.la
rm -R usr/lib64/gdkmm-*
rm -R usr/lib64/giomm-*
rm -R usr/lib64/glibmm-*
rm -R usr/lib64/gnome-settings-daemon-*
rm -R usr/lib64/gtkmm-*
rm -R usr/lib64/openjpeg-*
rm -R usr/lib64/pangomm-*
rm -R usr/lib64/python2*
rm -R usr/lib64/sigc++-*
rm -R usr/lib64/xmms
rm -R usr/share/gnome
rm -R usr/share/gnome-session
rm -R usr/share/gobject-introspection-1.0/tests
rm -R usr/share/graphite2
rm -R usr/share/gtk-*
rm -R usr/share/imlib2
rm -R usr/share/libcaca
rm -R usr/share/libgphoto2/*/konica/french
rm -R usr/share/libgphoto2/*/konica/german
rm -R usr/share/libgphoto2/*/konica/japanese
rm -R usr/share/libgphoto2/*/konica/korean
rm -R usr/share/libgphoto2/*/konica/spanish
rm -R usr/share/libgphoto2_port
rm -R usr/share/themes/Artwiz-boxed
rm -R usr/share/themes/Bear2
rm -R usr/share/themes/Clearlooks-3.4
rm -R usr/share/themes/Clearlooks-Olive
rm -R usr/share/themes/Mikachu
rm -R usr/share/themes/Natura
rm -R usr/share/themes/Orang
rm -R usr/share/X11/locale/am_ET.UTF-8
rm -R usr/share/X11/locale/cs_CZ.UTF-8
rm -R usr/share/X11/locale/el_GR.UTF-8
rm -R usr/share/X11/locale/fi_FI.UTF-8
rm -R usr/share/X11/locale/ja
rm -R usr/share/X11/locale/ja.JIS
rm -R usr/share/X11/locale/ja.SJIS
rm -R usr/share/X11/locale/ja_JP.UTF-8
rm -R usr/share/X11/locale/km_KH.UTF-8
rm -R usr/share/X11/locale/ko_KR.UTF-8
rm -R usr/share/X11/locale/pt_BR.UTF-8
rm -R usr/share/X11/locale/pt_PT.UTF-8
rm -R usr/share/X11/locale/ru_RU.UTF-8
rm -R usr/share/X11/locale/sr_RS.UTF-8
rm -R usr/share/X11/locale/tatar-cyr
rm -R usr/share/X11/locale/th_TH
rm -R usr/share/X11/locale/th_TH.UTF-8
rm -R usr/share/X11/locale/vi_VN.tcvn
rm -R usr/share/X11/locale/vi_VN.viscii
rm -R usr/share/X11/locale/zh_CN
rm -R usr/share/X11/locale/zh_CN.UTF-8
rm -R usr/share/X11/locale/zh_CN.gb18030
rm -R usr/share/X11/locale/zh_CN.gbk
rm -R usr/share/X11/locale/zh_HK.UTF-8
rm -R usr/share/X11/locale/zh_HK.big5
rm -R usr/share/X11/locale/zh_HK.big5hkscs
rm -R usr/share/X11/locale/zh_TW
rm -R usr/share/X11/locale/zh_TW.UTF-8
rm -R usr/share/X11/locale/zh_TW.big5
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
rm usr/bin/qv4l2
rm usr/bin/qvidcap
rm usr/bin/rsvg-convert
rm usr/bin/Xdmx
rm usr/share/applications/gcr-prompter.desktop
rm usr/share/applications/gcr-viewer.desktop
rm usr/share/applications/mimeinfo.cache
rm usr/share/applications/qv4l2.desktop
rm usr/share/applications/qvidcap.desktop
rm usr/share/applications/xterm.desktop
rm usr/share/fonts/TTF/Deja*Condensed*
rm usr/share/fonts/TTF/Deja*Italic*
rm usr/share/fonts/TTF/DejaVuMathTeXGyre.ttf
rm usr/share/fonts/TTF/DejaVuSans-BoldOblique.ttf
rm usr/share/fonts/TTF/DejaVuSans-ExtraLight.ttf
rm usr/share/fonts/TTF/DejaVuSans-Oblique.ttf
rm usr/share/fonts/TTF/DejaVuSansMono-Oblique.ttf
rm usr/share/icons/hicolor/scalable/apps/qv4l2.svg
rm usr/share/icons/hicolor/scalable/apps/qvidcap.svg
rm usr/share/xsessions/openbox-gnome.desktop
rm usr/share/xsessions/openbox-kde.desktop

find usr/share/icons/hicolor -name 'image-vnd.djvu.png' -delete

# move out things that don't support stripping
mv $MODULEPATH/packages/usr/lib64/dri $MODULEPATH/
mv $MODULEPATH/packages/usr/libexec/gpartedbin $MODULEPATH/
GenericStrip
AggressiveStrip
mv $MODULEPATH/dri $MODULEPATH/packages/usr/lib64/
mv $MODULEPATH/gpartedbin $MODULEPATH/packages/usr/libexec

### copy cache files

PrepareFilesForCache

### generate cache files

GenerateCaches

### finalize

Finalize
