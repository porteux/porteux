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

### packages that require specific stripping

DownloadPackage "iso-codes" & # required by mate-keyboard-properties and ibus
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
