#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

GenerateRepositoryUrls

DownloadPackage "glibc-i18n" &
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
