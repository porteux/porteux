#!/bin/bash

MODULENAME=003-gnome

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
cd $MODULEPATH

### download packages from slackware repositories

DownloadFromSlackware

### packages outside slackware repository

currentPackage=audacious
sh $SCRIPTPATH/../common/audacious/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=audacious-plugins
sh $SCRIPTPATH/../common/audacious/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=meson
sh $SCRIPTPATH/../common/${currentPackage}/${currentPackage}.SlackBuild || exit 1
/sbin/upgradepkg --install-new --reinstall $MODULEPATH/packages/${currentPackage}-*.txz
rm -fr $MODULEPATH/${currentPackage}
rm $MODULEPATH/packages/${currentPackage}-*.txz

# required from now on
installpkg $MODULEPATH/packages/*.txz || exit 1

# only required for building not for run-time
rm $MODULEPATH/packages/cups*
rm $MODULEPATH/packages/dbus-python*
rm $MODULEPATH/packages/egl-wayland*
rm $MODULEPATH/packages/gst-plugins-bad-free*
rm $MODULEPATH/packages/iso-codes*
rm $MODULEPATH/packages/krb5*
rm $MODULEPATH/packages/libsass*
rm $MODULEPATH/packages/libwnck3*
rm $MODULEPATH/packages/llvm*
rm $MODULEPATH/packages/sassc*
rm $MODULEPATH/packages/texinfo*
rm $MODULEPATH/packages/xtrans*

# not using rust from slackware because it's much slower
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --profile minimal --default-toolchain stable -y
rm -fr $HOME/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/share/doc 2>/dev/null
export PATH=$HOME/.cargo/bin/:$PATH

# some packages (e.g nautilus and vte) require this folder
mkdir -p /usr/local > /dev/null 2>&1
ln -s /usr/include /usr/local/include > /dev/null 2>&1

export GNOME_LATEST_MAJOR_VERSION="42"
export GNOME_LATEST_VERSION=$(curl -s https://download.gnome.org/core/${GNOME_LATEST_MAJOR_VERSION}/ | grep -oP '(?<=<a href=")[^"]+(?=" title)' | grep -v rc | grep -v alpha | grep -v beta | sort -V -r | head -1 | tr -d '/' )
[ ! "${GNOME_LATEST_MAJOR_VERSION}" ] || [ ! "${GNOME_LATEST_VERSION}" ] && echo "Couldn't detect GNOME latest version" && exit 1

echo "Building GNOME ${GNOME_LATEST_VERSION}..."
MODULENAME=$MODULENAME-${GNOME_LATEST_VERSION}

# gnome deps
for package in \
	mozjs91 \
	upower \
	libstemmer \
	libwpe \
	wpebackend-fdo \
	bubblewrap \
	libsoup3 \
	geoclue2 \
	libpeas \
	libwnck4 \
	pango \
; do
sh $SCRIPTPATH/deps/${package}/${package}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${package}-*.txz || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# gnome packages
for package in \
	gsettings-desktop-schemas \
	gtk4 \
	libhandy \
	vte \
	tracker3 \
	gtksourceview5 \
	geocode-glib \
	libgweather \
	gsound \
	gnome-autoar \
	gnome-desktop \
	gnome-settings-daemon \
	libadwaita \
	gnome-tweaks \
	gnome-bluetooth \
	libnma \
	gnome-control-center \
	mutter \
	gjs \
	gnome-shell \
	gnome-session \
	nautilus \
	nautilus-python \
	gdm \
	gspell \
	gnome-text-editor \
	eog \
	evince \
	gnome-system-monitor \
	gnome-console \
	gnome-user-share \
	gnome-backgrounds \
	gnome-browser-connector \
	file-roller \
	adwaita-icon-theme \
	xdg-desktop-portal-gnome \
; do
sh $SCRIPTPATH/gnome/${package}/${package}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${package}-*.txz || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

### fake root

cd $MODULEPATH/packages && ROOT=./ installpkg *.t?z
rm *.t?z

### install additional packages, including porteux utils

InstallAdditionalPackages

### remove some useless services

echo "Hidden=true" >> $MODULEPATH/packages/etc/xdg/autostart/org.gnome.SettingsDaemon.Housekeeping.desktop
echo "Hidden=true" >> $MODULEPATH/packages/etc/xdg/autostart/org.gnome.SettingsDaemon.Rfkill.desktop

### fix some .desktop files

sed -i "s|image/x-icns|image/x-icns;image/heic;image/jxl|g" $MODULEPATH/packages/usr/share/applications/org.gnome.eog.desktop

### copy build files to 05-devel

CopyToDevel

### copy language files to 08-multilanguage

CopyToMultiLanguage

### update icon cache

gtk-update-icon-cache $MODULEPATH/packages/usr/share/icons/Adwaita

### module clean up

cd $MODULEPATH/packages/

{
rm etc/xdg/autostart/blueman.desktop
rm etc/xdg/autostart/ibus*.desktop
rm usr/bin/gtk4-builder-tool
rm usr/bin/gtk4-demo
rm usr/bin/gtk4-demo-application
rm usr/bin/gtk4-encode-symbolic-svg
rm usr/bin/gtk4-icon-browser
rm usr/bin/gtk4-launch
rm usr/bin/gtk4-print-editor
rm usr/bin/gtk4-widget-factory
rm usr/bin/js[0-9]*
rm usr/lib${SYSTEMBITS}/gstreamer-1.0/libgstfluidsynthmidi.*
rm usr/lib${SYSTEMBITS}/gstreamer-1.0/libgstneonhttpsrc.*
rm usr/lib${SYSTEMBITS}/gstreamer-1.0/libgstopencv.*
rm usr/lib${SYSTEMBITS}/gstreamer-1.0/libgstopenexr.*
rm usr/lib${SYSTEMBITS}/gstreamer-1.0/libgstqmlgl.*
rm usr/lib${SYSTEMBITS}/gstreamer-1.0/libgstqroverlay.*
rm usr/lib${SYSTEMBITS}/gstreamer-1.0/libgsttaglib.*
rm usr/lib${SYSTEMBITS}/gstreamer-1.0/libgstwebrtc.*
rm usr/lib${SYSTEMBITS}/gstreamer-1.0/libgstzxing.*
rm usr/lib${SYSTEMBITS}/libgstopencv-1.0.*
rm usr/lib${SYSTEMBITS}/libgstwebrtcnice.*
rm usr/share/applications/org.gnome.Vte*.desktop
rm usr/share/applications/org.gtk.gtk4.NodeEditor.desktop

rm -fr etc/dbus-1/system.d
rm -fr etc/dconf
rm -fr etc/opt
rm -fr usr/lib${SYSTEMBITS}/aspell
rm -fr usr/lib${SYSTEMBITS}/glade
rm -fr usr/lib${SYSTEMBITS}/gnome-settings-daemon-3.0
rm -fr usr/lib${SYSTEMBITS}/graphene-1.0
rm -fr usr/lib${SYSTEMBITS}/gtk-2.0
rm -fr usr/lib${SYSTEMBITS}/tracker-3.0
rm -fr usr/lib*/python3*/site-packages/pip*
rm -fr usr/share/dbus-1/services/org.freedesktop.ColorHelper.service
rm -fr usr/share/dbus-1/services/org.freedesktop.IBus.service
rm -fr usr/share/dbus-1/services/org.freedesktop.portal.IBus.service
rm -fr usr/share/dbus-1/services/org.freedesktop.portal.Tracker.service
rm -fr usr/share/dbus-1/services/org.gnome.ArchiveManager1.service
rm -fr usr/share/dbus-1/services/org.gnome.evince.Daemon.service
rm -fr usr/share/dbus-1/services/org.gnome.FileRoller.service
rm -fr usr/share/dbus-1/services/org.gnome.Nautilus.Tracker3.Miner.Extract.service
rm -fr usr/share/dbus-1/services/org.gnome.Nautilus.Tracker3.Miner.Files.service
rm -fr usr/share/dbus-1/services/org.gnome.ScreenSaver.service
rm -fr usr/share/dbus-1/services/org.gnome.Shell.PortalHelper.service
rm -fr usr/share/gjs-1.0
rm -fr usr/share/glade/pixmaps
rm -fr usr/share/gnome/autostart
rm -fr usr/share/gnome/shutdown
rm -fr usr/share/gtk-4.0
rm -fr usr/share/ibus
rm -fr usr/share/icons/Adwaita/8x8
rm -fr usr/share/icons/Adwaita/96x96
rm -fr usr/share/icons/Adwaita/256x256
rm -fr usr/share/icons/Adwaita/512x512
rm -fr usr/share/icons/Adwaita/cursors
rm -fr usr/share/libgweather-4
rm -fr usr/share/pixmaps
rm -fr var/lib/AccountsService

[ "$SYSTEMBITS" == 64 ] && find usr/lib/ -mindepth 1 -maxdepth 1 ! \( -name "python*" \) -exec rm -rf '{}' \; 2>/dev/null
find usr/share/backgrounds/gnome/ -mindepth 1 -maxdepth 1 ! \( -name "adwaita*" \) -exec rm -rf '{}' \; 2>/dev/null
find usr/share/gnome-background-properties/ -mindepth 1 -maxdepth 1 ! \( -name "adwaita*" \) -exec rm -rf '{}' \; 2>/dev/null
} >/dev/null 2>&1

mv $MODULEPATH/packages/usr/lib${SYSTEMBITS}/libmozjs-* $MODULEPATH/
GenericStrip
AggressiveStripAll
mv $MODULEPATH/libmozjs-* $MODULEPATH/packages/usr/lib${SYSTEMBITS}

### copy cache files

PrepareFilesForCacheDE

### generate cache files

GenerateCachesDE

### finalize

Finalize
