#!/bin/bash
source "$BUILDER_UTILS_PATH/slackware-repository.sh"

generate_repository_urls

download_package "autoconf" &
download_package "autoconf-archive" &
download_package "automake" &
download_package "bison" &
download_package "cmake" &
download_package "gc" &
download_package "gcc" &
download_package "gcc-g++" &
download_package "gettext-tools" &
wait
download_package "git" &
download_package "gmp" &
download_package "guile" &
download_package "hwdata" &
download_package "intltool" &
download_package "isl" &
download_package "itstool" &
download_package "libmpc" &
download_package "libpthread-stubs" &
download_package "libtool" &
wait
download_package "linuxdoc-tools" &
download_package "m4" &
download_package "make" &
download_package "makedepend" &
download_package "meson" &
download_package "nasm" &
download_package "ninja" &
download_package "perl" &
download_package "pkgconf" & # this replaces pkg-config
download_package "python-packaging" &
wait
download_package "python-setuptools" &
download_package "util-macros" &
download_package "vala" &
download_package "wayland-protocols" &
download_package "xcb-proto" &
download_package "xorgproto" &
download_package "yasm" &
wait

