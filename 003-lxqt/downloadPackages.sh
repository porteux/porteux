#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

GenerateRepositoryUrls

DownloadPackage "accountsservice" &
DownloadPackage "blueman" &
DownloadPackage "ghostscript-fonts-std" &
DownloadPackage "hunspell" &
DownloadPackage "libdbusmenu-qt" &
DownloadPackage "libproxy" & # required by xpdf
DownloadPackage "libxklavier" & # required by lightdm-gtk-greeter
wait

### packages that require specific striping

DownloadPackage "qt6" &
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
