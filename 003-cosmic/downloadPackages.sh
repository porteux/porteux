#!/bin/sh
source "$PWD/../builder-utils/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

DownloadPackage "libdbusmenu" &
DownloadPackage "libnma" &
DownloadPackage "network-manager-applet" &
wait

### slackware current only packages

if [ $SLACKWAREVERSION == "current" ]; then
	DownloadPackage "libappindicator" &
	DownloadPackage "libindicator" &
	wait
fi

### temporary packages for further building

DownloadPackage "llvm" & # required by cosmic-greeter
DownloadPackage "xorg-server-xwayland" &
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
