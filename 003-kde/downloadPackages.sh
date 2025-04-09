#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

DownloadPackage "accountsservice" &
DownloadPackage "cfitsio" &
DownloadPackage "editorconfig-core-c" &
DownloadPackage "egl-wayland" &
DownloadPackage "eglexternalplatform" &
DownloadPackage "graphene" &
DownloadPackage "gst-plugins-good" &
wait
DownloadPackage "hunspell" &
DownloadPackage "jasper" &
DownloadPackage "keybinder3" &
DownloadPackage "libdmtx" &
DownloadPackage "libproxy" &
DownloadPackage "libqaccessibilityclient" &
DownloadPackage "LibRaw" &
wait
DownloadPackage "openblas" &
DownloadPackage "qrencode" &
DownloadPackage "wayland-protocols" &
DownloadPackage "xcb-util-cursor" &
DownloadPackage "xdpyinfo" &
DownloadPackage "zxing-cpp" &
wait

### packages that require specific striping

DownloadPackage "gcc-gfortran" & # required by spectable
DownloadPackage "opencv" & # required by spectable
DownloadPackage "phonon" & # required by dolphin and others
DownloadPackage "qt6" &
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
