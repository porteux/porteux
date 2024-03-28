#!/bin/sh
MODULENAME=003-cinnamon

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

# only include libgtk file, since gtk+3-classic breaks gnome apps UI
currentPackage=gtk+3
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv $MODULEPATH/packages/${currentPackage}-[0-9]* .
version=`ls * -a | cut -d'-' -f2- | sed 's/\.txz$//'`
ROOT=./ installpkg ${currentPackage}-*.txz || exit 1
mkdir ${currentPackage}-stripped-$version
cp --parents -P usr/lib$SYSTEMBITS/libgtk-3* ${currentPackage}-stripped-$version || exit 1
cd ${currentPackage}-stripped-$version
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-stripped-$version.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

### packages outside Slackware repository

currentPackage=audacious
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
info=$(DownloadLatestFromGithub "audacious-media-player" ${currentPackage})
version=${info#* }
cp $SCRIPTPATH/extras/audacious/${currentPackage}-gtk.SlackBuild .
sh ${currentPackage}-gtk.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=audacious-plugins
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
info=$(DownloadLatestFromGithub "audacious-media-player" ${currentPackage})
version=${info#* }
cp $SCRIPTPATH/extras/audacious/${currentPackage}-gtk.SlackBuild .
sh ${currentPackage}-gtk.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=lxdm
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
cp -R $SCRIPTPATH/../${currentPackage}/* .
GTK3=yes sh ${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=mozjs102
wget -c https://slackware.uk/cumulative/slackware64-current/slackware64/l/${currentPackage}-102.15.1esr-x86_64-2.txz -P $MODULEPATH/packages

# required only for building
installpkg $MODULEPATH/packages/iso-codes*.txz || exit 1
rm $MODULEPATH/packages/iso-codes*.txz
installpkg $MODULEPATH/packages/libgsf*.txz || exit 1
rm $MODULEPATH/packages/libgsf*.txz
installpkg $MODULEPATH/packages/libxklavier*.txz || exit 1
rm $MODULEPATH/packages/libxklavier*.txz
installpkg $MODULEPATH/packages/python-build*.txz || exit 1
rm $MODULEPATH/packages/python-build*.txz
installpkg $MODULEPATH/packages/python-flit-core*.txz || exit 1
rm $MODULEPATH/packages/python-flit-core*.txz
installpkg $MODULEPATH/packages/python-installer*.txz || exit 1
rm $MODULEPATH/packages/python-installer*.txz
installpkg $MODULEPATH/packages/python-pyproject-hooks*.txz || exit 1
rm $MODULEPATH/packages/python-pyproject-hooks*.txz
installpkg $MODULEPATH/packages/python-tomli*.txz || exit 1
rm $MODULEPATH/packages/python-tomli*.txz
installpkg $MODULEPATH/packages/python-six*.txz || exit 1
rm $MODULEPATH/packages/python-six*.txz
installpkg $MODULEPATH/packages/python-wheel*.txz || exit 1
rm $MODULEPATH/packages/python-wheel*.txz
installpkg $MODULEPATH/packages/xorg-server-xwayland*.txz || exit 1
rm $MODULEPATH/packages/xorg-server-xwayland*.txz

# required from now on
installpkg $MODULEPATH/packages/aspell*.txz || exit 1
installpkg $MODULEPATH/packages/colord*.txz || exit 1
installpkg $MODULEPATH/packages/enchant*.txz || exit 1
installpkg $MODULEPATH/packages/libcanberra*.txz || exit 1
installpkg $MODULEPATH/packages/libgtop*.txz || exit 1
installpkg $MODULEPATH/packages/libhandy*.txz || exit 1
installpkg $MODULEPATH/packages/libnma*.txz || exit 1
installpkg $MODULEPATH/packages/libsoup*.txz || exit 1
installpkg $MODULEPATH/packages/libwnck3.txz || exit 1
installpkg $MODULEPATH/packages/mozjs*.txz || exit 1
installpkg $MODULEPATH/packages/xtrans*.txz || exit 1

# gnome packages
for package in \
	tinycss2 \
	xdotool \
	gsound \
	pytz \
	libtimezonemap \
	setproctitle \
	ptyprocess \
	cjs \
	python-pam \
	cinnamon-desktop \
	libgnomekbd \
	xapp \
	cinnamon-session \
	cinnamon-settings-daemon \
	cinnamon-menus \
	cinnamon-control-center \
	zenity \
	cogl \
	clutter \
	clutter-gtk \
	muffin \
	caribou \
	pexpect \
	metacity \
	polib \
	nemo \
	python3-xapp \
	cinnamon-screensaver \
	cinnamon \
	file-roller \
	gnome-terminal \
	gnome-screenshot \
	gnome-system-monitor \
	gspell \
	gtksourceview4 \
	libpeas \
	libgxps \
	xreader \
	xviewer \
	xed \
; do
cd $SCRIPTPATH/cinnamon/$package || exit 1
sh ${package}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/$package-*.txz || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

### fake root

cd $MODULEPATH/packages && ROOT=./ installpkg *.t?z
rm *.t?z

### install additional packages, including porteux utils

InstallAdditionalPackages

### fix some .desktop files

sed -i "s|image/avif|image/avif;image/jxl|g" $MODULEPATH/packages/usr/share/applications/xviewer.desktop

### add cinnamon session

sed -i "s|SESSIONTEMPLATE|/usr/bin/cinnamon-session|g" $MODULEPATH/packages/etc/lxdm/lxdm.conf

### copy build files to 05-devel

CopyToDevel

### copy language files to 08-multilanguage

CopyToMultiLanguage

### update icon cache

gtk-update-icon-cache $MODULEPATH/packages/usr/share/icons/Yaru
gtk-update-icon-cache $MODULEPATH/packages/usr/share/icons/Yaru-blue

### module clean up

cd $MODULEPATH/packages/

rm -R etc/dconf
rm -R etc/dbus-1/system.d
rm -R etc/geoclue
rm -R etc/opt
rm -R usr/lib
rm -R usr/lib64/aspell
rm -R usr/lib64/glade
rm -R usr/lib64/graphene-1.0
rm -R usr/lib64/gtk-2.0
rm -R usr/lib64/libappindicator.*
rm -R usr/lib64/peas-demo
rm -R usr/lib64/python2.7
rm -R usr/lib64/python3.9/site-packages/pip*
rm -R usr/share/dbus-1/services/org.gnome.FileRoller.service
rm -R usr/share/cjs-1.0
rm -R usr/share/glade/pixmaps
rm -R usr/share/gnome
rm -R usr/share/installed-tests
rm -R usr/share/pixmaps
rm -R usr/share/vala
rm -R usr/share/zsh
rm -R var/lib/AccountsService

rm etc/xdg/autostart/blueman.desktop
rm usr/bin/canberra*
rm usr/bin/js[0-9]*
rm usr/bin/peas-demo
rm usr/lib64/libcanberra-gtk.*
rm usr/lib64/libdbusmenu-gtk.*

mv $MODULEPATH/packages/usr/lib64/libmozjs-* $MODULEPATH/
GenericStrip
AggressiveStripAll
mv $MODULEPATH/libmozjs-* $MODULEPATH/packages/usr/lib64

### copy cache files

PrepareFilesForCache

### generate cache files

GenerateCaches

### finalize

Finalize
