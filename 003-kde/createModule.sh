#!/bin/bash

MODULENAME=003-kde

source "$PWD/../builder-utils/setflags.sh"

SetFlags "$MODULENAME"

source "$BUILDERUTILSPATH/cachefiles.sh"
source "$BUILDERUTILSPATH/genericstrip.sh"
source "$BUILDERUTILSPATH/helper.sh"
source "$BUILDERUTILSPATH/slackwarerepository.sh"

if ! isRoot; then
	echo "Please enter admin's password below:"
	su -c "$0 $1"
	exit
fi

### create module folder

mkdir -p $MODULEPATH/packages > /dev/null 2>&1
cd $MODULEPATH

### download packages from slackware repository

sh $SCRIPTPATH/downloadPackages.sh

### packages that require specific stripping

LATESTVERSION=$(ls -a $MODULEPATH/packages/plasma-desktop-* | rev | cut -d - -f 3 | rev)
echo -e "Building KDE Plasma ${LATESTVERSION} based on Slackware ${SLACKWAREVERSION} ${ARCH}...\n"
MODULENAME=$MODULENAME-${LATESTVERSION}

currentPackage=qt6
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv $MODULEPATH/packages/${currentPackage}-[0-9]* .
installpkg ${currentPackage}*.txz || exit 1
packageFileName=$(ls * -a | rev | cut -d . -f 2- | rev)
ROOT=./ installpkg ${currentPackage}*.txz
mkdir ${currentPackage}-stripped
rm usr/lib$SYSTEMBITS/*.prl
cp --parents -P usr/lib$SYSTEMBITS/libQt6Concurrent.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6Core.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6Core5Compat.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6DBus.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6EglFsKmsSupport.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6Gui.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6LabsFolderListModel.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6LabsPlatform.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6LabsQmlModels.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6Multimedia.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6MultimediaQuick.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6MultimediaWidgets.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6Network.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6OpenGL.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6OpenGLWidgets.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6Positioning.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6PrintSupport.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6Qml.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QmlCore.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QmlMeta.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QmlModels.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QmlWorkerScript.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6Quick.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QuickControls2.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QuickControls2Basic.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QuickControls2BasicStyleImpl.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QuickControls2Fusion.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QuickControls2FusionStyleImpl.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QuickControls2Impl.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QuickDialogs2.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QuickDialogs2QuickImpl.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QuickDialogs2Utils.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QuickEffects.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QuickLayouts.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QuickParticles.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QuickShapes.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QuickTemplates2.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6QuickWidgets.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6Sensors.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6SerialPort.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6ShaderTools.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6Sql.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6Svg.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6SvgWidgets.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6TextToSpeech.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6WaylandClient.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6WaylandCompositor.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6WaylandEglCompositorHwIntegration.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6Widgets.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6XcbQpa.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQt6Xml.* "${currentPackage}-stripped"
cp --parents -R usr/lib$SYSTEMBITS/qt6/bin/qdbus "${currentPackage}-stripped"
cp --parents -R usr/lib$SYSTEMBITS/qt6/plugins/egldeviceintegrations/* "${currentPackage}-stripped"
cp --parents -R usr/lib$SYSTEMBITS/qt6/plugins/generic/* "${currentPackage}-stripped"
cp --parents -R usr/lib$SYSTEMBITS/qt6/plugins/iconengines/* "${currentPackage}-stripped"
cp --parents -R usr/lib$SYSTEMBITS/qt6/plugins/imageformats/* "${currentPackage}-stripped"
cp --parents -R usr/lib$SYSTEMBITS/qt6/plugins/networkinformation/* "${currentPackage}-stripped"
cp --parents -R usr/lib$SYSTEMBITS/qt6/plugins/platforminputcontexts/* "${currentPackage}-stripped"
cp --parents -R usr/lib$SYSTEMBITS/qt6/plugins/platforms/* "${currentPackage}-stripped"
cp --parents -R usr/lib$SYSTEMBITS/qt6/plugins/printsupport/* "${currentPackage}-stripped"
cp --parents -R usr/lib$SYSTEMBITS/qt6/plugins/qmltooling/* "${currentPackage}-stripped"
cp --parents -R usr/lib$SYSTEMBITS/qt6/plugins/sensors/* "${currentPackage}-stripped"
cp --parents -R usr/lib$SYSTEMBITS/qt6/plugins/sqldrivers/* "${currentPackage}-stripped"
cp --parents -R usr/lib$SYSTEMBITS/qt6/plugins/texttospeech/* "${currentPackage}-stripped"
cp --parents -R usr/lib$SYSTEMBITS/qt6/plugins/tls/* "${currentPackage}-stripped"
cp --parents -R usr/lib$SYSTEMBITS/qt6/plugins/wayland*/* "${currentPackage}-stripped"
cp --parents -R usr/lib$SYSTEMBITS/qt6/plugins/xcbglintegrations/* "${currentPackage}-stripped"
cp --parents -R usr/lib$SYSTEMBITS/qt6/qml/Qt/labs/* "${currentPackage}-stripped"
cp --parents -R usr/lib$SYSTEMBITS/qt6/qml/Qt5Compat/* "${currentPackage}-stripped"
cp --parents -R usr/lib$SYSTEMBITS/qt6/qml/QtCore/* "${currentPackage}-stripped"
cp --parents -R usr/lib$SYSTEMBITS/qt6/qml/QtMultimedia/* "${currentPackage}-stripped"
cp --parents -R usr/lib$SYSTEMBITS/qt6/qml/QtPositioning/* "${currentPackage}-stripped"
cp --parents -R usr/lib$SYSTEMBITS/qt6/qml/QtQml/* "${currentPackage}-stripped"
cp --parents -R usr/lib$SYSTEMBITS/qt6/qml/QtQuick/* "${currentPackage}-stripped"
cp --parents -R usr/lib$SYSTEMBITS/qt6/qml/QtQuick3D/* "${currentPackage}-stripped"
cp --parents -R usr/lib$SYSTEMBITS/qt6/qml/QtSensors/* "${currentPackage}-stripped"
cp --parents -R usr/lib$SYSTEMBITS/qt6/qml/QtTest/* "${currentPackage}-stripped"
cp --parents -R usr/lib$SYSTEMBITS/qt6/qml/QtWayland/* "${currentPackage}-stripped"
cp --parents -R usr/lib$SYSTEMBITS/qt6/qml/QtWebChannel/* "${currentPackage}-stripped"
cp --parents -R usr/lib$SYSTEMBITS/qt6/qml/QtWebSockets/* "${currentPackage}-stripped"
cd ${currentPackage}-stripped
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${packageFileName}_stripped.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

# required by main menu
currentPackage=appstream
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv $MODULEPATH/packages/${currentPackage}-[0-9]* .
installpkg ${currentPackage}*.txz || exit 1
packageVersion=$(ls * -a | rev | cut -d'-' -f3 | rev)
ROOT=./ installpkg ${currentPackage}*.txz
mkdir ${currentPackage}-stripped
cp --parents -P usr/lib$SYSTEMBITS/libAppStreamQt.* "${currentPackage}-stripped"
cd ${currentPackage}-stripped
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage}-qt-${packageVersion}_stripped.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

# required by spectacle
currentPackage=opencv
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv $MODULEPATH/packages/${currentPackage}-[0-9]* .
installpkg ${currentPackage}*.txz || exit 1
packageFileName=$(ls * -a | rev | cut -d . -f 2- | rev)
ROOT=./ installpkg ${currentPackage}*.txz
mkdir ${currentPackage}-stripped
cp --parents -P usr/lib$SYSTEMBITS/libopencv_imgproc.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libopencv_core.* "${currentPackage}-stripped"
cd ${currentPackage}-stripped
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${packageFileName}_stripped.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

# also required by spectacle
currentPackage=gcc-gfortran
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv $MODULEPATH/packages/${currentPackage}-[0-9]* .
installpkg ${currentPackage}*.txz || exit 1
packageFileName=$(ls * -a | rev | cut -d . -f 2- | rev)
ROOT=./ installpkg ${currentPackage}*.txz
mkdir ${currentPackage}-stripped
cp --parents -P usr/lib$SYSTEMBITS/libgfortran.so* "${currentPackage}-stripped"
cd ${currentPackage}-stripped
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${packageFileName}_stripped.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

# required by dolphin and others
currentPackage=phonon
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv $MODULEPATH/packages/${currentPackage}-[0-9]* .
packageFileName=$(ls * -a | rev | cut -d . -f 2- | rev)
ROOT=./ installpkg ${currentPackage}*.txz
mkdir ${currentPackage}-stripped
cp --parents -P -r usr/lib$SYSTEMBITS/qt6 "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libphonon4qt6* "${currentPackage}-stripped"
cd ${currentPackage}-stripped
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${packageFileName}_stripped.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

currentPackage=qcoro
mkdir $MODULEPATH/${currentPackage} && cd $MODULEPATH/${currentPackage}
mv $MODULEPATH/packages/${currentPackage}-[0-9]* .
installpkg ${currentPackage}*.txz || exit 1
packageFileName=$(ls * -a | rev | cut -d . -f 2- | rev)
ROOT=./ installpkg ${currentPackage}*.txz
mkdir ${currentPackage}-stripped
cp --parents -P usr/lib$SYSTEMBITS/libQCoro6Core.* "${currentPackage}-stripped"
cp --parents -P usr/lib$SYSTEMBITS/libQCoro6DBus.* "${currentPackage}-stripped"
cd ${currentPackage}-stripped
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${packageFileName}_stripped.txz > /dev/null 2>&1
rm -fr $MODULEPATH/${currentPackage}

### packages outside slackware repository

currentPackage=audacious
QT=6 sh $SCRIPTPATH/../common/${currentPackage}/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=audacious-plugins
QT=6 sh $SCRIPTPATH/../common/${currentPackage}/${currentPackage}.SlackBuild || exit 1
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
installpkg $MODULEPATH/packages/${package}*.txz || exit 1
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
rm etc/kde/xdg/autostart/baloo_file.desktop
rm etc/kde/xdg/autostart/kaccess.desktop
rm etc/kde/xdg/autostart/xembedsniproxy.desktop
rm usr/bin/kwalletmanager*
rm usr/bin/oxygen-demo5
rm usr/bin/oxygen-gtk-demo
rm usr/bin/systemmonitor
rm usr/bin/UserFeedbackConsole
rm usr/lib${SYSTEMBITS}/libKF5*
rm usr/lib${SYSTEMBITS}/libKF6PeopleBackend*
rm usr/lib${SYSTEMBITS}/libKF6PeopleWidgets*
rm usr/lib${SYSTEMBITS}/liboxygenstyle5*
rm usr/lib${SYSTEMBITS}/liboxygenstyleconfig5*
rm usr/lib${SYSTEMBITS}/libphonon4qt5*
rm usr/lib${SYSTEMBITS}/libpolkit-qt5*
rm usr/lib${SYSTEMBITS}/libqca-qt5*
rm usr/lib${SYSTEMBITS}/libQCoro5*
rm usr/lib${SYSTEMBITS}/qt6/plugins/designer/phonon4qt6widgets.so
rm usr/lib${SYSTEMBITS}/qt6/plugins/egldeviceintegrations/libqeglfs-emu-integration.so
rm usr/lib${SYSTEMBITS}/qt6/plugins/egldeviceintegrations/libqeglfs-kms-egldevice-integration.so
rm usr/lib${SYSTEMBITS}/qt6/plugins/egldeviceintegrations/libqeglfs-kms-integration.so
rm usr/lib${SYSTEMBITS}/qt6/plugins/egldeviceintegrations/libqeglfs-x11-integration.so
rm usr/lib${SYSTEMBITS}/qt6/plugins/imageformats/libqmng.so
rm usr/lib${SYSTEMBITS}/qt6/plugins/imageformats/libqpdf.so
rm usr/lib${SYSTEMBITS}/qt6/plugins/platforminputcontexts/libqtvirtualkeyboardplugin.so
rm usr/lib${SYSTEMBITS}/qt6/plugins/platforms/libqeglfs.so
rm usr/lib${SYSTEMBITS}/qt6/plugins/qmltooling/libqmldbg_quick3dprofiler.so
rm usr/lib${SYSTEMBITS}/qt6/plugins/sqldrivers/libqsqlmysql.so
rm usr/lib${SYSTEMBITS}/qt6/plugins/sqldrivers/libqsqlodbc.so
rm usr/lib${SYSTEMBITS}/qt6/plugins/styles/breeze5.so
rm usr/lib${SYSTEMBITS}/qt6/plugins/texttospeech/libqtexttospeech_speechd.so
rm usr/lib${SYSTEMBITS}/qt6/plugins/wayland-shell-integration/libwl-shell-plugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/Qt/labs/animation/liblabsanimationplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/Qt/labs/lottieqt/liblottieplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/Qt/labs/lottieqt/VectorImageHelpers/liblottievectorimagehelpersplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/Qt/labs/settings/libqmlsettingsplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/Qt/labs/sharedimage/libsharedimageplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/Qt/labs/synchronizer/liblabssynchronizerplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/Qt/labs/wavefrontmesh/libqmlwavefrontmeshplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/QtPositioning/libpositioningquickplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/QtQml/StateMachine/libqtqmlstatemachineplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/QtQml/XmlListModel/libqmlxmllistmodelplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/QtQuick/Controls/FluentWinUI3/impl/libqtquickcontrols2fluentwinui3styleimplplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/QtQuick/Controls/FluentWinUI3/libqtquickcontrols2fluentwinui3styleplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/QtQuick/Controls/Imagine/impl/libqtquickcontrols2imaginestyleimplplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/QtQuick/Controls/Imagine/libqtquickcontrols2imaginestyleplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/QtQuick/Controls/Material/impl/libqtquickcontrols2materialstyleimplplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/QtQuick/Controls/Material/libqtquickcontrols2materialstyleplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/QtQuick/Controls/Universal/impl/libqtquickcontrols2universalstyleimplplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/QtQuick/Controls/Universal/libqtquickcontrols2universalstyleplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/QtQuick/LocalStorage/libqmllocalstorageplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/QtQuick/Pdf/libpdfquickplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/QtQuick/Scene2D/libqtquickscene2dplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/QtQuick/Scene3D/libqtquickscene3dplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/QtQuick/Shapes/DesignHelpers/libqtquickshapesdesignhelpersplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/QtQuick/Timeline/BlendTrees/libqtquicktimelineblendtreesplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/QtQuick/Timeline/libqtquicktimelineplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/QtQuick/VectorImage/Helpers/libqquickvectorimagehelpersplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/QtQuick/VectorImage/libqquickvectorimageplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/QtQuick3D/AssetUtils/libqtquick3dassetutilsplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/QtQuick3D/Effects/libqtquick3deffectplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/QtQuick3D/Helpers/impl/libqtquick3dhelpersimplplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/QtQuick3D/Helpers/libqtquick3dhelpersplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/QtQuick3D/libqquick3dplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/QtQuick3D/ParticleEffects/libqtquick3dparticleeffectsplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/QtQuick3D/Particles3D/libqtquick3dparticles3dplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/QtQuick3D/Physics/Helpers/libqtquick3dphysicshelpersplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/QtQuick3D/Physics/libqquick3dphysicsplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/QtQuick3D/SpatialAudio/libquick3dspatialaudioplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/QtSensors/libsensorsquickplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/QtWebChannel/libwebchannelquickplugin.so
rm usr/lib${SYSTEMBITS}/qt6/qml/QtWebSockets/libqmlwebsocketsplugin.so
rm usr/share/applications/org.kde.dolphinsu.desktop
rm usr/share/applications/org.kde.kuserfeedback-console.desktop
rm usr/share/applications/org.kde.kwalletd*.desktop
rm usr/share/applications/org.kde.plasma.emojier.desktop
rm usr/share/icons/breeze/breeze-icons.rcc
rm usr/share/icons/breeze-dark/breeze-icons-dark.rcc
rm usr/share/plasma/avatars/*

rm -fr boot/
rm -fr lib/
rm -fr lib64/
rm -fr usr/lib${SYSTEMBITS}/qt5
rm -fr usr/lib${SYSTEMBITS}/qt6/qml/QtQuick/VirtualKeyboard
rm -fr usr/lib${SYSTEMBITS}/qt6/qml/QtTest
rm -fr usr/lib${SYSTEMBITS}/qt6/mkspecs
rm -fr usr/share/chromium
rm -fr usr/share/emoticons/EmojiOne
rm -fr usr/share/featherpad
rm -fr usr/share/gdb
rm -fr usr/share/gdm
rm -fr usr/share/gnome
rm -fr usr/share/google-chrome
rm -fr usr/share/icons/breeze*/*/64/
rm -fr usr/share/katepart6
rm -fr usr/share/kde4
rm -fr usr/share/kf6/kdoctools
rm -fr usr/share/kf6/locale
rm -fr usr/share/kf6/searchproviders
rm -fr usr/share/konqueror
rm -fr usr/share/kscreen
rm -fr usr/share/ksplash/Themes/Classic
rm -fr usr/share/kwin-x11/kcm_kwintabbox
rm -fr usr/share/phonon4qt6
rm -fr usr/share/plasma/desktoptheme/air
rm -fr usr/share/plasma/desktoptheme/oxygen
rm -fr usr/share/plasma/emoji
rm -fr usr/share/plasma/look-and-feel/org.kde.oxygen
rm -fr usr/share/plasma/nightcolor
rm -fr usr/share/sddm/themes/breeze/preview*
rm -fr usr/share/sddm/themes/elarun
rm -fr usr/share/sddm/themes/maldives
rm -fr usr/share/sddm/themes/maya
rm -fr usr/share/sddm/translations
rm -fr usr/share/themes/Breeze-Dark/gtk-4.0
rm -fr usr/share/themes/Breeze/gtk-4.0

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
