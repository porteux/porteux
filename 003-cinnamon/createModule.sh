#!/bin/bash

MODULENAME=003-cinnamon

source "$PWD/../builder-utils/setflags.sh"

SetFlags "$MODULENAME"

source "$PWD/../builder-utils/cachefiles.sh"
source "$PWD/../builder-utils/downloadfromslackware.sh"
source "$PWD/../builder-utils/genericstrip.sh"
source "$PWD/../builder-utils/helper.sh"
source "$PWD/../builder-utils/latestfromgithub.sh"

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

currentPackage=gettext-tools
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv $MODULEPATH/packages/${currentPackage}-[0-9]* .
version=`ls *.txz -a | rev | cut -d '-' -f 3 | rev`
ROOT=./ installpkg ${currentPackage}-*.txz
mkdir ${currentPackage}-stripped-$version
cp --parents -P usr/bin/msgfmt "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libgettextlib* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libgettextsrc* "${currentPackage}-stripped-$version"
cd ${currentPackage}-stripped-$version
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-stripped-$version-$ARCH-1.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

### packages outside Slackware repository

currentPackage=audacious
sh $SCRIPTPATH/../extras/audacious/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=audacious-plugins
sh $SCRIPTPATH/../extras/audacious/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=lightdm
SESSIONTEMPLATE=cinnamon sh $SCRIPTPATH/../extras/${currentPackage}/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=lightdm-gtk-greeter
sh $SCRIPTPATH/../extras/${currentPackage}/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=mate-polkit
sh $SCRIPTPATH/../extras/${currentPackage}/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=yaru
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget https://github.com/ubuntu/${currentPackage}/archive/refs/heads/master.tar.gz || exit 1
tar xvf master.tar.gz && rm master.tar.gz || exit 1
cd ${currentPackage}-master
version=$(date -r . +%Y%m%d)
mainIconRootFolder=../${currentPackage}-$version-noarch/usr/share/icons/Yaru
blueIconRootFolder=../${currentPackage}-$version-noarch/usr/share/icons/Yaru-blue
mkdir -p $mainIconRootFolder
mkdir -p $blueIconRootFolder
cp -r icons/Yaru/* $mainIconRootFolder || exit 1
cp -r icons/Yaru-blue/* $blueIconRootFolder || exit 1
rm -fr $mainIconRootFolder/cursor*
rm -fr $mainIconRootFolder/*@2x
rm -fr $blueIconRootFolder/*@2x
cp $SCRIPTPATH/deps/${currentPackage}/index.theme $mainIconRootFolder
cp $SCRIPTPATH/deps/${currentPackage}/index-blue.theme $blueIconRootFolder/index.theme
gtk-update-icon-cache -f $mainIconRootFolder || exit 1
gtk-update-icon-cache -f $blueIconRootFolder || exit 1
cd ../${currentPackage}-$version-noarch
echo "Generating icon package. This may take a while..."
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-icon-theme-$version-noarch-1.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

# required from now on
installpkg $MODULEPATH/packages/aspell*.txz || exit 1
installpkg $MODULEPATH/packages/colord*.txz || exit 1
installpkg $MODULEPATH/packages/libdbusmenu*.txz || exit 1
installpkg $MODULEPATH/packages/enchant*.txz || exit 1
installpkg $MODULEPATH/packages/gspell*.txz || exit 1
installpkg $MODULEPATH/packages/libcanberra*.txz || exit 1
installpkg $MODULEPATH/packages/libgee*.txz || exit 1
installpkg $MODULEPATH/packages/libgtop*.txz || exit 1
installpkg $MODULEPATH/packages/libhandy*.txz || exit 1
installpkg $MODULEPATH/packages/libnma*.txz || exit 1
installpkg $MODULEPATH/packages/libsoup*.txz || exit 1
installpkg $MODULEPATH/packages/libspectre*.txz || exit 1
installpkg $MODULEPATH/packages/libwnck3*.txz || exit 1
installpkg $MODULEPATH/packages/libxklavier*.txz || exit 1
installpkg $MODULEPATH/packages/python-six*.txz || exit 1
installpkg $MODULEPATH/packages/vte*.txz || exit 1

# required only for building
installpkg $MODULEPATH/packages/boost*.txz || exit 1
rm $MODULEPATH/packages/boost*.txz
installpkg $MODULEPATH/packages/iso-codes*.txz || exit 1
rm $MODULEPATH/packages/iso-codes*.txz
installpkg $MODULEPATH/packages/libgsf*.txz || exit 1
rm $MODULEPATH/packages/libgsf*.txz
installpkg $MODULEPATH/packages/llvm*.txz || exit 1
rm $MODULEPATH/packages/llvm*.txz
installpkg $MODULEPATH/packages/python-build*.txz || exit 1
rm $MODULEPATH/packages/python-build*.txz
installpkg $MODULEPATH/packages/python-flit-core*.txz || exit 1
rm $MODULEPATH/packages/python-flit-core*.txz
installpkg $MODULEPATH/packages/python-installer*.txz || exit 1
rm $MODULEPATH/packages/python-installer*.txz
installpkg $MODULEPATH/packages/python-pip*.txz || exit 1
rm $MODULEPATH/packages/python-pip*.txz
installpkg $MODULEPATH/packages/python-pyproject-hooks*.txz || exit 1
rm $MODULEPATH/packages/python-pyproject-hooks*.txz
installpkg $MODULEPATH/packages/python-wheel*.txz || exit 1
rm $MODULEPATH/packages/python-wheel*.txz
installpkg $MODULEPATH/packages/rust*.txz || exit 1
rm $MODULEPATH/packages/rust*.txz
installpkg $MODULEPATH/packages/xorg-server-xwayland*.txz || exit 1
rm $MODULEPATH/packages/xorg-server-xwayland*.txz
installpkg $MODULEPATH/packages/xtrans*.txz || exit 1
rm $MODULEPATH/packages/xtrans*.txz

# cinnamon deps
for package in \
	tinycss2 \
	xdotool \
	gsound \
	pytz \
	libtimezonemap \
	setproctitle \
	ptyprocess \
	python-pam \
	libgnomekbd \
	zenity \
	cogl \
	clutter \
	caribou \
	pexpect \
	polib \
	python3-xapp \
	libpeas \
	libgxps \
	exempi \
	mozjs115 \
; do
sh $SCRIPTPATH/deps/${package}/${package}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${package}-*.txz || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# cinnamon extras
for package in \
	file-roller \
	gnome-terminal \
	gnome-screenshot \
	gnome-system-monitor \
; do
sh $SCRIPTPATH/extras/${package}/${package}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${package}-*.txz || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

cd $MODULEPATH
pip install pysass # required by cinnamon project

# cinnamon packages
for package in \
	cjs \
	cinnamon-desktop \
	xapp \
	cinnamon-session \
	cinnamon-settings-daemon \
	cinnamon-menus \
	cinnamon-control-center \
	muffin \
	nemo \
	nemo-extensions \
	cinnamon-screensaver \
	cinnamon \
	xreader \
	xviewer \
	xed \
; do
sh $SCRIPTPATH/cinnamon/${package}/${package}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${package}-*.txz || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

### fake root

cd $MODULEPATH/packages && ROOT=./ installpkg *.t?z
rm *.t?z

### install additional packages, including porteux utils

InstallAdditionalPackages

### fix some .desktop files

sed -i "s|image/avif|image/avif;image/jxl|g" $MODULEPATH/packages/usr/share/applications/xviewer.desktop

### disable some services

echo "Hidden=true" >> $MODULEPATH/packages/etc/xdg/autostart/cinnamon-settings-daemon-color.desktop

### add cinnamon session

sed -i "s|SESSIONTEMPLATE|/usr/bin/cinnamon-session|g" $MODULEPATH/packages/etc/lxdm/lxdm.conf

### TEMPORARY: remove some xed plugins that doesn't work with new pygobject 3.52.x

rm -fr $MODULEPATH/packages/usr/lib64/xed/joinlines
rm -fr $MODULEPATH/packages/usr/lib64/xed/open-uri-context-menu
rm -fr $MODULEPATH/packages/usr/lib64/xed/textsize
rm $MODULEPATH/packages/usr/lib64/xed/joinlines.plugin
rm $MODULEPATH/packages/usr/lib64/xed/sort.plugin
rm $MODULEPATH/packages/usr/lib64/xed/textsize.plugin

### copy build files to 05-devel

CopyToDevel

### copy language files to 08-multilanguage

CopyToMultiLanguage

### module clean up

cd $MODULEPATH/packages/

rm -R etc/dbus-1/system.d
rm -R etc/dconf
rm -R etc/geoclue
rm -R etc/opt
rm -R usr/lib${SYSTEMBITS}/aspell
rm -R usr/lib${SYSTEMBITS}/glade
rm -R usr/lib${SYSTEMBITS}/graphene-1.0
rm -R usr/lib${SYSTEMBITS}/gtk-2.0
rm -R usr/lib${SYSTEMBITS}/python2*
rm -R usr/lib*/python*/site-packages/pip*
rm -R usr/lib*/python*/site-packages/psutil/tests
rm -R usr/share/cjs-1.0
rm -R usr/share/clutter-1.0
rm -R usr/share/cogl
rm -R usr/share/gdm
rm -R usr/share/glade/pixmaps
rm -R usr/share/gnome
rm -R usr/share/installed-tests
rm -R usr/share/libdbusmenu
rm -R usr/share/mate-panel
rm -R usr/share/pixmaps
rm -R usr/share/Thunar
rm -R usr/share/vala
rm -R usr/share/xed/gir-1.0
rm -R usr/share/xviewer/gir-1.0
rm -R usr/share/zsh
rm -R var/lib/AccountsService

