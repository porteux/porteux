#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

GenerateRepositoryUrls

DownloadPackage "libdbusmenu" &
wait

### only download if not present

[ ! -f /usr/bin/clang ] && DownloadPackage "llvm" & # required by cosmic-greeter
wait

### slackware current only packages

if [ $SLACKWAREVERSION == "current" ]; then
	DownloadPackage "libappindicator" &
	DownloadPackage "libindicator" &
	wait
fi

### script clean up

rm FILE_LIST
rm serverPackages.txt
