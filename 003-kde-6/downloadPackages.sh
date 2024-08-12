#!/bin/sh
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
DownloadPackage "libcanberra" &
DownloadPackage "libdmtx" &
DownloadPackage "libproxy" &
DownloadPackage "libqaccessibilityclient" &
DownloadPackage "LibRaw" &
wait
DownloadPackage "qrencode" &
DownloadPackage "taglib" &
DownloadPackage "wayland-protocols" &
DownloadPackage "xcb-util-cursor" &
DownloadPackage "xdpyinfo" &
DownloadPackage "xorg-server-xwayland" &
DownloadPackage "zxing-cpp" &
wait

### packages that require specific striping

DownloadPackage "opencv" &
DownloadPackage "qt6" &
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
