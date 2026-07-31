#!/bin/bash
source "$BUILDER_UTILS_PATH/slackware-repository.sh"

generate_repository_urls

download_package "libhandy" &
wait_for_downloads

### only download if not present

[ ! -f /usr/bin/clang ] && download_package "llvm" &
wait_for_downloads

### packages that require specific stripping

download_package "iso-codes" & # required by cosmic-settings
wait_for_downloads

### temporary packages only for building

download_package "leptonica" & # required by cosmic-reader
download_package "tesseract" & # required by cosmic-reader
wait_for_downloads

