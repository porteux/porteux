#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

GenerateRepositoryUrls

DownloadPackage "alsa-lib" &
DownloadPackage "alsa-plugins" &
DownloadPackage "brotli" &
DownloadPackage "bzip2" &
DownloadPackage "dbus" &
DownloadPackage "e2fsprogs" &
DownloadPackage "elfutils" &
DownloadPackage "elogind" &
DownloadPackage "expat" &
DownloadPackage "flac" &
wait
DownloadPackage "fontconfig" &
DownloadPackage "freetype" &
DownloadPackage "glib2" &
DownloadPackage "glibc" &
DownloadPackage "glibc-i18n" &
DownloadPackage "glibc-profile" &
DownloadPackage "glu" &
DownloadPackage "graphite2" &
DownloadPackage "harfbuzz" &
DownloadPackage "keyutils" &
wait
DownloadPackage "krb5" &
DownloadPackage "lame" &
DownloadPackage "libasyncns" &
DownloadPackage "libcap" &
DownloadPackage "libdisplay-info" &
DownloadPackage "libdrm" &
DownloadPackage "libedit" &
DownloadPackage "libffi" &
DownloadPackage "libglvnd" &
DownloadPackage "libICE" &
wait
DownloadPackage "libjpeg-turbo" &
DownloadPackage "libnsl" &
DownloadPackage "libogg" &
DownloadPackage "libpciaccess" &
DownloadPackage "libpng" &
DownloadPackage "libSM" &
DownloadPackage "libsndfile" &
DownloadPackage "libtirpc" &
DownloadPackage "libvorbis" &
DownloadPackage "libX11" &
wait
DownloadPackage "libXau" &
DownloadPackage "libxcb" &
DownloadPackage "libXcomposite" &
DownloadPackage "libXcursor" &
DownloadPackage "libXdamage" &
DownloadPackage "libXdmcp" &
DownloadPackage "libXext" &
DownloadPackage "libXfixes" &
DownloadPackage "libXft" &
DownloadPackage "libXi" &
wait
DownloadPackage "libXinerama" &
DownloadPackage "libxml2" &
DownloadPackage "libXrandr" &
DownloadPackage "libXrender" &
DownloadPackage "libxshmfence" &
DownloadPackage "libXtst" &
DownloadPackage "libXxf86vm" &
DownloadPackage "lm_sensors" &
DownloadPackage "lz4" &
DownloadPackage "mpg123" &
wait
DownloadPackage "ncurses" &
DownloadPackage "openal-soft" &
DownloadPackage "opus" &
DownloadPackage "pcre" &
DownloadPackage "util-linux" &
DownloadPackage "wayland" &
DownloadPackage "xcb-util-keysyms" &
DownloadPackage "xz" &
DownloadPackage "zlib" &
DownloadPackage "zstd" &
wait

### packages that require specific stripping

DownloadPackage "aaa_libraries" &
DownloadPackage "eudev" &
DownloadPackage "gcc" &
DownloadPackage "gcc-g++" &
DownloadPackage "llvm" &
DownloadPackage "mesa" &
DownloadPackage "pulseaudio" &
DownloadPackage "vulkan-sdk" &
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
