#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

GenerateRepositoryUrls

DownloadPackage "accountsservice" &
DownloadPackage "aspell" &
DownloadPackage "babl" &
DownloadPackage "blueman" &
DownloadPackage "dbus-python" &
DownloadPackage "dconf" &
DownloadPackage "enchant" &
DownloadPackage "hunspell" &
DownloadPackage "iso-codes" &
DownloadPackage "jasper" &
wait
DownloadPackage "keybinder3" &
DownloadPackage "libappindicator" &
DownloadPackage "libdbusmenu" &
DownloadPackage "libgtop" &
DownloadPackage "libindicator" &
DownloadPackage "libsoup" &
DownloadPackage "libwnck3" &
DownloadPackage "libxklavier" &
DownloadPackage "xtrans" &
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
