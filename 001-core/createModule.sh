#!/bin/bash

MODULENAME=001-core

source "$PWD/../builder-utils/setflags.sh"

SetFlags "$MODULENAME"

source "$BUILDERUTILSPATH/cachefiles.sh"
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

if [ $SLACKWAREVERSION != "current" ]; then
	currentPackage=meson
	sh $SCRIPTPATH/../common/${currentPackage}/${currentPackage}.SlackBuild || exit 1
	upgradepkg --install-new --reinstall $MODULEPATH/packages/${currentPackage}-*.txz
	rm -fr $MODULEPATH/${currentPackage}
	rm $MODULEPATH/packages/meson-*.txz
fi

installpkg $MODULEPATH/packages/libxml2*.txz > /dev/null 2>&1

installpkg $MODULEPATH/packages/llvm*.txz > /dev/null 2>&1
rm $MODULEPATH/packages/llvm*.txz > /dev/null 2>&1

# required to build procps-ng
installpkg $MODULEPATH/packages/ncurses*.txz || exit 1

# core deps
for package in \
	zstd \
	squashfs-tools \
	sysvinit \
	duktape \
	polkit \
; do
sh $SCRIPTPATH/deps/${package}/${package}.SlackBuild || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# core extras
for package in \
	fastfetch \
	7zip \
	rpm \
	procps-ng \
; do
sh $SCRIPTPATH/extras/${package}/${package}.SlackBuild || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# required by other modules
installpkg $MODULEPATH/packages/procps-ng*.txz
installpkg $MODULEPATH/packages/squashfs-tools*.txz
installpkg $MODULEPATH/packages/zstd*.txz

## packages that require specific stripping

