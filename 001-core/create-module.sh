#!/bin/bash

MODULE_NAME="001-core"

source "$PWD/../builder-utils/set-flags.sh"

set_flags "$MODULE_NAME"

source "$BUILDER_UTILS_PATH/cache-files.sh"
source "$BUILDER_UTILS_PATH/generic-strip.sh"
source "$BUILDER_UTILS_PATH/helper.sh"

elevate_if_needed "$0" "$@"

echo -e "Building ${MODULE_NAME} based on Slackware ${SLACKWARE_VERSION} ${ARCH}...\n"

### create module folder

mkdir -p $MODULE_PATH/packages > /dev/null 2>&1
cd $MODULE_PATH || exit 1

### download packages from slackware repository

bash $SCRIPT_PATH/download-packages.sh || exit 1

### critical libraries that need to be in sync with slackware repo before building

installpkg $MODULE_PATH/packages/glib2*.txz > /dev/null 2>&1
installpkg $MODULE_PATH/packages/libxml2*.txz > /dev/null 2>&1
installpkg $MODULE_PATH/packages/lua*.txz > /dev/null 2>&1

installpkg $MODULE_PATH/packages/llvm*.txz > /dev/null 2>&1
rm $MODULE_PATH/packages/llvm*.txz > /dev/null 2>&1

### packages outside slackware repository

# core deps
for package in \
	glibc \
	zlib-ng \
	zstd \
	squashfs-tools \
	duktape \
; do
bash $SCRIPT_PATH/deps/${package}/${package}.SlackBuild || exit 1
installpkg $MODULE_PATH/packages/${package}-[0-9]*.txz || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# required to build procps-ng
installpkg $MODULE_PATH/packages/ncurses*.txz || exit 1

# core extras
for package in \
	binutils \
	coreutils \
	sysvinit \
	procps-ng \
	polkit \
	ntfsprogs-plus \
	fastfetch \
	7zip \
	rpm \
; do
bash $SCRIPT_PATH/extras/${package}/${package}.SlackBuild || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

## packages that require specific stripping

strip_package avahi \
	usr/lib${SYSTEM_BITS}/libavahi-client.so* \
	usr/lib${SYSTEM_BITS}/libavahi-common.so* \
	usr/lib${SYSTEM_BITS}/libavahi-glib.so*

mkdir -p ${MODULE_PATH}/../05-devel/packages > /dev/null 2>&1
cp $MODULE_PATH/packages/binutils*.txz ${MODULE_PATH}/../05-devel/packages
strip_package binutils \
	usr/bin/ar \
	usr/bin/strip \
	usr/lib${SYSTEM_BITS}/libbfd*.so* \
	usr/lib${SYSTEM_BITS}/libsframe.so*

strip_package c-ares \
	usr/lib${SYSTEM_BITS}/libcares.so*

strip_package cups \
	usr/lib${SYSTEM_BITS}/libcups.so*

strip_package fftw \
	usr/lib${SYSTEM_BITS}/libfftw3.so* \
	usr/lib${SYSTEM_BITS}/libfftw3f.so*

strip_package fuse \
	lib${SYSTEM_BITS}/libfuse.so*

strip_package gcc \
	usr/lib${SYSTEM_BITS}/libatomic.so* \
	usr/lib${SYSTEM_BITS}/libgcc_s.so* \
	usr/lib${SYSTEM_BITS}/libgomp.so*

strip_package gcc-g++ \
	usr/lib${SYSTEM_BITS}/libstdc++.so*

strip_package gmp \
	usr/lib${SYSTEM_BITS}/libgmp.so*

strip_package krb5 \
	lib${SYSTEM_BITS}/libgssapi_krb5.so* \
	lib${SYSTEM_BITS}/libk5crypto.so* \
	lib${SYSTEM_BITS}/libkrb5.so* \
	lib${SYSTEM_BITS}/libkrb5support.so*

strip_package libtool \
	usr/lib${SYSTEM_BITS}/libltdl.so*

