#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

DownloadPackage "accountsservice" &
DownloadPackage "blueman" &
DownloadPackage "ffmpegthumbnailer" &
DownloadPackage "ghostscript-fonts-std" &
DownloadPackage "hunspell" &
wait
DownloadPackage "libdbusmenu-qt" &
DownloadPackage "libpaper" & # required by xpdf
DownloadPackage "libproxy" & # required by xpdf
DownloadPackage "libxklavier" & # required by lightdm-gtk-greeter
DownloadPackage "plasma-wayland-protocols" & # required by libkscreen
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
