#!/bin/sh
source "$PWD/../builder-utils/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

DownloadPackage "accountsservice" &
DownloadPackage "aspell" &
DownloadPackage "dconf" &
DownloadPackage "enchant" &
DownloadPackage "ffmpegthumbnailer" &
wait
DownloadPackage "gexiv2" &
DownloadPackage "glib-networking" &
DownloadPackage "hunspell" &
DownloadPackage "hyphen" &
DownloadPackage "ibus" &
DownloadPackage "libcanberra" &
wait
DownloadPackage "libgtop" &
DownloadPackage "libproxy" &
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
	wait
fi

### temporary packages for further building

DownloadPackage "boost" &
DownloadPackage "cups" &
DownloadPackage "dbus-python" &
DownloadPackage "egl-wayland" &
DownloadPackage "gst-plugins-bad-free" &
DownloadPackage "iso-codes" &
DownloadPackage "krb5" &
wait
DownloadPackage "libsass" & # required by gnome-console
DownloadPackage "libwnck3" &
DownloadPackage "llvm" & # required by mozjs
DownloadPackage "rust" &
DownloadPackage "sassc" & # required by gnome-console
DownloadPackage "texinfo" & # required by mozjs91
DownloadPackage "xtrans" &
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
