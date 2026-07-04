#!/bin/bash
source "$BUILDER_UTILS_PATH/slackware-repository.sh"

generate_repository_urls

download_package "alsa-lib" &
download_package "alsa-plugins" &
download_package "brotli" &
download_package "bzip2" &
download_package "dbus" &
download_package "e2fsprogs" &
download_package "elfutils" &
download_package "elogind" &
download_package "expat" &
download_package "flac" &
wait
download_package "fontconfig" &
download_package "freetype" &
download_package "glib2" &
download_package "glibc" &
download_package "glibc-i18n" &
download_package "glibc-profile" &
download_package "glu" &
download_package "graphite2" &
download_package "harfbuzz" &
download_package "keyutils" &
wait
download_package "krb5" &
download_package "lame" &
download_package "libasyncns" &
download_package "libcap" &
download_package "libdisplay-info" &
download_package "libdrm" &
download_package "libedit" &
download_package "libffi" &
download_package "libglvnd" &
download_package "libICE" &
wait
download_package "libjpeg-turbo" &
download_package "libnsl" &
download_package "libogg" &
download_package "libpciaccess" &
download_package "libpng" &
download_package "libSM" &
download_package "libsndfile" &
download_package "libtirpc" &
download_package "libvorbis" &
download_package "libX11" &
wait
download_package "libXau" &
download_package "libxcb" &
download_package "libXcomposite" &
download_package "libXcursor" &
download_package "libXdamage" &
download_package "libXdmcp" &
download_package "libXext" &
download_package "libXfixes" &
download_package "libXft" &
download_package "libXi" &
wait
download_package "libXinerama" &
download_package "libxml2" &
download_package "libXrandr" &
download_package "libXrender" &
download_package "libxshmfence" &
download_package "libXtst" &
download_package "libXxf86vm" &
download_package "lm_sensors" &
download_package "lz4" &
download_package "mpg123" &
wait
download_package "ncurses" &
download_package "openal-soft" &
download_package "opus" &
download_package "pcre" &
download_package "util-linux" &
download_package "wayland" &
download_package "xcb-util-keysyms" &
download_package "xz" &
download_package "zlib" &
download_package "zstd" &
wait

### packages that require specific stripping

download_package "aaa_libraries" &
download_package "eudev" &
download_package "gcc" &
download_package "gcc-g++" &
download_package "llvm" &
download_package "mesa" &
download_package "pulseaudio" &
download_package "vulkan-sdk" &
wait

### script clean up

rm FILE_LIST
rm server-packages.txt
