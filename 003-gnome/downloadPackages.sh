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
DownloadPackage "gcr4" & # required by gnome-settings-daemon
DownloadPackage "gexiv2" &
wait
DownloadPackage "gjs" &
DownloadPackage "hunspell" &
DownloadPackage "glib-networking" &
DownloadPackage "gperf" &
DownloadPackage "gst-plugins-bad-free" &
DownloadPackage "gst-plugins-good" &
DownloadPackage "gst-plugins-libav" &
wait
DownloadPackage "gtk4" &
DownloadPackage "hyphen" &
DownloadPackage "ibus" &
DownloadPackage "libcanberra" &
DownloadPackage "libgtop" &
DownloadPackage "libhandy" &
wait
DownloadPackage "libnma" &
DownloadPackage "libproxy" &
DownloadPackage "libxklavier" &
DownloadPackage "libyaml" &
DownloadPackage "mozjs115" &
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
DownloadPackage "iso-codes" &
DownloadPackage "krb5" &
DownloadPackage "libsass" & # required by gnome-console
wait
DownloadPackage "libsoup3" &
DownloadPackage "libwnck3" &
DownloadPackage "python-pip" &
DownloadPackage "rust" & # required by loupe
DownloadPackage "sassc" & # required by gnome-console
DownloadPackage "vulkan-sdk" & # required by gtksourceview
DownloadPackage "xtrans" &
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
