#!/bin/bash

MODULENAME=002-xtra

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

installpkg $MODULEPATH/packages/llvm*.txz > /dev/null 2>&1
rm $MODULEPATH/packages/llvm*.txz > /dev/null 2>&1

# required by libplacebo
installpkg $MODULEPATH/packages/python-pip-*.t?z || exit 1
rm $MODULEPATH/packages/python-pip-*.t?z
installpkg $MODULEPATH/packages/python-Jinja2-*.t?z || exit 1
rm $MODULEPATH/packages/python-Jinja2-*.t?z
installpkg $MODULEPATH/packages/python-MarkupSafe-*.t?z || exit 1
rm $MODULEPATH/packages/python-MarkupSafe-*.t?z
installpkg $MODULEPATH/packages/vulkan-sdk-*.t?z || exit 1
rm $MODULEPATH/packages/vulkan-sdk-*.t?z

cd $MODULEPATH
pip install glad2 || exit 1

# required by ffmpeg
installpkg $MODULEPATH/packages/openal-soft-*.t?z || exit 1
installpkg $MODULEPATH/packages/vid.stab-*.t?z || exit 1

installpkg $MODULEPATH/packages/frei0r-plugins*.t?z || exit 1
rm $MODULEPATH/packages/frei0r-plugins-*.t?z || exit 1
installpkg $MODULEPATH/packages/opencl-headers*.t?z || exit 1
rm $MODULEPATH/packages/opencl-headers-*.t?z || exit 1

# xtra deps
for package in \
	rtmpdump \
	xvidcore \
	x264 \
	x265 \
	twolame \
	libass \
	faad2 \
	faac \
	SVT-AV1 \
	dav1d \
	libheif \
	libplacebo \
	nv-codec-headers \
	AMF-headers \
	ffmpeg \
	luajit \
; do
sh $SCRIPTPATH/deps/${package}/${package}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${package}-*.txz || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# only required for building
rm $MODULEPATH/packages/nv-codec-headers*.txz
rm $MODULEPATH/packages/AMF-headers*.txz

currentPackage=mpv
sh $SCRIPTPATH/extras/${currentPackage}/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=transmission
sh $SCRIPTPATH/extras/${currentPackage}/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

### fake root

cd $MODULEPATH/packages && ROOT=./ installpkg *.t?z
rm *.t?z

### install additional packages, including porteux utils

InstallAdditionalPackages

### fix applications shortcuts

sed -i "s|TryExec=.*||g" $MODULEPATH/packages/usr/share/applications/mpv.desktop
sed -i "s|Exec=.*|Exec=mpv --player-operation-mode=pseudo-gui --hwdec=auto --no-osd-bar --audio-file-auto=fuzzy -- %U|g" $MODULEPATH/packages/usr/share/applications/mpv.desktop

### copy build files to 05-devel

CopyToDevel

### copy language files to 08-multilanguage

CopyToMultiLanguage

### module clean up

cd $MODULEPATH/packages/

{
rm usr/bin/alsoft-config
rm usr/share/applications/mimeinfo.cache

rm -fr usr/share/lua-jit
} >/dev/null 2>&1

GenericStrip

# move out things that don't support aggressive stripping
mv $MODULEPATH/packages/usr/bin/transmission-gtk $MODULEPATH/
AggressiveStrip
mv $MODULEPATH/transmission-gtk $MODULEPATH/packages/usr/bin/

### copy cache files

PrepareFilesForCache

### generate cache files

GenerateCaches

### finalize

Finalize
