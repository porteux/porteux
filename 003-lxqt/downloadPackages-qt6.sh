#!/bin/sh
source "$PWD/../builder-utils/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

DownloadPackage "blueman" &
DownloadPackage "ffmpegthumbnailer" &
DownloadPackage "ghostscript-fonts-std" &
DownloadPackage "hunspell" &
#DownloadPackage "kidletime" &
#DownloadPackage "kwindowsystem" &
#DownloadPackage "layer-shell-qt" &
DownloadPackage "libcanberra" &
wait
DownloadPackage "libdbusmenu-qt" &
#DownloadPackage "libkscreen" &
DownloadPackage "libpaper" & # required by xpdf
#DownloadPackage "libproxy" & # required by ...
#DownloadPackage "networkmanager-qt" &
#DownloadPackage "polkit-qt" &
#DownloadPackage "solid" &
DownloadPackage "xcb-util-cursor" &
wait

### packages that require specific striping

DownloadPackage "qt6" &
wait

### temporary packages for further building


### script clean up

rm FILE_LIST
rm serverPackages.txt
