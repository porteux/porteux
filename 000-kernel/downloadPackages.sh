#!/bin/sh
source "$PWD/../builder-utils/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

DownloadPackage "bc" &
wait

### only download if not present

[ ! -f /usr/bin/clang ] && DownloadPackage "llvm"

### script clean up

rm FILE_LIST
rm serverPackages.txt
