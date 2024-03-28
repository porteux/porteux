#!/bin/sh
source "$PWD/../builder-utils/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

DownloadPackage "accountsservice" &
DownloadPackage "aspell" &
DownloadPackage "babl" &
DownloadPackage "blueman" &
DownloadPackage "dbus-python" &
DownloadPackage "dconf" &
DownloadPackage "enchant" &
wait
DownloadPackage "ffmpegthumbnailer" &
DownloadPackage "gettext-tools" &
DownloadPackage "hunspell" &
DownloadPackage "hyphen" &
DownloadPackage "jasper" &
DownloadPackage "keybinder3" &
DownloadPackage "libappindicator" &
DownloadPackage "libdbusmenu" &
wait
DownloadPackage "libcanberra" &
DownloadPackage "libgee" &
DownloadPackage "libgpod" &
DownloadPackage "libgsf" &
DownloadPackage "libgtop" &
DownloadPackage "libgusb" &
DownloadPackage "libhandy" &
DownloadPackage "libindicator" &
DownloadPackage "libnma" &
wait
DownloadPackage "libspectre" &
DownloadPackage "libwnck3" &
DownloadPackage "libxklavier" &
DownloadPackage "network-manager-applet" &
DownloadPackage "polkit-gnome" & # consider using mate-polkit instead
DownloadPackage "python-certifi" &
DownloadPackage "python-charset-normalizer" &
DownloadPackage "python-distro" &
wait
DownloadPackage "python-idna" &
DownloadPackage "python-pillow" &
DownloadPackage "python-psutil" &
DownloadPackage "python-requests" &
DownloadPackage "python-six" &
DownloadPackage "python-webencodings" &
DownloadPackage "xtrans" & # maybe remove?
wait

### temporary packages for further building

DownloadPackage "libgsf" &
DownloadPackage "libxklavier" &
DownloadPackage "gtk+3" &
DownloadPackage "iso-codes" &
DownloadPackage "python-build" &
DownloadPackage "python-flit-core" &
wait
DownloadPackage "python-installer" &
DownloadPackage "python-pyproject-hooks" &
DownloadPackage "python-six" &
DownloadPackage "python-tomli" &
DownloadPackage "python-wheel" &
DownloadPackage "xorg-server-xwayland" &
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
