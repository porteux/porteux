#!/bin/sh
source "$PWD/../builder-utils/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

DownloadPackage "blueman" &
DownloadPackage "dconf" &
DownloadPackage "ffmpegthumbnailer" &
DownloadPackage "gtksourceview3" &
DownloadPackage "keybinder3" &
DownloadPackage "libcanberra" &
DownloadPackage "libdbusmenu" &
wait
DownloadPackage "libgtop" &
DownloadPackage "libnma" &
DownloadPackage "libwnck3" &
DownloadPackage "libxklavier" &
DownloadPackage "network-manager-applet" &
DownloadPackage "pavucontrol" &
DownloadPackage "polkit-gnome" &
wait

### slackware current only packages

if [ $SLACKWAREVERSION == "current" ]; then
	DownloadPackage "libappindicator" &
	DownloadPackage "libindicator" &
	DownloadPackage "libsoup" & # for stable this libsoup2 will be in 002-xorg
	wait
fi

### temporary packages

DownloadPackage "python-pip" & # to install lxml
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
