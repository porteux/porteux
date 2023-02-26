#!/bin/sh
source "$PWD/../builder-utils/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

DownloadPackage "automake" &
DownloadPackage "autoconf" &
DownloadPackage "autoconf-archive" &
DownloadPackage "binutils" &
DownloadPackage "bison" &
DownloadPackage "cmake" &
DownloadPackage "expat" &
DownloadPackage "gc" &
DownloadPackage "gcc" &
DownloadPackage "gcc-g++" &
DownloadPackage "gd" &
DownloadPackage "gettext-tools" &
wait
DownloadPackage "git" &
DownloadPackage "gmp" &
DownloadPackage "guile" &
DownloadPackage "intltool" &
DownloadPackage "isl" &
DownloadPackage "itstool" &
DownloadPackage "libmpc" &
DownloadPackage "libpthread-stubs" &
wait
DownloadPackage "libtool" &
DownloadPackage "libunistring" &
DownloadPackage "linuxdoc-tools" &
DownloadPackage "m4" &
DownloadPackage "make" &
DownloadPackage "makedepend" &
DownloadPackage "meson" &
DownloadPackage "nasm" &
DownloadPackage "ninja" &
wait
DownloadPackage "perl" &
DownloadPackage "pkg-config" &
DownloadPackage "python-setuptools" &
DownloadPackage "texinfo" &
DownloadPackage "util-macros" &
DownloadPackage "vala" &
DownloadPackage "wayland-protocols" &
DownloadPackage "xcb-proto" &
DownloadPackage "xorgproto" &
DownloadPackage "yasm" &
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
