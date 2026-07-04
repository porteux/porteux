#!/bin/bash
source "$BUILDER_UTILS_PATH/slackware-repository.sh"

generate_repository_urls

download_package "libhandy" &
wait

### only download if not present

[ ! -f /usr/bin/clang ] && download_package "llvm" &
wait

### packages that require specific stripping

download_package "iso-codes" & # required by cosmic-settings
wait

### temporary packages only for building

download_package "leptonica" & # required by cosmic-reader
download_package "tesseract" & # required by cosmic-reader
wait

### script clean up

rm FILE_LIST
rm server-packages.txt
