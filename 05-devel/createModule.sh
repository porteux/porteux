#!/bin/sh
MODULENAME=05-devel

source "$PWD/../builder-utils/setflags.sh"

SetFlags "$MODULENAME"

source "$PWD/../builder-utils/downloadfromslackware.sh"
source "$PWD/../builder-utils/helper.sh"

### create module folder

mkdir -p $MODULEPATH/packages > /dev/null 2>&1

### download packages from slackware repositories

DownloadFromSlackware

curentPackage=kernel-headers
wget https://slackware.uk/cumulative/slackware64-current/slackware64/d/kernel-headers-$KERNELVERSION-x86-1.txz -P $MODULEPATH/packages || exit 1

### packages outside Slackware repository

currentPackage=graph-easy
version=0.76
mkdir $MODULEPATH/$currentPackage && cd $MODULEPATH/$currentPackage
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/graphics/$currentPackage/ -A * || exit 1
wget https://cpan.metacpan.org/authors/id/S/SH/SHLOMIF/Graph-Easy-$version.tar.gz || exit 1
sed -i "s|make test| |g" $currentPackage.SlackBuild
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" $currentPackage.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" $currentPackage.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" $currentPackage.SlackBuild
sh $currentPackage.SlackBuild || exit 1
mv /tmp/$currentPackage*.t?z $MODULEPATH/packages
rm -fr $MODULEPATH/$currentPackage

### fake root

cd $MODULEPATH/packages && ROOT=./ installpkg *.t?z
rm *.t?z

### module clean up

cd $MODULEPATH/packages/

rm -R usr/x86_64-slackware-linux
rm -R usr/etc
rm -R usr/doc
rm -R usr/info
rm -R usr/local
rm -R usr/man
rm -R usr/lib64/bash
rm -R usr/lib64/python2.*
rm -R usr/share/devhelp
rm -R usr/share/cmake-*/Help
rm -R usr/share/gnome
rm -R usr/share/help
rm -R usr/share/icons
rm -R usr/share/locale
rm -R usr/share/sgml/docbook
rm -R usr/share/valadoc-*
rm -R usr/share/applications

rm usr/lib64/libmozjs-*.so

### finalize

Finalize
