#!/bin/bash

MODULENAME=05-devel

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

if [ ! -f $MODULEPATH/packages/kernel-headers*.txz ]; then
	wget https://slackware.uk/cumulative/slackware64-current/slackware64/d/kernel-headers-$KERNELVERSION-x86-1.txz -P $MODULEPATH/packages || exit 1
fi

if [ $SLACKWAREVERSION != "current" ]; then
	currentPackage=meson
	sh $SCRIPTPATH/../common/${currentPackage}/${currentPackage}.SlackBuild || exit 1
	/sbin/upgradepkg --install-new --reinstall $MODULEPATH/packages/${currentPackage}-*.txz
	rm -fr $MODULEPATH/${currentPackage}
fi

### fake root

cd $MODULEPATH/packages && ROOT=./ installpkg *.t?z
rm *.t?z

### copy language files to 08-multilanguage

CopyToMultiLanguage

### module clean up

cd $MODULEPATH/packages/

{
rm usr/lib/python*/site-packages/setuptools/_distutils/command/*.exe

rm -fr usr/doc
rm -fr usr/etc
rm -fr usr/info
rm -fr usr/lib${SYSTEMBITS}/bash
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
rm -fr var/log/pkgtools
rm -fr var/log/setup

# already included in aaa_libraries-stripped - keeping them will prevent 05-devel from being deactivated
rm usr/lib${SYSTEMBITS}/libatomic.so*
rm usr/lib${SYSTEMBITS}/libgcc_s.so*
rm usr/lib${SYSTEMBITS}/libgmp.so*
rm usr/lib${SYSTEMBITS}/libgmpxx.so*
rm usr/lib${SYSTEMBITS}/libgomp.so*
rm usr/lib${SYSTEMBITS}/libltdl.so*
rm usr/lib${SYSTEMBITS}/libstdc++.so*

# already included in binutils-stripped
rm usr/bin/ar
rm usr/bin/strip
rm usr/lib${SYSTEMBITS}/libbfd.so
rm usr/lib${SYSTEMBITS}/libbfd-*.so
rm usr/lib${SYSTEMBITS}/libsframe*.so

# remove 32-bit files
rm -fr usr/include/c++/*/x86_64-slackware-linux/32
rm -fr usr/lib/pkgconfig
rm -fr usr/lib${SYSTEMBITS}/gcc/x86_64-slackware-linux/*/32
rm usr/lib/*

find . -name '*.la' -delete
find usr/ -type d -empty -delete
} >/dev/null 2>&1

AggressiveStrip

### finalize

Finalize
