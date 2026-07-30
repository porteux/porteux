#!/bin/bash
source "$BUILDER_UTILS_PATH/slackware-repository.sh"

generate_repository_urls

download_package "libcue" &
download_package "openal-soft" &
download_package "vid.stab" &
wait

### only download if not present

[ ! -f /usr/bin/clang ] && download_package "llvm" &
wait

### temporary packages only for building

download_package "frei0r-plugins" & # to build ffmpeg
download_package "krb5" & # to build ffmpeg
download_package "opencl-headers" & # to build ffmpeg
download_package "python-Jinja2" & # to build libplacebo
download_package "python-MarkupSafe" & # to build libplacebo
download_package "python-pip" & # to build libplacebo
download_package "vulkan-sdk" & # to build libplacebo
wait

