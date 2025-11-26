#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

GenerateRepositoryUrls

DownloadPackage "glib-networking" &
DownloadPackage "gnupg2" &
DownloadPackage "gperf" &
DownloadPackage "libproxy" &
DownloadPackage "npth" &
DownloadPackage "pyparsing" &
DownloadPackage "socat" &
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
