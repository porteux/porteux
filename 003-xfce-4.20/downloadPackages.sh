#!/bin/bash
source "$PWD/../builder-utils/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

DownloadPackage "aspell" & # required by mousepad
DownloadPackage "blueman" &
DownloadPackage "dconf" &
DownloadPackage "enchant" &
DownloadPackage "ffmpegthumbnailer" &
DownloadPackage "gspell" &
DownloadPackage "gtksourceview3" &
DownloadPackage "keybinder3" &
DownloadPackage "libappindicator" &
DownloadPackage "libcanberra" &
wait
DownloadPackage "libdisplay-info" &
DownloadPackage "libdbusmenu" &
DownloadPackage "libgtop" &
DownloadPackage "libindicator" &
DownloadPackage "libnma" &
DownloadPackage "libsoup" &
DownloadPackage "libwnck3" &
DownloadPackage "libxklavier" &
DownloadPackage "network-manager-applet" &
DownloadPackage "vte" &
wait

### temporary packages

DownloadPackage "libyaml" & # to build xfdesktop with desktop icons
DownloadPackage "python-pip" & # to install lxml
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
