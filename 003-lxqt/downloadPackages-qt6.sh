#!/bin/sh
source "$PWD/../builder-utils/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

DownloadPackage "blueman" &
DownloadPackage "ffmpegthumbnailer" &
DownloadPackage "hunspell" &
#DownloadPackage "kidletime" &
#DownloadPackage "kwindowsystem" &
wait
DownloadPackage "libcanberra" &
DownloadPackage "libdbusmenu-qt" &
#DownloadPackage "libkscreen" &
DownloadPackage "libpaper" & # required by xpdf
#DownloadPackage "networkmanager-qt" &
#DownloadPackage "polkit-qt" &
#DownloadPackage "solid" &
DownloadPackage "xcb-util-cursor" &
wait

### packages that require specific striping

DownloadPackage "qt6" &
wait

### temporary packages for further building

#DownloadPackage "cups" & # to build qpdfview-qt
#DownloadPackage "libspectre" & # to build qpdfview-qt
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
