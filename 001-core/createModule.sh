#!/bin/bash

MODULENAME=001-core

source "$PWD/../builder-utils/setflags.sh"

SetFlags "$MODULENAME"

source "$BUILDERUTILSPATH/cachefiles.sh"
source "$BUILDERUTILSPATH/downloadfromslackware.sh"
source "$BUILDERUTILSPATH/genericstrip.sh"
source "$BUILDERUTILSPATH/helper.sh"
source "$BUILDERUTILSPATH/latestfromgithub.sh"

if ! isRoot; then
	echo "Please enter admin's password below:"
	su -c "$0 $1"
	exit
fi

### create module folder

mkdir -p $MODULEPATH/packages > /dev/null 2>&1

### download packages from slackware repositories

DownloadFromSlackware

### packages outside slackware repository

installpkg $MODULEPATH/packages/libxml2*.txz > /dev/null 2>&1

if [ $SLACKWAREVERSION != "current" ]; then
	# required by new wireplumber
	currentPackage=lua
	mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
	wget -r -nd --no-parent -l1 ${SLACKWAREDOMAIN}/slackware/slackware64-current/source/d/${currentPackage}/ || exit 1
	sed -i "s|-O[23].*|$GCCFLAGS -ffat-lto-objects -fPIC\"|g" ${currentPackage}.SlackBuild
	sh ${currentPackage}.SlackBuild || exit 1
	mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
	installpkg $MODULEPATH/packages/lua*.txz
	rm -fr $MODULEPATH/${currentPackage}
	
	currentPackage=meson
	sh $SCRIPTPATH/../common/${currentPackage}/${currentPackage}.SlackBuild || exit 1
	/sbin/upgradepkg --install-new --reinstall $MODULEPATH/packages/${currentPackage}-*.txz
	rm -fr $MODULEPATH/${currentPackage}
	rm $MODULEPATH/packages/meson-*.txz
fi

currentPackage=squashfs-tools
sh $SCRIPTPATH/extras/${currentPackage}/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=sysvinit
sh $SCRIPTPATH/extras/${currentPackage}/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=zstd
sh $SCRIPTPATH/extras/${currentPackage}/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=hyfetch
mkdir -p $MODULEPATH/${currentPackage}/package/usr/bin && cd $MODULEPATH/${currentPackage}
wget https://github.com/hykilpikonna/${currentPackage}/archive/refs/heads/master.tar.gz -O ${currentPackage}.tar.gz || exit 1
tar xvf ${currentPackage}.tar.gz && rm ${currentPackage}.tar.gz || exit 1
cp -p */neofetch package/usr/bin
sed -i "s|has pkginfo && tot pkginfo -i|#has pkginfo && tot pkginfo -i|g" package/usr/bin/neofetch
chown 755 package/usr/bin/neofetch
chmod +x package/usr/bin/neofetch
version=$(date -r package/usr/bin/neofetch +%Y%m%d)
cd $MODULEPATH/${currentPackage}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-$version-noarch-1.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

installpkg $MODULEPATH/packages/llvm*.txz > /dev/null 2>&1
rm $MODULEPATH/packages/llvm*.txz > /dev/null 2>&1

