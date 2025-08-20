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
cd $MODULEPATH

### download packages from slackware repository

DownloadFromSlackware

### packages outside slackware repository

currentPackage=audacious
sh $SCRIPTPATH/../common/audacious/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=audacious-plugins
sh $SCRIPTPATH/../common/audacious/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=adw-gtk3
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mkdir -p package/usr/share/themes
version=$(GetLatestVersionTagFromGithub "lassekongo83" ${currentPackage})
wget https://github.com/lassekongo83/${currentPackage}/releases/download/${version}/${currentPackage}${version}.tar.xz || exit 1
tar xvf ${currentPackage}${version}.tar.?z -C package/usr/share/themes || exit 1
cd $MODULEPATH/${currentPackage}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-${version//[^0-9._]/}-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

# required from now on
installpkg $MODULEPATH/packages/llvm*.txz > /dev/null 2>&1
rm $MODULEPATH/packages/llvm* > /dev/null 2>&1

# not using rust from slackware because it's much slower
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --profile minimal --default-toolchain stable -y
rm -fr $HOME/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/share/doc 2>/dev/null
export PATH=$HOME/.cargo/bin/:$PATH

currentPackage=just
wget https://github.com/casey/${currentPackage}/archive/refs/heads/master.tar.gz -O ${currentPackage}.tar.gz
tar xfv ${currentPackage}.tar.gz
cd ${currentPackage}-master
cargo build --release --target x86_64-unknown-linux-gnu || exit 1
export PATH=$MODULEPATH/just-master/target/x86_64-unknown-linux-gnu/release/:$PATH

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

{
rm etc/xdg/autostart/nm-applet.desktop
rm usr/share/applications/nm-applet.desktop
} >/dev/null 2>&1

GenericStrip
AggressiveStripAll

### copy cache files

PrepareFilesForCacheDE

### generate cache files

GenerateCachesDE

### finalize

Finalize
