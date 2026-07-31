#!/bin/bash
source "$BUILDER_UTILS_PATH/slackware-repository.sh"

generate_repository_urls

download_package "accountsservice" & # required by lightdm
download_package "aspell" & # required by mousepad
download_package "blueman" &
download_package "dconf" &
download_package "enchant" &
download_package "gspell" &
download_package "keybinder3" &
download_package "libappindicator" &
download_package "libdbusmenu" &
wait_for_downloads
download_package "libgtop" &
download_package "libindicator" &
download_package "libwnck3" &
download_package "libxklavier" &
wait_for_downloads

### temporary packages only for building

download_package "libyaml" & # to build xfdesktop with desktop icons
wait_for_downloads

