#!/bin/sh

MODULENAME="0050-multilib-lite"

source "$PWD/../builder-utils/setflags.sh"

export ARCH=i586
export SYSTEMBITS=32

SetFlags "$MODULENAME"

source "$PWD/../builder-utils/downloadfromslackware.sh"
source "$PWD/../builder-utils/genericstrip.sh"
source "$PWD/../builder-utils/helper.sh"
source "$PWD/../builder-utils/slackwarerepository.sh"

### create module folder

mkdir -p $MODULEPATH/packages > /dev/null 2>&1

### download packages from slackware repositories

DownloadFromSlackware

### packages that require specific stripping

currentPackage=llvm
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv ../packages/${currentPackage}-[0-9]* .
version=`ls * -a | cut -d'-' -f2- | sed 's/\.txz$//'`
tar xvf ${currentPackage}-*.txz
mkdir -p ${currentPackage}-stripped-$version/usr/lib
cp usr/lib/LLVMgold.so ${currentPackage}-stripped-$version/usr/lib
cp usr/lib/libLLVM*.so* ${currentPackage}-stripped-$version/usr/lib
cd ${currentPackage}-stripped-$version
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-stripped-$version.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=vulkan-sdk
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv ../packages/${currentPackage}-[0-9]* .
version=`ls * -a | cut -d'-' -f3- | sed 's/\.txz$//'`
tar xvf ${currentPackage}-*.txz
mkdir -p ${currentPackage}-stripped-$version/usr/lib
cp usr/lib/libvulkan.so* ${currentPackage}-stripped-$version/usr/lib
cd ${currentPackage}-stripped-$version
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-stripped-$version.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

### fake root

cd $MODULEPATH/packages && ROOT=./ installpkg *.t?z
rm *.t?z

### strip

rm -fr $MODULEPATH/packages/etc
rm -fr $MODULEPATH/packages/lib64
rm -fr $MODULEPATH/packages/run
rm -fr $MODULEPATH/packages/var/db
rm -fr $MODULEPATH/packages/var/kerberos
rm -fr $MODULEPATH/packages/var/run
rm -fr $MODULEPATH/packages/var/cache
rm -fr $MODULEPATH/packages/var/cache/fontconfig
rm -fr $MODULEPATH/packages/var/lib/dbus
rm -fr $MODULEPATH/packages/var/log/pkgtools
rm -fr $MODULEPATH/packages/var/log/setup
rm -fr $MODULEPATH/packages/lib/e2fsprogs
rm -fr $MODULEPATH/packages/lib/elogind
rm -fr $MODULEPATH/packages/lib/udev
rm -fr $MODULEPATH/packages/usr/lib/clang
rm -fr $MODULEPATH/packages/usr/lib/dbus-1.0
rm -fr $MODULEPATH/packages/usr/lib/gcc
rm -fr $MODULEPATH/packages/usr/lib/girepository-1.0
rm -fr $MODULEPATH/packages/usr/lib/glib-2.0
rm -fr $MODULEPATH/packages/usr/lib/libear
rm -fr $MODULEPATH/packages/usr/lib/libscanbuild
rm -fr $MODULEPATH/packages/usr/lib/python2.7
rm -fr $MODULEPATH/packages/usr/lib/python3.9
rm -fr $MODULEPATH/packages/usr/lib/xmms

rm $MODULEPATH/packages/*
rm $MODULEPATH/packages/bin/cpp
rm $MODULEPATH/packages/lib/e2initrd_helper
rm $MODULEPATH/packages/lib/libacl*
rm $MODULEPATH/packages/lib/libaio*
rm $MODULEPATH/packages/lib/libattr*
rm $MODULEPATH/packages/lib/libdevmapper*
rm $MODULEPATH/packages/lib/libdb*
rm $MODULEPATH/packages/lib/libdm*
rm $MODULEPATH/packages/lib/libfuse*
rm $MODULEPATH/packages/lib/libgpm*
rm $MODULEPATH/packages/lib/libpopt*
rm $MODULEPATH/packages/lib/libsigsegv*
rm $MODULEPATH/packages/lib/libsysfs*
rm $MODULEPATH/packages/lib/libtermcap*
rm $MODULEPATH/packages/lib/libudev*

rm $MODULEPATH/packages/usr/lib/*.o
rm $MODULEPATH/packages/usr/lib/*.spec
rm $MODULEPATH/packages/usr/lib/xml2Conf.sh
rm $MODULEPATH/packages/usr/lib/libargon*
rm $MODULEPATH/packages/usr/lib/libcares.*
rm $MODULEPATH/packages/usr/lib/libcc1.*
rm $MODULEPATH/packages/usr/lib/libclang*
rm $MODULEPATH/packages/usr/lib/libdxcompiler.*
rm $MODULEPATH/packages/usr/lib/libgdbm*
rm $MODULEPATH/packages/usr/lib/libglslang.*
rm $MODULEPATH/packages/usr/lib/libgmp*
rm $MODULEPATH/packages/usr/lib/libhistoy*
rm $MODULEPATH/packages/usr/lib/libhsail-rt.*
rm $MODULEPATH/packages/usr/lib/libidn*
rm $MODULEPATH/packages/usr/lib/libisl*
rm $MODULEPATH/packages/usr/lib/libadm*
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

find $MODULEPATH/packages/sbin \( -type f -o -type l \) ! \( -name "ldconfig" -o -name "sln" \) -delete
find $MODULEPATH/packages/bin \( -type f -o -type l \) ! -name "sln" -delete
find $MODULEPATH/packages/usr -mindepth 1 -maxdepth 1 -type d ! -name "lib" -exec rm -rf {} +
find $MODULEPATH/packages/usr/lib/locale -mindepth 1 -maxdepth 1 -type d ! -name "en_US.utf8" -exec rm -rf {} +

mv $MODULEPATH/packages/lib $MODULEPATH/ # move out /lib so we can strip safely
mv $MODULEPATH/packages/usr/lib/dri $MODULEPATH/ # move out usr/lib/dri so we can strip safely
GenericStrip
mv $MODULEPATH/lib $MODULEPATH/packages/
mv $MODULEPATH/dri $MODULEPATH/packages/usr/lib/

### finalize

Finalize
