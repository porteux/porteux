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

AggressiveStrip

### add symlink from /usr/include to /usr/local/include required by some packages

mkdir -p $MODULEPATH/packages/usr/local > /dev/null 2>&1
ln -s /usr/include $MODULEPATH/packages/usr/local/include > /dev/null 2>&1

### finalize

Finalize
