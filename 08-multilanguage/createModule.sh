#!/bin/bash

MODULENAME="08-multilanguage"

source "$PWD/../builder-utils/setflags.sh"

SetFlags "$MODULENAME"

source "$BUILDERUTILSPATH/downloadfromslackware.sh"
source "$BUILDERUTILSPATH/helper.sh"
source "$BUILDERUTILSPATH/slackwarerepository.sh"

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

### fake root

cd $MODULEPATH/packages && ROOT=./ installpkg *.t?z
rm *.t?z

### module clean up

{
rm $MODULEPATH/packages/var/log/removed_packages
rm $MODULEPATH/packages/var/log/removed_scripts
rm $MODULEPATH/packages/var/log/removed_uninstall_scripts

rm -fr $MODULEPATH/packages/var/lib/pkgtools/douninst.sh/
rm -fr $MODULEPATH/packages/var/lib/pkgtools/setup
rm -fr $MODULEPATH/packages/var/log/pkgtools
rm -fr $MODULEPATH/packages/var/log/setup

find $MODULEPATH/packages -type f -name '*.desktop' -exec rm -f {} +
} >/dev/null 2>&1

### finalize

Finalize
