#!/bin/bash

MODULE_NAME="003-kde"

source "$PWD/../builder-utils/set-flags.sh"

set_flags "$MODULE_NAME"

source "$BUILDER_UTILS_PATH/cache-files.sh"
source "$BUILDER_UTILS_PATH/generic-strip.sh"
source "$BUILDER_UTILS_PATH/helper.sh"
source "$BUILDER_UTILS_PATH/slackware-repository.sh"

elevate_if_needed "$0" "$@"

### create module folder

mkdir -p $MODULE_PATH/packages > /dev/null 2>&1
cd $MODULE_PATH || exit 1

### download packages from slackware repository

bash $SCRIPT_PATH/download-packages.sh || exit 1

### packages that require specific stripping

LATEST_VERSION=$(ls -a $MODULE_PATH/packages/plasma-desktop-* | rev | cut -d - -f 3 | rev)
[ "$LATEST_VERSION" ] || { echo "Error: could not detect KDE Plasma version." >&2; exit 1; }
echo -e "Building KDE Plasma ${LATEST_VERSION} based on Slackware ${SLACKWARE_VERSION} ${ARCH}...\n"
MODULE_NAME="$MODULE_NAME-${LATEST_VERSION}"

installpkg $MODULE_PATH/packages/qt6-[0-9]*.txz || exit 1

