#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

DownloadPackage "libdbusmenu" &
DownloadPackage "libnma" &
DownloadPackage "network-manager-applet" &
wait

### only download if not present

[ ! -f /usr/bin/clang ] && DownloadPackage "llvm" # required by cosmic-greeter

### slackware current only packages

if [ $SLACKWAREVERSION == "current" ]; then
	DownloadPackage "libappindicator" &
	DownloadPackage "libindicator" &
	wait
fi

### temporary packages for further building


### script clean up

rm FILE_LIST
rm serverPackages.txt
