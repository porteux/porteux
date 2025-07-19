#!/bin/bash

MODULENAME=003-gnome

source "$PWD/../builder-utils/setflags.sh"

SetFlags "$MODULENAME"

source "$BUILDERUTILSPATH/cachefiles.sh"
source "$BUILDERUTILSPATH/downloadfromslackware.sh"
source "$BUILDERUTILSPATH/genericstrip.sh"
source "$BUILDERUTILSPATH/helper.sh"
source "$BUILDERUTILSPATH/latestfromgithub.sh"

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

### packages outside Slackware repository

currentPackage=audacious
sh $SCRIPTPATH/../common/audacious/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=audacious-plugins
sh $SCRIPTPATH/../common/audacious/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

# required from now on
installpkg $MODULEPATH/packages/*.txz || exit 1

# only required for building not for run-time
rm $MODULEPATH/packages/boost*
rm $MODULEPATH/packages/c-ares*
rm $MODULEPATH/packages/cups*
rm $MODULEPATH/packages/dbus-python*
rm $MODULEPATH/packages/egl-wayland*
rm $MODULEPATH/packages/iso-codes*
rm $MODULEPATH/packages/krb5*
rm $MODULEPATH/packages/libsass*
rm $MODULEPATH/packages/libwnck3*
rm $MODULEPATH/packages/llvm*
rm $MODULEPATH/packages/openldap*
rm $MODULEPATH/packages/python-pip*
rm $MODULEPATH/packages/sassc*
rm $MODULEPATH/packages/vulkan-sdk*
rm $MODULEPATH/packages/xtrans*

# required by mutter 45+
cd $MODULEPATH
pip install argcomplete || exit 1
pip install attrs || exit 1
pip install jinja2 || exit 1
pip install pygments || exit 1

# rust nightly required by glycin and loupe
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain nightly -y
PATH=/root/.cargo/bin/:$PATH
rustup component add rust-src --toolchain nightly

DE_LATEST_VERSION=$(curl -s https://gitlab.gnome.org/GNOME/gnome-shell/-/tags?format=atom | grep -oPm 20 '(?<= <title>)[^<]+' | grep -v rc | grep -v alpha | grep -v beta | grep -v '\-dev' | sort -V -r | head -1)

echo "Building GNOME ${DE_LATEST_VERSION}..."
MODULENAME=$MODULENAME-${DE_LATEST_VERSION}

# gnome deps
for package in \
	libstemmer \
	libwpe \
	wpebackend-fdo \
	bubblewrap \
	geoclue2 \
	libpeas \
	colord-gtk \
	libei \
	libportal \
	libcloudproviders \
	libheif \
	glycin \
	libwnck4 \
	exempi \
	blueprint-compiler \
; do
sh $SCRIPTPATH/deps/${package}/${package}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${package}-*.txz || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# gnome packages
for package in \
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
	libnma-gtk4 \
	gnome-online-accounts \
	gnome-control-center \
	mutter \
	gnome-shell \
	gnome-session \
	tinysparql \
	localsearch \
	nautilus \
	nautilus-python \
	gdm \
	gspell \
	libspelling \
	gnome-text-editor \
	loupe \
	papers \
	gnome-system-monitor \
	vte \
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

# only required for building not for run-time
rm $MODULEPATH/packages/blueprint-compiler*
rm $MODULEPATH/packages/gperf*
rm $MODULEPATH/packages/libheif*

### fake root

cd $MODULEPATH/packages && ROOT=./ installpkg *.t?z
rm *.t?z

### install additional packages, including porteux utils

InstallAdditionalPackages

### renamed background images to jpg

mv $MODULEPATH/packages/usr/share/backgrounds/gnome/adwaita-d.jxl $MODULEPATH/packages/usr/share/backgrounds/gnome/adwaita-d.jpg
mv $MODULEPATH/packages/usr/share/backgrounds/gnome/adwaita-l.jxl $MODULEPATH/packages/usr/share/backgrounds/gnome/adwaita-l.jpg

### remove some useless services

echo "Hidden=true" >> $MODULEPATH/packages/etc/xdg/autostart/org.gnome.SettingsDaemon.Housekeeping.desktop
echo "Hidden=true" >> $MODULEPATH/packages/etc/xdg/autostart/org.gnome.SettingsDaemon.Rfkill.desktop

### copy build files to 05-devel

CopyToDevel

### copy language files to 08-multilanguage

CopyToMultiLanguage

### update icon cache

gtk-update-icon-cache $MODULEPATH/packages/usr/share/icons/Adwaita

### module clean up

cd $MODULEPATH/packages/

{
rm -R etc/dbus-1/system.d
rm -R etc/dconf
rm -R etc/opt
rm -R usr/lib${SYSTEMBITS}/aspell
rm -R usr/lib${SYSTEMBITS}/glade
rm -R usr/lib${SYSTEMBITS}/gnome-settings-daemon-3.0
rm -R usr/lib${SYSTEMBITS}/graphene-1.0
rm -R usr/lib${SYSTEMBITS}/gtk-2.0
rm -R usr/lib${SYSTEMBITS}/python2*
rm -R usr/lib${SYSTEMBITS}/python*/site-packages/pip*
rm -R usr/libexec/installed-tests
rm -R usr/share/icons/Adwaita/8x8
rm -R usr/share/icons/Adwaita/96x96
rm -R usr/share/icons/Adwaita/256x256
rm -R usr/share/icons/Adwaita/512x512
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
rm -R usr/share/gnome/autostart
rm -R usr/share/gnome/shutdown
rm -R usr/share/gtk-4.0
rm -R usr/share/ibus
rm -R usr/share/installed-tests
rm -R usr/share/libgweather-4
rm -R usr/share/pixmaps
rm -R usr/share/vala
rm -R usr/share/zsh
rm -R var/lib/AccountsService

rm etc/xdg/autostart/blueman.desktop
rm etc/xdg/autostart/ibus*.desktop
rm etc/xdg/autostart/localsearch-3.desktop
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
rm usr/lib${SYSTEMBITS}/libcanberra-gtk.*
rm usr/lib${SYSTEMBITS}/libgstopencv-1.0.*
rm usr/lib${SYSTEMBITS}/libgstwebrtcnice.*
rm usr/libexec/localsearch-*
rm usr/share/applications/org.gtk.Demo4.desktop
rm usr/share/applications/org.gtk.gtk4.NodeEditor.desktop
rm usr/share/applications/org.gtk.PrintEditor4.desktop
rm usr/share/applications/org.gtk.WidgetFactory4.desktop
rm usr/share/applications/vte-gtk4.desktop

[ "$SYSTEMBITS" == 64 ] && find usr/lib/ -mindepth 1 -maxdepth 1 ! \( -name "python*" \) -exec rm -rf '{}' \; 2>/dev/null
find usr/share/backgrounds/gnome/ -mindepth 1 -maxdepth 1 ! \( -name "adwaita*" \) -exec rm -rf '{}' \; 2>/dev/null
find usr/share/gnome-background-properties/ -mindepth 1 -maxdepth 1 ! \( -name "adwaita*" \) -exec rm -rf '{}' \; 2>/dev/null
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
