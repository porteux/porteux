#!/bin/bash

MODULENAME=003-gnome

source "$PWD/../builder-utils/setflags.sh"

SetFlags "$MODULENAME"

source "$BUILDERUTILSPATH/cachefiles.sh"
source "$BUILDERUTILSPATH/downloadfromslackware.sh"
source "$BUILDERUTILSPATH/genericstrip.sh"
source "$BUILDERUTILSPATH/helper.sh"

[ $SLACKWAREVERSION != "current" ] && echo "This module should be built in current only" && exit 1

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

### packages outside slackware repository

currentPackage=audacious
sh $SCRIPTPATH/../common/audacious/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=audacious-plugins
sh $SCRIPTPATH/../common/audacious/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=ffmpegthumbnailer
sh $SCRIPTPATH/../common/${currentPackage}/${currentPackage}.SlackBuild || exit 1
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

# not using rust from slackware because it's much slower
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --profile minimal --default-toolchain stable -y
rm -fr $HOME/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/share/doc 2>/dev/null
export PATH=$HOME/.cargo/bin/:$PATH

if [[ ${ALLOWTEST:-no} == no ]]; then
	export TESTRELEASES="grep -Ev '\.rc|\.beta|\.alpha'"
else
	export TESTRELEASES="grep ''"
fi

LATESTVERSION=$(curl -s https://gitlab.gnome.org/GNOME/gnome-shell/-/tags?format=atom | grep -oPm 20 '(?<= <title>)[^<]+' | eval "$TESTRELEASES" | grep -v '\-dev' | sed -e 's/alpha/0.0007/' -e 's/beta/0.0008/' -e 's/rc/0.0009/' | sort -V -r | sed 's/0.0007/alpha/g; s/0.0008/beta/g; s/0.0009/rc/g' | head -1)

echo "Building GNOME ${LATESTVERSION}..."
MODULENAME=$MODULENAME-${LATESTVERSION}

# gnome deps
for package in \
	libxmlb \
	appstream \
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
	glycin \
	libwnck4 \
	exempi \
	blueprint-compiler \
; do
sh $SCRIPTPATH/deps/${package}/${package}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${package}-*.txz || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# only required for building not for run-time
rm $MODULEPATH/packages/blueprint-compiler*
rm $MODULEPATH/packages/gperf*

# gnome packages
for package in \
	libadwaita \
	gnome-online-accounts \
	gtksourceview5 \
	geocode-glib \
	libgweather \
	gsound \
	gnome-autoar \
	gnome-desktop \
	gnome-settings-daemon \
	gnome-tweaks \
	gnome-bluetooth \
	libnma-gtk4 \
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
	ptyxis \
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

echo "Hidden=true" >> $MODULEPATH/packages/etc/xdg/autostart/localsearch-3.desktop
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
rm usr/lib${SYSTEMBITS}/libcanberra-gtk.*
rm usr/lib${SYSTEMBITS}/libgstopencv-1.0.*
rm usr/lib${SYSTEMBITS}/libgstwebrtcnice.*
rm usr/share/applications/org.gnome.Vte*.desktop
rm usr/share/applications/org.gtk.Demo4.desktop
rm usr/share/applications/org.gtk.gtk4.NodeEditor.desktop
rm usr/share/applications/org.gtk.PrintEditor4.desktop
rm usr/share/applications/org.gtk.WidgetFactory4.desktop
rm usr/share/applications/vte-gtk4.desktop
rm usr/share/dbus-1/services/org.freedesktop.ColorHelper.service
rm usr/share/dbus-1/services/org.freedesktop.IBus.service
rm usr/share/dbus-1/services/org.freedesktop.LocalSearch3.Control.service
rm usr/share/dbus-1/services/org.freedesktop.LocalSearch3.service
rm usr/share/dbus-1/services/org.freedesktop.portal.IBus.service
rm usr/share/dbus-1/services/org.freedesktop.portal.Tracker.service
rm usr/share/dbus-1/services/org.freedesktop.Tracker3.Miner.Files.Control.service
rm usr/share/dbus-1/services/org.freedesktop.Tracker3.Miner.Files.service
rm usr/share/dbus-1/services/org.gnome.ArchiveManager1.service
rm usr/share/dbus-1/services/org.gnome.evince.Daemon.service
rm usr/share/dbus-1/services/org.gnome.FileRoller.service
rm usr/share/dbus-1/services/org.gnome.Nautilus.Tracker3.Miner.Extract.service
rm usr/share/dbus-1/services/org.gnome.Nautilus.Tracker3.Miner.Files.service
rm usr/share/dbus-1/services/org.gnome.ScreenSaver.service
rm usr/share/dbus-1/services/org.gnome.Shell.PortalHelper.service
rm usr/share/glib-2.0/schemas/org.gtk.Demo4.gschema.xml
rm usr/share/icons/hicolor/symbolic/apps/org.gtk.Demo4-symbolic.svg
rm usr/share/icons/hicolor/scalable/apps/org.gtk.Demo4.svg

rm -fr etc/dbus-1/system.d
rm -fr etc/dconf
rm -fr etc/opt
rm -fr usr/lib${SYSTEMBITS}/aspell
rm -fr usr/lib${SYSTEMBITS}/glade
rm -fr usr/lib${SYSTEMBITS}/gnome-settings-daemon-3.0
rm -fr usr/lib${SYSTEMBITS}/graphene-1.0
rm -fr usr/lib${SYSTEMBITS}/gtk-2.0
rm -fr usr/lib${SYSTEMBITS}/python*/site-packages/pip*
rm -fr usr/share/gjs-1.0
rm -fr usr/share/glade/pixmaps
rm -fr usr/share/gnome
rm -fr usr/share/gtk-4.0
rm -fr usr/share/ibus
rm -fr usr/share/icons/Adwaita/8x8
rm -fr usr/share/icons/Adwaita/96x96
rm -fr usr/share/icons/Adwaita/256x256
rm -fr usr/share/icons/Adwaita/512x512
rm -fr usr/share/libgweather-4
rm -fr usr/share/pixmaps
rm -fr var/lib/AccountsService

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
