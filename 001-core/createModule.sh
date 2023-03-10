#!/bin/sh
MODULENAME=001-core

source "$PWD/../builder-utils/setflags.sh"

SetFlags "$MODULENAME"

source "$PWD/../builder-utils/cachefiles.sh"
source "$PWD/../builder-utils/downloadfromslackware.sh"
source "$PWD/../builder-utils/genericstrip.sh"
source "$PWD/../builder-utils/helper.sh"
source "$PWD/../builder-utils/latestfromgithub.sh"

### create module folder

mkdir -p $MODULEPATH/packages > /dev/null 2>&1

### download packages from slackware repositories

DownloadFromSlackware

### packages that require specific stripping

currentPackage=binutils
mkdir $MODULEPATH/$currentPackage && cd $MODULEPATH/$currentPackage
mv ../packages/$currentPackage-[0-9]* .
version=`ls * -a | cut -d'-' -f2- | sed 's/\.txz$//'`
ROOT=./ installpkg $currentPackage-*.txz
mkdir $currentPackage-stripped-$version
cp --parents usr/bin/ar $currentPackage-stripped-$version/
cp --parents usr/bin/strip $currentPackage-stripped-$version/
cp --parents -P usr/lib$SYSTEMBITS/libbfd* $currentPackage-stripped-$version/
cp --parents -P usr/lib$SYSTEMBITS/libsframe* $currentPackage-stripped-$version/
cd $MODULEPATH/$currentPackage/$currentPackage-stripped-$version
/sbin/makepkg -l y -c n $MODULEPATH/packages/$currentPackage-stripped-$version.txz > /dev/null 2>&1
rm -fr $MODULEPATH/$currentPackage

currentPackage=ntp
mkdir $MODULEPATH/$currentPackage && cd $MODULEPATH/$currentPackage
mv ../packages/$currentPackage-[0-9]* .
version=`ls * -a | cut -d'-' -f2- | sed 's/\.txz$//'`
ROOT=./ installpkg $currentPackage-*.txz
mkdir $currentPackage-stripped-$version
cp --parents usr/bin/ntpdate $currentPackage-stripped-$version/
cd $MODULEPATH/$currentPackage/$currentPackage-stripped-$version
/sbin/makepkg -l y -c n $MODULEPATH/packages/$currentPackage-stripped-$version.txz > /dev/null 2>&1
rm -fr $MODULEPATH/$currentPackage

