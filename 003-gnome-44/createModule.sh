#!/bin/sh
MODULENAME=003-gnome

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

# only include libgtk file, since gtk+3-classic breaks gnome UI
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

# required from now on
installpkg $MODULEPATH/packages/*.txz || exit 1

# only required for building not for run-time
rm $MODULEPATH/packages/boost*
rm $MODULEPATH/packages/cups*
rm $MODULEPATH/packages/dbus-python*
rm $MODULEPATH/packages/egl-wayland*
rm $MODULEPATH/packages/glade*
rm $MODULEPATH/packages/iso-codes*
rm $MODULEPATH/packages/krb5*
rm $MODULEPATH/packages/libglvnd*
rm $MODULEPATH/packages/libsass*
rm $MODULEPATH/packages/libwnck3*
rm $MODULEPATH/packages/openssl*
rm $MODULEPATH/packages/sassc*
rm $MODULEPATH/packages/xtrans*

# gnome packages
for package in \
	libstemmer \
	exempi \
	tracker3 \
	gtksourceview5 \
	libwpe \
	wpebackend-fdo \
	bubblewrap \
	geoclue2 \
	cogl \
	clutter \
	clutter-gtk \
	clutter-gst \
	geocode-glib \
	geocode-glib2 \
	libgweather \
	libpeas \
	gsound \
	amtk \
	gnome-autoar \
	gnome-desktop \
	gcr \
	gnome-settings-daemon \
	libadwaita \
	gnome-bluetooth \
	libgnomekbd \
	libnma-gtk4 \
	gnome-control-center \
	libgusb \
	colord \
	mutter \
	gnome-shell \
	gnome-session \
	gnome-menus \
	libportal \
	libcloudproviders \
	nautilus \
	nautilus-python \
	gdm \
	gspell \
	gnome-text-editor \
	eog \
	evince \
	gnome-system-monitor \
	vte-gtk4 \
	gnome-console \
	gnome-tweaks \
	gnome-user-share \
	libwnck4 \
	gnome-panel \
	gnome-browser-connector \
	file-roller \
	gnome-backgrounds \
	power-profiles-daemon \
; do
cd $SCRIPTPATH/gnome/$package || exit 1
sh ${package}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/$package-*.txz || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

### fake root

cd $MODULEPATH/packages && ROOT=./ installpkg *.t?z
rm *.t?z

### install additional packages, including porteux utils

InstallAdditionalPackages

### copy build files to 05-devel

CopyToDevel

### module clean up

cd $MODULEPATH/packages/

rm etc/xdg/autostart/blueman.desktop
rm etc/xdg/autostart/ibus*.desktop
rm usr/bin/canberra*
rm usr/bin/gtk4-builder-tool
rm usr/bin/gtk4-demo
rm usr/bin/gtk4-demo-application
rm usr/bin/gtk4-icon-browser
rm usr/bin/gtk4-launch
rm usr/bin/gtk4-print-editor
rm usr/bin/gtk4-widget-factory
rm usr/bin/js102
rm usr/share/applications/org.gtk.gtk4.NodeEditor.desktop

rm -R etc/dconf
rm -R etc/geoclue
rm -R etc/opt
rm -R usr/lib
rm -R usr/lib64/aspell
rm -R usr/lib64/python2.7
rm -R usr/lib64/peas-demo
rm -R usr/share/gstreamer-1.0/gdb
rm -R usr/lib64/graphene-1.0
rm -R usr/lib64/gnome-settings-daemon-3.0
rm -R usr/lib64/python3.9/site-packages/pip*
rm -R usr/share/dbus-1/services/org.freedesktop.ColorHelper.service
rm -R usr/share/dbus-1/services/org.freedesktop.IBus.service
rm -R usr/share/dbus-1/services/org.freedesktop.portal.IBus.service
rm -R usr/share/dbus-1/services/org.freedesktop.portal.Tracker.service
rm -R usr/share/dbus-1/services/org.gnome.ArchiveManager1.service
rm -R usr/share/dbus-1/services/org.gnome.evince.Daemon.service
rm -R usr/share/dbus-1/services/org.gnome.FileRoller.service
rm -R usr/share/dbus-1/services/org.gnome.Nautilus.Tracker3.Miner.Extract.service
rm -R usr/share/dbus-1/services/org.gnome.Nautilus.Tracker3.Miner.Files.service
rm -R usr/share/dbus-1/services/org.gnome.ScreenSaver.service
rm -R usr/share/dbus-1/services/org.gnome.Shell.PortalHelper.service
rm -R usr/share/gjs-1.0
rm -R usr/share/glade/pixmaps
rm -R usr/share/gst-plugins-base
rm -R usr/share/gstreamer-1.0/gdb
rm -R usr/share/gtk-4.0
rm -R usr/share/ibus
rm -R usr/share/installed-tests
rm -R usr/share/gnome/autostart
rm -R usr/share/gnome/shutdown
rm -R usr/share/libgweather-4
rm -R usr/share/pixmaps
rm -R usr/share/vala
rm -R usr/share/zsh
rm -R var/lib/AccountsService

find etc/dbus-1/system.d/ -mindepth 1 -maxdepth 1 ! \( -name "net.hadess.PowerProfiles.conf" \) -exec rm -rf '{}' \; 2>/dev/null
find usr/share/backgrounds/gnome/ -mindepth 1 -maxdepth 1 ! \( -name "adwaita*" \) -exec rm -rf '{}' \; 2>/dev/null
find usr/share/gnome-background-properties/ -mindepth 1 -maxdepth 1 ! \( -name "adwaita*" \) -exec rm -rf '{}' \; 2>/dev/null

GenericStrip
AggressiveStrip

### copy cache files

PrepareFilesForCache

### generate cache files

GenerateCaches

### finalize

Finalize
