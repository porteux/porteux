#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

GenerateRepositoryUrls

### only download if not present

if [ ${CLANG:-no} = "yes" ]; then
	if [ ! -f /usr/bin/clang ]; then
		DownloadPackage "libxml2" & # required by llvm
		DownloadPackage "llvm" & # required when building with clang
		wait
	fi
fi

if ls ${SCRIPTPATH}/kernel-firmware*.txz 1> /dev/null 2>&1; then
	DownloadPackage "kernel-firmware"
fi

### script clean up

rm FILE_LIST
rm serverPackages.txt
