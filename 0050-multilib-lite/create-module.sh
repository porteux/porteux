#!/bin/bash

MODULE_NAME="0050-multilib-lite"

export SYSTEM_BITS=

source "$PWD/../builder-utils/set-flags.sh"

set_flags "$MODULE_NAME"

source "$BUILDER_UTILS_PATH/generic-strip.sh"
source "$BUILDER_UTILS_PATH/helper.sh"
source "$BUILDER_UTILS_PATH/slackware-repository.sh"

elevate_if_needed "$0" "$@"

echo -e "Building ${MODULE_NAME} based on Slackware ${SLACKWARE_VERSION} i686...\n"

### create module folder

mkdir -p $MODULE_PATH/packages > /dev/null 2>&1
cd $MODULE_PATH || exit 1

### download packages from slackware repository

bash $SCRIPT_PATH/download-packages.sh || exit 1

### packages that require specific stripping

current_package=aaa_libraries
rm -rf $MODULE_PATH/${current_package}
mkdir $MODULE_PATH/${current_package} && cd $MODULE_PATH/${current_package} || exit 1
mv ../packages/${current_package}-[0-9]* .
package_file_name=$(ls * -a | rev | cut -d . -f 2- | rev)
mv ../packages/gcc-* . # required because aaa_libraries quite often is not in sync with gcc/g++
ROOT=./ installpkg ${current_package}*.txz
rm usr/lib/libslang.so.1*
rm usr/lib/libstdc++.so*
ROOT=./ installpkg gcc-*.txz
mkdir ${current_package}-stripped
cp --parents -P lib/libgssapi_krb5.* ${current_package}-stripped/
cp --parents -P lib/libk5crypto.* ${current_package}-stripped/
cp --parents -P lib/libkrb5.* ${current_package}-stripped/
cp --parents -P lib/libkrb5support.* ${current_package}-stripped/
cp --parents -P lib/libpcre2* ${current_package}-stripped/
cp --parents -P usr/lib/libatomic.* ${current_package}-stripped/
cp --parents -P usr/lib/libcups.* ${current_package}-stripped/
cp --parents -P usr/lib/libgcc_s.* ${current_package}-stripped/
cp --parents -P usr/lib/libgomp.* ${current_package}-stripped/
cp --parents -P usr/lib/libstdc++.* ${current_package}-stripped/
cd $MODULE_PATH/${current_package}/${current_package}-stripped || exit 1
makepkg ${MAKEPKG_FLAGS} $MODULE_PATH/packages/${package_file_name}_stripped.txz > /dev/null 2>&1
rm -fr $MODULE_PATH/${current_package} && cd $MODULE_PATH || exit 1

strip_package eudev \
	lib/libudev*.so*

strip_package llvm \
	usr/lib/libLLVM*.so*

current_package=mesa
rm -rf $MODULE_PATH/${current_package}
mkdir $MODULE_PATH/${current_package} && cd $MODULE_PATH/${current_package} || exit 1
mv $MODULE_PATH/packages/${current_package}-[0-9]* .
package_file_name=$(ls * -a | rev | cut -d . -f 2- | rev)
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
rsync -av * ${current_package}-stripped/ --exclude=${current_package}-stripped/
cd ${current_package}-stripped || exit 1
makepkg ${MAKEPKG_FLAGS} $MODULE_PATH/packages/${package_file_name}_stripped.txz > /dev/null 2>&1
rm -fr $MODULE_PATH/${current_package} && cd $MODULE_PATH || exit 1

strip_package pulseaudio \
	usr/lib/libpulse.so* \
	usr/lib/libpulse-mainloop-glib.so* \
	usr/lib/libpulse-simple.so* \
	usr/lib/pulseaudio/libpulsecommon*

strip_package vulkan-sdk \
	usr/lib/libvulkan.so* \
	usr/lib/libSPIRV-Tools.so*

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
rm $MODULE_PATH/packages/usr/lib/*.o
rm $MODULE_PATH/packages/usr/lib/*.spec

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

# move out things that don't support stripping
mv $MODULE_PATH/packages/lib/libc.so* $MODULE_PATH/
mv $MODULE_PATH/packages/lib/libc-* $MODULE_PATH/
mv $MODULE_PATH/packages/usr/lib/dri $MODULE_PATH/
mv $MODULE_PATH/packages/usr/lib/libgallium* $MODULE_PATH/
mv $MODULE_PATH/packages/usr/lib/libvulkan* $MODULE_PATH/
mv $MODULE_PATH/packages/usr/lib/libX11.so* $MODULE_PATH/
strip_clean
strip_hard_exec
mv $MODULE_PATH/libc.so* $MODULE_PATH/packages/lib
mv $MODULE_PATH/libc-* $MODULE_PATH/packages/lib
mv $MODULE_PATH/dri $MODULE_PATH/packages/usr/lib/
mv $MODULE_PATH/libgallium* $MODULE_PATH/packages/usr/lib/
mv $MODULE_PATH/libvulkan* $MODULE_PATH/packages/usr/lib/
mv $MODULE_PATH/libX11.so* $MODULE_PATH/packages/usr/lib/

### finalize

finalize
