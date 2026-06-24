#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

GenerateRepositoryUrls

DownloadPackage "libhandy" &
wait

### only download if not present

[ ! -f /usr/bin/clang ] && DownloadPackage "llvm" &
wait

### temporary packages only for building

DownloadPackage "leptonica" & # required by cosmic-reader
DownloadPackage "tesseract" & # required by cosmic-reader
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
