#!/bin/bash
source "$BUILDER_UTILS_PATH/slackware-repository.sh"

generate_repository_urls

download_package "accountsservice" &
download_package "blueman" &
download_package "dbus-glib" &
download_package "dconf" &
download_package "enchant" &
wait_for_downloads
download_package "libappindicator" &
download_package "libdbusmenu" &
download_package "libgtop" &
download_package "libsoup" &
download_package "libwnck3" &
download_package "libxklavier" &
download_package "xtrans" &
wait_for_downloads

### packages that require specific stripping

download_package "iso-codes" & # required by mate-keyboard-properties and ibus
wait_for_downloads

