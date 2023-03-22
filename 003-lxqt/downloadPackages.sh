#!/bin/sh
source "$PWD/../builder-utils/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

DownloadPackage "blueman" &
DownloadPackage "ffmpegthumbnailer" &
DownloadPackage "hunspell" &
DownloadPackage "json-glib" &
DownloadPackage "kidletime" &
wait
DownloadPackage "kwindowsystem" &
DownloadPackage "libdbusmenu-qt" &
DownloadPackage "libkscreen" &
DownloadPackage "networkmanager-qt" &
DownloadPackage "polkit-qt" &
DownloadPackage "solid" &
wait

### packages that require specific striping

DownloadPackage "qt5" &
wait

### temporary packages for further building

DownloadPackage "cups" & # to build qpdfview-qt
DownloadPackage "libspectre" & # to build qpdfview-qt
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
