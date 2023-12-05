#!/bin/sh
source "$PWD/../builder-utils/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

DownloadPackage "blueman" &
DownloadPackage "accountsservice" &
DownloadPackage "aspell" &
DownloadPackage "babl" &
DownloadPackage "dbus-python" &
DownloadPackage "dconf" &
DownloadPackage "enchant" &
DownloadPackage "ffmpegthumbnailer" &
DownloadPackage "hunspell" &
wait
DownloadPackage "iso-codes" &
DownloadPackage "jasper" &
DownloadPackage "keybinder3" &
DownloadPackage "libcanberra" &
DownloadPackage "libgpod" &
DownloadPackage "libgtop" &
wait
DownloadPackage "libnma" &
DownloadPackage "libspectre" &
DownloadPackage "libwnck3" &
DownloadPackage "libxklavier" &
DownloadPackage "network-manager-applet" &
DownloadPackage "svgalib" &
DownloadPackage "xtrans" &
wait

### slackware current only packages

if [ $SLACKWAREVERSION == "current" ]; then
	DownloadPackage "libappindicator" &
	DownloadPackage "libdbusmenu" &
	DownloadPackage "libindicator" &
	DownloadPackage "libsoup" & # in stable this libsoup2 will be in base
	wait
fi

### temporary packages for further building

DownloadPackage "boost" & # to build exempi
#DownloadPackage "glade" & # to build gtksourceview4
DownloadPackage "gtk+2" & # to build mate-themes
DownloadPackage "python-pip" & # to install lxml
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
