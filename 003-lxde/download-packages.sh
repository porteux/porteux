#!/bin/bash
source "$BUILDER_UTILS_PATH/slackware-repository.sh"

generate_repository_urls

download_package "accountsservice" & # required by lightdm
download_package "blueman" &
download_package "keybinder3" &
download_package "libappindicator" &
download_package "libdbusmenu" &
download_package "libindicator" &
download_package "libwnck3" &
download_package "libxklavier" &
wait_for_downloads

