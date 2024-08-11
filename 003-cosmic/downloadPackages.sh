#!/bin/sh
source "$PWD/../builder-utils/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

### temporary packages for further building

DownloadPackage "llvm" & # required by cosmic-greeter
DownloadPackage "xorg-server-xwayland" &
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
