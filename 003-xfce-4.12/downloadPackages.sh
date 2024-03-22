#!/bin/sh
source "$PWD/../builder-utils/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

DownloadPackage "blueman" &
DownloadPackage "dconf" &
DownloadPackage "ffmpegthumbnailer" &
DownloadPackage "keybinder3" &
DownloadPackage "libcanberra" &
wait
DownloadPackage "libnma" &
DownloadPackage "libwnck" &
DownloadPackage "libxklavier" &
DownloadPackage "network-manager-applet" &
DownloadPackage "pavucontrol" &
wait

### slackware current only packages

if [ $SLACKWAREVERSION == "current" ]; then
	DownloadPackage "libappindicator" &
	DownloadPackage "libdbusmenu" &
	DownloadPackage "libindicator" &
	DownloadPackage "libsoup" & # for stable this libsoup2 will be in 002-xorg
	wait
else
	DownloadPackage "gtk+2" &
	wait
fi

### temporary packages for further building

DownloadPackage "libgtop" & # to build mate-search-tool (from mate-utils)
DownloadPackage "python-pip" & # to install lxml
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
