#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

DownloadPackage "glibc-i18n" &
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
