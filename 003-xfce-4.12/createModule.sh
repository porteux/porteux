#!/bin/sh
MODULENAME=003-xfce-4.12

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

currentPackage=xcape
mkdir $MODULEPATH/$currentPackage && cd $MODULEPATH/$currentPackage
wget -r -nd --no-parent $SLACKBUILDREPOSITORY/misc/$currentPackage/ -A * || exit 1
info=$(DownloadLatestFromGithub "alols" $currentPackage)
version=${info#* }
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" $currentPackage.SlackBuild
sed -i "s|TAG=\${TAG:-_SBo}|TAG=|g" $currentPackage.SlackBuild
sed -i "s|PKGTYPE=\${PKGTYPE:-tgz}|PKGTYPE=\${PKGTYPE:-txz}|g" $currentPackage.SlackBuild
sh $currentPackage.SlackBuild || exit 1
mv /tmp/$currentPackage*.t?z $MODULEPATH/packages
installpkg $MODULEPATH/packages/$currentPackage*.t?z
rm -fr $MODULEPATH/$currentPackage

# required by most of the packages
installpkg $MODULEPATH/packages/gtk+2*.txz || exit 1

currentPackage=gpicview
version=0.2.5
mkdir $MODULEPATH/$currentPackage && cd $MODULEPATH/$currentPackage
git clone https://github.com/lxde/gpicview || exit 1
cd $currentPackage
./autogen.sh
CFLAGS="-g -O3 -feliminate-unused-debug-types -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=32 -Wformat -Wformat-security -m64 -fasynchronous-unwind-tables -Wp,-D_REENTRANT -ftree-loop-distribute-patterns -Wl,-z -Wl,now -Wl,-z -Wl,relro -fno-semantic-interposition -ffat-lto-objects -fno-trapping-math -Wl,-sort-common -Wl,--enable-new-dtags -mtune=skylake -Wa,-mbranches-within-32B-boundaries -flto -fuse-linker-plugin -DNDEBUG" ./configure --prefix=/usr --libdir=/usr/lib64 --sysconfdir=/etc --disable-static --disable-debug
make -j8 install DESTDIR=$MODULEPATH/$currentPackage/package || exit 1
cd $MODULEPATH/$currentPackage/package
/sbin/makepkg -l y -c n $MODULEPATH/packages/$currentPackage-$version-$ARCH-1.txz
rm -fr $MODULEPATH/$currentPackage

currentPackage=lxdm
mkdir $MODULEPATH/$currentPackage && cd $MODULEPATH/$currentPackage
cp -R $SCRIPTPATH/../lxdm/* .
GTK3=no sh $currentPackage.SlackBuild || exit 1
rm -fr $MODULEPATH/$currentPackage

currentPackage=epdfview
version=0.1.8
mkdir $MODULEPATH/$currentPackage && cd $MODULEPATH/$currentPackage
cp $SCRIPTPATH/extras/$currentPackage/$currentPackage-$version.tar.?z .
tar xvf $currentPackage-$version.tar.?z || exit 1
cd $currentPackage-$version
CXXFLAGS="-O2 -m64 -pipe -fPIC -DNDEBUG" ./configure --prefix=/usr --libdir=/usr/lib64 --sysconfdir=/etc --disable-static --disable-debug
make -j8 install DESTDIR=$MODULEPATH/$currentPackage/package || exit 1
cd $MODULEPATH/$currentPackage/package
/sbin/makepkg -l y -c n $MODULEPATH/packages/$currentPackage-$version-$ARCH-1.txz
rm -fr $MODULEPATH/$currentPackage

currentPackage=audacious
mkdir $MODULEPATH/$currentPackage && cd $MODULEPATH/$currentPackage
info=$(DownloadLatestFromGithub "audacious-media-player" $currentPackage)
#version=${info#* }
version="4.3-beta1"
cp $SCRIPTPATH/extras/audacious/$currentPackage-gtk.SlackBuild .
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" $currentPackage-gtk.SlackBuild
sh $currentPackage-gtk.SlackBuild || exit 1
rm -fr $MODULEPATH/$currentPackage

currentPackage=audacious-plugins
mkdir $MODULEPATH/$currentPackage && cd $MODULEPATH/$currentPackage
info=$(DownloadLatestFromGithub "audacious-media-player" $currentPackage)
#version=${info#* }
version="4.3-beta1"
cp $SCRIPTPATH/extras/audacious/$currentPackage-gtk.SlackBuild .
sed -i "s|VERSION=\${VERSION.*|VERSION=\${VERSION:-$version}|g" $currentPackage-gtk.SlackBuild
sh $currentPackage-gtk.SlackBuild || exit 1
rm -fr $MODULEPATH/$currentPackage

# temporary just to build engrampa and mate-search-tool
currentPackage=mate-common
mkdir $MODULEPATH/$currentPackage && cd $MODULEPATH/$currentPackage
info=$(DownloadLatestFromGithub "mate-desktop" $currentPackage)
version=${info#* }
filename=${info% *}
tar xvf $filename && rm $filename || exit 1
cd $currentPackage*
sh autogen.sh --prefix=/usr --libdir=/usr/lib$SYSTEMBITS --sysconfdir=/etc
make -j8 install || exit 1
rm -fr $MODULEPATH/$currentPackage

# temporary to build yelp-tools
installpkg $MODULEPATH/packages/python-pip*.txz || exit 1
rm $MODULEPATH/packages/python-pip*.txz
cd $MODULEPATH
pip install lxml || exit 1

# temporary to build yelp-tools
currentPackage=yelp-xsl
mkdir $MODULEPATH/$currentPackage && cd $MODULEPATH/$currentPackage
info=$(DownloadLatestFromGithub "GNOME" $currentPackage)
version=${info#* }
filename=${info% *}
tar xvf $filename && rm $filename || exit 1
cd $currentPackage*
sh autogen.sh --prefix=/usr --libdir=/usr/lib$SYSTEMBITS --sysconfdir=/etc
make -j8 install || exit 1
rm -fr $MODULEPATH/$currentPackage

# temporary to build engrampa and mate-search-tool
currentPackage=yelp-tools
mkdir $MODULEPATH/$currentPackage && cd $MODULEPATH/$currentPackage
info=$(DownloadLatestFromGithub "GNOME" $currentPackage)
version=${info#* }
filename=${info% *}
tar xvf $filename && rm $filename || exit 1
cd $currentPackage*
mkdir build && cd build
meson --prefix /usr ..
ninja -j8 install || exit 1
rm -fr $MODULEPATH/$currentPackage

# required from now on
installpkg $MODULEPATH/packages/libcanberra*.txz || exit 1
installpkg $MODULEPATH/packages/libgtop*.txz || exit 1
rm $MODULEPATH/packages/libgtop*.txz

currentPackage=mate-utils
mkdir $MODULEPATH/$currentPackage && cd $MODULEPATH/$currentPackage
info=$(DownloadLatestFromGithub "mate-desktop" $currentPackage)
version=${info#* }
filename=${info% *}
tar xvf $filename && rm $filename || exit 1
cd $currentPackage*
sed -i "s|baobab||g" ./Makefile.am
sed -i "s|mate-dictionary||g" ./Makefile.am
sed -i "s|mate-screenshot||g" ./Makefile.am
sed -i "s|logview||g" ./Makefile.am
CFLAGS="-O2 -m64 -pipe -fPIC -DNDEBUG" ./autogen.sh --prefix=/usr --libdir=/usr/lib$SYSTEMBITS --sysconfdir=/etc --disable-static --disable-debug --disable-gdict-applet --disable-disk-image-mounter || exit
make -j8 install DESTDIR=$MODULEPATH/$currentPackage/package || exit 1
cd $MODULEPATH/$currentPackage/package
wget https://raw.githubusercontent.com/mate-desktop/mate-desktop/v$version/schemas/org.mate.interface.gschema.xml -P usr/share/glib-2.0/schemas || exit 1
/sbin/makepkg -l y -c n $MODULEPATH/packages/mate-search-tool-$version-$ARCH-1.txz
rm -fr $MODULEPATH/$currentPackage

currentPackage=engrampa
mkdir $MODULEPATH/$currentPackage && cd $MODULEPATH/$currentPackage
info=$(DownloadLatestFromGithub "mate-desktop" $currentPackage)
version=${info#* }
filename=${info% *}
tar xvf $filename && rm $filename || exit 1
cd $currentPackage*
CFLAGS="-O2 -m64 -pipe -fPIC -DNDEBUG" sh autogen.sh --prefix=/usr --libdir=/usr/lib$SYSTEMBITS --sysconfdir=/etc --disable-static --disable-debug --disable-caja-actions || exit 1
make -j8 && make install DESTDIR=$MODULEPATH/$currentPackage/package || exit 1
cd $MODULEPATH/$currentPackage/package
/sbin/makepkg -l y -c n $MODULEPATH/packages/$currentPackage-$version-$ARCH-1.txz
rm -fr $MODULEPATH/$currentPackage

currentPackage=gtksourceview
version=2.10.5
mkdir $MODULEPATH/$currentPackage && cd $MODULEPATH/$currentPackage
wget https://download.gnome.org/sources/gtksourceview/2.10/gtksourceview-$version.tar.gz || exit 1
tar xvf $currentPackage-$version.tar.?z || exit 1
cd $currentPackage-$version
CFLAGS="-O2 -m64 -pipe -fPIC -DNDEBUG" ./configure --prefix=/usr --libdir=/usr/lib64 --sysconfdir=/etc --disable-static --disable-debug
make -j8 install DESTDIR=$MODULEPATH/$currentPackage/package || exit 1
cd $MODULEPATH/$currentPackage/package
/sbin/makepkg -l y -c n $MODULEPATH/packages/$currentPackage-$version-$ARCH-1.txz
installpkg $MODULEPATH/packages/$currentPackage-$version-$ARCH-1.txz
rm -fr $MODULEPATH/$currentPackage

# required by xfce4-panel
installpkg $MODULEPATH/packages/libwnck-*.txz || exit 1

# required by xfce4-pulseaudio-plugin
installpkg $MODULEPATH/packages/keybinder3*.txz || exit 1

# required by xfce4-xkb-plugin
installpkg $MODULEPATH/packages/libxklavier-*.txz || exit 1

# xfce packages
for package in \
xfce4-dev-tools \
libxfce4util \
xfconf \
libxfce4ui \
exo \
garcon \
xfce4-panel \
thunar \
thunar-volman \
tumbler \
xfce4-appfinder \
xfce4-power-manager \
xfce4-settings \
xfdesktop \
xfwm4 \
xfce4-session \
xfce4-taskmanager \
xfce4-terminal \
xfce4-screenshooter \
xfce4-notifyd \
mousepad \
xfce4-clipman-plugin \
xfce4-cpugraph-plugin \
xfce4-pulseaudio-plugin \
xfce4-sensors-plugin \
xfce4-systemload-plugin \
xfce4-whiskermenu-plugin \
xfce4-xkb-plugin \
; do
cd $SCRIPTPATH/xfce/$package || exit 1
sh ${package}.SlackBuild || exit 1
rm -fr $MODULEPATH/package-${package}
rm -fr $MODULEPATH/${package}-*
done

rm $MODULEPATH/package-Thunar
rm $MODULEPATH/Thunar-*

### fake root

cd $MODULEPATH/packages && ROOT=./ installpkg *.t?z
rm *.t?z

### install additional packages, including porteux utils

InstallAdditionalPackages

### make main menu more beautiful

patch --no-backup-if-mismatch -d $MODULEPATH/packages/ -p0 < $SCRIPTPATH/extras/xfce/xfce-applications.menu.patch

### make panel more beautiful

patch --no-backup-if-mismatch -d $MODULEPATH/packages/ -p0 < $SCRIPTPATH/extras/adwaita/main.rc.patch
cp $SCRIPTPATH/extras/adwaita/focus-line.png $MODULEPATH/packages/usr/share/themes/Adwaita-dark/gtk-2.0/assets/
sed -i "s|gtk-color-scheme = \"fg_color.*|gtk-color-scheme = \"fg_color:#2e3436\\\\nbg_color:#F8F8F7\"|g" $MODULEPATH/packages/usr/share/themes/Adwaita/gtk-2.0/gtkrc
echo ".xfce4-panel.background { background-color:  #33393b; }" >> $MODULEPATH/packages/usr/share/themes/Adwaita-dark/gtk-3.0/gtk.css
echo "#pulseaudio-button { background-color:  #33393b; }" >> $MODULEPATH/packages/usr/share/themes/Adwaita-dark/gtk-3.0/gtk.css

### fix some .desktop files

sed -i "s|Categories=System;|Categories=|g" $MODULEPATH/packages/usr/share/applications/Thunar.desktop
sed -i "s|Graphics;||g" $MODULEPATH/packages/usr/share/applications/epdfview.desktop
sed -i "s|Graphics;||g" $MODULEPATH/packages/usr/share/applications/gpicview.desktop
sed -i "s|Utility;||g" $MODULEPATH/packages/usr/share/applications/xfce4-taskmanager.desktop
sed -i "s|System;||g" $MODULEPATH/packages/usr/share/applications/Thunar-bulk-rename.desktop
sed -i "s|System;||g" $MODULEPATH/packages/usr/share/applications/xfce4-sensors.desktop
sed -i "s|Core;||g" $MODULEPATH/packages/usr/share/applications/gpicview.desktop

### add xfce session

sed -i "s|SESSIONTEMPLATE|/usr/bin/startxfce4|g" $MODULEPATH/packages/etc/lxdm/lxdm.conf

### copy xinitrc

mkdir -p $MODULEPATH/packages/etc/X11/xinit
cp $SCRIPTPATH/xfce/xfce4-session/xinitrc.xfce $MODULEPATH/packages/etc/X11/xinit/
chmod 0755 $MODULEPATH/packages/etc/X11/xinit/xinitrc.xfce

### copy build files to 05-devel

CopyToDevel

### module clean up

cd $MODULEPATH/packages/

rm -R usr/lib
rm -R usr/lib64/gnome-settings-daemon-3.0
rm -R usr/lib64/python2.7
rm -R usr/share/engrampa
rm -R usr/share/gnome
rm -R usr/share/gdm
rm -R usr/share/themes/Daloa
rm -R usr/share/themes/Default/balou
rm -R usr/share/themes/Kokodi
rm -R usr/share/themes/Moheli
rm -R usr/share/Thunar

rm etc/xdg/autostart/blueman.desktop
rm etc/xdg/autostart/xfce4-clipman-plugin-autostart.desktop
rm etc/xdg/autostart/xscreensaver.desktop
rm usr/bin/canberra*
rm usr/lib64/libkeybinder.*
rm usr/lib64/libpoppler-qt5*
rm usr/share/applications/exo*
rm usr/share/backgrounds/xfce/xfce-stripes.png
rm usr/share/backgrounds/xfce/xfce-teal.jpg
rm usr/share/backgrounds/xfce/xfce-verticals.png
rm usr/share/icons/hicolor/scalable/status/computer.svg
rm usr/share/icons/hicolor/scalable/status/keyboard.svg
rm usr/share/icons/hicolor/scalable/status/phone.svg

GenericStrip

### copy cache files

PrepareFilesForCache

### generate cache files

GenerateCaches

### finalize

Finalize
