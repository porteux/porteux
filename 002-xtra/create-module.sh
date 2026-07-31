#!/bin/bash

MODULE_NAME="002-xtra"

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

### packages outside slackware repository

installpkg $MODULE_PATH/packages/llvm*.txz > /dev/null 2>&1
rm $MODULE_PATH/packages/llvm*.txz > /dev/null 2>&1

# required by libplacebo
installpkg $MODULE_PATH/packages/python-pip-*.t?z || exit 1
rm $MODULE_PATH/packages/python-pip-*.t?z
installpkg $MODULE_PATH/packages/python-Jinja2-*.t?z || exit 1
rm $MODULE_PATH/packages/python-Jinja2-*.t?z
installpkg $MODULE_PATH/packages/python-MarkupSafe-*.t?z || exit 1
rm $MODULE_PATH/packages/python-MarkupSafe-*.t?z
installpkg $MODULE_PATH/packages/vulkan-sdk-*.t?z || exit 1
rm $MODULE_PATH/packages/vulkan-sdk-*.t?z

cd $MODULE_PATH || exit 1
pip install glad2 || exit 1

# required by ffmpeg
installpkg $MODULE_PATH/packages/openal-soft-*.t?z || exit 1
installpkg $MODULE_PATH/packages/vid.stab-*.t?z || exit 1

installpkg $MODULE_PATH/packages/frei0r-plugins*.t?z || exit 1
rm $MODULE_PATH/packages/frei0r-plugins-*.t?z
installpkg $MODULE_PATH/packages/krb5-*.t?z || exit 1
rm $MODULE_PATH/packages/krb5-*.t?z
installpkg $MODULE_PATH/packages/opencl-headers*.t?z || exit 1
rm $MODULE_PATH/packages/opencl-headers-*.t?z

# xtra deps
for package in \
	rtmpdump \
	xvidcore \
	x264 \
	x265 \
	libass \
	svt-av1 \
	dav1d \
	libplacebo \
	nv-codec-headers \
	amf-headers \
	ffmpeg \
	luajit \
; do
bash $SCRIPT_PATH/deps/${package}/${package}.SlackBuild || exit 1
installpkg $MODULE_PATH/packages/${package}*.txz || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# only required for building
rm $MODULE_PATH/packages/nv-codec-headers*.txz
rm $MODULE_PATH/packages/amf-headers*.txz

# xtra extras
for package in \
	libheif \
	mpv \
	transmission \
; do
bash $SCRIPT_PATH/extras/${package}/${package}.SlackBuild || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

### fake root

install_packages

### install additional packages, including porteux utils

install_additional_packages

### copy build files to 05-devel

copy_to_devel

### copy language files to 08-multilanguage

copy_to_multilanguage

### module clean up

cd $MODULE_PATH/packages/ || exit 1

{
rm usr/bin/alsoft-config
rm usr/share/applications/mimeinfo.cache
} >/dev/null 2>&1

strip_clean
strip_hard_all --exceptions='libluajit*,transmission-gtk'

### copy cache files

prepare_files_for_cache

### generate cache files

generate_caches

### finalize

finalize
