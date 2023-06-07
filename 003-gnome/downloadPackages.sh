#!/bin/sh
source "$PWD/../builder-utils/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

DownloadPackage "accountsservice" &
DownloadPackage "aspell" &
DownloadPackage "dconf" &
DownloadPackage "enchant" &
DownloadPackage "ffmpegthumbnailer" &
DownloadPackage "gexiv2" &
wait
DownloadPackage "glade" &
DownloadPackage "glib-networking" &
DownloadPackage "graphene" &
DownloadPackage "gst-plugins-base" &
DownloadPackage "gstreamer" &
DownloadPackage "hyphen" &
wait
DownloadPackage "ibus" &
DownloadPackage "json-glib" &
DownloadPackage "libcanberra" &
DownloadPackage "libgtop" &
DownloadPackage "libxklavier" &
DownloadPackage "xorg-server-xwayland" &
DownloadPackage "woff2" &
wait

### slackware current only packages

if [ $SLACKWAREVERSION == "current" ]; then
	DownloadPackage "gsettings-desktop-schemas" &
	DownloadPackage "gtk4" &
	DownloadPackage "libhandy" &
	DownloadPackage "libnma" &
	DownloadPackage "libsoup3" &
	DownloadPackage "openssl" &
	DownloadPackage "vte" &
	wait
fi

### packages that require specific striping

DownloadPackage "gtk+3" &
wait

### temporary packages for further building

DownloadPackage "boost" &
DownloadPackage "cups" &
DownloadPackage "dbus-python" &
DownloadPackage "egl-wayland" &
DownloadPackage "gst-plugins-bad-free" &
DownloadPackage "iso-codes" &
DownloadPackage "krb5" &
DownloadPackage "libglvnd" &
wait
DownloadPackage "libsass" & # required by gnome-console
DownloadPackage "libwnck3" &
DownloadPackage "llvm" & # required by mozjs
DownloadPackage "rust" &
DownloadPackage "sassc" & # required by gnome-console
DownloadPackage "xtrans" &
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
