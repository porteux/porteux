#!/bin/bash

MODULENAME=003-cosmic

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

### packages outside Slackware repository

currentPackage=audacious
sh $BUILDERUTILSPATH/common/audacious/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=audacious-plugins
sh $BUILDERUTILSPATH/common/audacious/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

# required from now on
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain nightly -y
export PATH=$HOME/.cargo/bin/:$PATH
rustup component add rust-src --toolchain nightly

currentPackage=just
cd $MODULEPATH
wget https://github.com/casey/${currentPackage}/archive/refs/heads/master.tar.gz -O ${currentPackage}.tar.gz
tar xfv ${currentPackage}.tar.gz
cd ${currentPackage}-master
cargo build --release -Zbuild-std=std,panic_abort --target x86_64-unknown-linux-gnu || exit 1
export PATH=$MODULEPATH/just-master/target/x86_64-unknown-linux-gnu/release/:$PATH

installpkg $MODULEPATH/packages/llvm*.txz > /dev/null 2>&1
rm $MODULEPATH/packages/llvm*.txz > /dev/null 2>&1

# cosmic deps
for package in \
	greetd \
	launcher \
	xdg-desktop-portal-gtk \
; do
sh $SCRIPTPATH/deps/${package}/${package}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${package}-*.txz || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" -o -name "just-master" \) -exec rm -rf '{}' \; 2>/dev/null
done

# cosmic extras
for package in \
	observatory \
; do
sh $SCRIPTPATH/extras/${package}/${package}.SlackBuild || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" -o -name "just-master" \) -exec rm -rf '{}' \; 2>/dev/null
done

# cosmic packages
for package in \
	cosmic-applets \
	cosmic-applibrary \
	cosmic-bg \
	cosmic-comp \
	cosmic-edit \
	cosmic-files \
	cosmic-greeter \
	cosmic-idle \
	cosmic-icons \
	cosmic-launcher \
	cosmic-notifications \
	cosmic-osd \
	cosmic-panel \
	cosmic-randr \
	cosmic-screenshot \
	cosmic-session \
	cosmic-settings \
	cosmic-settings-daemon \
	cosmic-term \
	cosmic-workspaces-epoch \
	xdg-desktop-portal-cosmic \
; do
sh $SCRIPTPATH/cosmic/${package}/${package}.SlackBuild || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" -o -name "just-master" \) -exec rm -rf '{}' \; 2>/dev/null
done

# only required for building not for run-time
rm -fr $MODULEPATH/just-master

### fake root

cd $MODULEPATH/packages && ROOT=./ installpkg *.t?z
rm *.t?z

### install additional packages, including porteux utils

InstallAdditionalPackages

### copy build files to 05-devel

CopyToDevel

### copy language files to 08-multilanguage

CopyToMultiLanguage

### module clean up

cd $MODULEPATH/packages/

rm etc/xdg/autostart/nm-applet.desktop
rm usr/share/applications/nm-applet.desktop

GenericStrip
AggressiveStripAll

### copy cache files

PrepareFilesForCacheDE

### generate cache files

GenerateCachesDE

### finalize

Finalize
