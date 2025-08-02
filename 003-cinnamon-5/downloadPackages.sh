#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

GenerateRepositoryUrls

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
DownloadPackage "python-certifi" &
DownloadPackage "python-charset-normalizer" &
wait
DownloadPackage "python-distro" &
DownloadPackage "python-idna" &
DownloadPackage "python-pillow" &
DownloadPackage "python-requests" &
DownloadPackage "python-six" &
DownloadPackage "vte" &
wait

### packages that require specific striping

DownloadPackage "gettext-tools" & # required by extensions
wait

### temporary packages for further building

DownloadPackage "iso-codes" &
DownloadPackage "libgsf" &
DownloadPackage "libxklavier" &
DownloadPackage "python-pip" &
DownloadPackage "xtrans" &
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
