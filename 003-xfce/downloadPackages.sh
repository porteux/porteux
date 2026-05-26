#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

GenerateRepositoryUrls

DownloadPackage "accountsservice" & # required by lightdm
DownloadPackage "aspell" & # required by mousepad
DownloadPackage "blueman" &
DownloadPackage "dconf" &
DownloadPackage "enchant" &
DownloadPackage "gspell" &
DownloadPackage "gtksourceview4" &
DownloadPackage "keybinder3" &
DownloadPackage "libappindicator" &
DownloadPackage "libdbusmenu" &
wait
DownloadPackage "libgtop" &
DownloadPackage "libindicator" &
DownloadPackage "libwnck3" &
DownloadPackage "libxklavier" &
wait

### temporary packages only for building

DownloadPackage "libyaml" & # to build xfdesktop with desktop icons
DownloadPackage "iso-codes" & # to build libnma
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
