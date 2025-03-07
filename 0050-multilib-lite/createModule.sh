#!/bin/bash

MODULENAME="0050-multilib-lite"

export SYSTEMBITS=

source "$PWD/../builder-utils/setflags.sh"

SetFlags "$MODULENAME"

source "$PWD/../builder-utils/downloadfromslackware.sh"
source "$PWD/../builder-utils/genericstrip.sh"
source "$PWD/../builder-utils/helper.sh"
source "$PWD/../builder-utils/slackwarerepository.sh"

if ! isRoot; then
	echo "Please enter admin's password below:"
	su -c "$0 $1"
	exit
fi

### create module folder

mkdir -p $MODULEPATH/packages > /dev/null 2>&1

### download packages from slackware repositories

DownloadFromSlackware

### packages that require specific stripping

currentPackage=aaa_libraries
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv ../packages/${currentPackage}-[0-9]* .
version=`ls * -a | cut -d'-' -f2- | sed 's/\.txz$//'`
mv ../packages/gcc-* . # required because aaa_libraries quite often is not in sync with gcc/g++
ROOT=./ installpkg ${currentPackage}*.txz && rm ${currentPackage}-*.txz
rm usr/lib/libslang.so.1*
rm usr/lib/libstdc++.so*
ROOT=./ installpkg gcc-*.txz
mkdir ${currentPackage}-stripped-$version
cp --parents -P lib/libfuse.* ${currentPackage}-stripped-$version/
cp --parents -P lib/libgssapi_krb5.* ${currentPackage}-stripped-$version/
cp --parents -P lib/libk5crypto.* ${currentPackage}-stripped-$version/
cp --parents -P lib/libkrb5.* ${currentPackage}-stripped-$version/
cp --parents -P lib/libkrb5support.* ${currentPackage}-stripped-$version/
cp --parents -P lib/libpcre2* ${currentPackage}-stripped-$version/
cp --parents -P lib/libsigsegv.* ${currentPackage}-stripped-$version/
cp --parents -P usr/lib/libatomic.* ${currentPackage}-stripped-$version/
cp --parents -P usr/lib/libcares.* ${currentPackage}-stripped-$version/
cp --parents -P usr/lib/libcups.* ${currentPackage}-stripped-$version/
cp --parents -P usr/lib/libgcc_s.* ${currentPackage}-stripped-$version/
cp --parents -P usr/lib/libgmp.* ${currentPackage}-stripped-$version/
cp --parents -P usr/lib/libgmpxx.* ${currentPackage}-stripped-$version/
cp --parents -P usr/lib/libgomp.* ${currentPackage}-stripped-$version/
cp --parents -P usr/lib/libltdl.* ${currentPackage}-stripped-$version/
cp --parents -P usr/lib/libslang.* ${currentPackage}-stripped-$version/
cp --parents -P usr/lib/libstdc++.* ${currentPackage}-stripped-$version/
cd ${currentPackage}-stripped-$version/usr/lib
cp -fs libcares.so* libcares.so
cp -fs libcares.so libcares.so.2
cp -fs libcups.so* libcups.so
cp -fs libgmp.so* libgmp.so
cp -fs libgmpxx.so* libgmpxx.so
cp -fs libltdl.so* libltdl.so
cp -fs libslang.so* libslang.so
cd $MODULEPATH/${currentPackage}/${currentPackage}-stripped-$version
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-stripped-$version-1.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=llvm
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv ../packages/${currentPackage}-[0-9]* .
version=`ls * -a | cut -d'-' -f2- | sed 's/\.txz$//'`
tar xvf ${currentPackage}-*.txz
mkdir -p ${currentPackage}-stripped-$version/usr/lib
cp usr/lib/libLLVM*.so* ${currentPackage}-stripped-$version/usr/lib
cd ${currentPackage}-stripped-$version
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-stripped-$version-1.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=pulseaudio
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv ../packages/${currentPackage}-[0-9]* .
version=`ls * -a | cut -d'-' -f3- | sed 's/\.txz$//'`
ROOT=./ installpkg ${currentPackage}-*.txz
mkdir ${currentPackage}-stripped-$version
cp --parents -P usr/lib/libpulse.so* ${currentPackage}-stripped-$version
cp --parents -P usr/lib/libpulse-mainloop-glib.so* ${currentPackage}-stripped-$version
cp --parents -P usr/lib/libpulse-simple.so* ${currentPackage}-stripped-$version
cp --parents -P usr/lib/pulseaudio/libpulsecommon* ${currentPackage}-stripped-$version
cd ${currentPackage}-stripped-$version
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-stripped-$version-1.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=vulkan-sdk
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv ../packages/${currentPackage}-[0-9]* .
version=`ls * -a | cut -d'-' -f3- | sed 's/\.txz$//'`
tar xvf ${currentPackage}-*.txz
mkdir -p ${currentPackage}-stripped-$version/usr/lib
cp usr/lib/libvulkan.so* ${currentPackage}-stripped-$version/usr/lib
if [ $SLACKWAREVERSION == "current" ]; then
	cp --parents -P usr/lib$SYSTEMBITS/libSPIRV-Tools.so* ${currentPackage}-stripped-$version
fi
cd ${currentPackage}-stripped-$version
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-stripped-$version-1.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

### fake root

cd $MODULEPATH/packages && ROOT=./ installpkg *.t?z
rm *.t?z

### strip

