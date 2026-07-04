#!/bin/bash
source "$BUILDER_UTILS_PATH/slackware-repository.sh"

generate_repository_urls

download_package "accountsservice" &
download_package "aspell" &
download_package "blueman" &
download_package "colord" &
download_package "dbus-python" &
download_package "dconf" &
download_package "enchant" &
download_package "gspell" &
wait
download_package "hunspell" &
download_package "jasper" &
download_package "keybinder3" &
download_package "libappindicator" &
download_package "libdbusmenu" &
download_package "libgee" &
download_package "libgpod" &
download_package "libgtop" &
download_package "libgusb" &
wait
download_package "libhandy" &
download_package "libindicator" &
download_package "libsoup" & # required by settings -> Date&Time
download_package "libspectre" &
download_package "libwnck3" &
download_package "libxklavier" &
download_package "mozjs140" &
download_package "python-certifi" &
download_package "python-charset-normalizer" &
wait
download_package "python-distro" &
download_package "python-idna" &
download_package "python-pillow" &
download_package "python-psutil" &
download_package "python-requests" &
download_package "python-six" &
download_package "python-webencodings" &
wait

### packages that require specific stripping

download_package "gettext-tools" & # required by extensions
download_package "ibus" &
wait

### temporary packages only for building

download_package "iso-codes" & # required by cinnamon-desktop
download_package "libgsf" &
download_package "libxklavier" &
download_package "python-build" &
download_package "python-flit-core" &
download_package "python-installer" &
download_package "python-pip" &
download_package "python-pyproject-hooks" &
download_package "python-wheel" &
download_package "xtrans" &
wait

### script clean up

rm FILE_LIST
rm server-packages.txt
