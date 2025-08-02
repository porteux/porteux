#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

GenerateRepositoryUrls

DownloadPackage "accountsservice" &
DownloadPackage "aspell" &
DownloadPackage "blueman" &
DownloadPackage "colord" &
DownloadPackage "dbus-python" &
DownloadPackage "dconf" &
DownloadPackage "enchant" &
wait
DownloadPackage "ffmpegthumbnailer" &
DownloadPackage "gspell" &
DownloadPackage "gtksourceview4" &
DownloadPackage "hunspell" &
DownloadPackage "jasper" &
DownloadPackage "keybinder3" &
DownloadPackage "libappindicator" &
DownloadPackage "libdbusmenu" &
wait
DownloadPackage "libgee" &
DownloadPackage "libgpod" &
DownloadPackage "libgtop" &
DownloadPackage "libgusb" &
DownloadPackage "libhandy" &
DownloadPackage "libindicator" &
DownloadPackage "libnma" &
DownloadPackage "libsoup" & # required by settings -> Date&Time
wait
DownloadPackage "libspectre" &
DownloadPackage "libwnck3" &
DownloadPackage "libxklavier" &
DownloadPackage "mozjs128" &
DownloadPackage "network-manager-applet" &
DownloadPackage "python-certifi" &
DownloadPackage "python-charset-normalizer" &
wait
DownloadPackage "python-distro" &
DownloadPackage "python-idna" &
DownloadPackage "python-pillow" &
DownloadPackage "python-psutil" &
DownloadPackage "python-requests" &
DownloadPackage "python-six" &
DownloadPackage "python-webencodings" &
DownloadPackage "vte" &
wait

### packages that require specific striping

DownloadPackage "gettext-tools" & # required by extensions
wait

### temporary packages for further building

DownloadPackage "iso-codes" &
DownloadPackage "libgsf" &
DownloadPackage "libxklavier" &
DownloadPackage "python-build" &
DownloadPackage "python-flit-core" &
wait
DownloadPackage "python-installer" &
DownloadPackage "python-pip" &
DownloadPackage "python-pyproject-hooks" &
DownloadPackage "python-wheel" &
DownloadPackage "xtrans" &
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