rm -fr $MODULEPATH/packages/etc
rm -fr $MODULEPATH/packages/lib/e2fsprogs
rm -fr $MODULEPATH/packages/lib/elogind
rm -fr $MODULEPATH/packages/lib/security
rm -fr $MODULEPATH/packages/lib/udev
rm -fr $MODULEPATH/packages/run
rm -fr $MODULEPATH/packages/usr/lib/clang
rm -fr $MODULEPATH/packages/usr/lib/dbus-1.0
rm -fr $MODULEPATH/packages/usr/lib/gcc
rm -fr $MODULEPATH/packages/usr/lib/girepository-1.0
rm -fr $MODULEPATH/packages/usr/lib/glib-2.0
rm -fr $MODULEPATH/packages/usr/lib/libear
rm -fr $MODULEPATH/packages/usr/lib/libscanbuild
rm -fr $MODULEPATH/packages/usr/lib/python2*
rm -fr $MODULEPATH/packages/usr/lib/xmms
rm -fr $MODULEPATH/packages/var/cache
rm -fr $MODULEPATH/packages/var/cache/fontconfig
rm -fr $MODULEPATH/packages/var/db
rm -fr $MODULEPATH/packages/var/kerberos
rm -fr $MODULEPATH/packages/var/lib/dbus
rm -fr $MODULEPATH/packages/var/run

rm $MODULEPATH/packages/*
rm $MODULEPATH/packages/lib/cpp
rm $MODULEPATH/packages/lib/e2initrd_helper
rm $MODULEPATH/packages/lib/libacl*
rm $MODULEPATH/packages/lib/libaio*
rm $MODULEPATH/packages/lib/libattr*
rm $MODULEPATH/packages/lib/libdb*
rm $MODULEPATH/packages/lib/libdevmapper*
rm $MODULEPATH/packages/lib/libdm*
rm $MODULEPATH/packages/lib/libfuse*
rm $MODULEPATH/packages/lib/libgpm*
rm $MODULEPATH/packages/lib/libpopt*
rm $MODULEPATH/packages/lib/libsigsegv*
rm $MODULEPATH/packages/lib/libsysfs*
rm $MODULEPATH/packages/lib/libtermcap*
rm $MODULEPATH/packages/lib/libudev*
rm $MODULEPATH/packages/usr/lib/libadm*
rm $MODULEPATH/packages/usr/lib/libargon*
rm $MODULEPATH/packages/usr/lib/libboost*
rm $MODULEPATH/packages/usr/lib/libcares.*
rm $MODULEPATH/packages/usr/lib/libcc1.*
rm $MODULEPATH/packages/usr/lib/libclang*
rm $MODULEPATH/packages/usr/lib/libdxcompiler.*
rm $MODULEPATH/packages/usr/lib/libgdbm*
rm $MODULEPATH/packages/usr/lib/libglslang.*
rm $MODULEPATH/packages/usr/lib/libgmp*
rm $MODULEPATH/packages/usr/lib/libhistoy*
rm $MODULEPATH/packages/usr/lib/libhsail-rt.*
rm $MODULEPATH/packages/usr/lib/libicu*
rm $MODULEPATH/packages/usr/lib/libidn*
rm $MODULEPATH/packages/usr/lib/libisl*
rm $MODULEPATH/packages/usr/lib/libkdb*
rm $MODULEPATH/packages/usr/lib/libkrad*
rm $MODULEPATH/packages/usr/lib/liblber*
rm $MODULEPATH/packages/usr/lib/libldap*
rm $MODULEPATH/packages/usr/lib/liblldb*
rm $MODULEPATH/packages/usr/lib/libltdl*
rm $MODULEPATH/packages/usr/lib/libmm*
rm $MODULEPATH/packages/usr/lib/libmpc*
rm $MODULEPATH/packages/usr/lib/libmpfr*
rm $MODULEPATH/packages/usr/lib/libpsl*
rm $MODULEPATH/packages/usr/lib/libreadline*
rm $MODULEPATH/packages/usr/lib/libslang*
rm $MODULEPATH/packages/usr/lib/libssh*
rm $MODULEPATH/packages/usr/lib/libtdb*
rm $MODULEPATH/packages/usr/lib/libtiff*
rm $MODULEPATH/packages/usr/lib/libunwind*
rm $MODULEPATH/packages/usr/lib/libusb*
rm $MODULEPATH/packages/usr/lib/libvga*
rm $MODULEPATH/packages/usr/lib/libvpx*
rm $MODULEPATH/packages/usr/lib/*.o
rm $MODULEPATH/packages/usr/lib/*.spec
rm $MODULEPATH/packages/usr/lib/xml2Conf.sh

find $MODULEPATH/packages/sbin \( -type f -o -type l \) ! \( -name "ldconfig" -o -name "sln" \) -delete
find $MODULEPATH/packages/bin \( -type f -o -type l \) ! -name "sln" -delete
find $MODULEPATH/packages/usr -mindepth 1 -maxdepth 1 -type d ! -name "lib" -exec rm -rf {} +
find $MODULEPATH/packages/usr/lib/locale -mindepth 1 -maxdepth 1 -type d ! -name "en_US.utf8" -exec rm -rf {} +

# move out things that don't support stripping
mv $MODULEPATH/packages/lib/libc.so* $MODULEPATH/
mv $MODULEPATH/packages/lib/libc-* $MODULEPATH/
mv $MODULEPATH/packages/usr/lib/dri $MODULEPATH/
mv $MODULEPATH/packages/usr/lib/libgallium* $MODULEPATH/
GenericStrip
AggressiveStrip
mv $MODULEPATH/libgallium* $MODULEPATH/packages/usr/lib/
mv $MODULEPATH/dri $MODULEPATH/packages/usr/lib/
mv $MODULEPATH/libc.so* $MODULEPATH/packages/lib
mv $MODULEPATH/libc-* $MODULEPATH/packages/lib

### finalize

Finalize
