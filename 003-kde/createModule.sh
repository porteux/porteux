#!/bin/bash

MODULENAME=003-kde

source "$PWD/../builder-utils/setflags.sh"

SetFlags "$MODULENAME"

source "$BUILDERUTILSPATH/cachefiles.sh"
source "$BUILDERUTILSPATH/downloadfromslackware.sh"
source "$BUILDERUTILSPATH/genericstrip.sh"
source "$BUILDERUTILSPATH/helper.sh"
source "$BUILDERUTILSPATH/latestfromgithub.sh"

[ $SLACKWAREVERSION != "current" ] && echo "This module should be built in current only" && exit 1

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

DE_LATEST_VERSION=$(ls plasma-desktop-* | cut -d "-" -f 3)
MODULENAME=$MODULENAME-${DE_LATEST_VERSION}

### packages that require specific stripping

currentPackage=qt6
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv $MODULEPATH/packages/${currentPackage}-[0-9]* .
installpkg ${currentPackage}*.txz || exit 1
version=`ls * -a | cut -d'-' -f2- | sed 's/\.txz$//'`
ROOT=./ installpkg ${currentPackage}-*.txz
mkdir ${currentPackage}-stripped-$version
rm usr/lib$SYSTEMBITS/*.prl
cp --parents -P usr/lib$SYSTEMBITS/libQt6Concurrent.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6Core.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6Core5Compat.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6DBus.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6EglFsKmsSupport.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6Gui.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6LabsPlatform.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6LabsQmlModels.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6Multimedia.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6MultimediaQuick.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6Network.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6OpenGL.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6OpenGLWidgets.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6Positioning.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6PrintSupport.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6Qml.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QmlCore.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QmlMeta.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QmlModels.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QmlWorkerScript.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6Quick.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QuickControls2.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QuickControls2Basic.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QuickControls2BasicStyleImpl.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QuickControls2Fusion.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QuickControls2FusionStyleImpl.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QuickControls2Impl.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QuickDialogs2.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QuickDialogs2QuickImpl.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QuickDialogs2Utils.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QuickEffects.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QuickLayouts.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QuickParticles.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QuickShapes.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QuickTemplates2.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QuickWidgets.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6Sensors.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6SerialPort.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6ShaderTools.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6Sql.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6Svg.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6SvgWidgets.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6TextToSpeech.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6WaylandClient.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6WaylandEglClientHwIntegration.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6Widgets.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6XcbQpa.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQt6Xml.* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt6/bin/qdbus "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt6/plugins/egldeviceintegrations/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt6/plugins/generic/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt6/plugins/iconengines/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt6/plugins/imageformats/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt6/plugins/networkinformation/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt6/plugins/platforminputcontexts/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt6/plugins/platforms/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt6/plugins/printsupport/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt6/plugins/qmltooling/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt6/plugins/sensors/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt6/plugins/sqldrivers/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt6/plugins/texttospeech/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt6/plugins/tls/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt6/plugins/wayland*/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt6/plugins/xcbglintegrations/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt6/qml/Qt/labs/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt6/qml/Qt5Compat/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt6/qml/QtCore/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt6/qml/QtMultimedia/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt6/qml/QtPositioning/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt6/qml/QtQml/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt6/qml/QtQuick/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt6/qml/QtQuick3D/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt6/qml/QtSensors/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt6/qml/QtTest/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt6/qml/QtWayland/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt6/qml/QtWebChannel/* "${currentPackage}-stripped-$version"
cp --parents -R usr/lib$SYSTEMBITS/qt6/qml/QtWebSockets/* "${currentPackage}-stripped-$version"
cd ${currentPackage}-stripped-$version
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-stripped-$version-1.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

# required by spectacle
currentPackage=opencv
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv $MODULEPATH/packages/${currentPackage}-[0-9]* .
installpkg ${currentPackage}*.txz || exit 1
version=`ls * -a | cut -d'-' -f2- | sed 's/\.txz$//'`
ROOT=./ installpkg ${currentPackage}-*.txz
mkdir ${currentPackage}-stripped-$version
cp --parents -P usr/lib$SYSTEMBITS/libopencv_imgproc.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libopencv_core.* "${currentPackage}-stripped-$version"
cd ${currentPackage}-stripped-$version
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-stripped-$version-1.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

# also required by spectacle
currentPackage=gcc-gfortran
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv $MODULEPATH/packages/${currentPackage}-[0-9]* .
installpkg ${currentPackage}*.txz || exit 1
version=`ls * -a | cut -d'-' -f2- | sed 's/\.txz$//'`
ROOT=./ installpkg ${currentPackage}-*.txz
mkdir ${currentPackage}-stripped-$version
cp --parents -P usr/lib$SYSTEMBITS/libgfortran.so* "${currentPackage}-stripped-$version"
cd ${currentPackage}-stripped-$version
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-stripped-$version-1.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

# required by dolphin and others
currentPackage=phonon
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv $MODULEPATH/packages/${currentPackage}-[0-9]* .
version=`ls * -a | cut -d'-' -f2- | sed 's/\.txz$//'`
ROOT=./ installpkg ${currentPackage}-*.txz
mkdir ${currentPackage}-stripped-$version
cp --parents -P -r usr/lib$SYSTEMBITS/qt6 "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libphonon4qt6* "${currentPackage}-stripped-$version"
cd ${currentPackage}-stripped-$version
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-stripped-$version-1.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=qcoro
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv $MODULEPATH/packages/${currentPackage}-[0-9]* .
installpkg ${currentPackage}*.txz || exit 1
version=`ls * -a | cut -d'-' -f2- | sed 's/\.txz$//'`
ROOT=./ installpkg ${currentPackage}-*.txz
mkdir ${currentPackage}-stripped-$version
cp --parents -P usr/lib$SYSTEMBITS/libQCoro6Core.* "${currentPackage}-stripped-$version"
cp --parents -P usr/lib$SYSTEMBITS/libQCoro6DBus.* "${currentPackage}-stripped-$version"
cd ${currentPackage}-stripped-$version
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-stripped-$version-1.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

### packages outside slackware repository

currentPackage=audacious
QT=6 sh $SCRIPTPATH/../common/audacious/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=audacious-plugins
QT=6 sh $SCRIPTPATH/../common/audacious/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

# required by featherpad
installpkg $MODULEPATH/packages/hunspell*.txz || exit 1

currentPackage=featherpad
sh $SCRIPTPATH/extras/${currentPackage}/${currentPackage}.SlackBuild || exit 1
rm -fr $MODULEPATH/${currentPackage}

# kde deps
for package in \
	extra-cmake-modules \
	kimageformats \
; do
sh $SCRIPTPATH/deps/${package}/${package}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${package}-*.txz || exit 1
find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# only required for building
rm $MODULEPATH/packages/extra-cmake-modules*.txz

### fake root

cd $MODULEPATH/packages && ROOT=./ installpkg *.t?z
rm *.t?z

### install additional packages, including porteux utils

InstallAdditionalPackages

### fix some .desktop files

sed -i "s|Graphics;||g" $MODULEPATH/packages/usr/share/applications/org.kde.okular.desktop
sed -i "s|image/png|image/png;image/jxl|g" $MODULEPATH/packages/usr/share/applications/org.kde.gwenview.desktop

### disable some services

rm $MODULEPATH/packages/usr/share/dbus-1/services/org.kde.runners.baloo.service
rm $MODULEPATH/packages/etc/xdg/autostart/baloo_file.desktop
mv $MODULEPATH/packages/usr/libexec/baloorunner $MODULEPATH/packages/usr/libexec/baloorunner_

### copy build files to 05-devel

CopyToDevel

### copy language files to 08-multilanguage

CopyToMultiLanguage

### module clean up

cd $MODULEPATH/packages/

{
rm usr/bin/kwalletmanager*
rm usr/bin/oxygen-demo5
rm usr/bin/oxygen-gtk-demo
rm usr/bin/systemmonitor
rm usr/bin/UserFeedbackConsole
rm etc/kde/xdg/autostart/baloo_file.desktop
rm etc/kde/xdg/autostart/kaccess.desktop
rm etc/kde/xdg/autostart/xembedsniproxy.desktop
rm usr/lib${SYSTEMBITS}/libKF5*
rm usr/lib${SYSTEMBITS}/libKF6PeopleBackend*
rm usr/lib${SYSTEMBITS}/libKF6PeopleWidgets*
rm usr/lib${SYSTEMBITS}/liboxygenstyle5*
rm usr/lib${SYSTEMBITS}/liboxygenstyleconfig5*
rm usr/lib${SYSTEMBITS}/libphonon4qt5*
rm usr/lib${SYSTEMBITS}/libpolkit-qt5*
rm usr/lib${SYSTEMBITS}/libqca-qt5*
rm usr/lib${SYSTEMBITS}/libQCoro5*

rm usr/share/applications/org.kde.dolphinsu.desktop
rm usr/share/applications/org.kde.kuserfeedback-console.desktop
rm usr/share/applications/org.kde.kwalletd*.desktop
rm usr/share/applications/org.kde.plasma.emojier.desktop
rm usr/share/icons/breeze/breeze-icons.rcc
rm usr/share/icons/breeze-dark/breeze-icons-dark.rcc
rm usr/share/plasma/avatars/*

rm -R boot/
rm -R lib/
rm -R lib64/
rm -R usr/lib${SYSTEMBITS}/qt5
rm -R usr/lib${SYSTEMBITS}/qt6/qml/QtQuick/VirtualKeyboard
rm -R usr/lib${SYSTEMBITS}/qt6/qml/QtTest
rm -R usr/lib${SYSTEMBITS}/qt6/mkspecs
rm -R usr/share/chromium
rm -R usr/share/emoticons/EmojiOne
rm -R usr/share/featherpad
rm -R usr/share/gdb
rm -R usr/share/gdm
rm -R usr/share/gnome
rm -R usr/share/google-chrome
rm -R usr/share/icons/breeze*/*/64/
rm -R usr/share/katepart6
rm -R usr/share/kde4
rm -R usr/share/kf6/kdoctools
rm -R usr/share/kf6/locale
rm -R usr/share/kf6/searchproviders
rm -R usr/share/konqueror
rm -R usr/share/kscreen
rm -R usr/share/ksplash/Themes/Classic
rm -R usr/share/phonon4qt6
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