strip_package ntp \
	usr/bin/ntpdate \
	usr/sbin/ntpd \
	usr/sbin/ntpdate

strip_package openldap \
	etc/openldap/ldap.conf \
	usr/include/* \
	usr/lib${SYSTEM_BITS}/liblber.so* \
	usr/lib${SYSTEM_BITS}/libldap.so*

strip_package slang \
	usr/lib${SYSTEM_BITS}/libslang.so*

### fake root

install_packages

### install additional packages, including porteux utils

install_additional_packages

### install certificates -- requires perl

TEMP_BUNDLE="$(mktemp -t ca-certificates.crt.tmp.XXXXXX)"

cd $MODULE_PATH/packages/etc/ssl/certs || exit 1
cp -s ../../../usr/share/ca-certificates/mozilla/* .

sed -s -e '$a\' *.crt > "$TEMP_BUNDLE"
rename crt pem *.crt

c_rehash . > /dev/null

chmod 0644 "$TEMP_BUNDLE"
mv -f "$TEMP_BUNDLE" ca-certificates.crt

### extract kbd map files

cd $MODULE_PATH/packages || exit 1
find usr/share/kbd -type f -name "*.gz" -exec gunzip {} \;

### set ctrl+alt+del to not show any error in the terminal

sed -i '/^ca::ctrlaltdel/c\ca::ctrlaltdel:/sbin/shutdown -r now 2>/dev/null' $MODULE_PATH/packages/etc/inittab

### remove pwquality dependency

sed -i "s|password    requisite     pam_pwquality.so|#password    requisite     pam_pwquality.so|g" $MODULE_PATH/packages/etc/pam.d/system-auth
sed -i "s|try_first_pass use_authtok||g" $MODULE_PATH/packages/etc/pam.d/system-auth

### remove fake curl dependencies

sed -i "s|,mit-krb5-gssapi||g" $MODULE_PATH/packages/usr/lib${SYSTEM_BITS}/pkgconfig/libcurl.pc
sed -i "s|,libcares||g" $MODULE_PATH/packages/usr/lib${SYSTEM_BITS}/pkgconfig/libcurl.pc

### set NetworkManager to use internal dhcp

sed -i "s|dhcp=dhclient|dhcp=internal|g" $MODULE_PATH/packages/etc/NetworkManager/NetworkManager.conf || exit 1
sed -i "s|^dhcp=|#dhcp=|g" $MODULE_PATH/packages/etc/NetworkManager/conf.d/00-dhcp-client.conf || exit 1
sed -i "s|#dhcp=internal|dhcp=internal|g" $MODULE_PATH/packages/etc/NetworkManager/conf.d/00-dhcp-client.conf || exit 1

### fix udev rules

sed -i "s|^KERNEL==\"kvm\".*|KERNEL==\"kvm\", GROUP=\"kvm\", MODE=\"0666\", OPTIONS+=\"static_node=kvm\"|g" $MODULE_PATH/packages/lib/udev/rules.d/50-udev-default.rules || exit 1
sed -i "s|^KERNEL==\"vhost-net\".*|KERNEL==\"vhost-net\", GROUP=\"kvm\", MODE=\"0666\", OPTIONS+=\"static_node=vhost-net\"|g" $MODULE_PATH/packages/lib/udev/rules.d/50-udev-default.rules || exit 1

### fix timeconfig missing folder

sed -i '/^TMP=\/var\/log\/setup\/tmp$/a [ ! -d \$TMP ] && mkdir -p \$TMP' $MODULE_PATH/packages/usr/sbin/timeconfig

### fix symlinks

cd $MODULE_PATH/packages/bin || exit 1
cp -s fusermount3 fusermount
cd $MODULE_PATH/packages/usr/bin || exit 1
cp -s python3 python > /dev/null 2>&1
cd $MODULE_PATH/packages/usr/lib${SYSTEM_BITS} || exit 1
cp -s libxml2.so libxml2.so.2 > /dev/null 2>&1

### update version

echo "PorteuX-v${PORTEUX_VERSION}-${PORTEUX_BUILD}" > $MODULE_PATH/packages/etc/porteux-version
sed -i "s|version|v${PORTEUX_VERSION}|" $MODULE_PATH/packages/etc/issue
sed -i "s|^VERSION=.*|VERSION=\"${PORTEUX_VERSION}\"|" $MODULE_PATH/packages/etc/os-release
sed -i "s|^VERSION_ID=.*|VERSION_ID=${PORTEUX_VERSION}|" $MODULE_PATH/packages/etc/os-release
sed -i "s|^PRETTY_NAME=.*|PRETTY_NAME=\"PorteuX ${PORTEUX_VERSION} ${PORTEUX_BUILD}\"|" $MODULE_PATH/packages/etc/os-release
sed -i "s|^CPE_NAME=.*|CPE_NAME=\"cpe:/o:porteux:porteux_linux:${PORTEUX_VERSION}\"|" $MODULE_PATH/packages/etc/os-release
sed -i "0,/PorteuX/s|PorteuX.*|PorteuX v${PORTEUX_VERSION}|" $SCRIPT_PATH/../iso/boot/syslinux/help.txt

### set permissions

cd $MODULE_PATH/packages || exit 1

chmod 644 etc/rc.d/rc.bluetooth
chmod 644 etc/rc.d/rc.crond
chmod 644 etc/rc.d/rc.fuse3
chmod 644 etc/rc.d/rc.inet1
chmod 644 etc/rc.d/rc.loop
chmod 755 etc/rc.d/rc.networkmanager
chmod 644 etc/rc.d/rc.sshd
chmod 644 etc/rc.d/rc.wireless

### copy build files to 05-devel

copy_to_devel

### copy language files to 08-multilanguage

copy_to_multilanguage

### module clean up

cd $MODULE_PATH/packages/ || exit 1

{
rm etc/init.d
rm etc/motd
rm etc/termcap
rm etc/openvpn/sample-config-files
rm etc/rc.d/rc.inet2
rm usr/bin/smbtorture
rm usr/bin/wpa_gui
rm usr/dict
rm usr/lib${SYSTEM_BITS}/libicutest.*
rm usr/lib${SYSTEM_BITS}/libqgpgme.so*
rm usr/libexec/samba/rpcd_*
rm usr/sbin/make-kernel-backup
rm usr/share/i18n/locales/C
rm usr/share/kbd/keymaps/i386/qwertz/sr-latin.map.gz
rm usr/share/pixmaps/wpa_gui.png
rm var/db/Makefile

rm -fr boot
rm -fr lib${SYSTEM_BITS}/pkgconfig
rm -fr lib/systemd
rm -fr mnt/*
rm -fr usr/etc
rm -fr usr/lib${SYSTEM_BITS}/guile
rm -fr usr/lib${SYSTEM_BITS}/krb*/plugins
rm -fr usr/lib${SYSTEM_BITS}/sasl2
rm -fr usr/lib${SYSTEM_BITS}/services
rm -fr usr/lib${SYSTEM_BITS}/systemd
rm -fr usr/lib/ldscripts
rm -fr usr/lib/modprobe.d
rm -fr usr/lib*/python*/__phello__
rm -fr usr/lib*/python*/config-*-x86_64-linux-gnu
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

find usr/share/terminfo/ -xtype l -delete
find usr/lib${SYSTEM_BITS}/python* -type d -name 'test' -prune -exec rm -rf {} +
find usr/lib${SYSTEM_BITS}/python* -type d -name 'tests' -prune -exec rm -rf {} +
} >/dev/null 2>&1

strip_clean --exceptions='ld-linux*,libc-*,libgcc_s*,libldap*,libpthread*,libstdc++*'
strip_hard_all --exceptions='ld-linux*,libc-*,libgcc_s*,libldap*,libpthread*,libstdc++*'

### copy cache files

prepare_files_for_cache

### finalize

finalize
