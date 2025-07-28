#!/bin/bash

MODULENAME=003-mate

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
cd $MODULEPATH

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
sed -i "s|-O[23].*|$GCCFLAGS\"|g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

# required by lightdm
installpkg $MODULEPATH/packages/libxklavier*.txz || exit 1

currentPackage=lightdm
SESSIONTEMPLATE=mate sh $SCRIPTPATH/../common/${currentPackage}/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=lightdm-gtk-greeter
ICONTHEME=elementary-xfce-dark sh $SCRIPTPATH/../common/${currentPackage}/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=audacious
sh $SCRIPTPATH/../common/audacious/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=audacious-plugins
sh $SCRIPTPATH/../common/audacious/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

# temporary just to build engrampa and mate-search-tool
currentPackage=mate-common
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
info=$(DownloadLatestFromGithub "mate-desktop" ${currentPackage} "1.29")
version=${info#* }
filename=${info% *}
tar xvf $filename && rm $filename || exit 1
cd ${currentPackage}*
./autogen.sh --prefix=/usr --libdir=/usr/lib${SYSTEMBITS} --sysconfdir=/etc
make -j${NUMBERTHREADS} install || exit 1
rm -fr $MODULEPATH/${currentPackage}

# required from now on
installpkg $MODULEPATH/packages/libappindicator*.txz || exit 1
installpkg $MODULEPATH/packages/libgtop*.txz || exit 1
installpkg $MODULEPATH/packages/libindicator*.txz || exit 1
installpkg $MODULEPATH/packages/dconf*.txz || exit 1
installpkg $MODULEPATH/packages/enchant*.txz || exit 1
installpkg $MODULEPATH/packages/libwnck*.txz || exit 1
installpkg $MODULEPATH/packages/vte*.txz || exit 1

if [ $SLACKWAREVERSION == "current" ]; then
	installpkg $MODULEPATH/packages/libsoup-2*.txz || exit 1
	installpkg $MODULEPATH/packages/libdbusmenu*.txz || exit 1
fi

# required just for building
installpkg $MODULEPATH/packages/gtk+2*.txz || exit 1
rm $MODULEPATH/packages/gtk+2*.txz
installpkg $MODULEPATH/packages/iso-codes*.txz || exit 1
rm $MODULEPATH/packages/iso-codes*.txz
installpkg $MODULEPATH/packages/xtrans*.txz || exit 1
rm $MODULEPATH/packages/xtrans*.txz

DE_LATEST_VERSION=$(curl -s https://github.com/mate-desktop/mate-desktop/tags/ | grep "/mate-desktop/mate-desktop/releases/tag/" | grep -oP "(?<=/mate-desktop/mate-desktop/releases/tag/)[^\"]+" | uniq | cut -d "v" -f 2 | grep -v "alpha" | grep -v "beta" | grep -v "rc[0-9]" | grep -v "1.29" | head -1)

echo "Building MATE ${DE_LATEST_VERSION}..."
MODULENAME=$MODULENAME-${DE_LATEST_VERSION}

# mate deps
for package in \
	zenity \
	gtk-layer-shell \
	libpeas \
	libgxps \
	gtksourceview4 \
; do
sh $SCRIPTPATH/deps/${package}/${package}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${package}-*.txz || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# mate packages
for package in \
	mate-desktop \
	libmatekbd \
	caja \
	caja-extensions \
	mate-polkit \
	marco \
	libmatemixer \
	mate-settings-daemon \
	mate-session-manager \
	mate-menus \
	mate-terminal \
	libmateweather \
	mate-panel \
	mate-themes \
	mate-notification-daemon \
	eom \
	mate-control-center \
	engrampa \
	mate-media \
	mate-power-manager \
	mate-system-monitor \
	atril \
	mozo \
	pluma \
; do
sh $SCRIPTPATH/mate/${package}/${package}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${package}-*.txz || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

currentPackage=mate-utils
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
info=$(DownloadLatestFromGithub "mate-desktop" ${currentPackage} "1.29")
version=${info#* }
filename=${info% *}
tar xvf $filename && rm $filename || exit 1
cd ${currentPackage}*
# missing files from 1.28.5
git clone https://github.com/mate-desktop/mate-submodules gsearchtool/mate-submodules
cp $PWD/mate/mate-panel/Makefile.in gsearchtool/mate-submodules
cp $PWD/mate/mate-panel/Makefile.in.libegg gsearchtool/mate-submodules/libegg/Makefile.in
sed -i "s|mate-dictionary||g" ./Makefile.am
sed -i "s|logview||g" ./Makefile.am
sed -i 's|yelp-build|ls|g' autogen.sh
sed -i 's|dnl yelp-tools stuff||g' configure.ac
sed -i 's|YELP_HELP_INIT||g' configure.ac
sed -i 's| help||g' gsearchtool/Makefile.am
sed -i 's| help||g' baobab/Makefile.am
CFLAGS="$GCCFLAGS -ffat-lto-objects" ./autogen.sh --prefix=/usr --libdir=/usr/lib$SYSTEMBITS --sysconfdir=/etc --disable-static --disable-debug --disable-gdict-applet --disable-disk-image-mounter || exit
make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
wget https://raw.githubusercontent.com/mate-desktop/mate-desktop/v$version/schemas/org.mate.interface.gschema.xml -P usr/share/glib-2.0/schemas || exit 1
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/mate-utils-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

### fake root

cd $MODULEPATH/packages && ROOT=./ installpkg *.t?z
rm *.t?z

### install additional packages, including porteux utils

InstallAdditionalPackages

### fix some .desktop files

sed -i "s|image/x-xpixmap|image/x-xpixmap;image/heic;image/jxl|g" $MODULEPATH/packages/usr/share/applications/eom.desktop

### copy xinitrc

cp $MODULEPATH/packages/etc/X11/xinit/xinitrc.mate-session .
cp -s xinitrc.mate-session xinitrc
mv xinitrc $MODULEPATH/packages/etc/X11/xinit/
rm xinitrc.mate-session

### copy build files to 05-devel

CopyToDevel

### copy language files to 08-multilanguage

CopyToMultiLanguage

### module clean up

cd $MODULEPATH/packages/

{
rm -R run/
rm -R usr/lib*/python2*
rm -R usr/lib*/python*/site-packages/pip*
rm -R usr/share/engrampa
rm -R usr/share/gdm
rm -R usr/share/gnome
rm -R usr/share/icons/ContrastHigh
rm -R usr/share/icons/mate
rm -R usr/share/icons/mate-black
rm -R usr/share/mate-media/icons
rm -R usr/share/mate-power-manager/icons
rm -R usr/share/Thunar

rm usr/bin/vte-*-gtk4
rm etc/xdg/autostart/blueman.desktop
rm usr/lib${SYSTEMBITS}/girepository-1.0/SoupGNOME*
rm usr/lib${SYSTEMBITS}/libappindicator.*
rm usr/lib${SYSTEMBITS}/libdbusmenu-gtk.*
rm usr/lib${SYSTEMBITS}/libindicator.*
rm usr/lib${SYSTEMBITS}/libkeybinder.*
rm usr/lib${SYSTEMBITS}/libsoup-gnome*
rm usr/lib${SYSTEMBITS}/libvte-*-gtk4*
rm usr/libexec/indicator-loader

[ "$SYSTEMBITS" == 64 ] && find usr/lib/ -mindepth 1 -maxdepth 1 ! \( -name "python*" \) -exec rm -rf '{}' \; 2>/dev/null
find usr/share/libmateweather -mindepth 1 -maxdepth 1 ! \( -name "Locations.xml" -o -name "locations.dtd" \) -exec rm -rf '{}' \; 2>/dev/null
find usr/share/themes -mindepth 1 -maxdepth 1 ! \( -name "Adwaita" -o -name "Adwaita-dark" -o -name "DustBlue" \) -exec rm -rf '{}' \; 2>/dev/null
} >/dev/null 2>&1

GenericStrip

# move out things that don't support aggressive stripping
mv $MODULEPATH/packages/usr/bin/mate-system-monitor $MODULEPATH/
mv $MODULEPATH/packages/usr/lib${SYSTEMBITS}/libvte-* $MODULEPATH/
AggressiveStripAll
mv $MODULEPATH/mate-system-monitor $MODULEPATH/packages/usr/bin
mv $MODULEPATH/libvte-* $MODULEPATH/packages/usr/lib${SYSTEMBITS}

### copy cache files

PrepareFilesForCacheDE

### generate cache files

GenerateCachesDE

### finalize

Finalize
