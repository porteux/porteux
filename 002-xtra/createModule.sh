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

### download packages from slackware repositories

DownloadFromSlackware

### packages outside slackware repository

installpkg $MODULEPATH/packages/llvm*.txz > /dev/null 2>&1
rm $MODULEPATH/packages/llvm*.txz > /dev/null 2>&1

currentPackage=transmission
sh $SCRIPTPATH/extras/${currentPackage}/${currentPackage}.SlackBuild
rm -fr $MODULEPATH/${currentPackage}

currentPackage=rtmpdump
sh $SCRIPTPATH/extras/${currentPackage}/${currentPackage}.SlackBuild
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=xvidcore
sh $SCRIPTPATH/extras/${currentPackage}/${currentPackage}.SlackBuild
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=x264
sh $SCRIPTPATH/extras/${currentPackage}/${currentPackage}.SlackBuild
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=x265
sh $SCRIPTPATH/extras/${currentPackage}/${currentPackage}.SlackBuild
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=twolame
sh $SCRIPTPATH/extras/${currentPackage}/${currentPackage}.SlackBuild
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=libass
sh $SCRIPTPATH/extras/${currentPackage}/${currentPackage}.SlackBuild
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=faad2
sh $SCRIPTPATH/extras/${currentPackage}/${currentPackage}.SlackBuild
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=faac
sh $SCRIPTPATH/extras/${currentPackage}/${currentPackage}.SlackBuild
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=SVT-AV1
sh $SCRIPTPATH/extras/${currentPackage}/${currentPackage}.SlackBuild
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=dav1d
sh $SCRIPTPATH/extras/${currentPackage}/${currentPackage}.SlackBuild
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=libheif
sh $SCRIPTPATH/extras/${currentPackage}/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

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

currentPackage=libplacebo
sh $SCRIPTPATH/deps/${currentPackage}/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

# temporary just to build ffmpeg and mpv
currentPackage=nv-codec-headers
sh $SCRIPTPATH/deps/${currentPackage}/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}
rm $MODULEPATH/packages/${currentPackage}*.txz

# temporary to build ffmpeg with amd hardware encoding acceleration
currentPackage=AMF
sh $SCRIPTPATH/deps/${currentPackage}/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}
rm $MODULEPATH/packages/${currentPackage}*.txz

# required by ffmpeg
installpkg $MODULEPATH/packages/openal-soft-*.t?z || exit 1
installpkg $MODULEPATH/packages/vid.stab-*.t?z || exit 1
installpkg $MODULEPATH/packages/frei0r-plugins*.t?z || exit 1
rm $MODULEPATH/packages/frei0r-plugins-*.t?z || exit 1
installpkg $MODULEPATH/packages/opencl-headers*.t?z || exit 1
rm $MODULEPATH/packages/opencl-headers-*.t?z || exit 1

currentPackage=ffmpeg
sh $SCRIPTPATH/extras/${currentPackage}/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

# required by mpv
currentPackage=luajit
sh $SCRIPTPATH/deps/${currentPackage}/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=mpv
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
rm -R usr/share/ffmpeg/examples
rm -R usr/share/lua

rm usr/bin/alsoft-config
rm usr/share/applications/mimeinfo.cache
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
