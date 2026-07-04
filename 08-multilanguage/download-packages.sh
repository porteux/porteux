#!/bin/bash
source "$BUILDER_UTILS_PATH/slackware-repository.sh"

generate_repository_urls

download_package "glibc-i18n" &
wait

### script clean up

rm FILE_LIST
rm server-packages.txt
