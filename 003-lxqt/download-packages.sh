#!/bin/bash
source "$BUILDER_UTILS_PATH/slackware-repository.sh"

generate_repository_urls

download_package "accountsservice" &
download_package "blueman" &
download_package "ghostscript-fonts-std" &
download_package "hunspell" &
download_package "libdbusmenu-qt" &
download_package "libxklavier" & # required by lightdm-gtk-greeter
wait

### packages that require specific stripping

download_package "qt6" &
wait

### script clean up

rm FILE_LIST
rm server-packages.txt