currentPackage=7zip
sh $SCRIPTPATH/extras/${currentPackage}/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=unrar
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
version=$(curl -s https://www.rarlab.com/rar_add.htm | grep "source" | grep -o 'unrarsrc-[0-9.]\+\.tar\.gz' | cut -d "-" -f 2 | sed 's/\.tar\.gz$//')
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/system/${currentPackage}/ -A * || exit 1
wget https://www.rarlab.com/rar/unrarsrc-$version.tar.gz || exit 1
sed -i "s|-j1 ||g" ${currentPackage}.SlackBuild
sed -i "s|make |make -j${NUMBERTHREADS} |g" ${currentPackage}.SlackBuild
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" ${currentPackage}.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" ${currentPackage}.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" ${currentPackage}.SlackBuild
sed -i "s|-O[23].*|$GCCFLAGS -fPIC\"|g" ${currentPackage}.SlackBuild
sed -i "s|libunrar.so.5|libunrar.so.7|g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
rm -fr $MODULEPATH/${currentPackage}

# temporary to build procps-ng
installpkg $MODULEPATH/packages/ncurses*.txz || exit 1

currentPackage=procps-ng
sh $SCRIPTPATH/extras/${currentPackage}/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=duktape
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent -l1 ${SLACKWAREDOMAIN}/slackware/slackware64-current/source/l/${currentPackage}/ || exit 1
sed -i "s|-O[23].*|$GCCFLAGS\"|g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
rm -fr $MODULEPATH/${currentPackage}

currentPackage=polkit
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent -l1 ${SLACKWAREDOMAIN}/slackware/slackware64-current/source/l/${currentPackage}/ || exit 1
sed -i "s|-O[23].*|${GCCFLAGS/ -ffunction-sections -fdata-sections/}\"|g" ${currentPackage}.SlackBuild
sed -i "s|Dman=true|Dman=false|g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
rm -fr $MODULEPATH/${currentPackage}

### packages that require specific stripping

if [ $SLACKWAREVERSION == "current" ]; then
	currentPackage=avahi
	mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
	mv ../packages/${currentPackage}-[0-9]* .
	version=`ls * -a | cut -d'-' -f2- | sed 's/\.txz$//'`
	ROOT=./ installpkg ${currentPackage}-*.txz && rm ${currentPackage}-*.txz
	mkdir ${currentPackage}-stripped-$version
	cp --parents -P usr/lib${SYSTEMBITS}/libavahi-client.* ${currentPackage}-stripped-$version/
	cp --parents -P usr/lib${SYSTEMBITS}/libavahi-common.* ${currentPackage}-stripped-$version/
	cp --parents -P usr/lib${SYSTEMBITS}/libavahi-glib.* ${currentPackage}-stripped-$version/
	cd $MODULEPATH/${currentPackage}/${currentPackage}-stripped-$version
	makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-stripped-$version-1.txz > /dev/null 2>&1
	rm -fr $MODULEPATH/${currentPackage}

	currentPackage=glibc
	mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
	mv ../packages/${currentPackage}-[0-9]* .
	version=`ls * -a | cut -d'-' -f2- | sed 's/\.txz$//'`
	ROOT=./ installpkg ${currentPackage}-*.txz && rm ${currentPackage}-*.txz
	rm -fr var/lib/pkgtools
	rm -fr var/log
	rm -fr lib/
	rm -fr usr/lib/
	rm usr/include/gnu/*-32.h
	rm usr/libexec/getconf/*ILP32*
	mkdir ${currentPackage}-stripped-$version
	rsync -av --exclude=${currentPackage}-stripped-$version/ * ${currentPackage}-stripped-$version/
	cd $MODULEPATH/${currentPackage}/${currentPackage}-stripped-$version
	makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-stripped-$version-1.txz > /dev/null 2>&1
	rm -fr $MODULEPATH/${currentPackage}
fi

currentPackage=aaa_libraries
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv ../packages/${currentPackage}-[0-9]* .
version=`ls * -a | cut -d'-' -f2- | sed 's/\.txz$//'`
mv ../packages/gcc-* . # required because aaa_libraries quite often is not in sync with gcc/g++
ROOT=./ installpkg ${currentPackage}*.txz && rm ${currentPackage}-*.txz
rm usr/lib${SYSTEMBITS}/libslang.so.1*
rm usr/lib${SYSTEMBITS}/libstdc++.so*
ROOT=./ installpkg gcc-*.txz
mkdir ${currentPackage}-stripped-$version
cp --parents -P lib${SYSTEMBITS}/libfuse.* ${currentPackage}-stripped-$version/
cp --parents -P lib${SYSTEMBITS}/libgssapi_krb5.* ${currentPackage}-stripped-$version/
cp --parents -P lib${SYSTEMBITS}/libk5crypto.* ${currentPackage}-stripped-$version/
cp --parents -P lib${SYSTEMBITS}/libkrb5.* ${currentPackage}-stripped-$version/
cp --parents -P lib${SYSTEMBITS}/libkrb5support.* ${currentPackage}-stripped-$version/
cp --parents -P lib${SYSTEMBITS}/libsigsegv.* ${currentPackage}-stripped-$version/
cp --parents -P usr/lib${SYSTEMBITS}/libatomic.* ${currentPackage}-stripped-$version/
cp --parents -P usr/lib${SYSTEMBITS}/libcares.* ${currentPackage}-stripped-$version/
cp --parents -P usr/lib${SYSTEMBITS}/libcups.* ${currentPackage}-stripped-$version/
cp --parents -P usr/lib${SYSTEMBITS}/libgcc_s.* ${currentPackage}-stripped-$version/
cp --parents -P usr/lib${SYSTEMBITS}/libgmp.* ${currentPackage}-stripped-$version/
cp --parents -P usr/lib${SYSTEMBITS}/libgmpxx.* ${currentPackage}-stripped-$version/
cp --parents -P usr/lib${SYSTEMBITS}/libgomp.* ${currentPackage}-stripped-$version/
cp --parents -P usr/lib${SYSTEMBITS}/libltdl.* ${currentPackage}-stripped-$version/
cp --parents -P usr/lib${SYSTEMBITS}/libslang.* ${currentPackage}-stripped-$version/
cp --parents -P usr/lib${SYSTEMBITS}/libstdc++.* ${currentPackage}-stripped-$version/
cd ${currentPackage}-stripped-$version/usr/lib${SYSTEMBITS}
cp -fs libcares.so* libcares.so
cp -fs libcares.so libcares.so.2
cp -fs libcups.so* libcups.so
cp -fs libgmp.so* libgmp.so
cp -fs libgmpxx.so* libgmpxx.so
cp -fs libltdl.so* libltdl.so
cp -fs libslang.so* libslang.so
cd $MODULEPATH/${currentPackage}/${currentPackage}-stripped-$version
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-stripped-$version-1.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=binutils
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv ../packages/${currentPackage}-[0-9]* .
version=`ls * -a | cut -d'-' -f2- | sed 's/\.txz$//'`
ROOT=./ installpkg ${currentPackage}-*.txz && rm ${currentPackage}-*.txz
mkdir ${currentPackage}-stripped-$version
cp --parents usr/bin/ar ${currentPackage}-stripped-$version/
cp --parents usr/bin/strip ${currentPackage}-stripped-$version/
cp --parents -P usr/lib$SYSTEMBITS/libbfd* ${currentPackage}-stripped-$version/
cp --parents -P usr/lib$SYSTEMBITS/libsframe* ${currentPackage}-stripped-$version/
cd $MODULEPATH/${currentPackage}/${currentPackage}-stripped-$version
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-stripped-$version-1.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=fftw
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv ../packages/${currentPackage}-[0-9]* .
version=`ls * -a | cut -d'-' -f2- | sed 's/\.txz$//'`
ROOT=./ installpkg ${currentPackage}-*.txz && rm ${currentPackage}-*.txz
mkdir ${currentPackage}-stripped-$version
cp --parents -P usr/lib${SYSTEMBITS}/libfftw3f.* ${currentPackage}-stripped-$version/
cd $MODULEPATH/${currentPackage}/${currentPackage}-stripped-$version
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-stripped-$version-1.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=ntp
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv ../packages/${currentPackage}-[0-9]* .
version=`ls * -a | cut -d'-' -f2- | sed 's/\.txz$//'`
ROOT=./ installpkg ${currentPackage}-*.txz && rm ${currentPackage}-*.txz
mkdir ${currentPackage}-stripped-$version
cp --parents -P usr/bin/ntpdate ${currentPackage}-stripped-$version/
cp --parents -P usr/sbin/ntpdate ${currentPackage}-stripped-$version/
cp --parents -P usr/sbin/ntpd ${currentPackage}-stripped-$version/
cd $MODULEPATH/${currentPackage}/${currentPackage}-stripped-$version
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-stripped-$version-1.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=openldap
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv ../packages/${currentPackage}-[0-9]* .
version=`ls * -a | cut -d'-' -f2- | sed 's/\.txz$//'`
ROOT=./ installpkg ${currentPackage}-*.txz && rm ${currentPackage}-*.txz
mkdir ${currentPackage}-stripped-$version
cp --parents etc/openldap/ldap.conf.new ${currentPackage}-stripped-$version/
mv ${currentPackage}-stripped-$version/etc/openldap/ldap.conf.new ${currentPackage}-stripped-$version/etc/openldap/ldap.conf
cp --parents usr/include/* ${currentPackage}-stripped-$version/
cp --parents -P usr/lib$SYSTEMBITS/libl* ${currentPackage}-stripped-$version/
cd $MODULEPATH/${currentPackage}/${currentPackage}-stripped-$version
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-stripped-$version-1.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

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

### set ctrl+alt+del to now show any error in the terminal

sed -i '/^ca::ctrlaltdel/c\ca::ctrlaltdel:/sbin/shutdown -r now 2>/dev/null' $MODULEPATH/packages/etc/inittab

### remove pwquality dependency

sed -i "s|password    requisite     pam_pwquality.so|#password    requisite     pam_pwquality.so|g" $MODULEPATH/packages/etc/pam.d/system-auth
sed -i "s|try_first_pass use_authtok||g" $MODULEPATH/packages/etc/pam.d/system-auth

### set NetworkManager to use internal dhcp

sed -i "s|dhcp=dhclient|dhcp=internal|g" $MODULEPATH/packages/etc/NetworkManager/NetworkManager.conf || exit 1
sed -i "s|#dhcp=internal|dhcp=internal|g" $MODULEPATH/packages/etc/NetworkManager/conf.d/00-dhcp-client.conf || exit 1

### fix symlinks

cd $MODULEPATH/packages/bin
cp -s fusermount3 fusermount
cd $MODULEPATH/packages/usr/bin
cp -s python3 python

### set CPU governor to performance -- only in stable because current is already doing it

if [ $SLACKWAREVERSION != "current" ]; then
	cd $MODULEPATH/packages
	patch -p0 < $SCRIPTPATH/extras/rc.cpufreq.patch
fi

### fix permissions

cd $MODULEPATH/packages

chmod 644 etc/rc.d/rc.bluetooth
chmod 644 etc/rc.d/rc.inet1
chmod 755 etc/rc.d/rc.networkmanager
chmod 644 etc/rc.d/rc.fuse3
chmod 644 etc/rc.d/rc.loop
chmod 644 etc/rc.d/rc.sshd
chmod 644 etc/rc.d/rc.wireless

### copy build files to 05-devel

CopyToDevel

### copy language files to 08-multilanguage

CopyToMultiLanguage

### module clean up

cd $MODULEPATH/packages/

{
rm -R boot
rm -R lib${SYSTEMBITS}/pkgconfig
rm -R lib/systemd
rm -R mnt/*
rm -R usr/etc
rm -R usr/include/qgpgme-qt*
rm -R usr/lib${SYSTEMBITS}/guile
rm -R usr/lib${SYSTEMBITS}/krb5/plugins
rm -R usr/lib${SYSTEMBITS}/locale/C.utf8
rm -R usr/lib${SYSTEMBITS}/sasl2
rm -R usr/lib${SYSTEMBITS}/services
rm -R usr/lib${SYSTEMBITS}/systemd
rm -R usr/lib/ldscripts
rm -R usr/lib/modprobe.d
rm -R usr/lib*/python2*
rm -R usr/lib*/python*/__phello__
rm -R usr/lib*/python*/config-*-x86_64-linux-gnu
rm -R usr/lib*/python*/ensurepip
rm -R usr/lib*/python*/idlelib
rm -R usr/lib*/python*/lib2to3
rm -R usr/lib*/python*/site-packages/demo
rm -R usr/lib*/python*/site-packages/msi
rm -R usr/lib*/python*/site-packages/peg_generator
rm -R usr/lib*/python*/turtledemo
rm -R usr/lib*/python*/unittest/__pycache__/
rm -R usr/lib/udev
rm -R usr/local
rm -R usr/share/applications
rm -R usr/share/common-lisp
rm -R usr/share/glib-2.0/gdb
rm -R usr/share/glib-2.0/gettext
rm -R usr/share/glib-2.0/valgrind
rm -R usr/share/guile
rm -R usr/share/icu
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
rm -R usr/share/terminfo/[0-9]
rm -R usr/share/terminfo/[A-Z]
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
rm -R var/mail
rm -R var/spool/mail

rm etc/init.d
rm etc/motd
rm etc/termcap
rm etc/openvpn/sample-config-files
rm etc/rc.d/rc.inet2
rm usr/bin/smbtorture
rm usr/bin/wpa_gui
rm usr/dict
rm usr/lib${SYSTEMBITS}/libduktaped.*
rm usr/lib${SYSTEMBITS}/libicutest.*
rm usr/lib${SYSTEMBITS}/libqgpgme*
rm usr/libexec/samba/rpcd_*
rm usr/share/i18n/locales/C
rm usr/share/pixmaps/wpa_gui.png
rm var/db/Makefile

find usr/lib${SYSTEMBITS}/python* -type d -name 'test' -prune -exec rm -rf {} +
find usr/lib${SYSTEMBITS}/python* -type d -name 'tests' -prune -exec rm -rf {} +
} >/dev/null 2>&1

# move out libc because it can't be stripped at all
mv $MODULEPATH/packages/lib${SYSTEMBITS}/libc.so* $MODULEPATH/
mv $MODULEPATH/packages/lib${SYSTEMBITS}/libc-* $MODULEPATH/
GenericStrip
mv $MODULEPATH/libc.so* $MODULEPATH/packages/lib${SYSTEMBITS}
mv $MODULEPATH/libc-* $MODULEPATH/packages/lib${SYSTEMBITS}

# move out stuff that can't be stripped
mv $MODULEPATH/packages/lib${SYSTEMBITS} $MODULEPATH/
AggressiveStrip
mv $MODULEPATH/lib${SYSTEMBITS} $MODULEPATH/packages/

### copy cache files

PrepareFilesForCache

### finalize

Finalize
