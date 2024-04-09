#!/bin/sh
source "$PWD/../builder-utils/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

DownloadPackage "blueman" &
DownloadPackage "ffmpegthumbnailer" &
DownloadPackage "ghostscript-fonts-std" &
DownloadPackage "hunspell" &
DownloadPackage "kidletime" &
DownloadPackage "kwindowsystem" &
DownloadPackage "libcanberra" &
wait
DownloadPackage "libdbusmenu-qt" &
DownloadPackage "libkscreen" &
DownloadPackage "libpaper" & # required by xpdf
DownloadPackage "networkmanager-qt" &
DownloadPackage "polkit-qt" &
DownloadPackage "solid" &
wait

### packages that require specific striping

DownloadPackage "qt5" &
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
