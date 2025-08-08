#!/bin/bash

MODULENAME=003-xfce-4.18

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

### packages outside slackware repository

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

currentPackage=gpicview
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/lxde/${currentPackage}
cd ${currentPackage}
version=$(git describe | cut -d- -f1)
./autogen.sh && CFLAGS="$GCCFLAGS -ffast-math" ./configure --prefix=/usr --libdir=/usr/lib$SYSTEMBITS --sysconfdir=/etc --disable-static --enable-gtk3
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

currentPackage=atril
sh $SCRIPTPATH/extras/${currentPackage}/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

if [ $SLACKWAREVERSION == "current" ]; then
	# required by mate-polkit
	installpkg $MODULEPATH/packages/libappindicator*.txz || exit 1
	installpkg $MODULEPATH/packages/libdbusmenu*.txz || exit 1
	installpkg $MODULEPATH/packages/libindicator*.txz || exit 1
fi

currentPackage=mate-polkit
sh $SCRIPTPATH/../common/${currentPackage}/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

# temporary just to build engrampa and mate-search-tool
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

# required from now on
installpkg $MODULEPATH/packages/libgtop*.txz || exit 1

currentPackage=pavucontrol
sh $SCRIPTPATH/extras/${currentPackage}/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=mate-utils
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
info=$(DownloadLatestFromGithub "mate-desktop" ${currentPackage} "1.29")
version=${info#* }
filename=${info% *}
tar xvf $filename && rm $filename || exit 1
cd ${currentPackage}*
cp $SCRIPTPATH/extras/${currentPackage}/*.patch .
for i in *.patch; do patch -p0 < $i || exit 1; done
sed -i 's|baobab||g' ./Makefile.am
sed -i 's|mate-dictionary||g' ./Makefile.am
sed -i 's|mate-screenshot||g' ./Makefile.am
sed -i 's|logview||g' ./Makefile.am
sed -i 's|yelp-build|ls|g' autogen.sh
sed -i 's|dnl yelp-tools stuff||g' configure.ac
sed -i 's|YELP_HELP_INIT||g' configure.ac
sed -i 's| help||g' gsearchtool/Makefile.am
CFLAGS="$GCCFLAGS -ffat-lto-objects" ./autogen.sh --prefix=/usr --libdir=/usr/lib$SYSTEMBITS --sysconfdir=/etc --disable-static --disable-debug --disable-gdict-applet --disable-disk-image-mounter || exit
make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
wget https://raw.githubusercontent.com/mate-desktop/mate-desktop/v$version/schemas/org.mate.interface.gschema.xml -P usr/share/glib-2.0/schemas || exit 1
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/mate-search-tool-$version-$ARCH-1.txz
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
CFLAGS="$GCCFLAGS -ffat-lto-objects" ./autogen.sh --prefix=/usr --libdir=/usr/lib$SYSTEMBITS --sysconfdir=/etc --disable-static --disable-debug --disable-caja-actions || exit 1
make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

# required by gspell and mousepad
installpkg $MODULEPATH/packages/aspell*.txz || exit 1
installpkg $MODULEPATH/packages/enchant*.txz || exit 1
installpkg $MODULEPATH/packages/gtksourceview*.txz || exit 1

if [ $SLACKWAREVERSION != "current" ]; then
	currentPackage=gspell
	sh $SCRIPTPATH/deps/${currentPackage}/${currentPackage}.SlackBuild || exit 1
	rm -fr $MODULEPATH/${currentPackage}
fi

installpkg $MODULEPATH/packages/gspell*.txz || exit 1

# required by libxfce4ui
installpkg $MODULEPATH/packages/glade*.txz || exit 1
rm $MODULEPATH/packages/glade*.txz || exit 1

# required by xfce4-panel
installpkg $MODULEPATH/packages/libdbusmenu*.txz || exit 1
installpkg $MODULEPATH/packages/libwnck3-*.txz || exit 1

# required by xfce4-pulseaudio-plugin
installpkg $MODULEPATH/packages/keybinder3*.txz || exit 1

# required by xfce4-terminal
installpkg $MODULEPATH/packages/vte-*.txz || exit 1

# required by xfce4-xkb-plugin
installpkg $MODULEPATH/packages/libxklavier-*.txz || exit 1

# xfce packages
for package in \
	xfce4-dev-tools \
	libxfce4util \
	xfconf \
	libxfce4ui \
	exo \
	garcon \
	xfce4-panel \
	thunar \
	thunar-volman \
	tumbler \
	xfce4-appfinder \
	xfce4-power-manager \
	xfce4-settings \
	xfdesktop \
	xfwm4 \
	xfce4-session \
	xfce4-taskmanager \
	xfce4-terminal \
	xfce4-screenshooter \
	xfce4-notifyd \
	mousepad \
	xfce4-clipman-plugin \
	xfce4-cpugraph-plugin \
	xfce4-pulseaudio-plugin \
	xfce4-sensors-plugin \
	xfce4-systemload-plugin \
	xfce4-whiskermenu-plugin \
	xfce4-xkb-plugin \
; do
sh $SCRIPTPATH/xfce/${package}/${package}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${package}-*.txz || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# only required for building not for run-time
rm $MODULEPATH/packages/xfce4-dev-tools*

currentPackage=lightdm
SESSIONTEMPLATE=xfce sh $SCRIPTPATH/../common/${currentPackage}/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=lightdm-gtk-greeter
ICONTHEME=elementary-xfce-dark sh $SCRIPTPATH/../common/${currentPackage}/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

### fake root

cd $MODULEPATH/packages && ROOT=./ installpkg *.t?z
rm *.t?z

### install additional packages, including porteux utils

InstallAdditionalPackages

### fix some .desktop files

sed -i "s|Core;||g" $MODULEPATH/packages/usr/share/applications/gpicview.desktop
sed -i "s|Graphics;|Utility;|g" $MODULEPATH/packages/usr/share/applications/gpicview.desktop
sed -i "s|image/x-xpixmap|image/x-xpixmap;image/heic;image/jxl|g" $MODULEPATH/packages/usr/share/applications/gpicview.desktop
sed -z -i "s|OnlyShowIn=MATE;\\n||g" $MODULEPATH/packages/usr/share/applications/mate-search-tool.desktop
sed -i "s|MATE;||g" $MODULEPATH/packages/usr/share/applications/mate-search-tool.desktop
sed -i "s|MATE ||g" $MODULEPATH/packages/usr/share/applications/mate-search-tool.desktop
sed -i "s| MATE||g" $MODULEPATH/packages/usr/share/applications/mate-search-tool.desktop
sed -i "s|Categories=System;|Categories=|g" $MODULEPATH/packages/usr/share/applications/thunar.desktop
sed -i "s|System;||g" $MODULEPATH/packages/usr/share/applications/thunar-bulk-rename.desktop
sed -i "s|System;||g" $MODULEPATH/packages/usr/share/applications/xfce4-sensors.desktop
sed -i "s|Utility;||g" $MODULEPATH/packages/usr/share/applications/xfce4-taskmanager.desktop

### copy xinitrc

mkdir -p $MODULEPATH/packages/etc/X11/xinit
cp $SCRIPTPATH/xfce/xfce4-session/xinitrc.xfce $MODULEPATH/packages/etc/X11/xinit/
chmod 0755 $MODULEPATH/packages/etc/X11/xinit/xinitrc.xfce

### copy build files to 05-devel

CopyToDevel

### copy language files to 08-multilanguage

CopyToMultiLanguage

### module clean up

cd $MODULEPATH/packages/

{
rm -R usr/lib${SYSTEMBITS}/gnome-settings-daemon-3.0
rm -R usr/share/engrampa
rm -R usr/share/gdm
rm -R usr/share/gnome
rm -R usr/share/themes/Default/balou
rm -R usr/share/Thunar

rm usr/bin/vte-*-gtk4
rm etc/xdg/autostart/blueman.desktop
rm etc/xdg/autostart/xfce4-clipman-plugin-autostart.desktop
rm etc/xdg/autostart/xscreensaver.desktop
rm usr/lib${SYSTEMBITS}/girepository-1.0/SoupGNOME*
rm usr/lib${SYSTEMBITS}/libappindicator.*
rm usr/lib${SYSTEMBITS}/libdbusmenu-gtk.*
rm usr/lib${SYSTEMBITS}/libindicator.*
rm usr/lib${SYSTEMBITS}/libkeybinder.*
rm usr/lib${SYSTEMBITS}/libsoup-gnome*
rm usr/lib${SYSTEMBITS}/libvte-*-gtk4*
rm usr/libexec/indicator-loader
rm usr/share/applications/org.gnome.Vte*.desktop
rm usr/share/applications/xfce4-file-manager.desktop
rm usr/share/applications/xfce4-mail-reader.desktop
rm usr/share/applications/xfce4-terminal-emulator.desktop
rm usr/share/applications/xfce4-web-browser.desktop
rm usr/share/backgrounds/xfce/xfce-flower.svg
rm usr/share/backgrounds/xfce/xfce-leaves.svg
rm usr/share/backgrounds/xfce/xfce-shapes.svg
rm usr/share/backgrounds/xfce/xfce-stripes.png
rm usr/share/backgrounds/xfce/xfce-teal.jpg
rm usr/share/backgrounds/xfce/xfce-verticals.png
rm usr/share/icons/hicolor/scalable/status/computer.svg
rm usr/share/icons/hicolor/scalable/status/keyboard.svg
rm usr/share/icons/hicolor/scalable/status/phone.svg

[ "$SYSTEMBITS" == 64 ] && find usr/lib/ -mindepth 1 -maxdepth 1 ! \( -name "python*" \) -exec rm -rf '{}' \; 2>/dev/null
} >/dev/null 2>&1

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
