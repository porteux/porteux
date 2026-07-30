#!/bin/bash

MODULE_NAME="05-devel"

source "$PWD/../builder-utils/set-flags.sh"

set_flags "$MODULE_NAME"

source "$BUILDER_UTILS_PATH/generic-strip.sh"
source "$BUILDER_UTILS_PATH/helper.sh"
source "$BUILDER_UTILS_PATH/slackware-repository.sh"

elevate_if_needed "$0" "$@"

echo -e "Building ${MODULE_NAME} based on Slackware ${SLACKWARE_VERSION} ${ARCH}...\n"

### create module folder

mkdir -p $MODULE_PATH/packages > /dev/null 2>&1
cd $MODULE_PATH || exit 1

### download packages from slackware repository

bash $SCRIPT_PATH/download-packages.sh || exit 1

if ! ls $MODULE_PATH/packages/kernel-headers*.txz 1> /dev/null 2>&1; then
	cd ${SCRIPT_PATH}/../000-kernel || exit 1
	ONLY_HEADERS=yes sh create-module.sh || wget https://slackware.uk/cumulative/slackware64-current/slackware64/d/kernel-headers-$KERNEL_VERSION-x86-1.txz -P $MODULE_PATH/packages || exit 1
fi

### fake root

cd $MODULE_PATH/packages && ROOT=./ installpkg *.t?z || exit 1
rm *.t?z

### copy language files to 08-multilanguage

copy_to_multilanguage

### module clean up

cd $MODULE_PATH/packages/ || exit 1

{
rm usr/lib/python*/site-packages/setuptools/_distutils/command/*.exe

rm -fr usr/doc
rm -fr usr/etc
rm -fr usr/info
rm -fr usr/lib${SYSTEM_BITS}/bash
rm -fr usr/local
rm -fr usr/man
rm -fr usr/share/applications
rm -fr usr/share/bash-completion
rm -fr usr/share/cmake-*/Help
rm -fr usr/share/devhelp
rm -fr usr/share/doc
rm -fr usr/share/gitk
rm -fr usr/share/gnome
rm -fr usr/share/gnome-doc-utils
rm -fr usr/share/help
rm -fr usr/share/icons
rm -fr usr/share/locale
rm -fr usr/share/valadoc-*
rm -fr usr/x86_64-slackware-linux
rm -fr var/lib/pkgtools/douninst.sh
rm -fr var/lib/pkgtools/setup
rm -fr var/log/pkgtools
rm -fr var/log/setup

# already included in the 001-core stripped packages - keeping them will prevent 05-devel from being deactivated
rm usr/lib${SYSTEM_BITS}/libatomic.so*
rm usr/lib${SYSTEM_BITS}/libgcc_s.so*
rm usr/lib${SYSTEM_BITS}/libgmp.so*
rm usr/lib${SYSTEM_BITS}/libgomp.so*
rm usr/lib${SYSTEM_BITS}/libltdl.so*
rm usr/lib${SYSTEM_BITS}/libstdc++.so*

# already included in binutils-stripped
rm usr/bin/ar
rm usr/bin/strip
rm usr/lib${SYSTEM_BITS}/libbfd.so
rm usr/lib${SYSTEM_BITS}/libbfd-*.so
rm usr/lib${SYSTEM_BITS}/libsframe*.so

# remove 32-bit files
rm -fr usr/include/c++/*/x86_64-slackware-linux/32
rm -fr usr/lib/pkgconfig
rm -fr usr/lib${SYSTEM_BITS}/gcc/x86_64-slackware-linux/*/32
rm usr/lib/*

find . -name '*.la' -delete
find usr/ -type d -empty -delete
} >/dev/null 2>&1

strip_hard_exec

### finalize

finalize
