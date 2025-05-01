#!/bin/bash

MODULENAME=003-lxde-0.11.1

source "$PWD/../builder-utils/setflags.sh"

SetFlags "$MODULENAME"

source "$BUILDERUTILSPATH/cachefiles.sh"
source "$BUILDERUTILSPATH/downloadfromslackware.sh"
source "$BUILDERUTILSPATH/genericstrip.sh"
source "$BUILDERUTILSPATH/helper.sh"
source "$BUILDERUTILSPATH/latestfromgithub.sh"

if ! isRoot; then
	echo "Please enter admin's password below:"
	su -c "$0 $1"
	exit
fi

### create module folder

mkdir -p $MODULEPATH/packages > /dev/null 2>&1

### download packages from slackware repositories

DownloadFromSlackware

### packages outside Slackware repository

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
SESSIONTEMPLATE=LXDE sh $SCRIPTPATH/../common/${currentPackage}/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=lightdm-gtk-greeter
ICONTHEME=kora sh $SCRIPTPATH/../common/${currentPackage}/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=atril
sh $SCRIPTPATH/extras/${currentPackage}/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=pavucontrol
sh $SCRIPTPATH/extras/${currentPackage}/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=l3afpad
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/stevenhoneyman/${currentPackage}
cd ${currentPackage}
version=`git log -1 --date=format:"%Y%m%d" --format="%ad"`
./autogen.sh && CFLAGS="$GCCFLAGS -flto=auto" ./configure --prefix=/usr --libdir=/usr/lib${SYSTEMBITS} --sysconfdir=/etc --disable-static --disable-debug || exit 1
make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=audacious
sh $SCRIPTPATH/../common/audacious/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=audacious-plugins
sh $SCRIPTPATH/../common/audacious/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

# temporary just to build engrampa
currentPackage=mate-common
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
info=$(DownloadLatestFromGithub "mate-desktop" ${currentPackage} "1.29")
version=${info#* }
filename=${info% *}
tar xvf $filename && rm $filename || exit 1
cd ${currentPackage}*
./autogen.sh --prefix=/usr --libdir=/usr/lib$SYSTEMBITS --sysconfdir=/etc
make -j${NUMBERTHREADS} install || exit 1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=engrampa
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
info=$(DownloadLatestFromGithub "mate-desktop" ${currentPackage} "1.29")
version=${info#* }
filename=${info% *}
tar xvf $filename && rm $filename || exit 1
cd ${currentPackage}*
sed -i 's|YELP_HELP_INIT||g' configure.ac
sed -i 's|yelp-build|ls|g' autogen.sh
sed -i 's|help.*|\\|g' Makefile.am
CFLAGS="$GCCFLAGS" ./autogen.sh --prefix=/usr --libdir=/usr/lib$SYSTEMBITS --sysconfdir=/etc --disable-static --disable-debug --disable-caja-actions || exit 1
make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=gnome-screenshot
version=3.36.0 # higher than this will require libhandy
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget https://gitlab.gnome.org/GNOME/${currentPackage}/-/archive/$version/${currentPackage}-$version.tar.gz || exit 1
tar xvf ${currentPackage}-$version.tar.?z || exit 1
cd ${currentPackage}-$version
mkdir build && cd build
sed -i "s|i18n.merge_file('desktop',|i18n.merge_file(|g" ../src/meson.build
sed -i "s|i18n.merge_file('appdata',|i18n.merge_file(|g" ../src/meson.build
meson setup -Dcpp_args="$GCCFLAGS -flto=auto" --prefix /usr ..
ninja -j${NUMBERTHREADS} || exit 1
DESTDIR=$MODULEPATH/${currentPackage}/package ninja install
cd $MODULEPATH/${currentPackage}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

# required by lxterminal
installpkg $MODULEPATH/packages/vte*.txz || exit 1

# required by lxpanel
installpkg $MODULEPATH/packages/libwnck3-*.txz || exit 1
installpkg $MODULEPATH/packages/keybinder3*.txz || exit 1

# lxde packages
for package in \
	gpicview \
	libfm-extra \
	menu-cache \
	libfm \
	pcmanfm \
	lxterminal \
	lxtask \
	lxrandr \
	lxsession \
	lxmenu-data \
	lxlauncher \
	lxinput \
	lxhotkey \
	lxde-common \
	lxappearance \
	lxappearance-obconf \
	lxpanel \
; do
sh $SCRIPTPATH/lxde/${package}/${package}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${package}-*.txz || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# only required to build menu-cache
rm $MODULEPATH/packages/libfm-extra*.txz

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

sed -i "s|Core;|Utility;|g" $MODULEPATH/packages/usr/share/applications/gpicview.desktop
sed -i "s|image/x-xpixmap|image/x-xpixmap;image/heic;image/jxl|g" $MODULEPATH/packages/usr/share/applications/gpicview.desktop
sed -i "s|;Settings;|;|g" $MODULEPATH/packages/usr/share/applications/pavucontrol.desktop
sed -i "s|System;|Utility;|g" $MODULEPATH/packages/usr/share/applications/pcmanfm.desktop

### add lxde session

sed -i "s|SESSIONTEMPLATE|/usr/bin/lxsession|g" $MODULEPATH/packages/etc/lxdm/lxdm.conf

### copy build files to 05-devel

CopyToDevel

### copy language files to 08-multilanguage

CopyToMultiLanguage

### module clean up

cd $MODULEPATH/packages/

rm -R usr/share/engrampa
rm -R usr/share/gdm
rm -R usr/share/gnome
rm -R usr/share/Thunar

rm etc/xdg/autostart/blueman.desktop
rm usr/bin/vte-*-gtk4
rm usr/lib${SYSTEMBITS}/libappindicator.*
rm usr/lib${SYSTEMBITS}/libdbusmenu-gtk.*
rm usr/lib${SYSTEMBITS}/libindicator.*
rm usr/lib${SYSTEMBITS}/libkeybinder.*
rm usr/lib${SYSTEMBITS}/libvte-*-gtk4*
rm usr/libexec/indicator-loader
rm usr/share/lxde/wallpapers/lxde_green.jpg
rm usr/share/lxde/wallpapers/lxde_red.jpg

[ "$SYSTEMBITS" == 64 ] && find usr/lib/ -mindepth 1 -maxdepth 1 ! \( -name "python*" \) -exec rm -rf '{}' \; 2>/dev/null

mv $MODULEPATH/packages/usr/lib${SYSTEMBITS}/libvte-* $MODULEPATH/
GenericStrip
AggressiveStripAll
mv $MODULEPATH/libvte-* $MODULEPATH/packages/usr/lib${SYSTEMBITS}

### copy cache files

PrepareFilesForCacheDE

### generate cache files

GenerateCachesDE

### finalize

Finalize