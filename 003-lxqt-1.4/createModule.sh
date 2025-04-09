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

### packages outside Slackware repository

currentPackage=muparser
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
info=$(DownloadLatestFromGithub "beltoforion" ${currentPackage})
version=${info#* }
filename=${info% *}
tar xvf $filename && rm $filename || exit 1
cd ${currentPackage}*
mkdir build && cd build
CXXFLAGS="$GCCFLAGS -flto=auto" cmake -DCMAKE_BUILD_TYPE=release -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=lib${SYSTEMBITS} -DENABLE_SAMPLES=off ..
make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
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
sed -i "s|-O2.*|$GCCFLAGS -flto=auto\"|g" ${currentPackage}.SlackBuild
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
mkdir build && cd build
CXXFLAGS="$GCCFLAGS -flto=auto" cmake -DCMAKE_BUILD_TYPE=release -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=lib${SYSTEMBITS} ..
make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=xpdf
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nH --cut-dirs=6 --no-parent --reject="index.html*" ${SLACKWAREDOMAIN}/slackware/slackware64-current/source/xap/${currentPackage}/ || exit 1
sed -i "s|-O2.*|$GCCFLAGS\"|g" ${currentPackage}.SlackBuild
sed -i "s|-DXPDFWIDGET_PRINTING=1|-DMULTITHREADED=ON|g" ${currentPackage}.SlackBuild
sed -z -i "s|mkdir build\n|sed -i \"s\|initialSidebarState = gTrue\|initialSidebarState = gFalse\|g\" xpdf/GlobalParams.cc\nmkdir build\n|g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
rm -fr $MODULEPATH/${currentPackage}

# required by featherpad
installpkg $MODULEPATH/packages/hunspell*.txz || exit 1

currentPackage=FeatherPad
mkdir $MODULEPATH/${currentPackage,,} && cd $MODULEPATH/${currentPackage,,}
version="1.4.1" # higher than this requires Qt6
wget https://github.com/tsujan/${currentPackage}/releases/download/V${version}/${currentPackage}-${version}.tar.xz
tar xvf ${currentPackage}-${version}.tar.xz && rm ${currentPackage}-${version}.tar.xz || exit 1
cd ${currentPackage}*
mkdir build && cd build
CXXFLAGS="$GCCFLAGS -flto=auto" cmake -DCMAKE_BUILD_TYPE=release -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=lib${SYSTEMBITS} ..
make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage,,}/package || exit 1
cd $MODULEPATH/${currentPackage,,}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage,,}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage,,}

currentPackage=audacious
QT=5 sh $SCRIPTPATH/../common/audacious/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=audacious-plugins
QT=5 sh $SCRIPTPATH/../common/audacious/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

# lxqt deps
for package in \
	extra-cmake-modules \
	kimageformats \
; do
sh $SCRIPTPATH/deps/${package}/${package}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${package}-*.txz || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# required by nm-tray
installpkg $MODULEPATH/packages/networkmanager-qt*.txz || exit 1

currentPackage=nm-tray
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
version="0.5.0"
wget https://github.com/palinek/${currentPackage}/archive/refs/tags/${version}.tar.gz 
tar xvf ${version}.tar.gz && rm ${version}.tar.gz || exit 1
cd ${currentPackage}*
sed -i "s|set(NM_TRAY_VERSION \".*|set(NM_TRAY_VERSION \"${version}\")|g" CMakeLists.txt
mkdir build && cd build
CXXFLAGS="$GCCFLAGS -flto=auto" cmake -DCMAKE_BUILD_TYPE=release -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_SYSCONFDIR=/etc -DCMAKE_INSTALL_LIBDIR=lib${SYSTEMBITS} ..
make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
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
CFLAGS="$GCCFLAGS" CXXFLAGS="$GCCFLAGS" ./configure --prefix=/usr --libdir=/usr/lib$SYSTEMBITS --sysconfdir=/etc --disable-static --disable-debug
make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage}/package  || exit 1
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
sh autogen.sh
CFLAGS="$GCCFLAGS" ./configure --prefix=/usr --libdir=/usr/lib$SYSTEMBITS --sysconfdir=/etc --disable-static --disable-debug
make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
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
./autogen.sh --prefix=/usr --without-gtk --disable-demo && CFLAGS="$GCCFLAGS -Wa,-mbranches-within-32B-boundaries" \
./configure \
	--prefix=/usr \
	--libdir=/usr/lib$SYSTEMBITS \
	--localstatedir=/var \
	--enable-static=no \
	--enable-udisks \
	--with-extra-only

