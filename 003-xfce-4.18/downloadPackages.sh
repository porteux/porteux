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
DownloadPackage "gtksourceview3" &
DownloadPackage "keybinder3" &
wait
DownloadPackage "libdbusmenu" &
DownloadPackage "libgtop" &
DownloadPackage "libnma" &
DownloadPackage "libwnck3" &
DownloadPackage "libxklavier" &
DownloadPackage "network-manager-applet" &
DownloadPackage "vte" &
wait

### slackware specific version packages

if [ $SLACKWAREVERSION == "current" ]; then
	DownloadPackage "libappindicator" &
	DownloadPackage "gspell" &
	DownloadPackage "libindicator" &
	wait
fi

### script clean up

rm FILE_LIST
rm serverPackages.txt
