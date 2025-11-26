#!/bin/bash

MODULENAME=flatpak

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

### packages outside slackware repository

installpkg $MODULEPATH/packages/*.txz || exit 1
rm $MODULEPATH/packages/gperf*.txz
rm $MODULEPATH/packages/pyparsing*.txz
rm $MODULEPATH/packages/socat*.txz

# flatpak deps
for package in \
	libostree \
	libfyaml \
	libxmlb \
	appstream \
	xdg-desktop-portal-gtk \
; do
sh $SCRIPTPATH/deps/${package}/${package}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${package}*.txz || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

currentPackage=flatpak
sh $SCRIPTPATH/${currentPackage}/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

### fake root

cd $MODULEPATH/packages && ROOT=./ installpkg *.t?z
rm *.t?z

### module clean up

GenericStrip
AggressiveStripAll

### set version

version=$(ls $MODULEPATH/packages/var/log/packages/flatpak* | rev | cut -d "/" -f1 | rev | cut -d "-" -f2)
MODULENAME=$MODULENAME-${version}

### finalize

Finalize
