#!/bin/bash
source "$PWD/../builder-utils/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

DownloadPackage "accountsservice" &
DownloadPackage "aspell" &
DownloadPackage "cracklib" &
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
DownloadPackage "libpwquality" &
DownloadPackage "libxklavier" &
DownloadPackage "woff2" &
wait

### only download if not present

[ ! -f /usr/bin/clang ] && DownloadPackage "llvm" # required by mozjs

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
DownloadPackage "llvm" &
DownloadPackage "rust" &
DownloadPackage "sassc" & # required by gnome-console
DownloadPackage "texinfo" & # required by mozjs91
DownloadPackage "xtrans" &
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
