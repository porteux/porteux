#!/bin/bash

MODULE_NAME="0050-multilib-lite"

export SYSTEM_BITS=

source "$PWD/../builder-utils/set-flags.sh"

set_flags "$MODULE_NAME"

source "$BUILDER_UTILS_PATH/generic-strip.sh"
source "$BUILDER_UTILS_PATH/helper.sh"

elevate_if_needed "$0" "$@"

echo -e "Building ${MODULE_NAME} based on Slackware ${SLACKWARE_VERSION} i686...\n"

### create module folder

mkdir -p $MODULE_PATH/packages > /dev/null 2>&1
cd $MODULE_PATH || exit 1

### download packages from slackware repository

bash $SCRIPT_PATH/download-packages.sh || exit 1

### packages that require specific stripping

strip_package cups \
	usr/lib/libcups.so*

strip_package eudev \
	lib/libudev*.so*

strip_package gcc \
	usr/lib/libatomic.so* \
	usr/lib/libgcc_s.so* \
	usr/lib/libgomp.so*

strip_package gcc-g++ \
	usr/lib/libstdc++.so*

strip_package llvm \
	usr/lib/libLLVM*.so*

current_package=mesa
rm -rf $MODULE_PATH/${current_package}
mkdir $MODULE_PATH/${current_package} && cd $MODULE_PATH/${current_package} || exit 1
mv $MODULE_PATH/packages/${current_package}-[0-9]* .
package_file_name=$(ls ${current_package}-[0-9]*.t?z | head -n1)
package_file_name=${package_file_name%.*}
ROOT=./ installpkg ${current_package}*.txz && rm ${current_package}*.txz
rm -fr etc/OpenCL
rm usr/lib/dri/i830*
rm usr/lib/dri/i965*
rm usr/lib/dri/nouveau_vieux*
rm usr/lib/dri/r200*
rm usr/lib/dri/radeon_dri*
rm usr/lib/libMesaOpenCL*
rm usr/lib/libRusticlOpenCL*
mkdir ${current_package}-stripped
find . -mindepth 1 -maxdepth 1 ! -name "${current_package}-stripped" -exec mv -t "${current_package}-stripped" {} +
cd ${current_package}-stripped || exit 1
makepkg ${MAKEPKG_FLAGS} $MODULE_PATH/packages/${package_file_name}_stripped.txz > /dev/null 2>&1
rm -fr $MODULE_PATH/${current_package} && cd $MODULE_PATH || exit 1

strip_package pcre2 \
	lib/libpcre2-8.so*

strip_package pulseaudio \
	usr/lib/libpulse-mainloop-glib.so* \
	usr/lib/libpulse-simple.so* \
	usr/lib/libpulse.so* \
	usr/lib/pulseaudio/libpulsecommon*.so*

strip_package vulkan-sdk \
	usr/lib/libSPIRV-Tools.so* \
	usr/lib/libvulkan.so*

### fake root

cd $MODULE_PATH/packages && ROOT=./ installpkg *.t?z || exit 1
rm *.t?z

### module clean up

{
rm $MODULE_PATH/packages/lib/e2initrd_helper
rm $MODULE_PATH/packages/lib/libfuse*
rm $MODULE_PATH/packages/lib/libsigsegv*
rm $MODULE_PATH/packages/usr/lib/libcares.*
rm $MODULE_PATH/packages/usr/lib/libgmp*
rm $MODULE_PATH/packages/usr/lib/libkdb*
rm $MODULE_PATH/packages/usr/lib/libkrad*
rm $MODULE_PATH/packages/usr/lib/libltdl*
rm $MODULE_PATH/packages/usr/lib/libslang*

rm -fr $MODULE_PATH/packages/etc
rm -fr $MODULE_PATH/packages/lib/e2fsprogs
rm -fr $MODULE_PATH/packages/lib/elogind
rm -fr $MODULE_PATH/packages/lib/security
rm -fr $MODULE_PATH/packages/run
rm -fr $MODULE_PATH/packages/usr/lib/dbus-1.0
rm -fr $MODULE_PATH/packages/usr/lib/gcc
rm -fr $MODULE_PATH/packages/usr/lib/girepository-1.0
rm -fr $MODULE_PATH/packages/usr/lib/glib-2.0
rm -fr $MODULE_PATH/packages/usr/lib/libear
rm -fr $MODULE_PATH/packages/usr/lib/libscanbuild
rm -fr $MODULE_PATH/packages/usr/lib/xmms
rm -fr $MODULE_PATH/packages/var/cache
rm -fr $MODULE_PATH/packages/var/cache/fontconfig
rm -fr $MODULE_PATH/packages/var/db
rm -fr $MODULE_PATH/packages/var/kerberos
rm -fr $MODULE_PATH/packages/var/lib/dbus
rm -fr $MODULE_PATH/packages/var/run

find $MODULE_PATH/packages -maxdepth 1 -type f -delete
find $MODULE_PATH/packages/sbin \( -type f -o -type l \) ! \( -name "ldconfig" -o -name "sln" \) -delete
find $MODULE_PATH/packages/bin \( -type f -o -type l \) ! -name "sln" -delete
find $MODULE_PATH/packages/usr/share -mindepth 1 -maxdepth 1 -type d ! -name "vulkan" -exec rm -rf {} +
find $MODULE_PATH/packages/usr -mindepth 1 -maxdepth 1 -type d ! -name "lib" ! -name "share" -exec rm -rf {} +
find $MODULE_PATH/packages/usr/lib/locale -mindepth 1 -maxdepth 1 -type d ! -name "en_US.utf8" -exec rm -rf {} +
} >/dev/null 2>&1

strip_clean --exceptions='*/dri/*,libc-*,libc.so*,libgallium*,libvulkan*,libX11.so*'
strip_hard_exec

### finalize

finalize
