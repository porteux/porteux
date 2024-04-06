#!/bin/sh
source "$PWD/../builder-utils/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

DownloadPackage "accountsservice" &
DownloadPackage "aspell" &
DownloadPackage "blueman" &
DownloadPackage "colord" &
DownloadPackage "dbus-python" &
DownloadPackage "dconf" &
DownloadPackage "enchant" &
wait
DownloadPackage "ffmpegthumbnailer" &
DownloadPackage "hunspell" &
DownloadPackage "jasper" &
DownloadPackage "keybinder3" &
DownloadPackage "libappindicator" &
DownloadPackage "libdbusmenu" &
DownloadPackage "libcanberra" &
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
DownloadPackage "mozjs115" &
DownloadPackage "network-manager-applet" &
DownloadPackage "polkit-gnome" & # consider using mate-polkit instead
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
wait

### temporary packages for further building

DownloadPackage "iso-codes" &
DownloadPackage "libgsf" &
DownloadPackage "python-build" &
DownloadPackage "python-flit-core" &
DownloadPackage "python-installer" &
wait
DownloadPackage "python-pyproject-hooks" &
DownloadPackage "python-wheel" &
DownloadPackage "xorg-server-xwayland" &
DownloadPackage "xtrans" &
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
