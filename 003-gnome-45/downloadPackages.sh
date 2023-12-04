#!/bin/sh
source "$PWD/../builder-utils/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

DownloadPackage "accountsservice" &
DownloadPackage "aspell" &
DownloadPackage "dconf" &
DownloadPackage "editorconfig-core-c" &
DownloadPackage "enchant" &
DownloadPackage "ffmpegthumbnailer" &
DownloadPackage "gexiv2" &
DownloadPackage "gjs" &
DownloadPackage "hunspell" &
wait
DownloadPackage "glib-networking" &
DownloadPackage "gperf" &
DownloadPackage "graphene" &
DownloadPackage "gsettings-desktop-schemas" &
DownloadPackage "gst-plugins-bad-free" &
DownloadPackage "gst-plugins-good" &
DownloadPackage "gst-plugins-libav" &
DownloadPackage "gtk4" &
wait
DownloadPackage "hyphen" &
DownloadPackage "ibus" &
DownloadPackage "libcanberra" &
DownloadPackage "libgtop" &
DownloadPackage "libhandy" &
DownloadPackage "libnma" &
DownloadPackage "libproxy" &
DownloadPackage "libxklavier" &
wait
DownloadPackage "libyaml" &
DownloadPackage "openssl" &
DownloadPackage "pipewire" &
DownloadPackage "vte" &
DownloadPackage "woff2" &
DownloadPackage "xorg-server-xwayland" &
wait

### packages that require specific striping

DownloadPackage "gtk+3" &
wait

### temporary packages for further building

DownloadPackage "boost" &
DownloadPackage "cups" &
DownloadPackage "dbus-python" &
DownloadPackage "egl-wayland" &
DownloadPackage "gst-plugins-base" & # required by cogl
DownloadPackage "gstreamer" & # required by cogl
DownloadPackage "iso-codes" &
wait
DownloadPackage "krb5" &
DownloadPackage "libglvnd" &
DownloadPackage "libsass" & # required by gnome-console
DownloadPackage "libwnck3" &
DownloadPackage "python-pip" &
DownloadPackage "sassc" & # required by gnome-console
DownloadPackage "xtrans" &
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
