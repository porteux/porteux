#!/bin/bash

MODULENAME=003-cinnamon

source "$PWD/../builder-utils/setflags.sh"

SetFlags "$MODULENAME"

source "$BUILDERUTILSPATH/cachefiles.sh"
source "$BUILDERUTILSPATH/downloadfromslackware.sh"
source "$BUILDERUTILSPATH/genericstrip.sh"
source "$BUILDERUTILSPATH/helper.sh"

if ! isRoot; then
	echo "Please enter admin's password below:"
	su -c "$0 $1"
	exit
fi

### create module folder

mkdir -p $MODULEPATH/packages > /dev/null 2>&1
cd $MODULEPATH

### download packages from slackware repository

DownloadFromSlackware

### packages that require specific stripping

currentPackage=gettext-tools
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv $MODULEPATH/packages/${currentPackage}-[0-9]* .
packageFileName=$(ls * -a | rev | cut -d . -f 2- | rev)
ROOT=./ installpkg ${currentPackage}*.txz
mkdir ${currentPackage}-stripped
cp --parents -P usr/bin/msgfmt "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libgettextlib* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libgettextsrc* "${currentPackage}-stripped"
cd $MODULEPATH/${currentPackage}/${currentPackage}-stripped
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${packageFileName}_stripped.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

# temporary until cjs fixes compatibility with glib 2.86.0+ (https://github.com/linuxmint/cjs/issues/130)
currentPackage=glib2
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget https://slackware.uk/cumulative/slackware64-current/slackware64/l/glib2-2.84.4-x86_64-1.txz
packageFileName=$(ls * -a | rev | cut -d . -f 2- | rev)
ROOT=./ installpkg ${currentPackage}*.txz
mkdir ${currentPackage}-stripped
cp --parents -Pr usr/lib$SYSTEMBITS/girepository-1.0 "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/lib* "${currentPackage}-stripped"
cd $MODULEPATH/${currentPackage}/${currentPackage}-stripped
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${packageFileName}_stripped.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

### packages outside slackware repository

# required by lightdm
installpkg $MODULEPATH/packages/libxklavier*.txz || exit 1

# required by mate-polkit
installpkg $MODULEPATH/packages/libappindicator*.txz || exit 1
installpkg $MODULEPATH/packages/libdbusmenu*.txz || exit 1
installpkg $MODULEPATH/packages/libindicator*.txz || exit 1

# cinnamon common
for package in \
	audacious \
	audacious-plugins \
	ffmpegthumbnailer \
	lightdm \
	lightdm-gtk-greeter \
	mate-common \
	mate-polkit \
; do
SESSIONTEMPLATE=cinnamon sh $SCRIPTPATH/../common/${package}/${package}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${package}*.txz || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# required from now on
installpkg $MODULEPATH/packages/aspell*.txz || exit 1
installpkg $MODULEPATH/packages/colord*.txz || exit 1
installpkg $MODULEPATH/packages/libdbusmenu*.txz || exit 1
installpkg $MODULEPATH/packages/enchant*.txz || exit 1
installpkg $MODULEPATH/packages/gtksourceview4*.txz || exit 1
installpkg $MODULEPATH/packages/gspell*.txz || exit 1
installpkg $MODULEPATH/packages/libgee*.txz || exit 1
installpkg $MODULEPATH/packages/libgtop*.txz || exit 1
installpkg $MODULEPATH/packages/libhandy*.txz || exit 1
installpkg $MODULEPATH/packages/libnma*.txz || exit 1
installpkg $MODULEPATH/packages/libsoup*.txz || exit 1
installpkg $MODULEPATH/packages/libspectre*.txz || exit 1
installpkg $MODULEPATH/packages/libwnck3*.txz || exit 1
installpkg $MODULEPATH/packages/python-six*.txz || exit 1
installpkg $MODULEPATH/packages/vte*.txz || exit 1

# required only for building
installpkg $MODULEPATH/packages/icu4c*.txz || exit 1
rm $MODULEPATH/packages/icu4c*.txz
installpkg $MODULEPATH/packages/iso-codes*.txz || exit 1
rm $MODULEPATH/packages/iso-codes*.txz
installpkg $MODULEPATH/packages/libgsf*.txz || exit 1
rm $MODULEPATH/packages/libgsf*.txz
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
installpkg $MODULEPATH/packages/xtrans*.txz || exit 1
rm $MODULEPATH/packages/xtrans*.txz

