#!/bin/sh
source "$PWD/../builder-utils/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

DownloadPackage "aaa_libraries" &
DownloadPackage "alsa-lib" &
DownloadPackage "brotli" &
DownloadPackage "alsa-plugins" &
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
DownloadPackage "gcc" &
DownloadPackage "gcc-brig" &
DownloadPackage "glib2" &
DownloadPackage "glibc" &
DownloadPackage "glibc-i18n" &
DownloadPackage "glibc-profile" &
DownloadPackage "graphite2" &
DownloadPackage "harfbuzz" &
DownloadPackage "keyutils" &
wait
DownloadPackage "krb5" &
DownloadPackage "lame" &
DownloadPackage "libcap" &
DownloadPackage "libasyncns" &
DownloadPackage "libcap" &
DownloadPackage "libdrm" &
DownloadPackage "libffi" &
DownloadPackage "libglvnd" &
DownloadPackage "libICE" &
DownloadPackage "libjpeg-turbo" &
DownloadPackage "libnsl" &
wait
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
DownloadPackage "libXdamage" &
DownloadPackage "libXdmcp" &
DownloadPackage "libXext" &
DownloadPackage "libXfixes" &
DownloadPackage "libXi" &
DownloadPackage "libXrandr" &
DownloadPackage "libXrender" &
DownloadPackage "libxml2" &
DownloadPackage "libxshmfence" &
wait
DownloadPackage "libXtst" &
DownloadPackage "libXxf86vm" &
DownloadPackage "llvm" &
DownloadPackage "lm_sensors" &
DownloadPackage "mesa" &
DownloadPackage "mpg123" &
DownloadPackage "ncurses" &
wait
DownloadPackage "opus" &
DownloadPackage "pcre" &
DownloadPackage "pulseaudio" &
DownloadPackage "util-linux" &
DownloadPackage "vulkan-sdk" &
DownloadPackage "xz" &
DownloadPackage "zlib" &
DownloadPackage "zstd" &
wait

### slackware current only packages

if [ $SLACKWAREVERSION == "current" ]; then
	DownloadPackage "libedit" &
fi
