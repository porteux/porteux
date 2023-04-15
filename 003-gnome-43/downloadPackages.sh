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
DownloadPackage "glade" &
DownloadPackage "gjs" &
wait
DownloadPackage "glib-networking" &
DownloadPackage "graphene" &
DownloadPackage "gsettings-desktop-schemas" &
DownloadPackage "gst-plugins-base" &
DownloadPackage "gstreamer" &
DownloadPackage "gtk4" &
DownloadPackage "hyphen" &
DownloadPackage "ibus" &
wait
DownloadPackage "json-glib" &
DownloadPackage "libcanberra" &
DownloadPackage "libgtop" &
DownloadPackage "libhandy" &
DownloadPackage "libsoup3" &
DownloadPackage "libxklavier" &
DownloadPackage "openssl" &
DownloadPackage "python-certifi" &
wait
DownloadPackage "python-cffi" &
DownloadPackage "python-chardet" &
DownloadPackage "python-charset-normalizer" &
DownloadPackage "python-idna" &
DownloadPackage "python-requests" &
DownloadPackage "python-urllib3" &
DownloadPackage "vte" &
DownloadPackage "woff2" &
wait

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
DownloadPackage "oniguruma" & # required by jq
#DownloadPackage "rust" &
DownloadPackage "sassc" & # required by gnome-console
DownloadPackage "xorg-server-xwayland" &
DownloadPackage "xtrans" &
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
