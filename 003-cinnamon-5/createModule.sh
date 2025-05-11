#!/bin/bash

MODULENAME=003-cinnamon-5.6.8

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
sh $SCRIPTPATH/../common/audacious/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=audacious-plugins
sh $SCRIPTPATH/../common/audacious/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

# required by lightdm
installpkg $MODULEPATH/packages/libxklavier-*.txz || exit 1

currentPackage=lightdm
SESSIONTEMPLATE=cinnamon sh $SCRIPTPATH/../common/${currentPackage}/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=lightdm-gtk-greeter
ICONTHEME=Yaru-blue sh $SCRIPTPATH/../common/${currentPackage}/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=mate-polkit
sh $SCRIPTPATH/../common/${currentPackage}/${currentPackage}.SlackBuild || exit 1
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
cp $SCRIPTPATH/extras/${currentPackage}/index.theme $mainIconRootFolder
cp $SCRIPTPATH/extras/${currentPackage}/index-blue.theme $blueIconRootFolder/index.theme
gtk-update-icon-cache -f $mainIconRootFolder || exit 1
gtk-update-icon-cache -f $blueIconRootFolder || exit 1
cd ../${currentPackage}-$version-noarch
echo "Generating icon package. This may take a while..."
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-icon-theme-$version-noarch-1.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

# required from now on
installpkg $MODULEPATH/packages/aspell*.txz || exit 1
installpkg $MODULEPATH/packages/dconf*.txz || exit 1
installpkg $MODULEPATH/packages/libdbusmenu*.txz || exit 1
installpkg $MODULEPATH/packages/enchant*.txz || exit 1
installpkg $MODULEPATH/packages/libgee*.txz || exit 1
installpkg $MODULEPATH/packages/libgtop*.txz || exit 1
installpkg $MODULEPATH/packages/libnma*.txz || exit 1
installpkg $MODULEPATH/packages/libspectre*.txz || exit 1
installpkg $MODULEPATH/packages/libwnck3*.txz || exit 1
installpkg $MODULEPATH/packages/libxklavier*.txz || exit 1
installpkg $MODULEPATH/packages/mozjs78*.txz || exit 1
installpkg $MODULEPATH/packages/python-six*.txz || exit 1
installpkg $MODULEPATH/packages/vte*.txz || exit 1

# required only for building
installpkg $MODULEPATH/packages/iso-codes*.txz || exit 1
rm $MODULEPATH/packages/iso-codes*.txz
installpkg $MODULEPATH/packages/libgsf*.txz || exit 1
rm $MODULEPATH/packages/libgsf*.txz
installpkg $MODULEPATH/packages/python-pip*.txz || exit 1
rm $MODULEPATH/packages/python-pip*.txz
installpkg $MODULEPATH/packages/xtrans*.txz || exit 1
rm $MODULEPATH/packages/xtrans*.txz

cd $MODULEPATH
pip install build || exit 1
pip install flit-core || exit 1
pip install installer || exit 1
pip install pygments || exit 1
pip install pyproject-hooks || exit 1
pip install wheel || exit 1

currentPackage=libhandy
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent -l1 ${SLACKWAREDOMAIN}/slackware/slackware64-current/source/l/${currentPackage}/ || exit 1
sed -i "s|-O[23].*|$GCCFLAGS\"|g" ${currentPackage}.SlackBuild
sed -i "s|\$TAG||g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

currentPackage=libgusb
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent -l1 ${SLACKWAREDOMAIN}/slackware/slackware64-current/source/l/${currentPackage}/ || exit 1
sed -i "s|-O[23].*|$GCCFLAGS\"|g" ${currentPackage}.SlackBuild
sed -i "s|\$TAG||g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

currentPackage=colord
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent -l1 ${SLACKWAREDOMAIN}/slackware/slackware64-current/source/l/${currentPackage}/ || exit 1
sed -i "s|-O[23].*|$GCCFLAGS\"|g" ${currentPackage}.SlackBuild
sed -i "s|\$TAG||g" ${currentPackage}.SlackBuild
sed -i "s|-Dsane=true|-Dsane=false|g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

currentPackage=python-psutil
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent -l1 ${SLACKWAREDOMAIN}/slackware/slackware64-current/source/l/${currentPackage}/ || exit 1
sed -i "s|-O[23].*|$GCCFLAGS\"|g" ${currentPackage}.SlackBuild
sed -i "s|\$TAG||g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

currentPackage=python-webencodings
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent -l1 ${SLACKWAREDOMAIN}/slackware/slackware64-current/source/l/${currentPackage}/ || exit 1
sed -i "s|-O[23].*|$GCCFLAGS\"|g" ${currentPackage}.SlackBuild
sed -i "s|\$TAG||g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

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
	gspell \
	gtksourceview4 \
	libpeas \
	libgxps \
; do
sh $SCRIPTPATH/deps/${package}/${package}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${package}-*.txz || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# required only for building
rm $MODULEPATH/packages/cogl*.txz
rm $MODULEPATH/packages/clutter*.txz

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
rm usr/bin/js[0-9]*
rm usr/bin/pastebin
rm usr/bin/xfce4-set-wallpaper
rm usr/lib${SYSTEMBITS}/libdbusmenu-gtk.*
rm usr/lib${SYSTEMBITS}/libvte-*-gtk4*
rm usr/lib${SYSTEMBITS}/xapps/mate-xapp-status-applet.py
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
