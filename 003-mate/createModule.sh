#!/bin/sh
MODULENAME=003-mate

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

### packages outside Slackware repository

currentPackage=xcape
mkdir $MODULEPATH/$currentPackage && cd $MODULEPATH/$currentPackage
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/misc/$currentPackage/ -A * || exit 1
info=$(DownloadLatestFromGithub "alols" $currentPackage)
version=${info#* }
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" $currentPackage.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" $currentPackage.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" $currentPackage.SlackBuild
sh $currentPackage.SlackBuild || exit 1
mv /tmp/$currentPackage*.t?z $MODULEPATH/packages
installpkg $MODULEPATH/packages/$currentPackage*.t?z
rm -fr $MODULEPATH/$currentPackage

currentPackage=lxdm
mkdir $MODULEPATH/$currentPackage && cd $MODULEPATH/$currentPackage
cp -R $SCRIPTPATH/../lxdm/* .
GTK3=no sh $currentPackage.SlackBuild || exit 1
rm -fr $MODULEPATH/$currentPackage

currentPackage=audacious
mkdir $MODULEPATH/$currentPackage && cd $MODULEPATH/$currentPackage
info=$(DownloadLatestFromGithub "audacious-media-player" $currentPackage)
#version=${info#* }
version="4.3-beta1"
cp $SCRIPTPATH/extras/audacious/$currentPackage-gtk.SlackBuild .
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" $currentPackage-gtk.SlackBuild
sh $currentPackage-gtk.SlackBuild || exit 1
rm -fr $MODULEPATH/$currentPackage

currentPackage=audacious-plugins
mkdir $MODULEPATH/$currentPackage && cd $MODULEPATH/$currentPackage
info=$(DownloadLatestFromGithub "audacious-media-player" $currentPackage)
#version=${info#* }
version="4.3-beta1"
cp $SCRIPTPATH/extras/audacious/$currentPackage-gtk.SlackBuild .
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" $currentPackage-gtk.SlackBuild
sh $currentPackage-gtk.SlackBuild || exit 1
rm -fr $MODULEPATH/$currentPackage

# temporary just to build engrampa and mate-search-tool
currentPackage=mate-common
mkdir $MODULEPATH/$currentPackage && cd $MODULEPATH/$currentPackage
info=$(DownloadLatestFromGithub "mate-desktop" $currentPackage)
version=${info#* }
filename=${info% *}
tar xvf $filename && rm $filename || exit 1
cd $currentPackage*
sh autogen.sh --prefix=/usr --libdir=/usr/lib$SYSTEMBITS --sysconfdir=/etc
make -j8 install || exit 1
rm -fr $MODULEPATH/$currentPackage

# temporary to build yelp-tools
installpkg $MODULEPATH/packages/python-pip*.txz || exit 1
rm $MODULEPATH/packages/python-pip*.txz
cd $MODULEPATH
pip install lxml || exit 1

# temporary to build yelp-tools
currentPackage=yelp-xsl
mkdir $MODULEPATH/$currentPackage && cd $MODULEPATH/$currentPackage
info=$(DownloadLatestFromGithub "GNOME" $currentPackage)
version=${info#* }
filename=${info% *}
tar xvf $filename && rm $filename || exit 1
cd $currentPackage*
sh autogen.sh --prefix=/usr --libdir=/usr/lib$SYSTEMBITS --sysconfdir=/etc
make -j8 install || exit 1
rm -fr $MODULEPATH/$currentPackage

# temporary to build engrampa and mate-search-tool
currentPackage=yelp-tools
mkdir $MODULEPATH/$currentPackage && cd $MODULEPATH/$currentPackage
info=$(DownloadLatestFromGithub "GNOME" $currentPackage)
version=${info#* }
filename=${info% *}
tar xvf $filename && rm $filename || exit 1
cd $currentPackage*
mkdir build && cd build
meson --prefix /usr ..
ninja -j8 install || exit 1
rm -fr $MODULEPATH/$currentPackage

 required from now on
installpkg $MODULEPATH/packages/libcanberra*.txz || exit 1
installpkg $MODULEPATH/packages/libgtop*.txz || exit 1
rm $MODULEPATH/packages/libgtop*.txz

currentPackage=mate-utils
mkdir $MODULEPATH/$currentPackage && cd $MODULEPATH/$currentPackage
info=$(DownloadLatestFromGithub "mate-desktop" $currentPackage)
version=${info#* }
filename=${info% *}
tar xvf $filename && rm $filename || exit 1
cd $currentPackage*
sed -i "s|mate-dictionary||g" ./Makefile.am
sed -i "s|logview||g" ./Makefile.am
CFLAGS="-O2 -pipe -fPIC -DNDEBUG" ./autogen.sh --prefix=/usr --libdir=/usr/lib$SYSTEMBITS --sysconfdir=/etc --disable-static --disable-debug --disable-gdict-applet --disable-disk-image-mounter || exit
make -j8 install DESTDIR=$MODULEPATH/$currentPackage/package || exit 1
cd $MODULEPATH/$currentPackage/package
wget https://raw.githubusercontent.com/mate-desktop/mate-desktop/v$version/schemas/org.mate.interface.gschema.xml -P usr/share/glib-2.0/schemas || exit 1
/sbin/makepkg -l y -c n $MODULEPATH/packages/mate-utils-$version-$ARCH-1.txz
rm -fr $MODULEPATH/$currentPackage

# required from now on
installpkg $MODULEPATH/packages/gstreamer*.txz || exit 1
rm $MODULEPATH/packages/gstreamer*.txz
installpkg $MODULEPATH/packages/gst-plugins-base*.txz || exit 1
rm $MODULEPATH/packages/gst-plugins-base*.txz
installpkg $MODULEPATH/packages/iso-codes*.txz || exit 1
installpkg $MODULEPATH/packages/libwnck*.txz || exit 1
installpkg $MODULEPATH/packages/xtrans*.txz || exit 1

# mate packages
for currentPackage in \
	mate-common \
	mate-desktop \
	libmatekbd \
	caja \
	mate-polkit \
	zenity \
	marco \
	libmatemixer \
	mate-settings-daemon \
	mate-session-manager \
	mate-menus \
	mate-terminal \
	gtk-layer-shell \
	libmateweather \
	mate-panel \
	mate-themes \
	mate-notification-daemon \
	libpeas \
	eom \
	mate-control-center \
	engrampa \
	mate-media \
	mate-power-manager \
	mate-system-monitor \
	libgxps \
	gtksourceview4 \
	atril \
	caja-extensions \
	mozo \
	pluma \
; do
export currentPackage=$currentPackage
cd $SCRIPTPATH/mate/$currentPackage || exit 1
sh ${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}
done

### fake root

cd $MODULEPATH/packages && ROOT=./ installpkg *.t?z
rm *.t?z

### install additional packages, including porteux utils

InstallAdditionalPackages

### fix some .desktop files

#sed -i "s|Categories=System;|Categories=|g" $MODULEPATH/packages/usr/share/applications/Thunar.desktop

### add mate session

sed -i "s|SESSIONTEMPLATE|/usr/bin/mate-session|g" $MODULEPATH/packages/etc/lxdm/lxdm.conf

### copy xinitrc

cp $MODULEPATH/packages/etc/X11/xinit/xinitrc.mate-session .
cp -s xinitrc.mate-session xinitrc
mv xinitrc $MODULEPATH/packages/etc/X11/xinit/
rm xinitrc.mate-session xinitrc

### copy build files to 05-devel

CopyToDevel

### module clean up

cd $MODULEPATH/packages/

rm -R usr/lib
rm -R usr/lib64/python2.7
rm -R usr/lib64/peas-demo
rm -R usr/lib64/python3.9/site-packages/pip
rm -R usr/lib64/python3.9/site-packages/pip-21.3.1-py3.9.egg-info
rm -R run
rm -R usr/share/engrampa
rm -R usr/share/gnome
rm -R usr/share/gdm
rm -R usr/share/icons/ContrastHigh
rm -R usr/share/icons/mate
rm -R usr/share/icons/mate-black
rm -R usr/share/mate-media/icons
rm -R usr/share/svgalib-demos
rm -R usr/share/Thunar
rm -R usr/share/mate-power-manager/icons
rm -R var/lib/AccountsService

rm etc/xdg/autostart/blueman.desktop
rm usr/bin/canberra*

# remove everything inside usr/share/themes, except Adwaita, Adwaita-dark and DustBlue

GenericStrip

### copy cache files

PrepareFilesForCache

### generate cache files

GenerateCaches

### finalize

Finalize