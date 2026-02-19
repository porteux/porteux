#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

GenerateRepositoryUrls

DownloadPackage "libcue" &
DownloadPackage "vid.stab" &
DownloadPackage "openal-soft" &
wait

### only download if not present

[ ! -f /usr/bin/clang ] && DownloadPackage "llvm" &

### temporary packages only for building

DownloadPackage "frei0r-plugins" & # to build ffmpeg
DownloadPackage "krb5" & # to build ffmpeg
DownloadPackage "opencl-headers" & # to build ffmpeg
DownloadPackage "python-Jinja2" & # to build libplacebo
DownloadPackage "python-MarkupSafe" & # to build libplacebo
DownloadPackage "python-pip" & # to build libplacebo
DownloadPackage "vulkan-sdk" & # to build libplacebo
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
