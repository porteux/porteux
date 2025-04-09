#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

DownloadPackage "blueman" &
DownloadPackage "accountsservice" &
DownloadPackage "aspell" &
DownloadPackage "babl" &
DownloadPackage "dbus-python" &
DownloadPackage "dconf" &
DownloadPackage "enchant" &
wait
DownloadPackage "ffmpegthumbnailer" &
DownloadPackage "hunspell" &
DownloadPackage "iso-codes" &
DownloadPackage "jasper" &
DownloadPackage "keybinder3" &
DownloadPackage "libappindicator" &
wait
DownloadPackage "libgtop" &
DownloadPackage "libindicator" &
DownloadPackage "libnma" &
DownloadPackage "libwnck3" &
DownloadPackage "libxklavier" &
DownloadPackage "network-manager-applet" &
DownloadPackage "vte" &
DownloadPackage "xtrans" &
wait

### slackware specific version packages

if [ $SLACKWAREVERSION == "current" ]; then
	DownloadPackage "libdbusmenu" &
	DownloadPackage "libsoup" & # in stable this libsoup2 will be in base
	wait
fi

### temporary packages for further building

DownloadPackage "gtk+2" & # to build mate-themes
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