strip_package qt6 \
	usr/lib$SYSTEM_BITS/libQt6Concurrent.* \
	usr/lib$SYSTEM_BITS/libQt6Core.* \
	usr/lib$SYSTEM_BITS/libQt6Core5Compat.* \
	usr/lib$SYSTEM_BITS/libQt6DBus.* \
	usr/lib$SYSTEM_BITS/libQt6EglFsKmsSupport.* \
	usr/lib$SYSTEM_BITS/libQt6Gui.* \
	usr/lib$SYSTEM_BITS/libQt6LabsFolderListModel.* \
	usr/lib$SYSTEM_BITS/libQt6LabsPlatform.* \
	usr/lib$SYSTEM_BITS/libQt6LabsQmlModels.* \
	usr/lib$SYSTEM_BITS/libQt6Multimedia.* \
	usr/lib$SYSTEM_BITS/libQt6MultimediaQuick.* \
	usr/lib$SYSTEM_BITS/libQt6MultimediaWidgets.* \
	usr/lib$SYSTEM_BITS/libQt6Network.* \
	usr/lib$SYSTEM_BITS/libQt6OpenGL.* \
	usr/lib$SYSTEM_BITS/libQt6OpenGLWidgets.* \
	usr/lib$SYSTEM_BITS/libQt6Positioning.* \
	usr/lib$SYSTEM_BITS/libQt6PrintSupport.* \
	usr/lib$SYSTEM_BITS/libQt6Qml.* \
	usr/lib$SYSTEM_BITS/libQt6QmlCore.* \
	usr/lib$SYSTEM_BITS/libQt6QmlMeta.* \
	usr/lib$SYSTEM_BITS/libQt6QmlModels.* \
	usr/lib$SYSTEM_BITS/libQt6QmlWorkerScript.* \
	usr/lib$SYSTEM_BITS/libQt6Quick.* \
	usr/lib$SYSTEM_BITS/libQt6QuickControls2.* \
	usr/lib$SYSTEM_BITS/libQt6QuickControls2Basic.* \
	usr/lib$SYSTEM_BITS/libQt6QuickControls2BasicStyleImpl.* \
	usr/lib$SYSTEM_BITS/libQt6QuickControls2Fusion.* \
	usr/lib$SYSTEM_BITS/libQt6QuickControls2FusionStyleImpl.* \
	usr/lib$SYSTEM_BITS/libQt6QuickControls2Impl.* \
	usr/lib$SYSTEM_BITS/libQt6QuickDialogs2.* \
	usr/lib$SYSTEM_BITS/libQt6QuickDialogs2QuickImpl.* \
	usr/lib$SYSTEM_BITS/libQt6QuickDialogs2Utils.* \
	usr/lib$SYSTEM_BITS/libQt6QuickEffects.* \
	usr/lib$SYSTEM_BITS/libQt6QuickLayouts.* \
	usr/lib$SYSTEM_BITS/libQt6QuickParticles.* \
	usr/lib$SYSTEM_BITS/libQt6QuickShapes.* \
	usr/lib$SYSTEM_BITS/libQt6QuickTemplates2.* \
	usr/lib$SYSTEM_BITS/libQt6QuickWidgets.* \
	usr/lib$SYSTEM_BITS/libQt6Sensors.* \
	usr/lib$SYSTEM_BITS/libQt6SerialPort.* \
	usr/lib$SYSTEM_BITS/libQt6ShaderTools.* \
	usr/lib$SYSTEM_BITS/libQt6Sql.* \
	usr/lib$SYSTEM_BITS/libQt6Svg.* \
	usr/lib$SYSTEM_BITS/libQt6SvgWidgets.* \
	usr/lib$SYSTEM_BITS/libQt6Test.* \
	usr/lib$SYSTEM_BITS/libQt6TextToSpeech.* \
	usr/lib$SYSTEM_BITS/libQt6WaylandClient.* \
	usr/lib$SYSTEM_BITS/libQt6WaylandCompositor.* \
	usr/lib$SYSTEM_BITS/libQt6WaylandEglCompositorHwIntegration.* \
	usr/lib$SYSTEM_BITS/libQt6Widgets.* \
	usr/lib$SYSTEM_BITS/libQt6XcbQpa.* \
	usr/lib$SYSTEM_BITS/libQt6Xml.* \
	usr/lib$SYSTEM_BITS/qt6/bin/qdbus \
	usr/lib$SYSTEM_BITS/qt6/plugins/egldeviceintegrations/* \
	usr/lib$SYSTEM_BITS/qt6/plugins/generic/* \
	usr/lib$SYSTEM_BITS/qt6/plugins/iconengines/* \
	usr/lib$SYSTEM_BITS/qt6/plugins/imageformats/* \
	usr/lib$SYSTEM_BITS/qt6/plugins/networkinformation/* \
	usr/lib$SYSTEM_BITS/qt6/plugins/platforminputcontexts/* \
	usr/lib$SYSTEM_BITS/qt6/plugins/platforms/* \
	usr/lib$SYSTEM_BITS/qt6/plugins/printsupport/* \
	usr/lib$SYSTEM_BITS/qt6/plugins/qmltooling/* \
	usr/lib$SYSTEM_BITS/qt6/plugins/sensors/* \
	usr/lib$SYSTEM_BITS/qt6/plugins/sqldrivers/* \
	usr/lib$SYSTEM_BITS/qt6/plugins/texttospeech/* \
	usr/lib$SYSTEM_BITS/qt6/plugins/tls/* \
	usr/lib$SYSTEM_BITS/qt6/plugins/wayland*/* \
	usr/lib$SYSTEM_BITS/qt6/plugins/xcbglintegrations/* \
	usr/lib$SYSTEM_BITS/qt6/qml/Qt/labs/* \
	usr/lib$SYSTEM_BITS/qt6/qml/Qt5Compat/* \
	usr/lib$SYSTEM_BITS/qt6/qml/QtCore/* \
	usr/lib$SYSTEM_BITS/qt6/qml/QtMultimedia/* \
	usr/lib$SYSTEM_BITS/qt6/qml/QtPositioning/* \
	usr/lib$SYSTEM_BITS/qt6/qml/QtQml/* \
	usr/lib$SYSTEM_BITS/qt6/qml/QtQuick/* \
	usr/lib$SYSTEM_BITS/qt6/qml/QtQuick3D/* \
	usr/lib$SYSTEM_BITS/qt6/qml/QtSensors/* \
	usr/lib$SYSTEM_BITS/qt6/qml/QtTest/* \
	usr/lib$SYSTEM_BITS/qt6/qml/QtWayland/* \
	usr/lib$SYSTEM_BITS/qt6/qml/QtWebChannel/* \
	usr/lib$SYSTEM_BITS/qt6/qml/QtWebSockets/*

# required by network tray
strip_package qtkeychain usr/lib$SYSTEM_BITS/libqt6keychain.*

# required by clipboard tray
strip_package zint usr/lib$SYSTEM_BITS/libzint.*

# required by main menu
strip_package appstream usr/lib$SYSTEM_BITS/libAppStreamQt.*
rename appstream appstream-qt $MODULE_PATH/packages/appstream-[0-9]*_stripped.txz

# required by spectacle
strip_package opencv \
	usr/lib$SYSTEM_BITS/libopencv_imgproc.* \
	usr/lib$SYSTEM_BITS/libopencv_core.*

# also required by spectacle
strip_package gcc-gfortran usr/lib$SYSTEM_BITS/libgfortran.so*

# also required by spectacle
strip_package tesseract \
	usr/lib$SYSTEM_BITS/libtesseract.so* \
	usr/share/tessdata/*

# also required by spectacle
strip_package leptonica usr/lib$SYSTEM_BITS/libleptonica.so*

# required by dolphin and others
strip_package phonon \
	usr/lib$SYSTEM_BITS/qt6 \
	usr/lib$SYSTEM_BITS/libphonon4qt6*

strip_package qcoro \
	usr/lib$SYSTEM_BITS/libQCoro6Core.* \
	usr/lib$SYSTEM_BITS/libQCoro6DBus.*

### packages outside slackware repository

export QT=6

# required by featherpad
installpkg $MODULE_PATH/packages/hunspell*.txz || exit 1

# kde common deps
for package in \
	audacious \
	audacious-plugins \
	featherpad \
	extra-cmake-modules \
	exiv2 \
	kimageformats \
	kwindowsystem \
	kwayland \
	solid \
	kidletime \
	libkscreen \
	networkmanager-qt \
; do
bash $SCRIPT_PATH/../common/${package}/${package}.SlackBuild || exit 1
installpkg $MODULE_PATH/packages/${package}*.txz || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# only required for building
rm $MODULE_PATH/packages/extra-cmake-modules*.txz

### fake root

cd $MODULE_PATH/packages && ROOT=./ installpkg *.t?z || exit 1
rm *.t?z

### install additional packages, including porteux utils

install_additional_packages

### fix some .desktop files

sed -i "s|Documentation;||g" $MODULE_PATH/packages/usr/share/applications/org.kde.kinfocenter.desktop
sed -i "s|Graphics;||g" $MODULE_PATH/packages/usr/share/applications/org.kde.okular.desktop
sed -i "s|image/png|image/png;image/jxl|g" $MODULE_PATH/packages/usr/share/applications/org.kde.gwenview.desktop

### disable some services

rm $MODULE_PATH/packages/usr/share/dbus-1/services/org.kde.runners.baloo.service
rm $MODULE_PATH/packages/etc/xdg/autostart/baloo_file.desktop
mv $MODULE_PATH/packages/usr/libexec/baloorunner $MODULE_PATH/packages/usr/libexec/baloorunner_

### copy build files to 05-devel

copy_to_devel

### copy language files to 08-multilanguage

copy_to_multilanguage

### module clean up

cd $MODULE_PATH/packages/ || exit 1

{
rm etc/kde/xdg/autostart/baloo_file.desktop
rm etc/kde/xdg/autostart/kaccess.desktop
rm etc/kde/xdg/autostart/xembedsniproxy.desktop
rm usr/bin/kwalletmanager*
rm usr/bin/oxygen-demo5
rm usr/bin/oxygen-gtk-demo
rm usr/bin/systemmonitor
rm usr/bin/UserFeedbackConsole
rm usr/lib${SYSTEM_BITS}/libKF5*
rm usr/lib${SYSTEM_BITS}/libKF6PeopleBackend*
rm usr/lib${SYSTEM_BITS}/libKF6PeopleWidgets*
rm usr/lib${SYSTEM_BITS}/liboxygenstyle5*
rm usr/lib${SYSTEM_BITS}/liboxygenstyleconfig5*
rm usr/lib${SYSTEM_BITS}/libphonon4qt5*
rm usr/lib${SYSTEM_BITS}/libpolkit-qt5*
rm usr/lib${SYSTEM_BITS}/libqca-qt5*
rm usr/lib${SYSTEM_BITS}/libQCoro5*
rm usr/lib${SYSTEM_BITS}/qt6/plugins/designer/phonon4qt6widgets.so
rm usr/lib${SYSTEM_BITS}/qt6/plugins/egldeviceintegrations/libqeglfs-emu-integration.so
rm usr/lib${SYSTEM_BITS}/qt6/plugins/egldeviceintegrations/libqeglfs-kms-egldevice-integration.so
rm usr/lib${SYSTEM_BITS}/qt6/plugins/egldeviceintegrations/libqeglfs-kms-integration.so
rm usr/lib${SYSTEM_BITS}/qt6/plugins/egldeviceintegrations/libqeglfs-x11-integration.so
rm usr/lib${SYSTEM_BITS}/qt6/plugins/imageformats/libqmng.so
rm usr/lib${SYSTEM_BITS}/qt6/plugins/imageformats/libqpdf.so
rm usr/lib${SYSTEM_BITS}/qt6/plugins/platforminputcontexts/libqtvirtualkeyboardplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/plugins/platforms/libqeglfs.so
rm usr/lib${SYSTEM_BITS}/qt6/plugins/qmltooling/libqmldbg_quick3dprofiler.so
rm usr/lib${SYSTEM_BITS}/qt6/plugins/sqldrivers/libqsqlmysql.so
rm usr/lib${SYSTEM_BITS}/qt6/plugins/sqldrivers/libqsqlodbc.so
rm usr/lib${SYSTEM_BITS}/qt6/plugins/styles/breeze5.so
rm usr/lib${SYSTEM_BITS}/qt6/plugins/texttospeech/libqtexttospeech_speechd.so
rm usr/lib${SYSTEM_BITS}/qt6/plugins/wayland-shell-integration/libwl-shell-plugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/Qt/labs/animation/liblabsanimationplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/Qt/labs/lottieqt/liblottieplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/Qt/labs/lottieqt/VectorImageHelpers/liblottievectorimagehelpersplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/Qt/labs/settings/libqmlsettingsplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/Qt/labs/sharedimage/libsharedimageplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/Qt/labs/synchronizer/liblabssynchronizerplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/Qt/labs/wavefrontmesh/libqmlwavefrontmeshplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/QtPositioning/libpositioningquickplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/QtQml/StateMachine/libqtqmlstatemachineplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/QtQml/XmlListModel/libqmlxmllistmodelplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/Controls/FluentWinUI3/impl/libqtquickcontrols2fluentwinui3styleimplplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/Controls/FluentWinUI3/libqtquickcontrols2fluentwinui3styleplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/Controls/Imagine/impl/libqtquickcontrols2imaginestyleimplplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/Controls/Imagine/libqtquickcontrols2imaginestyleplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/Controls/Material/impl/libqtquickcontrols2materialstyleimplplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/Controls/Material/libqtquickcontrols2materialstyleplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/Controls/Universal/impl/libqtquickcontrols2universalstyleimplplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/Controls/Universal/libqtquickcontrols2universalstyleplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/LocalStorage/libqmllocalstorageplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/Pdf/libpdfquickplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/Scene2D/libqtquickscene2dplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/Scene3D/libqtquickscene3dplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/Shapes/DesignHelpers/libqtquickshapesdesignhelpersplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/Timeline/BlendTrees/libqtquicktimelineblendtreesplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/Timeline/libqtquicktimelineplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/VectorImage/Helpers/libqquickvectorimagehelpersplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/VectorImage/libqquickvectorimageplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick3D/AssetUtils/libqtquick3dassetutilsplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick3D/Effects/libqtquick3deffectplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick3D/Helpers/impl/libqtquick3dhelpersimplplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick3D/Helpers/libqtquick3dhelpersplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick3D/libqquick3dplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick3D/ParticleEffects/libqtquick3dparticleeffectsplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick3D/Particles3D/libqtquick3dparticles3dplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick3D/Physics/Helpers/libqtquick3dphysicshelpersplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick3D/Physics/libqquick3dphysicsplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick3D/SpatialAudio/libquick3dspatialaudioplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/QtSensors/libsensorsquickplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/QtWebChannel/libwebchannelquickplugin.so
rm usr/lib${SYSTEM_BITS}/qt6/qml/QtWebSockets/libqmlwebsocketsplugin.so
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
rm -fr usr/lib${SYSTEM_BITS}/qt5
rm -fr usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/VirtualKeyboard
rm -fr usr/lib${SYSTEM_BITS}/qt6/qml/QtTest
rm -fr usr/lib${SYSTEM_BITS}/qt6/mkspecs
rm -fr usr/share/chromium
rm -fr usr/share/emoticons/EmojiOne
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

[ "$SYSTEM_BITS" == 64 ] && find usr/lib/ -mindepth 1 -maxdepth 1 ! \( -name "python*" \) -exec rm -rf '{}' \; 2>/dev/null
find usr/share/plasma/avatars/photos -mindepth 1 ! \( -name "Air Balloon.png" -o -name "Air Balloon.png.license" -o -name "Astronaut.png" -o -name "Astronaut.png.license" \) -exec rm -rf '{}' \; 2>/dev/null
} >/dev/null 2>&1

generic_strip

# move out things that don't support aggressive stripping
mv $MODULE_PATH/packages/usr/lib${SYSTEM_BITS}/libexiv2.so* $MODULE_PATH/
mv $MODULE_PATH/packages/usr/lib${SYSTEM_BITS}/libgwenviewlib.so* $MODULE_PATH/
aggressive_strip_all
mv $MODULE_PATH/libexiv2.so* $MODULE_PATH/packages/usr/lib${SYSTEM_BITS}
mv $MODULE_PATH/libgwenviewlib.so* $MODULE_PATH/packages/usr/lib${SYSTEM_BITS}

### copy cache files

prepare_files_for_cache_de

### generate cache files

generate_caches_de

### kde specific mime cache

rm -fr $PORTEUX_BUILDER_PATH/caches/mime/packages
cp -r $PORTEUX_BUILDER_PATH/caches/mime $MODULE_PATH/packages/usr/share/

### finalize

finalize