rm usr/bin/vte-*-gtk4
rm etc/profile.d/80xapp-gtk3-module.sh
rm etc/xdg/autostart/blueman.desktop
rm etc/xdg/autostart/caribou-autostart.desktop
rm etc/xdg/autostart/xapp-sn-watcher.desktop
rm usr/bin/canberra*
rm usr/bin/js[0-9]*
rm usr/bin/pastebin
rm usr/bin/xfce4-set-wallpaper
rm usr/lib${SYSTEMBITS}/libappindicator.*
rm usr/lib${SYSTEMBITS}/libcanberra-gtk.*
rm usr/lib${SYSTEMBITS}/libdbusmenu-gtk.*
rm usr/lib${SYSTEMBITS}/libindicator.*
rm usr/lib${SYSTEMBITS}/libvte-*-gtk4*
rm usr/lib${SYSTEMBITS}/xapps/mate-xapp-status-applet.py
rm usr/libexec/indicator-loader
rm usr/share/dbus-1/services/org.gnome.Caribou.Antler.service
rm usr/share/dbus-1/services/org.gnome.Caribou.Daemon.service
rm usr/share/dbus-1/services/org.gnome.FileRoller.service
rm usr/share/dbus-1/services/org.mate.panel.applet.MateXAppStatusAppletFactory.service

[ "$SYSTEMBITS" == 64 ] && find usr/lib/ -mindepth 1 -maxdepth 1 ! \( -name "python*" \) -exec rm -rf '{}' \; 2>/dev/null
find usr/share/cinnamon/faces -mindepth 1 -maxdepth 1 ! \( -name "user-generic*" \) -exec rm -rf '{}' \; 2>/dev/null
find usr/share/cinnamon/thumbnails/cursors -mindepth 1 -maxdepth 1 ! \( -name "Adwaita*" -o -name "Paper*" -o -name "unknown*" -o -name "Yaru*" \) -exec rm -rf '{}' \; 2>/dev/null

mv $MODULEPATH/packages/usr/lib${SYSTEMBITS}/libmozjs-* $MODULEPATH/
mv $MODULEPATH/packages/usr/lib${SYSTEMBITS}/libvte-* $MODULEPATH/
GenericStrip
AggressiveStripAll
mv $MODULEPATH/libvte-* $MODULEPATH/packages/usr/lib${SYSTEMBITS}
mv $MODULEPATH/libmozjs-* $MODULEPATH/packages/usr/lib${SYSTEMBITS}

### copy cache files

PrepareFilesForCacheDE

### generate cache files

GenerateCachesDE

### finalize

Finalize
