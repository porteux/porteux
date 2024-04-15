#!/bin/sh
MODULENAME=003-kde

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

### packages that require specific stripping

currentPackage=qt5
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv $MODULEPATH/packages/${currentPackage}-[0-9]* .
installpkg qt5*.txz || exit 1
version=`ls * -a | cut -d'-' -f2- | sed 's/\.txz$//'`
ROOT=./ installpkg ${currentPackage}-*.txz
mkdir ${currentPackage}-stripped-$version
cp --parents -P usr/lib$SYSTEMBITS/libQt5Concurrent.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5Core.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5DBus.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5DesignerComponents.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5Designer.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5EglFSDeviceIntegration.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5EglFsKmsSupport.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5Gui.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5Help.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5Multimedia.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5Network.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5OpenGL.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5PrintSupport.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5QmlModels.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5Qml.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5QmlWorkerScript.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5QuickControls2.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5QuickParticles.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5QuickShapes.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5Quick.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5QuickTemplates2.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5QuickTest.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5QuickWidgets.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5Script.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5ScriptTools.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5Sensors.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5SerialPort.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5Sql.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5Svg.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5Test.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5TextToSpeech.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5WaylandClient.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5WaylandCompositor.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5WebChannel.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5Widgets.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5X11Extras.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5XcbQpa.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5XmlPatterns.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt5Xml.* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt5/bin/qdbus "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt5/plugins/bearer/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt5/plugins/egldeviceintegrations/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt5/plugins/generic/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt5/plugins/iconengines/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt5/plugins/imageformats/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt5/plugins/platforminputcontexts/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt5/plugins/platforms/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt5/plugins/printsupport/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt5/plugins/qmltooling/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt5/plugins/sensors/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt5/plugins/sqldrivers/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt5/plugins/texttospeech/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt5/plugins/wayland-decoration-client/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt5/plugins/wayland-graphics-integration-client/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt5/plugins/wayland-graphics-integration-server/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt5/plugins/wayland-shell-integration/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt5/plugins/xcbglintegrations/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt5/qml/Qt/labs/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt5/qml/QtAudioEngine/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt5/qml/QtGraphicalEffects/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt5/qml/QtMultimedia/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt5/qml/QtQml/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt5/qml/QtQuick/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt5/qml/QtQuick.2/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt5/qml/QtSensors/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt5/qml/QtTest/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt5/qml/QtWayland/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt5/qml/QtWebChannel/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt5/qml/QtWebSockets/* "${currentPackage}-stripped-$version"
rm "${currentPackage}-stripped-$version"/usr/lib$SYSTEMBITS/*.prl
cd ${currentPackage}-stripped-$version
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage}-stripped-$version-1.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

### packages outside Slackware repository ###

# required by featherpad
installpkg $MODULEPATH/packages/hunspell*.txz || exit 1

currentPackage=FeatherPad
mkdir $MODULEPATH/${currentPackage,,} && cd $MODULEPATH/${currentPackage,,}
#info=$(DownloadLatestFromGithub "tsujan" ${currentPackage})
#version=${info#* }
#filename=${info% *}
version="1.4.1"
wget https://github.com/tsujan/${currentPackage}/releases/download/V${version}/${currentPackage}-${version}.tar.xz
tar xvf ${currentPackage}-${version}.tar.xz && rm ${currentPackage}-${version}.tar.xz || exit 1
cd ${currentPackage}*
mkdir build && cd build
CXXFLAGS="$GCCFLAGS -flto" cmake -DCMAKE_BUILD_TYPE=release -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=lib${SYSTEMBITS} ..
make -j${NUMBERTHREADS} install DESTDIR=$MODULEPATH/${currentPackage,,}/package || exit 1
cd $MODULEPATH/${currentPackage,,}/package
/sbin/makepkg -l y -c n $MODULEPATH/packages/${currentPackage,,}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage,,}

currentPackage=audacious
QT=yes sh $SCRIPTPATH/../extras/audacious/${currentPackage}/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=audacious-plugins
QT=yes sh $SCRIPTPATH/../extras/audacious/${currentPackage}/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

### fake root

cd $MODULEPATH/packages && ROOT=./ installpkg *.t?z
rm *.t?z

### install additional packages, including porteux utils

InstallAdditionalPackages

### copy wallpaper

mv $MODULEPATH/packages/usr/share/kf5/infopage/body-background.png $MODULEPATH/packages/usr/share/wallpapers

### fix some .desktop files

sed -i "s|Graphics;||g" $MODULEPATH/packages/usr/share/applications/org.kde.okular.desktop
sed -i "s|image/x-xcf|image/x-xcf;image/heic;image/jxl|g" $MODULEPATH/packages/usr/share/applications/org.kde.gwenview.desktop

### copy build files to 05-devel

CopyToDevel

### copy language files to 08-multilanguage

CopyToMultiLanguage

### module clean up

cd $MODULEPATH/packages/

rm usr/bin/systemmonitor
rm usr/share/applications/org.kde.dolphinsu.desktop
rm usr/share/applications/org.kde.plasma.emojier.desktop
rm usr/share/icons/breeze/breeze-icons.rcc
rm usr/share/icons/breeze-dark/breeze-icons-dark.rcc
rm usr/share/plasma/avatars/*

rm -R etc/kde/xdg/autostart/baloo_file.desktop
rm -R etc/kde/xdg/autostart/kaccess.desktop
rm -R etc/kde/xdg/autostart/xembedsniproxy.desktop
rm -R usr/share/chromium
rm -R usr/share/emoticons/EmojiOne
rm -R usr/share/featherpad
rm -R usr/share/gdb
rm -R usr/share/gdm
rm -R usr/share/gnome
rm -R usr/share/google-chrome
rm -R usr/share/icons/breeze_cursors
rm -R usr/share/icons/Breeze_Snow
rm -R usr/share/icons/KDE_Classic
rm -R usr/share/icons/Oxygen_Black
rm -R usr/share/icons/Oxygen_Blue
rm -R usr/share/icons/Oxygen_White
rm -R usr/share/icons/Oxygen_Yellow
rm -R usr/share/icons/Oxygen_Zion
rm -R usr/share/katepart5
rm -R usr/share/kde4
rm -R usr/share/kf5/kdoctools
rm -R usr/share/kf5/locale
rm -R usr/share/ksplash/Themes/Classic
rm -R usr/share/phonon4qt5
rm -R usr/share/plasma/desktoptheme/air
rm -R usr/share/plasma/desktoptheme/oxygen
rm -R usr/share/plasma/emoji
rm -R usr/share/plasma/look-and-feel/org.kde.oxygen
rm -R usr/share/plasma/nightcolor
rm -R usr/share/sddm/themes/breeze/preview*
rm -R usr/share/sddm/themes/elarun
rm -R usr/share/sddm/themes/maldives
rm -R usr/share/sddm/themes/maya
rm -R usr/share/sddm/translations
rm -R usr/share/themes/Breeze-Dark/gtk-4.0
rm -R usr/share/themes/Breeze/gtk-4.0
rm -R usr/share/wallpapers/Next

[ "$SYSTEMBITS" == 64 ] && find usr/lib/ -mindepth 1 -maxdepth 1 ! \( -name "python*" \) -exec rm -rf '{}' \; 2>/dev/null
find usr/share/plasma/avatars/photos -mindepth 1 ! \( -name "Air Balloon.png" -o -name "Air Balloon.png.license" -o -name "Astronaut.png" -o -name "Astronaut.png.license" \) -exec rm -rf '{}' \; 2>/dev/null

GenericStrip
AggressiveStripAll

### copy cache files

PrepareFilesForCache

### generate cache files

GenerateCaches

### kde specific mime cache

rm -fr $PORTEUXBUILDERPATH/caches/mime/packages
cp -r $PORTEUXBUILDERPATH/caches/mime $MODULEPATH/packages/usr/share/

### finalize

Finalize
