#!/bin/bash

MODULENAME="0050-multilib-lite"

export SYSTEMBITS=

source "$PWD/../builder-utils/setflags.sh"

SetFlags "$MODULENAME"

source "$BUILDERUTILSPATH/downloadfromslackware.sh"
source "$BUILDERUTILSPATH/genericstrip.sh"
source "$BUILDERUTILSPATH/helper.sh"

if ! isRoot; then
	echo "Please enter admin's password below:"
	su -c "$0 $1"
	exit
fi

### create module folder

mkdir -p $MODULEPATH/packages > /dev/null 2>&1
cd $MODULEPATH

### download packages from slackware repository

DownloadFromSlackware

### packages that require specific stripping

currentPackage=aaa_libraries
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv ../packages/${currentPackage}-[0-9]* .
packageFileName=$(ls * -a | rev | cut -d . -f 2- | rev)
mv ../packages/gcc-* . # required because aaa_libraries quite often is not in sync with gcc/g++
ROOT=./ installpkg ${currentPackage}*.txz
rm usr/lib/libslang.so.1*
rm usr/lib/libstdc++.so*
ROOT=./ installpkg gcc-*.txz
mkdir ${currentPackage}-stripped
cp --parents -P lib/libgssapi_krb5.* ${currentPackage}-stripped/
cp --parents -P lib/libk5crypto.* ${currentPackage}-stripped/
cp --parents -P lib/libkrb5.* ${currentPackage}-stripped/
cp --parents -P lib/libkrb5support.* ${currentPackage}-stripped/
cp --parents -P lib/libpcre2* ${currentPackage}-stripped/
cp --parents -P lib/libsigsegv.* ${currentPackage}-stripped/
cp --parents -P usr/lib/libatomic.* ${currentPackage}-stripped/
cp --parents -P usr/lib/libcups.* ${currentPackage}-stripped/
cp --parents -P usr/lib/libgcc_s.* ${currentPackage}-stripped/
cp --parents -P usr/lib/libgomp.* ${currentPackage}-stripped/
cp --parents -P usr/lib/libstdc++.* ${currentPackage}-stripped/
cd $MODULEPATH/${currentPackage}/${currentPackage}-stripped
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${packageFileName}_stripped.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=eudev
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv ../packages/${currentPackage}-[0-9]* .
packageFileName=$(ls * -a | rev | cut -d . -f 2- | rev)
ROOT=./ installpkg ${currentPackage}*.txz
mkdir -p ${currentPackage}-stripped/lib
cp -P lib/libudev*.so* ${currentPackage}-stripped/lib
cd ${currentPackage}-stripped
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${packageFileName}_stripped.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=llvm
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv ../packages/${currentPackage}-[0-9]* .
packageFileName=$(ls * -a | rev | cut -d . -f 2- | rev)
tar xvf ${currentPackage}*.txz
mkdir -p ${currentPackage}-stripped/usr/lib
cp usr/lib/libLLVM*.so* ${currentPackage}-stripped/usr/lib
cd ${currentPackage}-stripped
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${packageFileName}_stripped.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=mesa
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv $MODULEPATH/packages/${currentPackage}-[0-9]* .
packageFileName=$(ls * -a | rev | cut -d . -f 2- | rev)
ROOT=./ installpkg ${currentPackage}*.txz && rm ${currentPackage}*.txz
rm -fr etc/OpenCL
rm usr/lib/dri/i830*
rm usr/lib/dri/i965*
rm usr/lib/dri/nouveau_vieux*
rm usr/lib/dri/r200*
rm usr/lib/dri/radeon_dri*
rm usr/lib/libMesaOpenCL*
rm usr/lib/libRusticlOpenCL*
mkdir ${currentPackage}-stripped
rsync -av * ${currentPackage}-stripped/ --exclude=${currentPackage}-stripped/
cd ${currentPackage}-stripped
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${packageFileName}_stripped.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=pulseaudio
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv ../packages/${currentPackage}-[0-9]* .
packageFileName=$(ls * -a | rev | cut -d . -f 2- | rev)
ROOT=./ installpkg ${currentPackage}*.txz
mkdir ${currentPackage}-stripped
cp --parents -P usr/lib/libpulse.so* ${currentPackage}-stripped
cp --parents -P usr/lib/libpulse-mainloop-glib.so* ${currentPackage}-stripped
cp --parents -P usr/lib/libpulse-simple.so* ${currentPackage}-stripped
cp --parents -P usr/lib/pulseaudio/libpulsecommon* ${currentPackage}-stripped
cd ${currentPackage}-stripped
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${packageFileName}_stripped.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=vulkan-sdk
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv ../packages/${currentPackage}*.txz .
packageFileName=$(ls * -a | rev | cut -d . -f 2- | rev)
ROOT=./ installpkg ${currentPackage}*.txz
mkdir ${currentPackage}-stripped
cp --parents -P usr/lib/libvulkan.so* ${currentPackage}-stripped
cp --parents -P usr/lib/libSPIRV-Tools.so* ${currentPackage}-stripped
cd ${currentPackage}-stripped
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${packageFileName}_stripped.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

