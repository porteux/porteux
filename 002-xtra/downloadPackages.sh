#!/bin/sh
source "$PWD/../builder-utils/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

DownloadPackage "libcue" &
DownloadPackage "vid.stab" &
DownloadPackage "openal-soft" &
wait

### temporary packages for further building

DownloadPackage "frei0r-plugins" & # temporary to build ffmpeg
DownloadPackage "opencl-headers" & # temporary to build ffmpeg
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
