#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

GenerateRepositoryUrls

DownloadPackage "accountsservice" &
DownloadPackage "blueman" &
DownloadPackage "ghostscript-fonts-std" &
DownloadPackage "hunspell" &
DownloadPackage "kidletime" &
DownloadPackage "kwindowsystem" &
wait
DownloadPackage "libdbusmenu-qt" &
DownloadPackage "libkscreen" &
DownloadPackage "libpaper" & # required by xpdf
DownloadPackage "libxklavier" & # required by lightdm-gtk-greeter
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
