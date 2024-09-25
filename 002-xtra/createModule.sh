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

installpkg $MODULEPATH/packages/llvm*.txz > /dev/null 2>&1
rm $MODULEPATH/packages/llvm*.txz > /dev/null 2>&1

currentPackage=transmission
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
info=$(DownloadLatestFromGithub "${currentPackage}" ${currentPackage})
version=${info#* }
filename=${info% *}
tar xvf $filename && rm $filename || exit 1
cd ${currentPackage}*
cp $SCRIPTPATH/extras/transmission/*.patch .
for i in *.patch; do patch -p0 < $i || exit 1; done # only for version 4.0.6 which is broken
mkdir build && cd build
CFLAGS="$GCCFLAGS -fPIC" CXXFLAGS="$CLANGFLAGS -flto" cmake -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=lld" -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=release -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=lib${SYSTEMBITS} -DENABLE_TESTS=OFF -DWITH_APPINDICATOR=OFF -DENABLE_QT=OFF -DINSTALL_DOC=OFF ..
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
sed -i "s|-O2 |$GCCFLAGS -flto |g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

currentPackage=gsm
version="1.0.22"
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/libraries/${currentPackage}/ -A * || exit 1
wget https://www.quut.com/${currentPackage}/${currentPackage}-$version.tar.gz || exit 1
sed -z -i "s|make\nmake |make -j${NUMBERTHREADS}\nmake -j${NUMBERTHREADS} |g" ${currentPackage}.SlackBuild
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" ${currentPackage}.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" ${currentPackage}.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" ${currentPackage}.SlackBuild
sed -i "s|-O2 |$GCCFLAGS -flto |g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

currentPackage=xvidcore
version="1.3.7"
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/multimedia/${currentPackage}/ -A * || exit 1
wget https://downloads.xvid.com/downloads/${currentPackage}-${version}.tar.gz || exit 1
sed -z -i "s|make\nmake |make -j${NUMBERTHREADS}\nmake -j${NUMBERTHREADS} |g" ${currentPackage}.SlackBuild
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" ${currentPackage}.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" ${currentPackage}.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" ${currentPackage}.SlackBuild
sed -i "s|-O2 |$GCCFLAGS -flto |g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

# temporary just to build x264 with mp4 support
currentPackage=l-smash
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/${currentPackage}/${currentPackage}/ || exit 1
cd ${currentPackage}
CFLAGS="$GCCFLAGS -flto" ./configure --prefix=/usr --libdir=/usr/lib$SYSTEMBITS --disable-static
make -j${NUMBERTHREADS} install || exit 1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=x264
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget https://code.videolan.org/videolan/${currentPackage}/-/archive/master/${currentPackage}-master.tar.gz || exit 1
tar xvf ${currentPackage}-master.tar.gz && rm ${currentPackage}-master.tar.gz || exit 1
cd ${currentPackage}-master
version=$(date -r . +%Y%m%d)
CC=clang CFLAGS="$CLANGFLAGS -flto" ./configure --prefix=/usr --libdir=/usr/lib$SYSTEMBITS --enable-shared --enable-pic --enable-strip --enable-lto --disable-cli
make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz > /dev/null 2>&1
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

currentPackage=x265
sh $SCRIPTPATH/extras/${currentPackage}/${currentPackage}.SlackBuild || exit 1
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
sed -i "s|-O2 |$GCCFLAGS -flto |g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

currentPackage=opencore-amr
version="0.1.6"
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/audio/${currentPackage}/ -A * || exit 1
wget https://sourceforge.net/projects/${currentPackage}/files/${currentPackage}/${currentPackage}-$version.tar.gz || exit 1
sed -z -i "s|make\nmake|make -j${NUMBERTHREADS}\nmake -j${NUMBERTHREADS} |g" ${currentPackage}.SlackBuild
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" ${currentPackage}.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" ${currentPackage}.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" ${currentPackage}.SlackBuild
sed -i "s|-O2 |$GCCFLAGS -flto |g" ${currentPackage}.SlackBuild
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
sed -i "s|-O2 |$GCCFLAGS |g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

currentPackage=libass
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget ${SLACKWAREDOMAIN}/pub/slackware/slackware64-current/source/l/libass/${currentPackage}.SlackBuild  || exit 1
info=$(DownloadLatestFromGithub "libass" ${currentPackage})
version=${info#* }
sed -i "s|-O2 |$GCCFLAGS -flto |g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

currentPackage=faad2
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
info=$(DownloadLatestFromGithub "knik0" ${currentPackage})
version=${info#* }
mkdir package
tar xvf ${currentPackage}-${version}.tar.gz
cd ${currentPackage}-${version}
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=release -DCMAKE_C_FLAGS:STRING="$GCCFLAGS -flto" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=/usr/lib${SYSTEMBITS} ..  || exit 1
make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-${version}-$ARCH-1.txz
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
sed -i "s|-O2 |$GCCFLAGS -flto |g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

currentPackage=SVT-AV1
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mkdir package
version=$(curl -s https://gitlab.com/AOMediaCodec/${currentPackage}/-/tags?format=atom | grep ' <title>' | grep -v rc | sort -V -r | head -1 | cut -d '>' -f 2 | cut -d '<' -f 1)
wget https://gitlab.com/AOMediaCodec/${currentPackage}/-/archive/${version}/${currentPackage}-${version}.tar.gz
tar xvf ${currentPackage}-${version}.tar.gz && cd ${currentPackage}-${version}
mkdir build && cd build
cmake -DCMAKE_C_FLAGS:STRING="$GCCFLAGS" -DCMAKE_CXX_FLAGS:STRING="$GCCFLAGS" -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_INSTALL_LIBDIR:PATH=/usr/lib${SYSTEMBITS} -Wno-dev -DBUILD_DEC=OFF ..
make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage}/package
cd $MODULEPATH/${currentPackage}/package
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage,,}-${version//[vV]}-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage,,}-${version//[vV]}-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=dav1d
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget https://code.videolan.org/videolan/${currentPackage}/-/archive/master/${currentPackage}-master.tar.gz || exit 1
tar xvf ${currentPackage}-master.tar.gz && rm ${currentPackage}-master.tar.gz || exit 1
cd ${currentPackage}-master
version=$(date -r . +%Y%m%d)
mkdir build && cd build
CFLAGS="$GCCFLAGS -flto" meson -Denable_tests=false -Denable_tools=false --prefix /usr ..
DESTDIR=$MODULEPATH/${currentPackage}/package ninja -j${NUMBERTHREADS} install || exit 1
cd $MODULEPATH/${currentPackage}/package
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

# temporary just to build ffmpeg and mpv
currentPackage=nv-codec-headers
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget ${SLACKWAREDOMAIN}/slackware/slackware64-current/source/d/${currentPackage}/${currentPackage}.SlackBuild || exit 1
if [ $SLACKWAREVERSION == "current" ]; then
	info=$(DownloadLatestFromGithub "FFmpeg" ${currentPackage})
	version=${info#* }
else
	version="12.0.16.1"
	wget https://github.com/FFmpeg/${currentPackage}/releases/download/n${version}/${currentPackage}-${version}.tar.gz
fi
sh ${currentPackage}.SlackBuild || exit 1
installpkg /tmp/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}
rm /tmp/${currentPackage}*.t?z

# required by libplacebo
installpkg $MODULEPATH/packages/python-pip-*.t?z || exit 1
rm $MODULEPATH/packages/python-pip-*.t?z || exit 1
installpkg $MODULEPATH/packages/python-Jinja2-*.t?z || exit 1
rm $MODULEPATH/packages/python-Jinja2-*.t?z || exit 1
installpkg $MODULEPATH/packages/python-MarkupSafe-*.t?z || exit 1
rm $MODULEPATH/packages/python-MarkupSafe-*.t?z || exit 1
installpkg $MODULEPATH/packages/vulkan-sdk-*.t?z || exit 1
rm $MODULEPATH/packages/vulkan-sdk-*.t?z || exit 1

cd $MODULEPATH
pip install glad2 || exit 1

if [ $SLACKWAREVERSION != "current" ]; then
	currentPackage=meson
	sh $SCRIPTPATH/../extras/${currentPackage}/${currentPackage}.SlackBuild || exit 1
	/sbin/upgradepkg --install-new --reinstall $MODULEPATH/packages/${currentPackage}-*.txz
	rm -fr $MODULEPATH/${currentPackage}
	rm $MODULEPATH/packages/meson-*.txz
fi

currentPackage=libplacebo
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
version=$(curl -s https://code.videolan.org/videolan/${currentPackage}/-/tags?format=atom | grep ' <title>' | grep -v rc | head -1 | cut -d '>' -f 2 | cut -d '<' -f 1)
version=${version//[vV]}
wget ${SLACKWAREDOMAIN}/slackware/slackware64-current/source/l/${currentPackage}/${currentPackage}.SlackBuild || exit 1
wget https://code.videolan.org/videolan/${currentPackage}/-/archive/v${version}/${currentPackage}-v${version}.tar.gz
cp $SCRIPTPATH/extras/${currentPackage}/meson.build.patch . || exit 1
sed -i "s|chown -R.*|patch -p0 < \${CWD}/meson\.build\.patch \|\| exit 1\nchown -R root:root \.|g" ${currentPackage}.SlackBuild
sed -i "s|\$PKGNAM-\$VERSION-\$ARCH|\$PKGNAM-\${VERSION//[vV]}-\$ARCH|g" ${currentPackage}.SlackBuild
sed -i "s|glslang=enabled|glslang=disabled -Dvulkan=disabled -Dshaderc=disabled |g" ${currentPackage}.SlackBuild
sed -i "s|-O2 |$GCCFLAGS -flto |g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

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
sed -i "s|\./configure \\\\|\./configure \\\\\n  --enable-nvdec --enable-nvenc --disable-ffplay \\\\|g" ${currentPackage}.SlackBuild
sed -i "s|-O2.*|$GCCFLAGS\"|g" ${currentPackage}.SlackBuild
sed -i "s|\$TAG||g" ${currentPackage}.SlackBuild
AOM=no GLSLANG=no SHADERC=no VULKAN=no ASS=yes OPENCORE=yes GSM=yes RTMP=yes TWOLAME=yes XVID=yes X265=yes X264=yes DAV1D=yes AAC=yes SVTAV1=yes sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

# required by mpv
currentPackage=LuaJIT
mkdir $MODULEPATH/${currentPackage,,} && cd $MODULEPATH/${currentPackage,,}
git clone https://github.com/${currentPackage}/${currentPackage}
cd LuaJIT
version=`git --git-dir=.git log -1 --date=format:"%Y%m%d" --format="%ad"`
sed -i -e '/-DLUAJIT_ENABLE_LUA52COMPAT/s/^#//' src/Makefile
CFLAGS="$GCCFLAGS" CXXFLAGS="$GCCFLAGS" make -j${NUMBERTHREADS} Q= PREFIX=/usr INSTALL_LIB=/usr/lib$SYSTEMBITS || exit 1
make Q= PREFIX=/usr INSTALL_LIB=$MODULEPATH/${currentPackage,,}/package/usr/lib$SYSTEMBITS install DESTDIR=$MODULEPATH/${currentPackage,,}/package || exit 1
rm -fr $MODULEPATH/${currentPackage,,}/package/usr/bin
cd $MODULEPATH/${currentPackage,,}/package
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage,,}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage,,}*.t?z
rm -fr $MODULEPATH/${currentPackage,,}

currentPackage=mpv
USE_PIPEWIRE=yes sh $SCRIPTPATH/extras/${currentPackage}/${currentPackage}.SlackBuild || exit 1
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

rm -R usr/share/ffmpeg/examples
rm -R usr/share/lua

rm usr/bin/alsoft-config
rm usr/share/applications/mimeinfo.cache

GenericStrip

# move out things that don't support aggressive stripping
AggressiveStrip

### copy cache files

PrepareFilesForCache

### generate cache files

GenerateCaches

### finalize

Finalize
