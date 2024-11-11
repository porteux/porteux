#!/bin/sh

MODULENAME=05-devel

source "$PWD/../builder-utils/setflags.sh"

SetFlags "$MODULENAME"

source "$PWD/../builder-utils/downloadfromslackware.sh"
source "$PWD/../builder-utils/genericstrip.sh"
source "$PWD/../builder-utils/helper.sh"

### create module folder

mkdir -p $MODULEPATH/packages > /dev/null 2>&1

### download packages from slackware repositories

DownloadFromSlackware

if [ ! -f $MODULEPATH/packages/kernel-headers*.txz ]; then
	wget https://slackware.uk/cumulative/slackware64-current/slackware64/d/kernel-headers-$KERNELVERSION-x86-1.txz -P $MODULEPATH/packages || exit 1
fi

if [ $SLACKWAREVERSION != "current" ]; then
	currentPackage=meson
	sh $SCRIPTPATH/../extras/${currentPackage}/${currentPackage}.SlackBuild || exit 1
	/sbin/upgradepkg --install-new --reinstall $MODULEPATH/packages/${currentPackage}-*.txz
fi

### fake root

cd $MODULEPATH/packages && ROOT=./ installpkg *.t?z
rm *.t?z

### copy language files to 08-multilanguage

CopyToMultiLanguage

### module clean up

cd $MODULEPATH/packages/

rm -R usr/doc
rm -R usr/etc
rm -R usr/info
rm -R usr/lib${SYSTEMBITS}/bash
rm -R usr/lib*/python2*
rm -R usr/local
rm -R usr/man
rm -R usr/share/applications
rm -R usr/share/cmake-*/Help
rm -R usr/share/devhelp
rm -R usr/share/gnome
rm -R usr/share/help
rm -R usr/share/icons
rm -R usr/share/locale
rm -R usr/share/sgml/docbook/dsssl-stylesheets*
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

# remove 32-bit files
rm -R usr/include/c++/*/x86_64-slackware-linux/32
rm -R usr/lib/pkgconfig
rm -R usr/lib${SYSTEMBITS}/gcc/x86_64-slackware-linux/*/32
rm usr/lib/*

find . -name '*.la' -delete

AggressiveStrip

### add symlink from /usr/include to /usr/local/include required by some packages

mkdir -p $MODULEPATH/packages/usr/local > /dev/null 2>&1
ln -s /usr/include $MODULEPATH/packages/usr/local/include > /dev/null 2>&1

### finalize

Finalize
