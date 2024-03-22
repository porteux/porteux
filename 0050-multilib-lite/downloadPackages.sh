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
DownloadPackage "glu" &
DownloadPackage "graphite2" &
DownloadPackage "harfbuzz" &
wait
DownloadPackage "keyutils" &
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
wait
DownloadPackage "libnsl" &
DownloadPackage "libogg" &
DownloadPackage "libpciaccess" &
DownloadPackage "libpng" &
DownloadPackage "libSM" &
DownloadPackage "libsndfile" &
DownloadPackage "libtirpc" &
DownloadPackage "libvorbis" &
DownloadPackage "libX11" &
DownloadPackage "libXau" &
wait
DownloadPackage "libxcb" &
DownloadPackage "libXcomposite" &
DownloadPackage "libXcursor" &
DownloadPackage "libXdamage" &
DownloadPackage "libXdmcp" &
DownloadPackage "libXext" &
DownloadPackage "libXfixes" &
DownloadPackage "libXft" &
DownloadPackage "libXi" &
DownloadPackage "libXinerama" &
DownloadPackage "libXrandr" &
wait
DownloadPackage "libXrender" &
DownloadPackage "libxml2" &
DownloadPackage "libxshmfence" &
DownloadPackage "libXtst" &
DownloadPackage "libXxf86vm" &
DownloadPackage "llvm" &
DownloadPackage "lm_sensors" &
DownloadPackage "mesa" &
DownloadPackage "mpg123" &
DownloadPackage "ncurses" &
wait
DownloadPackage "openal-soft" &
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
