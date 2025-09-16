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

if [ ! -f ${SCRIPTPATH}/kernel-firmware*.txz ]; then
	# always download firmware from current
	wget -r -nd --no-parent -w 2 ${SLACKWAREDOMAIN}/slackware/slackware64-current/slackware64/a/ -A kernel-firmware-*.txz
fi

### script clean up

rm FILE_LIST
rm serverPackages.txt
