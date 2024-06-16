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
DownloadPackage "gc" &
DownloadPackage "gcc" &
DownloadPackage "gcc-g++" &
wait
DownloadPackage "gd" &
DownloadPackage "gettext-tools" &
DownloadPackage "git" &
DownloadPackage "gmp" &
DownloadPackage "guile" &
DownloadPackage "intltool" &
DownloadPackage "isl" &
DownloadPackage "itstool" &
DownloadPackage "libmpc" &
wait
DownloadPackage "libpthread-stubs" &
DownloadPackage "libtool" &
DownloadPackage "linuxdoc-tools" &
DownloadPackage "m4" &
DownloadPackage "make" &
DownloadPackage "makedepend" &
DownloadPackage "meson" &
DownloadPackage "nasm" &
DownloadPackage "ninja" &
DownloadPackage "perl" &
wait
DownloadPackage "pkg-config" &
DownloadPackage "python-packaging" &
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
