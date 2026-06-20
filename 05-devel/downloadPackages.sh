#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

GenerateRepositoryUrls

DownloadPackage "autoconf" &
DownloadPackage "autoconf-archive" &
DownloadPackage "automake" &
DownloadPackage "binutils" &
DownloadPackage "bison" &
DownloadPackage "cmake" &
DownloadPackage "gc" &
DownloadPackage "gcc" &
DownloadPackage "gcc-g++" &
DownloadPackage "gettext-tools" &
wait
DownloadPackage "git" &
DownloadPackage "gmp" &
DownloadPackage "guile" &
DownloadPackage "hwdata" &
DownloadPackage "intltool" &
DownloadPackage "isl" &
DownloadPackage "itstool" &
DownloadPackage "libmpc" &
DownloadPackage "libpthread-stubs" &
DownloadPackage "libtool" &
wait
DownloadPackage "linuxdoc-tools" &
DownloadPackage "m4" &
DownloadPackage "make" &
DownloadPackage "makedepend" &
DownloadPackage "meson" &
DownloadPackage "nasm" &
DownloadPackage "ninja" &
DownloadPackage "perl" &
DownloadPackage "pkgconf" & # this replaces pkg-config
DownloadPackage "python-packaging" &
wait
DownloadPackage "python-setuptools" &
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
