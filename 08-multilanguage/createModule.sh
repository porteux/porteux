#!/bin/bash

MODULENAME="08-multilanguage"

source "$PWD/../builder-utils/setflags.sh"

SetFlags "$MODULENAME"

source "$PWD/../builder-utils/downloadfromslackware.sh"
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

### fake root

cd $MODULEPATH/packages && ROOT=./ installpkg *.t?z
rm *.t?z

### strip

rm -R $MODULEPATH/packages/var/lib/pkgtools/douninst.sh/
rm -R $MODULEPATH/packages/var/lib/pkgtools/setup
rm -R $MODULEPATH/packages/var/log/pkgtools
rm -R $MODULEPATH/packages/var/log/setup

rm $MODULEPATH/packages/var/log/removed_packages
rm $MODULEPATH/packages/var/log/removed_scripts
rm $MODULEPATH/packages/var/log/removed_uninstall_scripts

find $MODULEPATH/packages -type f -name '*.desktop' -exec rm -f {} +

### finalize

Finalize
