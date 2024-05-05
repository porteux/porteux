#!/bin/sh
source "$PWD/../builder-utils/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

DownloadPackage "accountsservice" &
DownloadPackage "aspell" &
DownloadPackage "blueman" &
DownloadPackage "dbus-python" &
DownloadPackage "dconf" &
DownloadPackage "enchant" &
wait
DownloadPackage "ffmpegthumbnailer" &
DownloadPackage "hunspell" &
DownloadPackage "jasper" &
DownloadPackage "keybinder3" &
DownloadPackage "libdbusmenu" &
wait
DownloadPackage "libcanberra" &
DownloadPackage "libgee" &
DownloadPackage "libgpod" &
DownloadPackage "libgtop" &
DownloadPackage "libnma" &
DownloadPackage "libspectre" &
wait
DownloadPackage "libwnck3" &
DownloadPackage "libxklavier" &
DownloadPackage "mozjs78" &
DownloadPackage "network-manager-applet" &
DownloadPackage "polkit-gnome" & # consider using mate-polkit instead
DownloadPackage "python-certifi" &
wait
DownloadPackage "python-charset-normalizer" &
DownloadPackage "python-distro" &
DownloadPackage "python-idna" &
DownloadPackage "python-pillow" &
DownloadPackage "python-requests" &
DownloadPackage "python-six" &
wait

### temporary packages for further building

DownloadPackage "boost" & # to build exempi
DownloadPackage "iso-codes" &
DownloadPackage "libgsf" &
DownloadPackage "python-pip" &
DownloadPackage "xtrans" &
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
