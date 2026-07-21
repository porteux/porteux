#!/bin/bash

MODULE_NAME="003-cosmic"

source "$PWD/../builder-utils/set-flags.sh"

set_flags "$MODULE_NAME"

source "$BUILDER_UTILS_PATH/cache-files.sh"
source "$BUILDER_UTILS_PATH/generic-strip.sh"
source "$BUILDER_UTILS_PATH/helper.sh"
source "$BUILDER_UTILS_PATH/slackware-repository.sh"

elevate_if_needed "$0" "$@"

### create module folder

mkdir -p $MODULE_PATH/packages > /dev/null 2>&1
cd $MODULE_PATH || exit 1

### download packages from slackware repository

bash $SCRIPT_PATH/download-packages.sh || exit 1

### packages outside slackware repository

# cosmic common deps
for package in \
	audacious \
	dart-sass \
; do
bash $SCRIPT_PATH/../common/deps/${package}/${package}.SlackBuild || exit 1
installpkg $MODULE_PATH/packages/${package}*.txz || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# cosmic common extras
for package in \
	adw-gtk3 \
	audacious-plugins \
	ffmpegthumbnailer \
	gpicview \
; do
bash $SCRIPT_PATH/../common/extras/${package}/${package}.SlackBuild || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# only required for building adw-gtk3
rm $MODULE_PATH/packages/dart-sass*.txz

# required by file-roller
installpkg $MODULE_PATH/packages/libhandy*.txz || exit 1

current_package=file-roller
bash $SCRIPT_PATH/../common/extras/${current_package}/${current_package}.SlackBuild || exit 1
rm -fr $MODULE_PATH/${current_package} && cd $MODULE_PATH || exit 1

# required from now on
installpkg $MODULE_PATH/packages/llvm*.txz > /dev/null 2>&1
rm $MODULE_PATH/packages/llvm* > /dev/null 2>&1

# not using rust from slackware because it's much slower
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --profile minimal --default-toolchain stable -y
rm -fr $HOME/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/share/doc 2>/dev/null
export PATH=$HOME/.cargo/bin/:$PATH

current_package=just
wget https://github.com/casey/${current_package}/archive/refs/heads/master.tar.gz -O ${current_package}.tar.gz
tar xf ${current_package}.tar.gz
cd ${current_package}-master || exit 1
cargo build --release --target x86_64-unknown-linux-gnu || exit 1
export PATH=$MODULE_PATH/just-master/target/x86_64-unknown-linux-gnu/release/:$PATH

# cosmic deps
for package in \
	gumbo-parser \
	jbig2dec \
	greetd \
	launcher \
; do
bash $SCRIPT_PATH/deps/${package}/${package}.SlackBuild || exit 1
installpkg $MODULE_PATH/packages/${package}*.txz || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" -o -name "just-master" \) -exec rm -rf '{}' \; 2>/dev/null
done

# required by cosmic-reader
installpkg $MODULE_PATH/packages/leptonica*.txz
rm $MODULE_PATH/packages/leptonica*.txz
installpkg $MODULE_PATH/packages/tesseract*.txz
rm $MODULE_PATH/packages/tesseract*.txz

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
	cosmic-monitor \
	cosmic-notifications \
	cosmic-osd \
	cosmic-panel \
	cosmic-randr \
	cosmic-reader \
	cosmic-screenshot \
	cosmic-session \
	cosmic-settings \
	cosmic-settings-daemon \
	cosmic-term \
	cosmic-workspaces-epoch \
	xdg-desktop-portal-cosmic \
; do
bash $SCRIPT_PATH/cosmic/${package}/${package}.SlackBuild || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" -o -name "just-master" \) -exec rm -rf '{}' \; 2>/dev/null
rm -fr $HOME/.cargo/git/checkouts/* # this increases build time but frees up RAM
rm -fr $HOME/.cargo/registry/src/index.crates*/* # this increases build time but frees up RAM
done

# only required for building not for run-time
rm -fr $MODULE_PATH/just-master

### packages that require specific stripping

strip_package iso-codes \
	usr/share/iso-codes/json/iso_3166-1.json \
	usr/share/iso-codes/json/iso_639-2.json \
	usr/share/iso-codes/json/iso_639-3.json

### fake root

cd $MODULE_PATH/packages && ROOT=./ installpkg *.t?z || exit 1
rm *.t?z

### install-strip additional packages, including porteux utils

install_additional_packages

### copy build files to 05-devel

copy_to_devel

### copy language files to 08-multilanguage

copy_to_multilanguage

### module clean up

cd $MODULE_PATH/packages/ || exit 1

strip_clean
strip_hard_all

### copy cache files

prepare_files_for_cache_de

### generate cache files

generate_caches_de

### finalize

finalize
