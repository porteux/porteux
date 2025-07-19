#!/bin/bash

MODULENAME=003-lxqt

source "$PWD/../builder-utils/setflags.sh"

SetFlags "$MODULENAME"

source "$BUILDERUTILSPATH/cachefiles.sh"
source "$BUILDERUTILSPATH/downloadfromslackware.sh"
source "$BUILDERUTILSPATH/genericstrip.sh"
source "$BUILDERUTILSPATH/helper.sh"
source "$BUILDERUTILSPATH/latestfromgithub.sh"

[ $SLACKWAREVERSION != "current" ] && echo "This module should be built in current only" && exit 1

if ! isRoot; then
	echo "Please enter admin's password below:"
	su -c "$0 $1"
	exit
fi

### create module folder

mkdir -p $MODULEPATH/packages > /dev/null 2>&1

### download packages from slackware repositories

DownloadFromSlackware

### packages that require specific stripping

currentPackage=qt6
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv $MODULEPATH/packages/${currentPackage}-[0-9]* .
installpkg ${currentPackage}*.txz || exit 1
version=`ls * -a | cut -d'-' -f2- | sed 's/\.txz$//'`
ROOT=./ installpkg ${currentPackage}-*.txz
mkdir ${currentPackage}-stripped-$version
cp --parents -P usr/lib$SYSTEMBITS/libQt6Concurrent.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6Core.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6DBus.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6Gui.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6Network.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6Pdf.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6PrintSupport.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6Svg.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6SvgWidgets.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6WaylandClient.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6Widgets.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6XcbQpa.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6Xml.* "${currentPackage}-stripped-$version"
cp --parents -f usr/lib$SYSTEMBITS/qt6/plugins/egldeviceintegrations/* "${currentPackage}-stripped-$version"
cp --parents -f usr/lib$SYSTEMBITS/qt6/plugins/iconengines/* "${currentPackage}-stripped-$version"
cp --parents -f usr/lib$SYSTEMBITS/qt6/plugins/imageformats/* "${currentPackage}-stripped-$version"
cp --parents -f usr/lib$SYSTEMBITS/qt6/plugins/platforminputcontexts/* "${currentPackage}-stripped-$version"
cp --parents -f usr/lib$SYSTEMBITS/qt6/plugins/platforms/libqeglfs.so "${currentPackage}-stripped-$version"
cp --parents -f usr/lib$SYSTEMBITS/qt6/plugins/platforms/libqlinuxfb.so "${currentPackage}-stripped-$version"
cp --parents -f usr/lib$SYSTEMBITS/qt6/plugins/platforms/libqminimal.so "${currentPackage}-stripped-$version"
cp --parents -f usr/lib$SYSTEMBITS/qt6/plugins/platforms/libqminimalegl.so "${currentPackage}-stripped-$version"
cp --parents -f usr/lib$SYSTEMBITS/qt6/plugins/platforms/libqoffscreen.so "${currentPackage}-stripped-$version"
cp --parents -f usr/lib$SYSTEMBITS/qt6/plugins/platforms/libqvnc.so "${currentPackage}-stripped-$version"
cp --parents -f usr/lib$SYSTEMBITS/qt6/plugins/platforms/libqwayland*.so "${currentPackage}-stripped-$version"
cp --parents -f usr/lib$SYSTEMBITS/qt6/plugins/platforms/libqxcb.so "${currentPackage}-stripped-$version"
cp --parents -f usr/lib$SYSTEMBITS/qt6/plugins/platformthemes/* "${currentPackage}-stripped-$version"
cp --parents -f usr/lib$SYSTEMBITS/qt6/plugins/wayland*/* "${currentPackage}-stripped-$version"
cp --parents -f usr/lib$SYSTEMBITS/qt6/plugins/xcbglintegrations/* "${currentPackage}-stripped-$version"
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

### packages outside Slackware repository

currentPackage=muparser
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
info=$(DownloadLatestFromGithub "beltoforion" ${currentPackage})
version=${info#* }
filename=${info% *}
tar xvf $filename && rm $filename || exit 1
cd ${currentPackage}*
cmake -B build -S . -DCMAKE_CXX_FLAGS:STRING="$GCCFLAGS" -DCMAKE_BUILD_TYPE=release -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=/usr/lib${SYSTEMBITS} -DENABLE_SAMPLES=off
make -C build -j${NUMBERTHREADS} DESTDIR="$MODULEPATH/${currentPackage}/package" install
cd $MODULEPATH/${currentPackage}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

currentPackage=xcape
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/misc/${currentPackage}/ -A * || exit 1
info=$(DownloadLatestFromGithub "alols" ${currentPackage})
version=${info#* }
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" ${currentPackage}.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" ${currentPackage}.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" ${currentPackage}.SlackBuild
sed -i "s|-O[23].*|$GCCFLAGS\"|g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
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

currentPackage=adwaita-qt
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/FedoraQt/${currentPackage} || exit 1
cd ${currentPackage}
version=`git log -1 --date=format:"%Y%m%d" --format="%ad"`
cp $SCRIPTPATH/deps/adwaita-qt/*.patch .
for i in *.patch; do patch -p0 < $i || exit 1; done
cmake -B build -S . -DCMAKE_CXX_FLAGS:STRING="$GCCFLAGS" -DCMAKE_BUILD_TYPE=release -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=/usr/lib${SYSTEMBITS} -DUSE_QT6=true
make -C build -j${NUMBERTHREADS} DESTDIR="$MODULEPATH/${currentPackage}/package" install
cd $MODULEPATH/${currentPackage}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

# required by xpdf
installpkg $MODULEPATH/packages/libpaper*.txz || exit 1
installpkg $MODULEPATH/packages/libproxy*.txz || exit 1

installpkg $MODULEPATH/packages/cups*.txz || exit 1
rm $MODULEPATH/packages/cups*.txz

currentPackage=xpdf
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nH --cut-dirs=5 --no-parent --reject="index.html*" ${SLACKWAREDOMAIN}/slackware/slackware64-current/source/xap/${currentPackage}/
[ -d ${currentPackage} ] && cd ${currentPackage}
sed -i "s|-O[23].*|$GCCFLAGS -ffat-lto-objects\"|g" ${currentPackage}.SlackBuild
sed -i "s|-DXPDFWIDGET_PRINTING=1|-DMULTITHREADED=ON -DCMAKE_POLICY_VERSION_MINIMUM=3.5|g" ${currentPackage}.SlackBuild
sed -z -i "s|mkdir build\n|sed -i \"s\|initialSidebarState = gTrue\|initialSidebarState = gFalse\|g\" xpdf/GlobalParams.cc\nmkdir build\n|g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
rm -fr $MODULEPATH/${currentPackage}

# required by featherpad
installpkg $MODULEPATH/packages/hunspell*.txz || exit 1

currentPackage=FeatherPad
mkdir $MODULEPATH/${currentPackage,,} && cd $MODULEPATH/${currentPackage,,}
info=$(DownloadLatestFromGithub "tsujan" ${currentPackage})
version=${info#* }
filename=${info% *}
tar xvf ${currentPackage}-${version}.tar.xz && rm ${currentPackage}-${version}.tar.xz || exit 1
cd ${currentPackage}*
cmake -B build -S . -DCMAKE_CXX_FLAGS:STRING="$GCCFLAGS" -DCMAKE_BUILD_TYPE=release -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=/usr/lib${SYSTEMBITS}
make -C build -j${NUMBERTHREADS} DESTDIR="$MODULEPATH/${currentPackage,,}/package" install
cd $MODULEPATH/${currentPackage,,}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage,,}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage,,}

currentPackage=audacious
QT=6 sh $SCRIPTPATH/../common/audacious/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=audacious-plugins
QT=6 sh $SCRIPTPATH/../common/audacious/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

DE_LATEST_VERSION=$(curl -s https://github.com/lxqt/lxqt-about/tags/ | grep "/lxqt/lxqt-about/releases/tag/" | grep -oP "(?<=/lxqt/lxqt-about/releases/tag/)[^\"]+" | uniq | grep -v "alpha" | grep -v "beta" | grep -v "rc[0-9]" | head -1)

echo "Building LXQt ${DE_LATEST_VERSION}..."
MODULENAME=$MODULENAME-${DE_LATEST_VERSION}

# required by libkscreen
installpkg $MODULEPATH/packages/plasma-wayland-protocols*.txz || exit 1

# lxqt deps
for package in \
	polkit-qt6-1 \
	extra-cmake-modules \
	layer-shell-qt6 \
	kwindowsystem \
	kwayland \
	solid \
	kidletime \
	libkscreen \
	networkmanager-qt \
	kimageformats \
; do
sh $SCRIPTPATH/deps/${package}/${package}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${package}-*.txz || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

currentPackage=nm-tray
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
info=$(DownloadLatestFromGithub "palinek" ${currentPackage})
version=${info#* }
filename=${info% *}
tar xvf $filename && rm $filename || exit 1
cd ${currentPackage}*
cmake -B build -S . -DCMAKE_CXX_FLAGS:STRING="$GCCFLAGS" -DCMAKE_BUILD_TYPE=release -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_SYSCONFDIR=/etc -DCMAKE_INSTALL_LIBDIR=/usr/lib${SYSTEMBITS} -DBUILD_WITH_QT6=true
make -C build -j${NUMBERTHREADS} DESTDIR="$MODULEPATH/${currentPackage}/package" install
cd $MODULEPATH/${currentPackage}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=libconfig
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
info=$(DownloadLatestFromGithub "hyperrealm" ${currentPackage})
version=${info#* }
filename=${info% *}
tar xvf $filename && rm $filename || exit 1
cd ${currentPackage}*
cmake -B build -S . -DCMAKE_BUILD_TYPE=release -DCMAKE_C_FLAGS:STRING="$GCCFLAGS" -DCMAKE_CXX_FLAGS:STRING="$GCCFLAGS" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=/usr/lib64
make -C build -j${NUMBERTHREADS} DESTDIR="$MODULEPATH/${currentPackage}/package" install
cd $MODULEPATH/${currentPackage}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz > /dev/null 2>&1
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

currentPackage=libstatgrab
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
info=$(DownloadLatestFromGithub ${currentPackage} ${currentPackage})
version=${info#* }
filename=${info% *}
tar xvf $filename && rm $filename || exit 1
cd ${currentPackage}*
./autogen.sh && CFLAGS="$GCCFLAGS -ffat-lto-objects" ./configure --prefix=/usr --libdir=/usr/lib$SYSTEMBITS --sysconfdir=/etc --disable-static --disable-debug
make -j${NUMBERTHREADS} && make install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz > /dev/null 2>&1
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

currentPackage=libfm-extra
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/lxde/libfm ${currentPackage}
cd ${currentPackage}
version=`git describe | cut -d- -f1`
sed -i "s|g_file_info_get_size(inf)|g_file_info_get_attribute_uint64 (inf, G_FILE_ATTRIBUTE_STANDARD_SIZE)|g" src/base/fm-file-info.c || exit 1
sed -i "s|g_file_info_get_size(inf)|g_file_info_get_attribute_uint64 (inf, G_FILE_ATTRIBUTE_STANDARD_SIZE)|g" src/job/fm-deep-count-job.c || exit 1
sed -i "s|g_file_info_get_size(inf)|g_file_info_get_attribute_uint64 (inf, G_FILE_ATTRIBUTE_STANDARD_SIZE)|g" src/job/fm-file-ops-job.c || exit 1
sed -i "s|g_file_info_get_size(info)|g_file_info_get_attribute_uint64 (info, G_FILE_ATTRIBUTE_STANDARD_SIZE)|g" src/modules/vfs-search.c || exit 1
./autogen.sh --prefix=/usr --without-gtk --disable-demo && CFLAGS="$GCCFLAGS -ffat-lto-objects -Wa,-mbranches-within-32B-boundaries" \
./configure \
	--prefix=/usr \
	--libdir=/usr/lib$SYSTEMBITS \
	--localstatedir=/var \
	--enable-static=no \
	--enable-udisks \
	--with-extra-only

make -j${NUMBERTHREADS} && make install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=menu-cache
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget https://github.com/lxde/${currentPackage}/archive/refs/heads/master.tar.gz -O ${currentPackage}.tar.gz
tar xfv ${currentPackage}.tar.gz
cd ${currentPackage}-master
version=`git describe | cut -d- -f1`
./autogen.sh && CFLAGS="$GCCFLAGS -ffat-lto-objects" \
./configure \
	--prefix=/usr \
	--libdir=/usr/lib$SYSTEMBITS \
	--localstatedir=/var \
	--sysconfdir=/etc \
	--mandir=/usr/man \
	--enable-static=no \
	--program-prefix= \
	--program-suffix= 

make -j${NUMBERTHREADS} && make install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

# required by lxqt
installpkg $MODULEPATH/packages/libdbusmenu-qt*.txz || exit 1
installpkg $MODULEPATH/packages/polkit-qt*.txz || exit 1

currentPackage=lxqt
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/${currentPackage}/${currentPackage} $MODULEPATH/${currentPackage}
git submodule init || exit 1
git submodule update --remote --rebase || exit 1
cp $SCRIPTPATH/lxqt/build_all_cmake_projects.sh .
cp $SCRIPTPATH/lxqt/*.patch .
for i in *.patch; do patch -p0 < $i || exit 1; done
sh build_all_cmake_projects.sh || exit 1
rm -fr $MODULEPATH/${currentPackage}

# only required for building
rm $MODULEPATH/packages/extra-cmake-modules*.txz
rm $MODULEPATH/packages/kwayland*.txz
rm $MODULEPATH/packages/lxqt-build-tools*.txz
rm $MODULEPATH/packages/plasma-wayland-protocols*.txz

currentPackage=kora
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget https://github.com/bikass/${currentPackage}/archive/refs/heads/master.tar.gz || exit 1
tar xvf master.tar.gz && rm master.tar.gz || exit 1
cd ${currentPackage}-master
version=$(date -r . +%Y%m%d)
iconRootFolder=../${currentPackage}-$version-noarch/usr/share/icons/${currentPackage}
lightIconRootFolder=../${currentPackage}-$version-noarch/usr/share/icons/${currentPackage}-light
mkdir -p $iconRootFolder
mkdir -p $lightIconRootFolder
cp -r ${currentPackage}/* $iconRootFolder || exit 1
cp -r ${currentPackage}-light/* $lightIconRootFolder || exit 1
rm $iconRootFolder/apps/scalable/application.svg
rm $iconRootFolder/create-new-icon-theme.cache.sh
rm $lightIconRootFolder/create-new-icon-theme.cache.sh
gtk-update-icon-cache -f $iconRootFolder || exit 1
gtk-update-icon-cache -f $lightIconRootFolder || exit 1
cd ../${currentPackage}-$version-noarch
echo "Generating icon package. This may take a while..."
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-icon-theme-$version-noarch-1.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

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
rm -R usr/lib${SYSTEMBITS}/gnome-settings-daemon-3.0/
rm -R usr/lib${SYSTEMBITS}/gtk-2.0/
rm -R usr/lib${SYSTEMBITS}/qt6/mkspecs
rm -R usr/share/featherpad
rm -R usr/share/gdm
rm -R usr/share/gnome
rm -R usr/share/libfm-qt/translations
rm -R usr/share/lximage-qt
rm -R usr/share/lxqt-archiver
rm -R usr/share/lxqt/graphics
rm -R usr/share/lxqt/panel
rm -R usr/share/lxqt/translations
rm -R usr/share/obconf-qt
rm -R usr/share/pavucontrol-qt
rm -R usr/share/pcmanfm-qt/translations
rm -R usr/share/qlogging-categories5
rm -R usr/share/qps
rm -R usr/share/qterminal
rm -R usr/share/qtermwidget5/translations
rm -R usr/share/screengrab/translations
rm -R usr/share/Thunar

rm etc/xdg/autostart/blueman.desktop
rm usr/lib${SYSTEMBITS}/libdbusmenu-gtk.*
rm usr/share/icons/hicolor/scalable/apps/pcmanfm-qt.svg
rm usr/share/nm-tray/nm-tray*.qm

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
