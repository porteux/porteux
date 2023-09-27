#!/bin/sh
MODULENAME=003-lxde

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

currentPackage=acpilight
version=20201001
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
cp $SCRIPTPATH/extras/${currentPackage}/${currentPackage}-$version.tar.gz .
tar xvf ${currentPackage}-$version.tar.?z || exit 1
cd ${currentPackage}-$version
make install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=xcape
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/misc/${currentPackage}/ -A * || exit 1
info=$(DownloadLatestFromGithub "alols" ${currentPackage})
version=${info#* }
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" ${currentPackage}.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" ${currentPackage}.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" ${currentPackage}.SlackBuild
sh ${currentPackage}.SlackBuild || exit 1
mv /tmp/${currentPackage}*.t?z $MODULEPATH/packages
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

currentPackage=gpicview
version=0.2.5
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/lxde/gpicview || exit 1
cd ${currentPackage}
./autogen.sh
CFLAGS="-g -O3 -feliminate-unused-debug-types -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fstack-protector --param=ssp-buffer-size=32 -Wformat -Wformat-security -m64 -fasynchronous-unwind-tables -Wp,-D_REENTRANT -ftree-loop-distribute-patterns -Wl,-z -Wl,now -Wl,-z -Wl,relro -fno-semantic-interposition -ffat-lto-objects -fno-trapping-math -Wl,-sort-common -Wl,--enable-new-dtags -mtune=skylake -Wa,-mbranches-within-32B-boundaries -flto -fuse-linker-plugin -DNDEBUG" ./configure --prefix=/usr --libdir=/usr/lib$SYSTEMBITS --sysconfdir=/etc --disable-static --disable-debug --enable-gtk3
make -j$NUMBERTHREADS install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=lxdm
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
cp -R $SCRIPTPATH/../${currentPackage}/* .
GTK3=yes sh ${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=atril
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
info=$(DownloadLatestFromGithub "mate-desktop" ${currentPackage})
version=${info#* }
cp $SCRIPTPATH/extras/${currentPackage}/${currentPackage}.SlackBuild .
sh ${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=l3afpad
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/stevenhoneyman/${currentPackage}
cd ${currentPackage}
version=`git log -1 --date=format:"%Y%m%d" --format="%ad"`
sh autogen.sh
CFLAGS="-O3 -m64 -pipe -fPIC -DNDEBUG" ./configure --prefix=/usr --libdir=/usr/lib64 --sysconfdir=/etc --disable-static --disable-debug || exit 1
make -j$NUMBERTHREADS && make install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=audacious
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
info=$(DownloadLatestFromGithub "audacious-media-player" ${currentPackage})
version=${info#* }
cp $SCRIPTPATH/extras/audacious/${currentPackage}-gtk.SlackBuild .
sh ${currentPackage}-gtk.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=audacious-plugins
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
info=$(DownloadLatestFromGithub "audacious-media-player" ${currentPackage})
version=${info#* }
cp $SCRIPTPATH/extras/audacious/${currentPackage}-gtk.SlackBuild .
sh ${currentPackage}-gtk.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

# temporary just to build engrampa and mate-search-tool
currentPackage=mate-common
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
info=$(DownloadLatestFromGithub "mate-desktop" ${currentPackage})
version=${info#* }
filename=${info% *}
tar xvf $filename && rm $filename || exit 1
cd ${currentPackage}*
sh autogen.sh --prefix=/usr --libdir=/usr/lib$SYSTEMBITS --sysconfdir=/etc
make -j$NUMBERTHREADS install || exit 1
rm -fr $MODULEPATH/${currentPackage}

# temporary to build yelp-tools
installpkg $MODULEPATH/packages/python-pip*.txz || exit 1
rm $MODULEPATH/packages/python-pip*.txz
cd $MODULEPATH
pip install lxml || exit 1

# temporary to build yelp-tools
currentPackage=yelp-xsl
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
info=$(DownloadLatestFromGithub "GNOME" ${currentPackage})
version=${info#* }
filename=${info% *}
tar xvf $filename && rm $filename || exit 1
cd ${currentPackage}*
sh autogen.sh --prefix=/usr --libdir=/usr/lib$SYSTEMBITS --sysconfdir=/etc
make -j$NUMBERTHREADS install || exit 1
rm -fr $MODULEPATH/${currentPackage}

# temporary to build engrampa and mate-search-tool
currentPackage=yelp-tools
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
info=$(DownloadLatestFromGithub "GNOME" ${currentPackage})
version=${info#* }
filename=${info% *}
tar xvf $filename && rm $filename || exit 1
cd ${currentPackage}*
mkdir build && cd build
meson --prefix /usr ..
ninja -j$NUMBERTHREADS install || exit 1
rm -fr $MODULEPATH/${currentPackage}

# required from now on
installpkg $MODULEPATH/packages/libcanberra*.txz || exit 1

currentPackage=engrampa
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
info=$(DownloadLatestFromGithub "mate-desktop" ${currentPackage})
version=${info#* }
filename=${info% *}
tar xvf $filename && rm $filename || exit 1
cd ${currentPackage}*
CFLAGS="-O3 -m64 -pipe -fPIC -DNDEBUG" sh autogen.sh --prefix=/usr --libdir=/usr/lib$SYSTEMBITS --sysconfdir=/etc --disable-static --disable-debug --disable-caja-actions || exit 1
make -j$NUMBERTHREADS && make install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=gnome-screenshot
version=3.36.0 # higher than this will require libhandy
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget https://gitlab.gnome.org/GNOME/${currentPackage}/-/archive/$version/${currentPackage}-$version.tar.gz || exit 1
tar xvf ${currentPackage}-$version.tar.?z || exit 1
cd ${currentPackage}-$version
mkdir build && cd build
sed -i "s|i18n.merge_file('desktop',|i18n.merge_file(|g" ../src/meson.build
sed -i "s|i18n.merge_file('appdata',|i18n.merge_file(|g" ../src/meson.build
meson -Dcpp_args="-O3 -pipe -fPIC -DNDEBUG" --prefix /usr ..
ninja -j$NUMBERTHREADS || exit 1
DESTDIR=$MODULEPATH/${currentPackage}/package ninja install
cd $MODULEPATH/${currentPackage}/package
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}*.t?z
rm -fr $MODULEPATH/${currentPackage}

currentPackage=libfm-extra
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/lxde/libfm ${currentPackage}
cd ${currentPackage}
version=`git describe | cut -d- -f1`
./autogen.sh --prefix=/usr --without-gtk --disable-demo && CFLAGS="-g -O3 -feliminate-unused-debug-types -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=32 -Wformat -Wformat-security -fasynchronous-unwind-tables -Wp,-D_REENTRANT -ftree-loop-distribute-patterns -Wl,-z -Wl,now -Wl,-z -Wl,relro -fno-semantic-interposition -ffat-lto-objects -fno-trapping-math -Wl,-sort-common -Wl,--enable-new-dtags -mtune=skylake -Wa,-mbranches-within-32B-boundaries -flto -fuse-linker-plugin" \
./configure \
	--prefix=/usr \
	--libdir=/usr/lib$SYSTEMBITS \
	--localstatedir=/var \
	--enable-static=no \
	--enable-udisks \
	--with-gtk=3 \
	--with-extra-only 
	
make -j$NUMBERTHREADS && make install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=menu-cache
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/lxde/${currentPackage}
cd ${currentPackage}
version=`git describe | cut -d- -f1`
sh ./autogen.sh && CFLAGS="-g -O3 -feliminate-unused-debug-types -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=32 -Wformat -Wformat-security -fasynchronous-unwind-tables -Wp,-D_REENTRANT -ftree-loop-distribute-patterns -Wl,-z -Wl,now -Wl,-z -Wl,relro -fno-semantic-interposition -ffat-lto-objects -fno-trapping-math -Wl,-sort-common -Wl,--enable-new-dtags -mtune=skylake -Wa,-mbranches-within-32B-boundaries -flto -fuse-linker-plugin" \
./configure \
  --prefix=/usr \
  --libdir=/usr/lib$SYSTEMBITS \
  --localstatedir=/var \
  --sysconfdir=/etc \
  --mandir=/usr/man \
  --enable-static=no \
  --program-prefix= \
  --program-suffix= 

make -j$NUMBERTHREADS && make install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=libfm
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/lxde/${currentPackage}
cd ${currentPackage}
version=`git describe | cut -d- -f1`
./autogen.sh --prefix=/usr --without-gtk --disable-demo && CFLAGS="-g -O3 -feliminate-unused-debug-types -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=32 -Wformat -Wformat-security -fasynchronous-unwind-tables -Wp,-D_REENTRANT -ftree-loop-distribute-patterns -Wl,-z -Wl,now -Wl,-z -Wl,relro -fno-semantic-interposition -ffat-lto-objects -fno-trapping-math -Wl,-sort-common -Wl,--enable-new-dtags -mtune=skylake -Wa,-mbranches-within-32B-boundaries -flto -fuse-linker-plugin" \
./configure \
	--prefix=/usr \
	--libdir=/usr/lib$SYSTEMBITS \
	--localstatedir=/var \
	--with-gtk=3 \
	--enable-static=no
	
make -j$NUMBERTHREADS && make install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=pcmanfm
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/lxde/${currentPackage}
cd ${currentPackage}
version=`git describe | cut -d- -f1`
./autogen.sh && CFLAGS="-g -O3 -feliminate-unused-debug-types -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=32 -Wformat -Wformat-security -fasynchronous-unwind-tables -Wp,-D_REENTRANT -ftree-loop-distribute-patterns -Wl,-z -Wl,now -Wl,-z -Wl,relro -fno-semantic-interposition -ffat-lto-objects -fno-trapping-math -Wl,-sort-common -Wl,--enable-new-dtags -mtune=skylake -Wa,-mbranches-within-32B-boundaries -flto -fuse-linker-plugin" \
./configure \
	--prefix=/usr \
	--libdir=/usr/lib$SYSTEMBITS \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--with-gtk=3 \
	--enable-static=no
	
make -j$NUMBERTHREADS && make install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=lxterminal
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/lxde/${currentPackage}
cd ${currentPackage}
version=`git describe | cut -d- -f1`
./autogen.sh && CFLAGS="-g -O3 -feliminate-unused-debug-types -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=32 -Wformat -Wformat-security -fasynchronous-unwind-tables -Wp,-D_REENTRANT -ftree-loop-distribute-patterns -Wl,-z -Wl,now -Wl,-z -Wl,relro -fno-semantic-interposition -ffat-lto-objects -fno-trapping-math -Wl,-sort-common -Wl,--enable-new-dtags -mtune=skylake -Wa,-mbranches-within-32B-boundaries -flto -fuse-linker-plugin" \
./configure \
	--prefix=/usr \
	--libdir=/usr/lib$SYSTEMBITS \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--enable-gtk3 \
	--enable-man
	
make -j$NUMBERTHREADS && make install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=lxtask
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/lxde/${currentPackage}
cd ${currentPackage}
version=`git describe | cut -d- -f1`
./autogen.sh && CFLAGS="-g -O3 -feliminate-unused-debug-types -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=32 -Wformat -Wformat-security -fasynchronous-unwind-tables -Wp,-D_REENTRANT -ftree-loop-distribute-patterns -Wl,-z -Wl,now -Wl,-z -Wl,relro -fno-semantic-interposition -ffat-lto-objects -fno-trapping-math -Wl,-sort-common -Wl,--enable-new-dtags -mtune=skylake -Wa,-mbranches-within-32B-boundaries -flto -fuse-linker-plugin" \
./configure \
	--prefix=/usr \
	--libdir=/usr/lib$SYSTEMBITS \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--enable-gtk3 \
	--enable-static=no

make -j$NUMBERTHREADS && make install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=lxrandr
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/lxde/${currentPackage}
cd ${currentPackage}
version=`git describe | cut -d- -f1`
./autogen.sh && CFLAGS="-g -O3 -feliminate-unused-debug-types -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=32 -Wformat -Wformat-security -fasynchronous-unwind-tables -Wp,-D_REENTRANT -ftree-loop-distribute-patterns -Wl,-z -Wl,now -Wl,-z -Wl,relro -fno-semantic-interposition -ffat-lto-objects -fno-trapping-math -Wl,-sort-common -Wl,--enable-new-dtags -mtune=skylake -Wa,-mbranches-within-32B-boundaries -flto -fuse-linker-plugin" \
./configure \
	--prefix=/usr \
	--libdir=/usr/lib$SYSTEMBITS \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--enable-man \
	--enable-gtk3

make -j$NUMBERTHREADS && make install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=lxsession
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/lxde/${currentPackage}
cd ${currentPackage}
version=`git describe | cut -d- -f1`
./autogen.sh && CFLAGS="-g -O3 -feliminate-unused-debug-types -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=32 -Wformat -Wformat-security -fasynchronous-unwind-tables -Wp,-D_REENTRANT -ftree-loop-distribute-patterns -Wl,-z -Wl,now -Wl,-z -Wl,relro -fno-semantic-interposition -ffat-lto-objects -fno-trapping-math -Wl,-sort-common -Wl,--enable-new-dtags -mtune=skylake -Wa,-mbranches-within-32B-boundaries -flto -fuse-linker-plugin" \
./configure \
	--prefix=/usr \
	--libdir=/usr/lib$SYSTEMBITS \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--enable-gtk3 \
	--enable-static=no
	
make -j$NUMBERTHREADS && make install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=lxmenu-data
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/lxde/${currentPackage}
cd ${currentPackage}
version=`git describe | cut -d- -f1`
./autogen.sh && CFLAGS="-g -O3 -feliminate-unused-debug-types -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=32 -Wformat -Wformat-security -fasynchronous-unwind-tables -Wp,-D_REENTRANT -ftree-loop-distribute-patterns -Wl,-z -Wl,now -Wl,-z -Wl,relro -fno-semantic-interposition -ffat-lto-objects -fno-trapping-math -Wl,-sort-common -Wl,--enable-new-dtags -mtune=skylake -Wa,-mbranches-within-32B-boundaries -flto -fuse-linker-plugin" \
./configure \
	--prefix=/usr \
	--libdir=/usr/lib$SYSTEMBITS \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--enable-gtk3 \
	--enable-static=no
	
make -j$NUMBERTHREADS && make install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=lxlauncher
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/lxde/${currentPackage}
cd ${currentPackage}
version=`git describe | cut -d- -f1`
./autogen.sh && CFLAGS="-g -O3 -feliminate-unused-debug-types -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=32 -Wformat -Wformat-security -fasynchronous-unwind-tables -Wp,-D_REENTRANT -ftree-loop-distribute-patterns -Wl,-z -Wl,now -Wl,-z -Wl,relro -fno-semantic-interposition -ffat-lto-objects -fno-trapping-math -Wl,-sort-common -Wl,--enable-new-dtags -mtune=skylake -Wa,-mbranches-within-32B-boundaries -flto -fuse-linker-plugin" \
./configure \
	--prefix=/usr \
	--libdir=/usr/lib$SYSTEMBITS \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--enable-gtk3 \
	--enable-static=no
	
make -j$NUMBERTHREADS && make install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=lxinput
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/lxde/${currentPackage}
cd ${currentPackage}
version=`git describe | cut -d- -f1`
./autogen.sh && CFLAGS="-g -O3 -feliminate-unused-debug-types -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=32 -Wformat -Wformat-security -fasynchronous-unwind-tables -Wp,-D_REENTRANT -ftree-loop-distribute-patterns -Wl,-z -Wl,now -Wl,-z -Wl,relro -fno-semantic-interposition -ffat-lto-objects -fno-trapping-math -Wl,-sort-common -Wl,--enable-new-dtags -mtune=skylake -Wa,-mbranches-within-32B-boundaries -flto -fuse-linker-plugin" \
./configure \
	--prefix=/usr \
	--libdir=/usr/lib$SYSTEMBITS \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--enable-gtk3 \
	--enable-man
	
make -j$NUMBERTHREADS && make install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=lxhotkey
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/lxde/${currentPackage}
cd ${currentPackage}
version=`git describe | cut -d- -f1`
./autogen.sh && CFLAGS="-g -O3 -feliminate-unused-debug-types -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=32 -Wformat -Wformat-security -fasynchronous-unwind-tables -Wp,-D_REENTRANT -ftree-loop-distribute-patterns -Wl,-z -Wl,now -Wl,-z -Wl,relro -fno-semantic-interposition -ffat-lto-objects -fno-trapping-math -Wl,-sort-common -Wl,--enable-new-dtags -mtune=skylake -Wa,-mbranches-within-32B-boundaries -flto -fuse-linker-plugin" \
./configure \
	--prefix=/usr \
	--libdir=/usr/lib$SYSTEMBITS \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--enable-gtk3 \
	--enable-static=no
	
make -j$NUMBERTHREADS && make install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=lxde-common
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/lxde/${currentPackage}
cd ${currentPackage}
version=`git describe | cut -d- -f1`
./autogen.sh && CFLAGS="-g -O3 -feliminate-unused-debug-types -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=32 -Wformat -Wformat-security -fasynchronous-unwind-tables -Wp,-D_REENTRANT -ftree-loop-distribute-patterns -Wl,-z -Wl,now -Wl,-z -Wl,relro -fno-semantic-interposition -ffat-lto-objects -fno-trapping-math -Wl,-sort-common -Wl,--enable-new-dtags -mtune=skylake -Wa,-mbranches-within-32B-boundaries -flto -fuse-linker-plugin" \
./configure \
	--prefix=/usr \
	--libdir=/usr/lib$SYSTEMBITS \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--enable-gtk3 \
	--enable-static=no
	
make -j$NUMBERTHREADS && make install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=lxappearance
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/lxde/${currentPackage}
cd ${currentPackage}
version=`git describe | cut -d- -f1`
./autogen.sh && CFLAGS="-g -O3 -feliminate-unused-debug-types -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=32 -Wformat -Wformat-security -fasynchronous-unwind-tables -Wp,-D_REENTRANT -ftree-loop-distribute-patterns -Wl,-z -Wl,now -Wl,-z -Wl,relro -fno-semantic-interposition -ffat-lto-objects -fno-trapping-math -Wl,-sort-common -Wl,--enable-new-dtags -mtune=skylake -Wa,-mbranches-within-32B-boundaries -flto -fuse-linker-plugin" \
./configure \
	--prefix=/usr \
	--libdir=/usr/lib$SYSTEMBITS \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--enable-gtk3 \
	--enable-dbus \
	--enable-man \
	--enable-static=no
	
make -j$NUMBERTHREADS && make install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=lxappearance-obconf
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/lxde/${currentPackage}
cd ${currentPackage}
version=`git describe | cut -d- -f1`
./autogen.sh && CFLAGS="-g -O3 -feliminate-unused-debug-types -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=32 -Wformat -Wformat-security -fasynchronous-unwind-tables -Wp,-D_REENTRANT -ftree-loop-distribute-patterns -Wl,-z -Wl,now -Wl,-z -Wl,relro -fno-semantic-interposition -ffat-lto-objects -fno-trapping-math -Wl,-sort-common -Wl,--enable-new-dtags -mtune=skylake -Wa,-mbranches-within-32B-boundaries -flto -fuse-linker-plugin" \
./configure \
	--prefix=/usr \
	--libdir=/usr/lib$SYSTEMBITS \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--enable-gtk3 \
	--enable-static=no
	
make -j$NUMBERTHREADS && make install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

# required by lxpanel
installpkg $MODULEPATH/packages/libwnck3-*.txz
installpkg $MODULEPATH/packages/keybinder3*.txz

currentPackage=lxpanel
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
git clone https://github.com/lxde/${currentPackage}
cd ${currentPackage}
version=`git describe | cut -d- -f1`
./autogen.sh && CFLAGS="-g -O3 -feliminate-unused-debug-types -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=32 -Wformat -Wformat-security -fasynchronous-unwind-tables -Wp,-D_REENTRANT -ftree-loop-distribute-patterns -Wl,-z -Wl,now -Wl,-z -Wl,relro -fno-semantic-interposition -ffat-lto-objects -fno-trapping-math -Wl,-sort-common -Wl,--enable-new-dtags -mtune=skylake -Wa,-mbranches-within-32B-boundaries -flto -fuse-linker-plugin" \
./configure \
	--prefix=/usr \
	--libdir=/usr/lib$SYSTEMBITS \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--enable-gtk3 \
	--with-plugins=all \
	--program-prefix= \
    --disable-silent-rules \
	--enable-static=no

cp $SCRIPTPATH/extras/lxde/lxpanel*.patch .
for i in *.patch; do patch -p0 < $i; done

make -j$NUMBERTHREADS && make install DESTDIR=$MODULEPATH/${currentPackage}/package || exit 1
cd $MODULEPATH/${currentPackage}/package
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/${currentPackage}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=kora
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
wget https://github.com/bikass/${currentPackage}/archive/refs/heads/master.tar.gz || exit 1
tar xvf master.tar.gz && rm master.tar.gz || exit 1
cd ${currentPackage}-master
version=$(date -r . +%Y%m%d)
iconRootFolder=../${currentPackage}-$version-noarch/usr/share/icons/${currentPackage}
lightIconRootFolder=../${currentPackage}-$version-noarch/usr/share/icons/${currentPackage}-light
mkdir -p $iconRootFolder
mkdir -p $lightIconRootFolder
cp -r ${currentPackage}/* $iconRootFolder || exit 1
cp -r ${currentPackage}-light/* $lightIconRootFolder || exit 1
gtk-update-icon-cache -f $iconRootFolder || exit 1
gtk-update-icon-cache -f $lightIconRootFolder || exit 1
cd ../${currentPackage}-$version-noarch
echo "Generating icon package. This may take a while..."
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-icon-theme-$version-noarch.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

### fake root

cd $MODULEPATH/packages && ROOT=./ installpkg *.t?z
rm *.t?z

### install additional packages, including porteux utils

InstallAdditionalPackages

### fix some .desktop files

sed -i "s|Core;|Utility;|g" $MODULEPATH/packages/usr/share/applications/gpicview.desktop
sed -i "s|image/x-xpixmap|image/x-xpixmap;image/heic|g" $MODULEPATH/packages/usr/share/applications/gpicview.desktop
sed -i "s|System;|Utility;|g" $MODULEPATH/packages/usr/share/applications/pcmanfm.desktop

### add lxde session

sed -i "s|SESSIONTEMPLATE|/usr/bin/lxsession|g" $MODULEPATH/packages/etc/lxdm/lxdm.conf

### copy build files to 05-devel

CopyToDevel

### module clean up

cd $MODULEPATH/packages/

rm etc/xdg/autostart/blueman.desktop
rm usr/bin/canberra*
rm usr/lib64/libkeybinder.*
rm usr/lib64/libpoppler-qt5*
rm usr/share/lxde/wallpapers/lxde_green.jpg
rm usr/share/lxde/wallpapers/lxde_red.jpg

rm -R usr/lib
rm -R usr/share/Thunar
rm -R usr/share/engrampa
rm -R usr/share/gdm
rm -R usr/share/gnome

GenericStrip
AggressiveStripAll

### copy cache files

CopyModuleUtils

### copy cache files

PrepareFilesForCache

### generate cache files

GenerateCaches

### finalize

Finalize
