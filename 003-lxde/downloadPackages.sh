#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

GenerateRepositoryUrls

DownloadPackage "accountsservice" & # required by lightdm
DownloadPackage "blueman" &
DownloadPackage "keybinder3" &
DownloadPackage "libappindicator" &
DownloadPackage "libdbusmenu" &
DownloadPackage "libindicator" &
DownloadPackage "libnma" &
DownloadPackage "libwnck3" &
DownloadPackage "libxklavier" &
DownloadPackage "vte" &
wait

### temporary packages only for building

DownloadPackage "icu4c" & # required by lxterminal (only for safety in case it gets updated in Slackware repo)
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
