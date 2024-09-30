#!/bin/sh

MODULENAME=003-cosmic

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

### packages outside Slackware repository

currentPackage=audacious
sh $SCRIPTPATH/../extras/audacious/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=audacious-plugins
sh $SCRIPTPATH/../extras/audacious/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=xdg-desktop-portal-gtk
sh $SCRIPTPATH/deps/xdg-desktop-portal-gtk/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

# required from now on
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain nightly -y
export PATH=$HOME/.cargo/bin/:$PATH
rustup component add rust-src --toolchain nightly

currentPackage=seatd
sh $SCRIPTPATH/deps/${currentPackage}/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=just
cd $MODULEPATH
git clone https://github.com/casey/${currentPackage}
cd ${currentPackage}
cargo build --release -Zbuild-std=std,panic_abort --target x86_64-unknown-linux-gnu || exit 1
export PATH=$MODULEPATH/just/target/x86_64-unknown-linux-gnu/release/:$PATH

currentPackage=greetd
sh $SCRIPTPATH/deps/${currentPackage}/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

installpkg $MODULEPATH/packages/llvm*.txz > /dev/null 2>&1
rm $MODULEPATH/packages/llvm*.txz > /dev/null 2>&1

# cosmic deps
for package in \
	launcher \
; do
sh $SCRIPTPATH/deps/${package}/${package}.SlackBuild || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" -o -name "just" \) -exec rm -rf '{}' \; 2>/dev/null
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
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" -o -name "just" \) -exec rm -rf '{}' \; 2>/dev/null
done

# only required for building not for run-time
rm -fr $MODULEPATH/just

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
