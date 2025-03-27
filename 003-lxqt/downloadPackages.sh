#!/bin/bash
source "$PWD/../builder-utils/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

DownloadPackage "accountsservice" &
DownloadPackage "blueman" &
DownloadPackage "ffmpegthumbnailer" &
DownloadPackage "ghostscript-fonts-std" &
DownloadPackage "hunspell" &
wait
DownloadPackage "libcanberra" &
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

DownloadPackage "cups" & # required by qt6
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
