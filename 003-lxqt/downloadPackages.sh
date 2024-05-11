#!/bin/sh
source "$PWD/../builder-utils/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

DownloadPackage "blueman" &
DownloadPackage "ffmpegthumbnailer" &
DownloadPackage "ghostscript-fonts-std" &
DownloadPackage "hunspell" &
DownloadPackage "libcanberra" &
wait
DownloadPackage "libdbusmenu-qt" &
DownloadPackage "libpaper" & # required by xpdf
DownloadPackage "libproxy" & # required by xpdf
DownloadPackage "plasma-wayland-protocols" & # required by libkscreen
DownloadPackage "xcb-util-cursor" &
wait

### packages that require specific striping

DownloadPackage "qt6" &
wait

### temporary packages for further building


### script clean up

rm FILE_LIST
rm serverPackages.txt