### fake root

cd $MODULEPATH/packages && ROOT=./ installpkg *.t?z
rm *.t?z

### module clean up

{
rm $MODULEPATH/packages/lib/e2initrd_helper
rm $MODULEPATH/packages/lib/libfuse*
rm $MODULEPATH/packages/lib/libsigsegv*
rm $MODULEPATH/packages/usr/lib/libcares.*
rm $MODULEPATH/packages/usr/lib/libgmp*
rm $MODULEPATH/packages/usr/lib/libkdb*
rm $MODULEPATH/packages/usr/lib/libkrad*
rm $MODULEPATH/packages/usr/lib/libltdl*
rm $MODULEPATH/packages/usr/lib/libslang*
rm $MODULEPATH/packages/usr/lib/*.o
rm $MODULEPATH/packages/usr/lib/*.spec

rm -fr $MODULEPATH/packages/etc
rm -fr $MODULEPATH/packages/lib/e2fsprogs
rm -fr $MODULEPATH/packages/lib/elogind
rm -fr $MODULEPATH/packages/lib/security
rm -fr $MODULEPATH/packages/run
rm -fr $MODULEPATH/packages/usr/lib/dbus-1.0
rm -fr $MODULEPATH/packages/usr/lib/gcc
rm -fr $MODULEPATH/packages/usr/lib/girepository-1.0
rm -fr $MODULEPATH/packages/usr/lib/glib-2.0
rm -fr $MODULEPATH/packages/usr/lib/libear
rm -fr $MODULEPATH/packages/usr/lib/libscanbuild
rm -fr $MODULEPATH/packages/usr/lib/xmms
rm -fr $MODULEPATH/packages/var/cache
rm -fr $MODULEPATH/packages/var/cache/fontconfig
rm -fr $MODULEPATH/packages/var/db
rm -fr $MODULEPATH/packages/var/kerberos
rm -fr $MODULEPATH/packages/var/lib/dbus
rm -fr $MODULEPATH/packages/var/run

find $MODULEPATH/packages -maxdepth 1 -type f -delete
find $MODULEPATH/packages/sbin \( -type f -o -type l \) ! \( -name "ldconfig" -o -name "sln" \) -delete
find $MODULEPATH/packages/bin \( -type f -o -type l \) ! -name "sln" -delete
find $MODULEPATH/packages/usr/share -mindepth 1 -maxdepth 1 -type d ! -name "vulkan" -exec rm -rf {} +
find $MODULEPATH/packages/usr -mindepth 1 -maxdepth 1 -type d ! -name "lib" ! -name "share" -exec rm -rf {} +
find $MODULEPATH/packages/usr/lib/locale -mindepth 1 -maxdepth 1 -type d ! -name "en_US.utf8" -exec rm -rf {} +
} >/dev/null 2>&1

# move out things that don't support stripping
mv $MODULEPATH/packages/lib/libc.so* $MODULEPATH/
mv $MODULEPATH/packages/lib/libc-* $MODULEPATH/
mv $MODULEPATH/packages/usr/lib/dri $MODULEPATH/
mv $MODULEPATH/packages/usr/lib/libgallium* $MODULEPATH/
mv $MODULEPATH/packages/usr/lib/libvulkan* $MODULEPATH/
mv $MODULEPATH/packages/usr/lib/libX11.so* $MODULEPATH/
GenericStrip
AggressiveStrip
mv $MODULEPATH/libc.so* $MODULEPATH/packages/lib
mv $MODULEPATH/libc-* $MODULEPATH/packages/lib
mv $MODULEPATH/dri $MODULEPATH/packages/usr/lib/
mv $MODULEPATH/libgallium* $MODULEPATH/packages/usr/lib/
mv $MODULEPATH/libvulkan* $MODULEPATH/packages/usr/lib/
mv $MODULEPATH/libX11.so* $MODULEPATH/packages/usr/lib/

### finalize

Finalize
