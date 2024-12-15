#!/bin/bash
source "$PWD/../builder-utils/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

DownloadPackage "blueman" &
DownloadPackage "ffmpegthumbnailer" &
DownloadPackage "keybinder3" &
DownloadPackage "libcanberra" &
wait
DownloadPackage "libnma" &
DownloadPackage "libwnck3" &
DownloadPackage "network-manager-applet" &
DownloadPackage "vte" &
wait

### slackware specific version packages

if [ $SLACKWAREVERSION == "current" ]; then
	DownloadPackage "libappindicator" &
	DownloadPackage "libdbusmenu" &
	DownloadPackage "libindicator" &
	wait
fi

### temporary packages for further building

DownloadPackage "python-pip" & # to install lxml
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
