#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

GenerateRepositoryUrls

DownloadPackage "accountsservice" & # required by lightdm
DownloadPackage "blueman" &
DownloadPackage "keybinder3" &
DownloadPackage "libappindicator" &
DownloadPackage "libdbusmenu" &
DownloadPackage "libindicator" &
DownloadPackage "libwnck3" &
DownloadPackage "libxklavier" &
wait

### temporary packages only for building

DownloadPackage "iso-codes" & # to build libnma
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