if [ $SLACKWAREVERSION == "current" ]; then
	currentPackage=avahi
	mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
	mv ../packages/${currentPackage}-[0-9]* .
	packageFileName=$(ls * -a | rev | cut -d . -f 2- | rev)
	ROOT=./ installpkg ${currentPackage}-*.txz
	mkdir ${currentPackage}-stripped
	cp --parents -P usr/lib${SYSTEMBITS}/libavahi-client.* ${currentPackage}-stripped/
	cp --parents -P usr/lib${SYSTEMBITS}/libavahi-common.* ${currentPackage}-stripped/
	cp --parents -P usr/lib${SYSTEMBITS}/libavahi-glib.* ${currentPackage}-stripped/
	cd ${currentPackage}-stripped
	makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${packageFileName}_stripped.txz > /dev/null 2>&1
	rm -fr $MODULEPATH/${currentPackage}

	currentPackage=glibc
	mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
	mv $MODULEPATH/packages/${currentPackage}-[0-9]* .
	packageFileName=$(ls * -a | rev | cut -d . -f 2- | rev)
	ROOT=./ installpkg ${currentPackage}-*.txz && rm ${currentPackage}-*.txz
	rm usr/include/gnu/*-32.h
	rm usr/libexec/getconf/*ILP32*
	rm var/log/packages
	rm var/log/scripts
	rm var/log/setup
	rm -fr lib/
	rm -fr usr/lib/
	rm -fr var/lib/pkgtools
	rm -fr var/log/pkgtools
	mkdir ${currentPackage}-stripped
	rsync -av * ${currentPackage}-stripped/ --exclude=${currentPackage}-stripped/
	cd ${currentPackage}-stripped
	makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${packageFileName}_stripped.txz > /dev/null 2>&1
	rm -fr $MODULEPATH/${currentPackage}
fi

currentPackage=aaa_libraries
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv ../packages/${currentPackage}-[0-9]* .
packageFileName=$(ls * -a | rev | cut -d . -f 2- | rev)
mv ../packages/gcc-* . # required because aaa_libraries quite often is not in sync with gcc/g++
ROOT=./ installpkg ${currentPackage}*.txz
rm usr/lib${SYSTEMBITS}/libslang.so.1*
rm usr/lib${SYSTEMBITS}/libstdc++.so*
ROOT=./ installpkg gcc-*.txz
mkdir ${currentPackage}-stripped
cp --parents -P lib${SYSTEMBITS}/libfuse.* ${currentPackage}-stripped/
cp --parents -P lib${SYSTEMBITS}/libgssapi_krb5.* ${currentPackage}-stripped/
cp --parents -P lib${SYSTEMBITS}/libk5crypto.* ${currentPackage}-stripped/
cp --parents -P lib${SYSTEMBITS}/libkrb5.* ${currentPackage}-stripped/
cp --parents -P lib${SYSTEMBITS}/libkrb5support.* ${currentPackage}-stripped/
cp --parents -P lib${SYSTEMBITS}/libsigsegv.* ${currentPackage}-stripped/
cp --parents -P usr/lib${SYSTEMBITS}/libatomic.* ${currentPackage}-stripped/
cp --parents -P usr/lib${SYSTEMBITS}/libcares.* ${currentPackage}-stripped/
cp --parents -P usr/lib${SYSTEMBITS}/libcups.* ${currentPackage}-stripped/
cp --parents -P usr/lib${SYSTEMBITS}/libgcc_s.* ${currentPackage}-stripped/
cp --parents -P usr/lib${SYSTEMBITS}/libgmp.* ${currentPackage}-stripped/
cp --parents -P usr/lib${SYSTEMBITS}/libgmpxx.* ${currentPackage}-stripped/
cp --parents -P usr/lib${SYSTEMBITS}/libgomp.* ${currentPackage}-stripped/
cp --parents -P usr/lib${SYSTEMBITS}/libltdl.* ${currentPackage}-stripped/
cp --parents -P usr/lib${SYSTEMBITS}/libslang.* ${currentPackage}-stripped/
cp --parents -P usr/lib${SYSTEMBITS}/libstdc++.* ${currentPackage}-stripped/
cd ${currentPackage}-stripped/usr/lib${SYSTEMBITS}
cp -fs $(basename $(readlink -f $(command ls libcares.so* | head -n1))) libcares.so
cp -fs $(basename $(readlink -f $(command ls libcups.so* | head -n1))) libcups.so
cp -fs $(basename $(readlink -f $(command ls libgmp.so* | head -n1))) libgmp.so
cp -fs $(basename $(readlink -f $(command ls libgmpxx.so* | head -n1))) libgmpxx.so
cp -fs $(basename $(readlink -f $(command ls libltdl.so* | head -n1))) libltdl.so
cp -fs $(basename $(readlink -f $(command ls libslang.so* | head -n1))) libslang.so
cd $MODULEPATH/${currentPackage}/${currentPackage}-stripped
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${packageFileName}_stripped.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=binutils
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv ../packages/${currentPackage}-[0-9]* .
packageFileName=$(ls * -a | rev | cut -d . -f 2- | rev)
ROOT=./ installpkg ${currentPackage}-*.txz
mkdir ${currentPackage}-stripped
cp --parents usr/bin/ar ${currentPackage}-stripped/
cp --parents usr/bin/strip ${currentPackage}-stripped/
cp --parents -P usr/lib$SYSTEMBITS/libbfd* ${currentPackage}-stripped/
cp --parents -P usr/lib$SYSTEMBITS/libsframe* ${currentPackage}-stripped/
cd ${currentPackage}-stripped
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${packageFileName}_stripped.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=fftw
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv ../packages/${currentPackage}-[0-9]* .
packageFileName=$(ls * -a | rev | cut -d . -f 2- | rev)
ROOT=./ installpkg ${currentPackage}-*.txz
mkdir ${currentPackage}-stripped
cp --parents -P usr/lib${SYSTEMBITS}/libfftw3.* ${currentPackage}-stripped/
cp --parents -P usr/lib${SYSTEMBITS}/libfftw3f.* ${currentPackage}-stripped/
cd ${currentPackage}-stripped
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${packageFileName}_stripped.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=ntp
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv ../packages/${currentPackage}-[0-9]* .
packageFileName=$(ls * -a | rev | cut -d . -f 2- | rev)
ROOT=./ installpkg ${currentPackage}-*.txz
mkdir ${currentPackage}-stripped
cp --parents -P usr/bin/ntpdate ${currentPackage}-stripped/
cp --parents -P usr/sbin/ntpdate ${currentPackage}-stripped/
cp --parents -P usr/sbin/ntpd ${currentPackage}-stripped/
cd ${currentPackage}-stripped
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${packageFileName}_stripped.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=openldap
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv ../packages/${currentPackage}-[0-9]* .
packageFileName=$(ls * -a | rev | cut -d . -f 2- | rev)
ROOT=./ installpkg ${currentPackage}-*.txz
mkdir ${currentPackage}-stripped
cp --parents etc/openldap/ldap.conf.new ${currentPackage}-stripped/
mv ${currentPackage}-stripped/etc/openldap/ldap.conf.new ${currentPackage}-stripped/etc/openldap/ldap.conf
cp --parents usr/include/* ${currentPackage}-stripped/
cp --parents -P usr/lib$SYSTEMBITS/libl* ${currentPackage}-stripped/
cd ${currentPackage}-stripped
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${packageFileName}_stripped.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

### fake root

cd $MODULEPATH/packages && ROOT=./ installpkg *.t?z
rm *.t?z

### install additional packages, including porteux utils

InstallAdditionalPackages

### install certificates -- requires perl

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

### set ctrl+alt+del to not show any error in the terminal

sed -i '/^ca::ctrlaltdel/c\ca::ctrlaltdel:/sbin/shutdown -r now 2>/dev/null' $MODULEPATH/packages/etc/inittab

### remove pwquality dependency

sed -i "s|password    requisite     pam_pwquality.so|#password    requisite     pam_pwquality.so|g" $MODULEPATH/packages/etc/pam.d/system-auth
sed -i "s|try_first_pass use_authtok||g" $MODULEPATH/packages/etc/pam.d/system-auth

### remove fake curl deps

sed -i "s|,mit-krb5-gssapi||g" $MODULEPATH/packages/usr/lib64/pkgconfig/libcurl.pc
sed -i "s|,libcares||g" $MODULEPATH/packages/usr/lib64/pkgconfig/libcurl.pc

### set NetworkManager to use internal dhcp

sed -i "s|dhcp=dhclient|dhcp=internal|g" $MODULEPATH/packages/etc/NetworkManager/NetworkManager.conf || exit 1
sed -i "s|#dhcp=internal|dhcp=internal|g" $MODULEPATH/packages/etc/NetworkManager/conf.d/00-dhcp-client.conf || exit 1

### fix timeconfig missing folder

sed -i '/^TMP=\/var\/log\/setup\/tmp$/a [ ! -d \$TMP ] && mkdir -p \$TMP' $MODULEPATH/packages/usr/sbin/timeconfig

### fix symlinks

cd $MODULEPATH/packages/bin
cp -s fusermount3 fusermount
cd $MODULEPATH/packages/usr/bin
cp -s python3 python > /dev/null 2>&1

### set CPU governor to performance -- only in stable because current is already doing it

if [ $SLACKWAREVERSION != "current" ]; then
	cd $MODULEPATH/packages
	patch -p0 < $SCRIPTPATH/extras/rc.cpufreq.patch
fi

### update version

echo "PorteuX-v${PORTEUXVERSION}-${PORTEUXBUILD}" > $MODULEPATH/packages/etc/porteux-version
sed -i "s|version|v${PORTEUXVERSION}|" $MODULEPATH/packages/etc/issue
sed -i "s|version|v${PORTEUXVERSION}|" $MODULEPATH/packages/etc/issue-openbox
sed -i "s|^VERSION=.*|VERSION=\"${PORTEUXVERSION}\"|" $MODULEPATH/packages/etc/os-release
sed -i "s|^VERSION_ID=.*|VERSION_ID=${PORTEUXVERSION}|" $MODULEPATH/packages/etc/os-release
sed -i "s|^PRETTY_NAME=.*|PRETTY_NAME=\"PorteuX ${PORTEUXVERSION} ${PORTEUXBUILD}\"|" $MODULEPATH/packages/etc/os-release
sed -i "s|^CPE_NAME=.*|CPE_NAME=\"cpe:/o:porteux:porteux_linux:${PORTEUXVERSION}\"|" $MODULEPATH/packages/etc/os-release
sed -i "0,/PorteuX/s|PorteuX.*|PorteuX v${PORTEUXVERSION}|" $SCRIPTPATH/../boot/boot/syslinux/help.txt

### set permissions

cd $MODULEPATH/packages

chmod 644 etc/rc.d/rc.bluetooth
chmod 644 etc/rc.d/rc.crond
chmod 644 etc/rc.d/rc.fuse3
chmod 644 etc/rc.d/rc.inet1
chmod 644 etc/rc.d/rc.loop
chmod 755 etc/rc.d/rc.networkmanager
chmod 644 etc/rc.d/rc.sshd
chmod 644 etc/rc.d/rc.wireless

### copy build files to 05-devel

CopyToDevel

### copy language files to 08-multilanguage

CopyToMultiLanguage

### module clean up

cd $MODULEPATH/packages/

{
rm etc/init.d
rm etc/motd
rm etc/termcap
rm etc/openvpn/sample-config-files
rm etc/rc.d/rc.inet2
rm usr/bin/smbtorture
rm usr/bin/wpa_gui
rm usr/dict
rm usr/lib${SYSTEMBITS}/libicutest.*
rm usr/libexec/samba/rpcd_*
rm usr/share/i18n/locales/C
rm usr/share/pixmaps/wpa_gui.png
rm var/db/Makefile

rm -fr boot
rm -fr lib${SYSTEMBITS}/pkgconfig
rm -fr lib/systemd
rm -fr mnt/*
rm -fr usr/etc
rm -fr usr/lib${SYSTEMBITS}/guile
rm -fr usr/lib${SYSTEMBITS}/krb*/plugins
rm -fr usr/lib${SYSTEMBITS}/locale/C.utf8
rm -fr usr/lib${SYSTEMBITS}/sasl2
rm -fr usr/lib${SYSTEMBITS}/services
rm -fr usr/lib${SYSTEMBITS}/systemd
rm -fr usr/lib/ldscripts
rm -fr usr/lib/modprobe.d
rm -fr usr/lib*/python*/__phello__
rm -fr usr/lib*/python*/config-*-x86_64-linux-gnu
rm -fr usr/lib*/python*/ensurepip
rm -fr usr/lib*/python*/idlelib
rm -fr usr/lib*/python*/lib2to3
rm -fr usr/lib*/python*/site-packages/demo
rm -fr usr/lib*/python*/site-packages/msi
rm -fr usr/lib*/python*/site-packages/peg_generator
rm -fr usr/lib*/python*/turtledemo
rm -fr usr/lib*/python*/unittest/__pycache__/
rm -fr usr/lib/udev
rm -fr usr/local
rm -fr usr/share/applications
rm -fr usr/share/common-lisp
rm -fr usr/share/glib-2.0/gdb
rm -fr usr/share/glib-2.0/gettext
rm -fr usr/share/glib-2.0/valgrind
rm -fr usr/share/guile
rm -fr usr/share/icu
rm -fr usr/share/info
rm -fr usr/share/kbd/keymaps/amiga
rm -fr usr/share/kbd/keymaps/atari
rm -fr usr/share/kbd/keymaps/mac
rm -fr usr/share/kbd/keymaps/ppc
rm -fr usr/share/kbd/keymaps/sun
rm -fr usr/share/lynx
rm -fr usr/share/mc/examples
rm -fr usr/share/mc/help
rm -fr usr/share/mc/hints
rm -fr usr/share/terminfo/[0-9]
rm -fr usr/share/terminfo/[A-Z]
rm -fr usr/share/terminfo/b
rm -fr usr/share/terminfo/c
rm -fr usr/share/terminfo/e
rm -fr usr/share/terminfo/f
rm -fr usr/share/terminfo/g
rm -fr usr/share/terminfo/h
rm -fr usr/share/terminfo/i
rm -fr usr/share/terminfo/j
rm -fr usr/share/terminfo/k
rm -fr usr/share/terminfo/m
rm -fr usr/share/terminfo/n
rm -fr usr/share/terminfo/o
rm -fr usr/share/terminfo/p
rm -fr usr/share/terminfo/q
rm -fr usr/share/terminfo/s
rm -fr usr/share/terminfo/t
rm -fr usr/share/terminfo/u
rm -fr usr/share/terminfo/w
rm -fr usr/share/terminfo/z
rm -fr usr/x86_64-slackware-linux
rm -fr var/mail
rm -fr var/spool/mail

