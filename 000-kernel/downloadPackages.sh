#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

GenerateRepositoryUrls

### only download if not present

if [ ${CLANG:-no} = "yes" ]; then
	if [ ! -f /usr/bin/clang ]; then
		DownloadPackage "libxml2" &
		[ ! -f /usr/bin/clang ] && DownloadPackage "llvm" &
		wait
	fi
fi

if [ ! -f ${SCRIPTPATH}/kernel-firmware*.txz ]; then
	DownloadPackage "kernel-firmware" &
	wait
fi

### script clean up

rm FILE_LIST
rm serverPackages.txt
