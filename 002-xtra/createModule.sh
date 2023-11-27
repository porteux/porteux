#!/bin/sh
MODULENAME=002-xtra

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

currentPackage=transmission
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
info=$(DownloadLatestFromGithub "${currentPackage}" ${currentPackage})
version=${info#* }
filename=${info% *}
tar xvf $filename && rm $filename || exit 1
cd ${currentPackage}*
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=release -DCMAKE_CFLAGS:STRING="-O2 -s -fPIC -DNDEBUG -ffat-lto-objects" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=lib$SYSTEMBITS -DENABLE_TESTS=OFF -DWITH_APPINDICATOR=OFF -DENABLE_QT=OFF ..
make -j${NUMBERTHREADS} && make install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=rtmpdump
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/multimedia/${currentPackage}/ -A * || exit 1
git clone http://git.ffmpeg.org/${currentPackage} || exit 1
version=`git --git-dir=${currentPackage}/.git log -1 --date=format:"%Y%m%d" --format="%ad"`
mv ${currentPackage} ${currentPackage}-$version
tar cvfz ${currentPackage}-${version}.tar.gz ${currentPackage}-${version}/
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" ${currentPackage}.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" ${currentPackage}.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

currentPackage=gsm
version=1.0.22
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/libraries/${currentPackage}/ -A * || exit 1
wget https://www.quut.com/${currentPackage}/${currentPackage}-$version.tar.gz || exit 1
sed -z -i "s|make\nmake |make -j${NUMBERTHREADS}\nmake -j${NUMBERTHREADS} |g" ${currentPackage}.SlackBuild
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" ${currentPackage}.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" ${currentPackage}.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

currentPackage=xvidcore
version=1.3.7
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/multimedia/${currentPackage}/ -A * || exit 1
wget https://downloads.xvid.com/downloads/${currentPackage}-$version.tar.gz || exit 1
sed -z -i "s|make\nmake |make -j${NUMBERTHREADS}\nmake -j${NUMBERTHREADS} |g" ${currentPackage}.SlackBuild
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" ${currentPackage}.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" ${currentPackage}.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

# temporary just to build x264 with mp4 support
currentPackage=l-smash
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/${currentPackage}/${currentPackage}/ || exit 1
cd ${currentPackage}
CFLAGS="-O3 -pipe -fPIC -DNDEBUG" ./configure --prefix=/usr --libdir=/usr/lib$SYSTEMBITS --disable-static
make -j${NUMBERTHREADS} install || exit 1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=x264
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget https://code.videolan.org/videolan/${currentPackage}/-/archive/master/${currentPackage}-master.tar.gz || exit 1
tar xvf ${currentPackage}-master.tar.gz && rm ${currentPackage}-master.tar.gz || exit 1
cd ${currentPackage}-master
version=$(date -r . +%Y%m%d)
CFLAGS="-O3 -pipe -fPIC -DNDEBUG" ./configure --prefix=/usr --libdir=/usr/lib$SYSTEMBITS --enable-shared --enable-pic --enable-strip --enable-lto --disable-cli
make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz > /dev/null 2>&1
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

currentPackage=x265
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
cp $SCRIPTPATH/extras/${currentPackage}/* .
wget https://bitbucket.org/multicoreware/${currentPackage}_git/get/HEAD.tar.gz || exit 1
tar xvf HEAD.tar.gz && rm HEAD.tar.gz || exit 1
cd multicoreware-${currentPackage}*
version=$(date -r . +%Y%m%d)
mkdir ../${currentPackage}_${version} && mv * ../${currentPackage}_${version} && cd ..
tar cvfz ${currentPackage}_${version}.tar.gz ${currentPackage}_${version} || exit 1
sed -z -i "s| make| make -j${NUMBERTHREADS}|g" ${currentPackage}.SlackBuild
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" ${currentPackage}.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" ${currentPackage}.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

currentPackage=twolame
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/audio/${currentPackage}/ -A * || exit 1
info=$(DownloadLatestFromGithub "njh" ${currentPackage})
version=${info#* }
sed -z -i "s|make\nmake |make -j${NUMBERTHREADS}\nmake -j${NUMBERTHREADS} |g" ${currentPackage}.SlackBuild
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" ${currentPackage}.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" ${currentPackage}.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

currentPackage=opencore-amr
version=0.1.6
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/audio/${currentPackage}/ -A * || exit 1
wget https://sourceforge.net/projects/${currentPackage}/files/${currentPackage}/${currentPackage}-$version.tar.gz || exit 1
sed -z -i "s|make\nmake|make -j${NUMBERTHREADS}\nmake -j${NUMBERTHREADS} |g" ${currentPackage}.SlackBuild
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" ${currentPackage}.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" ${currentPackage}.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

currentPackage=mp4v2
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/libraries/lib${currentPackage}/ -A * || exit 1
mv lib${currentPackage}.SlackBuild ${currentPackage}.SlackBuild
info=$(DownloadLatestFromGithub "enzo1982" ${currentPackage})
version=${info#* }
sed -z -i "s|make\nmake |make -j${NUMBERTHREADS}\nmake -j${NUMBERTHREADS} |g" ${currentPackage}.SlackBuild
sed -i "s|patch |#patch |g" ${currentPackage}.SlackBuild
sed -i "s|PRGNAM=libmp4v2|PRGNAM=mp4v2|g" ${currentPackage}.SlackBuild
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" ${currentPackage}.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" ${currentPackage}.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

currentPackage=libass
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/libraries/${currentPackage}/ -A * || exit 1
info=$(DownloadLatestFromGithub "libass" ${currentPackage})
version=${info#* }
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" ${currentPackage}.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" ${currentPackage}.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

currentPackage=faad2
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/audio/${currentPackage}/ -A * || exit 1
info=$(DownloadLatestFromGithub "knik0" ${currentPackage})
version=${info#* }
sed -i "s|SRCVER=\${.*}|SRCVER=\$VERSION|g" ${currentPackage}.SlackBuild
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" ${currentPackage}.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" ${currentPackage}.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

currentPackage=faac
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/audio/${currentPackage}/ -A * || exit 1
info=$(DownloadLatestFromGithub "knik0" ${currentPackage})
version=${info#* }
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" ${currentPackage}.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" ${currentPackage}.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

currentPackage=dav1d
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget https://code.videolan.org/videolan/${currentPackage}/-/archive/master/${currentPackage}-master.tar.gz || exit 1
tar xvf ${currentPackage}-master.tar.gz && rm ${currentPackage}-master.tar.gz || exit 1
cd ${currentPackage}-master
version=$(date -r . +%Y%m%d)
mkdir build && cd build
meson -Denable_tests=false -Denable_tools=false --prefix /usr ..
DESTDIR=$MODULEPATH/${currentPackage}/package ninja -j${NUMBERTHREADS} install || exit 1
cd $MODULEPATH/${currentPackage}/package
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

# temporary just to build ffmpeg and mpv
currentPackage=nv-codec-headers
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/libraries/${currentPackage}/ -A * || exit 1
# TODO: remove hardcoded version when upstream fixes ffmpeg compilation error
#info=$(DownloadLatestFromGithub "FFmpeg" ${currentPackage})
#version=${info#* }
version=12.0.16.1
wget https://github.com/FFmpeg/${currentPackage}/releases/download/n${version}/${currentPackage}-${version}.tar.gz
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" ${currentPackage}.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" ${currentPackage}.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
installpkg /tmp/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}
rm /tmp/${currentPackage}*.t?z

# required by ffmpeg
installpkg $MODULEPATH/packages/openal-soft-*.t?z || exit 1
installpkg $MODULEPATH/packages/vid.stab-*.t?z || exit 1
installpkg $MODULEPATH/packages/frei0r-plugins*.t?z || exit 1
rm $MODULEPATH/packages/frei0r-plugins-*.t?z || exit 1
installpkg $MODULEPATH/packages/opencl-headers*.t?z || exit 1
rm $MODULEPATH/packages/opencl-headers-*.t?z || exit 1

currentPackage=ffmpeg
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent -l1 $SOURCEREPOSITORY/l/${currentPackage}/ || exit 1
if [ $SLACKWAREVERSION != "current" ]; then
	rm ffmpeg-*.tar.xz
	wget https://ffmpeg.org/releases/ffmpeg-4.4.4.tar.xz
fi
sed -i "s|\./configure \\\\|\./configure \\\\\n  --enable-nvdec --enable-nvenc \\\\|g" ${currentPackage}.SlackBuild
GLSLANG=no VULKAN=no ASS=yes OPENCORE=yes GSM=yes RTMP=yes TWOLAME=yes XVID=yes X265=yes X264=yes DAV1D=yes AAC=yes sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

# required by mpv
currentPackage=LuaJIT
mkdir $MODULEPATH/${currentPackage,,} && cd $MODULEPATH/${currentPackage,,}
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/development/${currentPackage,,}/ -A * || exit 1
version=2.0.5
wget https://github.com/${currentPackage}/${currentPackage}/archive/refs/tags/v${version}.tar.gz -O ${currentPackage}-${version}.tar.gz
sed -z -i "s|make |make -j${NUMBERTHREADS} |g" ${currentPackage,,}.SlackBuild
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" ${currentPackage,,}.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" ${currentPackage,,}.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" ${currentPackage,,}.SlackBuild
sh ${currentPackage,,}.SlackBuild || exit 1
mv /tmp/${currentPackage,,}*.t?z $MODULEPATH/packages
installpkg $MODULEPATH/packages/${currentPackage,,}*.t?z
rm -fr $MODULEPATH/${currentPackage,,}

# required by libplacebo
installpkg $MODULEPATH/packages/python-glad2-*.t?z || exit 1
rm $MODULEPATH/packages/python-glad2-*.t?z || exit 1
installpkg $MODULEPATH/packages/python-Jinja2-*.t?z || exit 1
rm $MODULEPATH/packages/python-Jinja2*.t?z || exit 1
installpkg $MODULEPATH/packages/python-MarkupSafe-*.t?z || exit 1
rm $MODULEPATH/packages/python-MarkupSafe-*.t?z || exit 1
installpkg $MODULEPATH/packages/vulkan-sdk-*.t?z || exit 1
rm $MODULEPATH/packages/vulkan-sdk-*.t?z || exit 1

currentPackage=libplacebo
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
version=$(curl -s https://code.videolan.org/videolan/${currentPackage}/-/tags?format=atom | grep ' <title>' | grep -v rc | head -1 | cut -d '>' -f 2 | cut -d '<' -f 1)
version=${version//[vV]}
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/graphics/${currentPackage}/ -A * || exit 1
wget https://code.videolan.org/videolan/${currentPackage}/-/archive/v${version}/${currentPackage}-v${version}.tar.gz
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" ${currentPackage}.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" ${currentPackage}.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" ${currentPackage}.SlackBuild
sed -i "s|-Dbuildtype=\$RELEASE|-Dbuildtype=\$RELEASE -Dvulkan=disabled -Ddemos=false -Dshaderc=disabled -Dglslang=disabled|g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

currentPackage=mpv
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
cp $SCRIPTPATH/extras/${currentPackage}/* .
info=$(DownloadLatestFromGithub "mpv-player" ${currentPackage})
sh ${currentPackage}.SlackBuild || exit 1
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

### module clean up

cd $MODULEPATH/packages/

rm -R usr/share/ffmpeg/examples
rm -R usr/share/lua

rm usr/lib64/mpg123/output_sdl.so
rm usr/share/applications/mimeinfo.cache

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
