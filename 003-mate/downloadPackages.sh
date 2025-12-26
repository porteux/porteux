#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

GenerateRepositoryUrls

DownloadPackage "blueman" &
DownloadPackage "accountsservice" &
DownloadPackage "aspell" &
DownloadPackage "babl" &
DownloadPackage "dbus-python" &
DownloadPackage "dconf" &
DownloadPackage "enchant" &
wait
DownloadPackage "hunspell" &
DownloadPackage "iso-codes" &
DownloadPackage "jasper" &
DownloadPackage "keybinder3" &
DownloadPackage "libappindicator" &
DownloadPackage "libdbusmenu" &
DownloadPackage "libgtop" &
DownloadPackage "libindicator" &
wait
DownloadPackage "libnma" &
DownloadPackage "libsoup" &
DownloadPackage "libwnck3" &
DownloadPackage "libxklavier" &
DownloadPackage "network-manager-applet" &
DownloadPackage "vte" &
DownloadPackage "xtrans" &
wait

### temporary packages only for building

DownloadPackage "icu4c" & # required by mate-terminal (only for safety in case it gets updated in Slackware repo)
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
