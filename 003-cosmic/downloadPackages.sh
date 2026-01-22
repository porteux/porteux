#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

GenerateRepositoryUrls

DownloadPackage "libdbusmenu" &
DownloadPackage "libgtop" &
DownloadPackage "libhandy" &
DownloadPackage "libwnck3" &
wait

### only download if not present

[ ! -f /usr/bin/clang ] && DownloadPackage "llvm" &
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
