#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

DownloadPackage "accountsservice" & # required by lightdm
DownloadPackage "aspell" & # required by mousepad
DownloadPackage "blueman" &
DownloadPackage "dconf" &
DownloadPackage "enchant" &
DownloadPackage "ffmpegthumbnailer" &
DownloadPackage "gspell" &
DownloadPackage "gtksourceview4" &
DownloadPackage "keybinder3" &
DownloadPackage "libappindicator" &
wait
DownloadPackage "libdbusmenu" &
DownloadPackage "libgtop" &
DownloadPackage "libindicator" &
DownloadPackage "libnma" &
DownloadPackage "libwnck3" &
DownloadPackage "libxklavier" &
DownloadPackage "network-manager-applet" &
DownloadPackage "vte" &
wait

### temporary packages

DownloadPackage "glade" & # required by libxfce4ui to provide more system information (e.g. nvidia cards)
DownloadPackage "libyaml" & # to build xfdesktop with desktop icons
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