currentPackage=openldap
mkdir $MODULEPATH/$currentPackage && cd $MODULEPATH/$currentPackage
mv ../packages/$currentPackage-[0-9]* .
version=`ls * -a | cut -d'-' -f2- | sed 's/\.txz$//'`
ROOT=./ installpkg $currentPackage-*.txz
mkdir $currentPackage-stripped-$version
cp --parents etc/openldap/ldap.conf.new $currentPackage-stripped-$version/
mv $currentPackage-stripped-$version/etc/openldap/ldap.conf.new $currentPackage-stripped-$version/etc/openldap/ldap.conf
cp --parents usr/include/* $currentPackage-stripped-$version/
cp --parents -P usr/lib$SYSTEMBITS/libl* $currentPackage-stripped-$version/
cd $MODULEPATH/$currentPackage/$currentPackage-stripped-$version
/sbin/makepkg -l y -c n $MODULEPATH/packages/$currentPackage-stripped-$version.txz > /dev/null 2>&1
rm -fr $MODULEPATH/$currentPackage

### packages outside slackware repository

currentPackage=p7zip
version=17.04
mkdir $MODULEPATH/$currentPackage && cd $MODULEPATH/$currentPackage
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/system/$currentPackage/ -A * || exit 1
wget https://github.com/flyfishzy/p7zip/archive/refs/tags/v$version.tar.gz -O $currentPackage-$version.tar.gz || exit 1
sed -i "s|make |make -j8 |g" ./$currentPackage.SlackBuild
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" $currentPackage.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" $currentPackage.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" $currentPackage.SlackBuild
sh $currentPackage.SlackBuild || exit 1
mv /tmp/$currentPackage*.t?z $MODULEPATH/packages
rm -fr $MODULEPATH/$currentPackage

currentPackage=pptp
version=1.10.0
mkdir $MODULEPATH/$currentPackage && cd $MODULEPATH/$currentPackage
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/network/$currentPackage/ -A * || exit 1
wget http://downloads.sourceforge.net/pptpclient/pptp-$version.tar.gz || exit 1
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" $currentPackage.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" $currentPackage.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" $currentPackage.SlackBuild
sh $currentPackage.SlackBuild || exit 1
mv /tmp/$currentPackage*.t?z $MODULEPATH/packages
rm -fr $MODULEPATH/$currentPackage

currentPackage=TLP
mkdir $MODULEPATH/$currentPackage && cd $MODULEPATH/$currentPackage
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/system/$currentPackage/ -A * || exit 1
info=`DownloadLatestFromGithub "linrunner" "TLP"`
version=${info#* }
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" $currentPackage.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" $currentPackage.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" $currentPackage.SlackBuild
sh $currentPackage.SlackBuild || exit 1
mv /tmp/$currentPackage*.t?z $MODULEPATH/packages
rm -fr $MODULEPATH/$currentPackage

currentPackage=unrar
version=6.1.7
mkdir $MODULEPATH/$currentPackage && cd $MODULEPATH/$currentPackage
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/system/$currentPackage/ -A * || exit 1
wget https://www.rarlab.com/rar/unrarsrc-$version.tar.gz || exit 1
sed -i "s|make |make -j8 |g" ./$currentPackage.SlackBuild
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" $currentPackage.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" $currentPackage.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" $currentPackage.SlackBuild
sh $currentPackage.SlackBuild || exit 1
mv /tmp/$currentPackage*.t?z $MODULEPATH/packages
rm -fr $MODULEPATH/$currentPackage

currentPackage=webfs
version=1.21
mkdir $MODULEPATH/$currentPackage && cd $MODULEPATH/$currentPackage
wget https://www.kraxel.org/releases/webfs/webfs-$version.tar.gz || exit 1
tar xvf $currentPackage*.tar.gz && cd $currentPackage-$version || exit 1
make -j8 install DESTDIR=$MODULEPATH/$currentPackage/package || exit 1
cd $MODULEPATH/$currentPackage/package
/sbin/makepkg -l y -c n $MODULEPATH/packages/$currentPackage-$version-$ARCH-1.txz
rm -fr $MODULEPATH/$currentPackage

# fix me: they have a current filename convention: http://wgetpaste.zlin.dk/wgetpaste-current.tar.bz2
currentPackage=wgetpaste
version=2.30
mkdir $MODULEPATH/$currentPackage && cd $MODULEPATH/$currentPackage
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/accessibility/$currentPackage/ -A * || exit 1
wget http://wgetpaste.zlin.dk/$currentPackage-$version.tar.bz2
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" $currentPackage.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" $currentPackage.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" $currentPackage.SlackBuild
sh $currentPackage.SlackBuild || exit 1
mv /tmp/$currentPackage*.t?z $MODULEPATH/packages
rm -fr $MODULEPATH/$currentPackage

### fake root

cd $MODULEPATH/packages && ROOT=./ installpkg *.t?z
rm *.t?z

### install additional packages, including porteux utils

InstallAdditionalPackages

### install certificates -- requires perl installed

TEMPBUNDLE="$(mktemp -t "${CERTBUNDLE}.tmp.XXXXXX")"

cd $MODULEPATH/packages/etc/ssl/certs
cp -s ../../../usr/share/ca-certificates/mozilla/* .

for i in *.crt; do
	sed -e '$a\' "$i" >> "$TEMPBUNDLE";
	rename crt pem "$i"
done

c_rehash . > /dev/null

chmod 0644 "$TEMPBUNDLE"
mv -f "$TEMPBUNDLE" ca-certificates.crt

### install kbd fonts

cd $MODULEPATH/packages
find usr/share/kbd -type f -name "*.gz" -exec gunzip {} \;

### fix symlinks

cd $MODULEPATH/packages/bin
cp -s fusermount3 fusermount
cd $MODULEPATH/packages/usr/bin
cp -s python3 python

### fix permissions

cd $MODULEPATH/packages

chmod 755 etc/rc.d/rc.networkmanager
chmod 644 etc/rc.d/rc.fuse3
chmod 644 etc/rc.d/rc.loop
chmod 644 etc/rc.d/rc.sshd
chmod 644 etc/rc.d/rc.wireless

### copy build files to 05-devel

CopyToDevel

### module clean up

cd $MODULEPATH/packages/

rm -R lib/systemd
rm -R lib64/pkgconfig
rm -R mnt/*
rm -R usr/etc
rm -R usr/lib/ldscripts
rm -R usr/lib/modprobe.d
rm -R usr/lib/udev
rm -R usr/lib64/locale/C.utf8
rm -R usr/lib64/python2.7
rm -R usr/lib64/python3.9/idlelib
rm -R usr/lib64/python3.9/lib2to3
rm -R usr/lib64/python3.9/site-packages/demo
rm -R usr/lib64/python3.9/turtledemo
rm -R usr/lib64/systemd
rm -R usr/local/etc
rm -R usr/local/games
rm -R usr/local/include
rm -R usr/local/info
rm -R usr/local/lib
rm -R usr/local/lib64
rm -R usr/local/man
rm -R usr/local/sbin
rm -R usr/local/share
rm -R usr/local/src
rm -R usr/share/applications
rm -R usr/share/info
rm -R usr/share/kbd/keymaps/amiga
rm -R usr/share/kbd/keymaps/atari
rm -R usr/share/kbd/keymaps/mac
rm -R usr/share/kbd/keymaps/ppc
rm -R usr/share/kbd/keymaps/sun
rm -R usr/share/lynx
rm -R usr/share/mc/examples
rm -R usr/share/mc/help
rm -R usr/share/mc/hints
rm -R usr/share/terminfo/1
rm -R usr/share/terminfo/2
rm -R usr/share/terminfo/3
rm -R usr/share/terminfo/4
rm -R usr/share/terminfo/5
rm -R usr/share/terminfo/6
rm -R usr/share/terminfo/7
rm -R usr/share/terminfo/8
rm -R usr/share/terminfo/9
rm -R usr/share/terminfo/A
rm -R usr/share/terminfo/E
rm -R usr/share/terminfo/L
rm -R usr/share/terminfo/M
rm -R usr/share/terminfo/N
rm -R usr/share/terminfo/P
rm -R usr/share/terminfo/Q
rm -R usr/share/terminfo/X
rm -R usr/share/terminfo/b
rm -R usr/share/terminfo/c
rm -R usr/share/terminfo/e
rm -R usr/share/terminfo/f
rm -R usr/share/terminfo/g
rm -R usr/share/terminfo/h
rm -R usr/share/terminfo/i
rm -R usr/share/terminfo/j
rm -R usr/share/terminfo/k
rm -R usr/share/terminfo/m
rm -R usr/share/terminfo/n
rm -R usr/share/terminfo/o
rm -R usr/share/terminfo/p
rm -R usr/share/terminfo/q
rm -R usr/share/terminfo/s
rm -R usr/share/terminfo/t
rm -R usr/share/terminfo/u
rm -R usr/share/terminfo/w
rm -R usr/share/terminfo/z
rm -R usr/x86_64-slackware-linux
rm etc/init.d
rm etc/ld.so.cache
rm etc/motd
rm etc/openvpn/sample-config-files
rm etc/rc.d/rc.inet2
rm usr/bin/js[0-9]*
rm usr/bin/smbtorture
rm usr/libexec/samba/rpcd_*
rm usr/local/bin/webfsd
find usr/lib64/python* -type d -name 'test' -prune -exec rm -rf {} +
find usr/lib64/python* -type d -name 'tests' -prune -exec rm -rf {} +

mv $MODULEPATH/packages/lib64 $MODULEPATH/ # move out /lib64 so we can strip safely
GenericStrip
mv $MODULEPATH/lib64 $MODULEPATH/packages/

### copy cache files

PrepareFilesForCache

### finalize

Finalize
