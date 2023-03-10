#!/bin/sh
source "$PWD/../builder-utils/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

DownloadPackage "blueman" &
DownloadPackage "dconf" &
DownloadPackage "ffmpegthumbnailer" &
DownloadPackage "gnome-themes-extra" &
DownloadPackage "gtksourceview3" &
DownloadPackage "json-glib" &
DownloadPackage "keybinder3" &
DownloadPackage "libcanberra" &
wait
DownloadPackage "libdbusmenu" &
DownloadPackage "libgtop" &
DownloadPackage "libnma" &
DownloadPackage "network-manager-applet" &
DownloadPackage "pavucontrol" &
DownloadPackage "polkit-gnome" &
DownloadPackage "libwnck3" &
DownloadPackage "libxklavier" &
wait

### slackware current only packages

if [ $SLACKWAREVERSION == "current" ]; then
	DownloadPackage "libappindicator" &
	DownloadPackage "libindicator" &
	wait
fi

### temporary packages

DownloadPackage "python-pip" & # to install lxml
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
