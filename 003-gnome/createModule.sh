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

currentPackage=gtk+3
mkdir $MODULEPATH/$currentPackage && cd $MODULEPATH/$currentPackage
mv $MODULEPATH/packages/$currentPackage-[0-9]* .
version=`ls * -a | cut -d'-' -f2- | sed 's/\.txz$//'`
ROOT=./ installpkg $currentPackage-*.txz || exit 1
mkdir $currentPackage-stripped-$version
cp --parents -P usr/lib$SYSTEMBITS/libgtk-3* $currentPackage-stripped-$version || exit 1
cd $currentPackage-stripped-$version
/sbin/makepkg -l y -c n $MODULEPATH/packages/$currentPackage-stripped-$version.txz > /dev/null 2>&1
rm -fr $MODULEPATH/$currentPackage

### packages outside Slackware repository

currentPackage=lxdm
mkdir $MODULEPATH/$currentPackage && cd $MODULEPATH/$currentPackage
cp -R $SCRIPTPATH/../lxdm/* .
GTK3=no sh $currentPackage.SlackBuild || exit 1
rm -fr $MODULEPATH/$currentPackage

currentPackage=audacious
mkdir $MODULEPATH/$currentPackage && cd $MODULEPATH/$currentPackage
info=$(DownloadLatestFromGithub "audacious-media-player" $currentPackage)
version=${info#* }
cp $SCRIPTPATH/extras/audacious/$currentPackage-gtk.SlackBuild .
sh $currentPackage-gtk.SlackBuild || exit 1
rm -fr $MODULEPATH/$currentPackage

currentPackage=audacious-plugins
mkdir $MODULEPATH/$currentPackage && cd $MODULEPATH/$currentPackage
info=$(DownloadLatestFromGithub "audacious-media-player" $currentPackage)
version=${info#* }
cp $SCRIPTPATH/extras/audacious/$currentPackage-gtk.SlackBuild .
sh $currentPackage-gtk.SlackBuild || exit 1
rm -fr $MODULEPATH/$currentPackage

currentPackage=meson
mkdir $MODULEPATH/$currentPackage && cd $MODULEPATH/$currentPackage
cp $SCRIPTPATH/extras/meson/* .
sh $currentPackage.SlackBuild || exit 1
rm -fr $MODULEPATH/package-$currentPackage
rm -fr $MODULEPATH/$currentPackage*
/sbin/upgradepkg --install-new --reinstall $MODULEPATH/packages/meson-*.txz
rm $MODULEPATH/packages/meson-*.txz

# required from now on
installpkg $MODULEPATH/packages/*.txz || exit 1

rm $MODULEPATH/packages/boost*
rm $MODULEPATH/packages/cups*
rm $MODULEPATH/packages/dbus-python*
rm $MODULEPATH/packages/egl-wayland*
rm $MODULEPATH/packages/glade*
rm $MODULEPATH/packages/gst-plugins-bad-free*
rm $MODULEPATH/packages/iso-codes*
rm $MODULEPATH/packages/krb5*
rm $MODULEPATH/packages/libglvnd*
rm $MODULEPATH/packages/libsoup3*
rm $MODULEPATH/packages/libwnck3*
rm $MODULEPATH/packages/llvm*
rm $MODULEPATH/packages/oniguruma*
rm $MODULEPATH/packages/rust*
rm $MODULEPATH/packages/xorg-server-xwayland*
rm $MODULEPATH/packages/xtrans*

if [ $SLACKWAREVERSION != "current" ]; then
	rm $MODULEPATH/packages/openssl*

	currentPackage=gsettings-desktop-schemas
	cd $SCRIPTPATH/gnome/$currentPackage || exit 1
	sh ${currentPackage}.SlackBuild || exit 1
	installpkg $MODULEPATH/packages/$currentPackage-*.txz || exit 1
	find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
	
	currentPackage=gtk4
	cd $SCRIPTPATH/gnome/$currentPackage || exit 1
	sh ${currentPackage}.SlackBuild || exit 1
	installpkg $MODULEPATH/packages/$currentPackage-*.txz || exit 1
	find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null

	currentPackage=libhandy
	cd $SCRIPTPATH/gnome/$currentPackage || exit 1
	sh ${currentPackage}.SlackBuild || exit 1
	installpkg $MODULEPATH/packages/$currentPackage-*.txz || exit 1
	find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null

	currentPackage=libnma
	cd $SCRIPTPATH/gnome/$currentPackage || exit 1
	sh ${currentPackage}.SlackBuild || exit 1
	installpkg $MODULEPATH/packages/$currentPackage-*.txz || exit 1
	find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null

	currentPackage=libsoup3
	cd $SCRIPTPATH/gnome/$currentPackage || exit 1
	sh ${currentPackage}.SlackBuild || exit 1
	installpkg $MODULEPATH/packages/$currentPackage-*.txz || exit 1
	find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null

	currentPackage=vte
	cd $SCRIPTPATH/gnome/$currentPackage || exit 1
	sh ${currentPackage}.SlackBuild || exit 1
	installpkg $MODULEPATH/packages/$currentPackage-*.txz || exit 1
	find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
fi

# gnome packages
for package in \
	mozjs91 \
	upower \
	libstemmer \
	exempi \
	tracker3 \
	gtksourceview4 \
	gtksourceview5 \
	rest \
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
	tepl \
	libmanette \
	gnome-autoar \
	gnome-desktop \
	gnome-settings-daemon \
	libadwaita \
	gnome-bluetooth \
	libgnomekbd \
	libnma-gtk4 \
	gnome-control-center \
	mutter \
	gjs \
	gnome-shell \
	gnome-session \
	gnome-menus \
	nautilus \
	nautilus-python \
	gdm \
	gspell \
	gnome-text-editor \
	eog \
	adwaita-icon-theme \
	evince \
	gnome-system-monitor \
	gnome-console \
	gnome-tweaks \
	gnome-user-share \
	libwnck4 \
	gnome-panel \
	jq \
	gnome-browser-connector \
	file-roller \
	power-profiles-daemon \
; do
cd $SCRIPTPATH/gnome/$package || exit 1
sh ${package}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/$package-*.txz || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
cd ..
done

### fake root

cd $MODULEPATH/packages && ROOT=./ installpkg *.t?z
rm *.t?z

### install additional packages, including porteux utils

InstallAdditionalPackages

### add gnome session

sed -i "s|SESSIONTEMPLATE|/usr/bin/gnome-session|g" $MODULEPATH/packages/etc/lxdm/lxdm.conf

### copy build files to 05-devel

CopyToDevel

### module clean up

cd $MODULEPATH/packages/

rm etc/xdg/autostart/blueman.desktop
rm usr/bin/canberra*
rm usr/bin/gtk4-builder-tool
rm usr/bin/gtk4-demo
rm usr/bin/gtk4-demo-application
rm usr/bin/gtk4-icon-browser
rm usr/bin/gtk4-launch
rm usr/bin/gtk4-print-editor
rm usr/bin/gtk4-widget-factory
rm usr/bin/js91
rm usr/share/applications/org.gtk.gtk4.NodeEditor.desktop

rm -R usr/lib
rm -R usr/lib64/aspell
rm -R usr/lib64/python2.7
rm -R usr/lib64/peas-demo
rm -R usr/lib64/gnome-settings-daemon-3.0
rm -R usr/lib64/python3.9/site-packages/pip*
rm -R usr/share/gdb
rm -R usr/share/glade/pixmaps
rm -R usr/share/gst-plugins-base
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

find usr/lib64/gstreamer-1.0 -mindepth 1 -maxdepth 1 ! \( -name "libcluttergst3.so" -o -name "libgstcogl.so" \) -exec rm -rf '{}' \; 2>/dev/null

GenericStrip

### copy cache files

PrepareFilesForCache

### generate cache files

GenerateCaches

### finalize

Finalize