LATESTVERSION=$(curl -s https://github.com/linuxmint/cinnamon/tags/ | grep "/linuxmint/cinnamon/releases/tag/" | grep -oP "(?<=/linuxmint/cinnamon/releases/tag/)[^\"]+" | uniq | grep -v "alpha" | grep -v "beta" | grep -v "rc[0-9]" | grep -v "master." | head -1)

echo "Building Cinnamon ${LATESTVERSION}..."
MODULENAME=$MODULENAME-${LATESTVERSION}

# cinnamon deps
for package in \
	python-tinycss2 \
	xdotool \
	gsound \
	python-pytz \
	libtimezonemap \
	python-setproctitle \
	python-ptyprocess \
	python-pam \
	libgnomekbd \
	zenity \
	cogl \
	clutter \
	caribou \
	python-pexpect \
	python-polib \
	python-xapp \
	libpeas \
	libgxps \
; do
sh $SCRIPTPATH/deps/${package}/${package}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${package}*.txz || exit 1
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
	yaru-icon-theme \
; do
sh $SCRIPTPATH/extras/${package}/${package}.SlackBuild || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

cd $MODULEPATH
pip install pysass # required by cinnamon project

# temporary until cjs migrates do mozjs140
wget https://slackware.uk/cumulative/slackware64-current/slackware64/l/mozjs128-128.14.0esr-x86_64-1.txz -P $MODULEPATH/packages
installpkg $MODULEPATH/packages/mozjs*.txz || exit 1

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
installpkg $MODULEPATH/packages/${package}*.txz || exit 1
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

### TEMPORARY: remove some xed plugins that doesn't work with new pygobject 3.52.x

rm -fr $MODULEPATH/packages/usr/lib${SYSTEMBITS}/xed/plugins/bracket-complete
rm -fr $MODULEPATH/packages/usr/lib${SYSTEMBITS}/xed/plugins/joinlines
rm -fr $MODULEPATH/packages/usr/lib${SYSTEMBITS}/xed/plugins/open-uri-context-menu
rm -fr $MODULEPATH/packages/usr/lib${SYSTEMBITS}/xed/plugins/textsize
rm $MODULEPATH/packages/usr/lib${SYSTEMBITS}/xed/plugins/joinlines.plugin
rm $MODULEPATH/packages/usr/lib${SYSTEMBITS}/xed/plugins/sort.plugin
rm $MODULEPATH/packages/usr/lib${SYSTEMBITS}/xed/plugins/textsize.plugin

### copy build files to 05-devel

CopyToDevel

### copy language files to 08-multilanguage

CopyToMultiLanguage

### module clean up

cd $MODULEPATH/packages/

{
rm usr/bin/vte-*-gtk4
rm etc/profile.d/80xapp-gtk3-module.sh
rm etc/xdg/autostart/blueman.desktop
rm etc/xdg/autostart/caribou-autostart.desktop
rm etc/xdg/autostart/xapp-sn-watcher.desktop
rm usr/bin/js[0-9]*
rm usr/bin/pastebin
rm usr/bin/xfce4-set-wallpaper
rm usr/lib${SYSTEMBITS}/libappindicator.*
rm usr/lib${SYSTEMBITS}/libdbusmenu-gtk.*
rm usr/lib${SYSTEMBITS}/libindicator.*
rm usr/lib${SYSTEMBITS}/libvte-*-gtk4*
rm usr/lib${SYSTEMBITS}/xapps/mate-xapp-status-applet.py
rm usr/libexec/indicator-loader
rm usr/share/applications/org.gnome.Vte*.desktop
rm usr/share/dbus-1/services/org.gnome.Caribou.Antler.service
rm usr/share/dbus-1/services/org.gnome.Caribou.Daemon.service
rm usr/share/dbus-1/services/org.gnome.FileRoller.service
rm usr/share/dbus-1/services/org.mate.panel.applet.MateXAppStatusAppletFactory.service

rm -fr etc/dbus-1/system.d
rm -fr etc/dconf
rm -fr etc/geoclue
rm -fr etc/opt
rm -fr usr/lib${SYSTEMBITS}/aspell
rm -fr usr/lib${SYSTEMBITS}/glade
rm -fr usr/lib${SYSTEMBITS}/graphene-1.0
rm -fr usr/lib${SYSTEMBITS}/gtk-2.0
rm -fr usr/lib*/python*/site-packages/pip*
rm -fr usr/lib*/python*/site-packages/psutil/tests
rm -fr usr/share/cjs-1.0
rm -fr usr/share/clutter-1.0
rm -fr usr/share/cogl
rm -fr usr/share/gdm
rm -fr usr/share/glade/pixmaps
rm -fr usr/share/gnome
rm -fr usr/share/gtksourceview-2.0
rm -fr usr/share/gtksourceview-3.0
rm -fr usr/share/libdbusmenu
rm -fr usr/share/mate-panel
rm -fr usr/share/pixmaps
rm -fr usr/share/Thunar
rm -fr usr/share/xed/gir-1.0
rm -fr usr/share/xviewer/gir-1.0
rm -fr var/lib/AccountsService

[ "$SYSTEMBITS" == 64 ] && find usr/lib/ -mindepth 1 -maxdepth 1 ! \( -name "python*" \) -exec rm -rf '{}' \; 2>/dev/null
find usr/share/cinnamon/faces -mindepth 1 -maxdepth 1 ! \( -name "user-generic*" \) -exec rm -rf '{}' \; 2>/dev/null
find usr/share/cinnamon/thumbnails/cursors -mindepth 1 -maxdepth 1 ! \( -name "Adwaita*" -o -name "Paper*" -o -name "unknown*" -o -name "Yaru*" \) -exec rm -rf '{}' \; 2>/dev/null
} >/dev/null 2>&1

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
