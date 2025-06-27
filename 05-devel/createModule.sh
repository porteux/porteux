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

### download packages from slackware repositories

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
rm -R usr/doc
rm -R usr/etc
rm -R usr/info
rm -R usr/lib${SYSTEMBITS}/bash
rm -R usr/lib*/python2*
rm -R usr/local
rm -R usr/man
rm -R usr/share/applications
rm -R usr/share/bash-completion
rm -R usr/share/cmake-*/Help
rm -R usr/share/devhelp
rm -R usr/share/doc
rm -R usr/share/gitk
rm -R usr/share/gnome
rm -R usr/share/ffmpeg/examples
rm -R usr/share/help
rm -R usr/share/icons
rm -R usr/share/locale
rm -R usr/share/valadoc-*
rm -R usr/x86_64-slackware-linux
rm -R var/log/pkgtools
rm -R var/log/setup

rm usr/lib/python*/site-packages/setuptools/_distutils/command/*.exe

# already included in aaa_libraries - keeping them will prevent 05-devel from being deactivated
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
rm -R usr/include/c++/*/x86_64-slackware-linux/32
rm -R usr/lib/pkgconfig
rm -R usr/lib${SYSTEMBITS}/gcc/x86_64-slackware-linux/*/32
rm usr/lib/*

find . -name '*.la' -delete
find usr/ -type d -empty -delete
} >/dev/null 2>&1

AggressiveStrip

### finalize

Finalize
