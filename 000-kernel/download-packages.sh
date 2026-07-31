#!/bin/bash
source "$BUILDER_UTILS_PATH/slackware-repository.sh"

generate_repository_urls

### only download if not present

if [ ${CLANG:-no} = "yes" ]; then
	if [ ! -f /usr/bin/clang ]; then
		download_package "libxml2" & # required by llvm
		download_package "llvm" & # required when building with clang
		wait_for_downloads
	fi
fi

if ! ls ${SCRIPT_PATH}/kernel-firmware*.txz 1> /dev/null 2>&1; then
	download_package "kernel-firmware"
fi