if [ $SLACKWAREVERSION != "current" ]; then
	rm usr/lib${SYSTEMBITS}/libqgpgmeqt6.so*
	rm -fr usr/include/qgpgme-qt6*
else
	rm usr/lib${SYSTEMBITS}/libqgpgme.so*
	rm -fr usr/include/qgpgme-qt5*
fi

find usr/lib${SYSTEMBITS}/python* -type d -name 'test' -prune -exec rm -rf {} +
find usr/lib${SYSTEMBITS}/python* -type d -name 'tests' -prune -exec rm -rf {} +
} >/dev/null 2>&1

# move out libc because it can't be stripped at all
mv $MODULEPATH/packages/lib${SYSTEMBITS}/libc.so* $MODULEPATH/
mv $MODULEPATH/packages/lib${SYSTEMBITS}/libc-* $MODULEPATH/
GenericStrip
mv $MODULEPATH/libc.so* $MODULEPATH/packages/lib${SYSTEMBITS}
mv $MODULEPATH/libc-* $MODULEPATH/packages/lib${SYSTEMBITS}

# move out things that don't support aggressive stripping
mv $MODULEPATH/packages/lib${SYSTEMBITS} $MODULEPATH/
AggressiveStrip
mv $MODULEPATH/lib${SYSTEMBITS} $MODULEPATH/packages/

### copy cache files

PrepareFilesForCache

### finalize

Finalize