find usr/share/wallpapers -mindepth 1 -maxdepth 1 ! \( -name "body-background.png" \) -exec rm -rf '{}' \; 2>/dev/null
find usr/share/icons -mindepth 1 -maxdepth 1 ! \( -name "breeze" -o -name "breeze-dark" -o -name "hicolor" \) -exec rm -rf '{}' \; 2>/dev/null

[ "$SYSTEMBITS" == 64 ] && find usr/lib/ -mindepth 1 -maxdepth 1 ! \( -name "python*" \) -exec rm -rf '{}' \; 2>/dev/null
find usr/share/plasma/avatars/photos -mindepth 1 ! \( -name "Air Balloon.png" -o -name "Air Balloon.png.license" -o -name "Astronaut.png" -o -name "Astronaut.png.license" \) -exec rm -rf '{}' \; 2>/dev/null
} >/dev/null 2>&1

GenericStrip

# move out things that don't support aggressive stripping
mv $MODULEPATH/packages/usr/lib${SYSTEMBITS}/libgwenviewlib.so* $MODULEPATH/
AggressiveStripAll
mv $MODULEPATH/libgwenviewlib.so* $MODULEPATH/packages/usr/lib${SYSTEMBITS}

### copy cache files

PrepareFilesForCacheDE

### generate cache files

GenerateCachesDE

### kde specific mime cache

rm -fr $PORTEUXBUILDERPATH/caches/mime/packages
cp -r $PORTEUXBUILDERPATH/caches/mime $MODULEPATH/packages/usr/share/

### finalize

Finalize
