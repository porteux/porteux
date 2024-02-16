#!/bin/sh

MODULENAME="08-multilanguage"

source "$PWD/../builder-utils/setflags.sh"

SetFlags "$MODULENAME"

source "$PWD/../builder-utils/downloadfromslackware.sh"
source "$PWD/../builder-utils/helper.sh"
source "$PWD/../builder-utils/slackwarerepository.sh"

### create module folder

mkdir -p $MODULEPATH/packages > /dev/null 2>&1

### download packages from slackware repositories

DownloadFromSlackware

#### packages that require specific stripping

currentPackage=aaa_libraries
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv ../packages/${currentPackage}-[0-9]* .
version=`ls * -a | cut -d'-' -f2- | sed 's/\.txz$//'`
ROOT=./ installpkg ${currentPackage}-*.txz
mkdir ${currentPackage}-stripped-$version
cp --parents -P lib64/libfuse.* ${currentPackage}-stripped-$version/
cp --parents -P lib64/libgssapi_krb5.* ${currentPackage}-stripped-$version/
cp --parents -P lib64/libk5crypto.* ${currentPackage}-stripped-$version/
cp --parents -P lib64/libkrb5.* ${currentPackage}-stripped-$version/
cp --parents -P lib64/libkrb5support.* ${currentPackage}-stripped-$version/
cp --parents -P lib64/libsigsegv.* ${currentPackage}-stripped-$version/
cp --parents -P usr/lib64/libatomic.* ${currentPackage}-stripped-$version/
cp --parents -P usr/lib64/libcares.* ${currentPackage}-stripped-$version/
cp --parents -P usr/lib64/libcups.* ${currentPackage}-stripped-$version/
cp --parents -P usr/lib64/libexpat.* ${currentPackage}-stripped-$version/
cp --parents -P usr/lib64/libgcc_s.* ${currentPackage}-stripped-$version/
cp --parents -P usr/lib64/libgmp.* ${currentPackage}-stripped-$version/
cp --parents -P usr/lib64/libgmpxx.* ${currentPackage}-stripped-$version/
cp --parents -P usr/lib64/libgomp.* ${currentPackage}-stripped-$version/
cp --parents -P usr/lib64/libltdl.* ${currentPackage}-stripped-$version/
cp --parents -P usr/lib64/libslang.* ${currentPackage}-stripped-$version/
cp --parents -P usr/lib64/libstdc++.so.6* ${currentPackage}-stripped-$version/
cd $MODULEPATH/${currentPackage}/${currentPackage}-stripped-$version
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-stripped-$version.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

### fake root

cd $MODULEPATH/packages && ROOT=./ installpkg *.t?z
rm *.t?z

### strip

rm -R $MODULEPATH/packages/var/log/pkgtools
rm -R $MODULEPATH/packages/var/log/setup
rm -R $MODULEPATH/packages/var/lib/pkgtools/douninst.sh/
rm -R $MODULEPATH/packages/var/lib/pkgtools/setup

rm $MODULEPATH/packages/var/log/removed_packages
rm $MODULEPATH/packages/var/log/removed_scripts
rm $MODULEPATH/packages/var/log/removed_uninstall_scripts

### finalize

Finalize
