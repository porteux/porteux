#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

GenerateRepositoryUrls

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
DownloadPackage "gettext-tools" &
DownloadPackage "git" &
DownloadPackage "gmp" &
DownloadPackage "guile" &
DownloadPackage "hwdata" &
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
DownloadPackage "nasm" &
DownloadPackage "ninja" &
DownloadPackage "perl" &
wait
DownloadPackage "pkg-config" &
DownloadPackage "python-packaging" &
DownloadPackage "python-setuptools" &
DownloadPackage "util-macros" &
DownloadPackage "vala" &
DownloadPackage "wayland-protocols" &
DownloadPackage "xcb-proto" &
DownloadPackage "xorgproto" &
DownloadPackage "yasm" &
wait

### slackware specific version packages

if [ $SLACKWAREVERSION == "current" ]; then
	DownloadPackage "meson" & # for stable we're building because slackware repo has an ancient version
	DownloadPackage "pkgconf" & # this replaces pkg-config
	wait
fi

### script clean up

rm FILE_LIST
rm serverPackages.txt
