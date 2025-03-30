#!/bin/bash
source "$PWD/../builder-utils/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

DownloadPackage "accountsservice" &
DownloadPackage "cfitsio" &
DownloadPackage "editorconfig-core-c" &
DownloadPackage "egl-wayland" &
DownloadPackage "eglexternalplatform" &
DownloadPackage "graphene" &
DownloadPackage "gst-plugins-good" &
DownloadPackage "hunspell" &
wait
DownloadPackage "jasper" &
DownloadPackage "keybinder3" &
DownloadPackage "libdmtx" &
DownloadPackage "libproxy" &
DownloadPackage "libqaccessibilityclient" &
DownloadPackage "LibRaw" &
wait
DownloadPackage "qrencode" &
DownloadPackage "wayland-protocols" &
DownloadPackage "xcb-util-cursor" &
DownloadPackage "xdpyinfo" &
DownloadPackage "zxing-cpp" &
wait

### packages that require specific striping

DownloadPackage "opencv" &
DownloadPackage "qt6" &
wait

### temporary packages for further building

DownloadPackage "cups" & # required by qt6
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
