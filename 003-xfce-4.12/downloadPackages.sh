#!/bin/sh
source "$PWD/../builder-utils/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

DownloadPackage "blueman" &
DownloadPackage "dconf" &
DownloadPackage "ffmpegthumbnailer" &
DownloadPackage "json-glib" &
DownloadPackage "keybinder3" &
DownloadPackage "libcanberra" &
wait
DownloadPackage "libnma" &
DownloadPackage "network-manager-applet" &
DownloadPackage "pavucontrol" &
DownloadPackage "polkit-gnome" &
DownloadPackage "gtk+2" &
DownloadPackage "libwnck" &
DownloadPackage "libxklavier" &
wait

### slackware current only packages

if [ $SLACKWAREVERSION == "current" ]; then
	DownloadPackage "libappindicator" &
	DownloadPackage "libdbusmenu" &
	DownloadPackage "libindicator" &
	wait
fi

### temporary packages for further building

DownloadPackage "libgtop" & # to build mate-search-tool (from mate-utils)
DownloadPackage "python-pip" & # to install lxml
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
