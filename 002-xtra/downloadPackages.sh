#!/bin/bash
source "$PWD/../builder-utils/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

DownloadPackage "libcue" &
DownloadPackage "vid.stab" &
DownloadPackage "openal-soft" &
wait

### only download if not present

[ ! -f /usr/bin/clang ] && DownloadPackage "llvm"

### temporary packages for further building

DownloadPackage "frei0r-plugins" & # temporary to build ffmpeg
DownloadPackage "opencl-headers" & # temporary to build ffmpeg
DownloadPackage "python-Jinja2" & # temporary to build libplacebo
DownloadPackage "python-MarkupSafe" & # temporary to build libplacebo
DownloadPackage "python-pip" & # temporary to build libplacebo
DownloadPackage "vulkan-sdk" & # temporary to build libplacebo
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
