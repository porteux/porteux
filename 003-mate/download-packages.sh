#!/bin/bash
source "$BUILDER_UTILS_PATH/slackware-repository.sh"

generate_repository_urls

download_package "accountsservice" &
download_package "aspell" &
download_package "babl" &
download_package "blueman" &
download_package "dbus-python" &
download_package "dconf" &
download_package "enchant" &
download_package "hunspell" &
download_package "jasper" &
wait_for_downloads
download_package "keybinder3" &
download_package "libappindicator" &
download_package "libdbusmenu" &
download_package "libgtop" &
download_package "libindicator" &
download_package "libsoup" &
download_package "libwnck3" &
download_package "libxklavier" &
download_package "xtrans" &
wait_for_downloads

### packages that require specific stripping

download_package "iso-codes" & # required by mate-keyboard-properties and ibus
wait_for_downloads