make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=menu-cache
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/lxde/${currentPackage} || exit 1
cd ${currentPackage}
version=`git describe | cut -d- -f1`
sh ./autogen.sh && CFLAGS="$GCCFLAGS" \
./configure \
	--prefix=/usr \
	--libdir=/usr/lib$SYSTEMBITS \
	--localstatedir=/var \
	--sysconfdir=/etc \
	--mandir=/usr/man \
	--enable-static=no \
	--program-prefix= \
	--program-suffix= 

make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

# required by lxqt
installpkg $MODULEPATH/packages/libdbusmenu-qt*.txz || exit 1
installpkg $MODULEPATH/packages/libkscreen*.txz || exit 1
installpkg $MODULEPATH/packages/kidletime*.txz || exit 1
installpkg $MODULEPATH/packages/kwindowsystem*.txz || exit 1
installpkg $MODULEPATH/packages/polkit-qt*.txz || exit 1
installpkg $MODULEPATH/packages/solid*.txz || exit 1

currentPackage=lxqt
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/${currentPackage}/${currentPackage} $MODULEPATH/${currentPackage}
git submodule init || exit 1
git submodule update --remote --rebase || exit 1
cd $MODULEPATH/${currentPackage}/lxqt-build-tools && git checkout 1304079edbe62c8c9e528de8ee0cf1a1119724dc
cd $MODULEPATH/${currentPackage}/libqtxdg && git checkout e31ae3b2566939cf868a93cb2f088c5423232f4b
cd $MODULEPATH/${currentPackage}/qtxdg-tools && git checkout bff8e86b229566ba671514a7e170c618a8f881ad
cd $MODULEPATH/${currentPackage}/liblxqt && git checkout c3c22449bb3360768ed15b0ff2c4607669f58a08
cd $MODULEPATH/${currentPackage}/libsysstat && git checkout a4f05535c12c4d895b715c9c9ac819aba5530739
cd $MODULEPATH/${currentPackage}/lxqt-menu-data && git checkout fc4e7ad693c1ceaea9b2ec68c909245f8a40e815
cd $MODULEPATH/${currentPackage}/libfm-qt && git checkout d5c15390917f55a0d8ee3283234addf4f8bf5a40
cd $MODULEPATH/${currentPackage}/lxqt-themes && git checkout d76946fcb232ca7ee9aed7b795d3794ea8edf9d6
cd $MODULEPATH/${currentPackage}/pavucontrol-qt && git checkout 84203392bd6c4b0ad73f66f41e701d35ed3e9987
cd $MODULEPATH/${currentPackage}/lxqt-about && git checkout c3c228a5419a373dc0e4c45f5addff35098622fd
cd $MODULEPATH/${currentPackage}/lxqt-admin && git checkout d4ef11b304830048074260b9d511cb6bbb9a4191
cd $MODULEPATH/${currentPackage}/lxqt-config && git checkout a6c57228667465abf0479f996adbf408220961e8
cd $MODULEPATH/${currentPackage}/lxqt-globalkeys && git checkout d21077cdeb61370e72db6250ac2e2274d8cd61f4
cd $MODULEPATH/${currentPackage}/lxqt-notificationd && git checkout 54d80331a19be2538cb73fc582fb9ca723f36489
cd $MODULEPATH/${currentPackage}/lxqt-openssh-askpass && git checkout 3ef415b7294ec6fb177b7dbc48eb4908bb288536
cd $MODULEPATH/${currentPackage}/lxqt-policykit && git checkout 9f0f731e4622712ec977ae9ffa1d5e3833fd3cbc
cd $MODULEPATH/${currentPackage}/lxqt-powermanagement && git checkout 1a1b28e43c7ab5df1cf9d21a6f0ce34378007489
cd $MODULEPATH/${currentPackage}/lxqt-qtplugin && git checkout 480dcd853da719c1d60b84fb21316549b614c5ab
cd $MODULEPATH/${currentPackage}/lxqt-session && git checkout d4ef195cde72de423f3829b98b439464364996f9
cd $MODULEPATH/${currentPackage}/lxqt-sudo && git checkout b940dd0d6ce3211f79e11dde5548789be8cc9292
cd $MODULEPATH/${currentPackage}/pcmanfm-qt && git checkout e28baeb3a2c98e17278381cd201916b9c03ef71a
cd $MODULEPATH/${currentPackage}/lxqt-panel && git checkout 371f60fa806a89779a9c90ed5a1dce7b92126e0b
cd $MODULEPATH/${currentPackage}/lxqt-runner && git checkout f57f1de245c748539d180fd9dd13615c43501193
cd $MODULEPATH/${currentPackage}/lxqt-archiver && git checkout 49513a0eaa614d4173d445017bd0175073e22602
cd $MODULEPATH/${currentPackage}/xdg-desktop-portal-lxqt && git checkout e229ca1d1fe98cdfcdeb2733adf5f5a97e7fcf47
cd $MODULEPATH/${currentPackage}/obconf-qt && git checkout d2626ef4d36f312048c8968cc175599a21c8f1cb
cd $MODULEPATH/${currentPackage}/lximage-qt && git checkout 48de1ba52d6f543126d87f0dd4643da08e238966
cd $MODULEPATH/${currentPackage}/qtermwidget && git checkout 8be34ffa31717f7ee08542de9ba87622f5eca8e2
cd $MODULEPATH/${currentPackage}/qterminal && git checkout 05a0b64daa41c52b6aed4602dafcd46c061ec6e0
cd $MODULEPATH/${currentPackage}/qps && git checkout 2f6f14de5b46d42cf8c18b09c62a66d0ba9c3f2d
cd $MODULEPATH/${currentPackage}/screengrab && git checkout 09264f734146d6929751b5c80e7d777c76479216
cd $MODULEPATH/${currentPackage}
cp $SCRIPTPATH/lxqt/build_all_cmake_projects.sh .
cp $SCRIPTPATH/lxqt/*.patch .
for i in *.patch; do patch -p0 < $i || exit 1; done
cp $SCRIPTPATH/lxqt/cmake_repos.list $MODULEPATH/${currentPackage}/ || exit 1
sh build_all_cmake_projects.sh || exit 1
rm -fr $MODULEPATH/${currentPackage}

# only required for building
rm $MODULEPATH/packages/extra-cmake-modules*.txz
rm $MODULEPATH/packages/lxqt-build-tools*.txz

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
sed -i "s|Icon=xpdfIcon|Icon=xpdf|g" $MODULEPATH/packages/usr/share/applications/xpdf.desktop

### add session

sed -i "s|SESSIONTEMPLATE|/usr/bin/startlxqt|g" $MODULEPATH/packages/etc/lxdm/lxdm.conf

### copy build files to 05-devel

CopyToDevel

### copy language files to 08-multilanguage

CopyToMultiLanguage

### module clean up

cd $MODULEPATH/packages/

rm -R usr/lib${SYSTEMBITS}/gnome-settings-daemon-3.0/
rm -R usr/lib${SYSTEMBITS}/gtk-2.0/
rm -R usr/lib${SYSTEMBITS}/qt5/mkspecs
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
rm usr/share/nm-tray/nm-tray*.qm

find usr/share/lxqt/wallpapers -mindepth 1 -maxdepth 1 ! \( -name "simple_blue_widescreen*" \) -exec rm -rf '{}' \; 2>/dev/null
find usr/share/lxqt/themes -mindepth 1 -maxdepth 1 ! \( -name "Porteux-dark" -o -name "Clearlooks" \) -exec rm -rf '{}' \; 2>/dev/null

[ "$SYSTEMBITS" == 64 ] && find usr/lib/ -mindepth 1 -maxdepth 1 ! \( -name "python*" \) -exec rm -rf '{}' \; 2>/dev/null

GenericStrip
AggressiveStripAll

### copy cache files

PrepareFilesForCacheDE

### generate cache files

GenerateCachesDE

### finalize

Finalize
