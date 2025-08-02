#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

GenerateRepositoryUrls

### only download if not present

DownloadPackage "libxml2"
DownloadPackage "llvm"

### script clean up

rm FILE_LIST
rm serverPackages.txt
