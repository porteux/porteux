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
DownloadPackage "gnome-themes-extra" &
DownloadPackage "hunspell" &
wait
DownloadPackage "iso-codes" &
DownloadPackage "jasper" &
DownloadPackage "json-glib" &
DownloadPackage "keybinder3" &
DownloadPackage "libcanberra" &
DownloadPackage "libgpod" &
DownloadPackage "libgtop" &
DownloadPackage "libnma" &
DownloadPackage "libspectre" &
DownloadPackage "libwnck3" &
wait
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
	wait
fi

### temporary packages for further building

DownloadPackage "libgtop" & # to build mate-utils
DownloadPackage "python-pip" & # to install lxml
DownloadPackage "gstreamer" & # to build caja-extensions
DownloadPackage "gst-plugins-base" & # to build caja-extensions
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
