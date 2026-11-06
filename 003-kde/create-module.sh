#!/bin/bash

MODULE_NAME="003-kde"

source "$(dirname "$0")/../builder-utils/set-flags.sh"

set_flags "$MODULE_NAME"

source "$BUILDER_UTILS_PATH/cache-files.sh"
source "$BUILDER_UTILS_PATH/generic-strip.sh"
source "$BUILDER_UTILS_PATH/helper.sh"

elevate_if_needed "$0" "$@"

FRAMEWORKS_VERSION=$(curl -sL https://download.kde.org/stable/frameworks/ | grep -oP 'href="\K[0-9]+\.[0-9]+(?=/")' | sort -Vr | head -1)
PLASMA_VERSION=$(curl -sL https://download.kde.org/stable/plasma/ | grep -oP 'href="\K[0-9.]+(?=/")' | sort -Vr | head -1)
GEAR_VERSION=$(curl -sL https://download.kde.org/stable/release-service/ | grep -oP 'href="\K[0-9.]+(?=/")' | sort -Vr | head -1)
[ "$FRAMEWORKS_VERSION" ] && [ "$PLASMA_VERSION" ] && [ "$GEAR_VERSION" ] || { echo "Error: could not detect KDE versions." >&2; exit 1; }
export FRAMEWORKS_VERSION PLASMA_VERSION GEAR_VERSION
echo -e "Building KDE Plasma ${PLASMA_VERSION} based on Slackware ${SLACKWARE_VERSION} ${ARCH}...\n"
MODULE_NAME="$MODULE_NAME-${PLASMA_VERSION}"

### create module folder

mkdir -p $MODULE_PATH/packages > /dev/null 2>&1
cd $MODULE_PATH || exit 1

### download packages from slackware repository

bash $SCRIPT_PATH/download-packages.sh || exit 1

installpkg $MODULE_PATH/packages/*.txz || exit 1

### packages that require specific stripping

strip_package qt6 \
	usr/lib${SYSTEM_BITS}/libQt6Concurrent.so* \
	usr/lib${SYSTEM_BITS}/libQt6Core.so* \
	usr/lib${SYSTEM_BITS}/libQt6Core5Compat.so* \
	usr/lib${SYSTEM_BITS}/libQt6DBus.so* \
	usr/lib${SYSTEM_BITS}/libQt6EglFsKmsSupport.so* \
	usr/lib${SYSTEM_BITS}/libQt6Gui.so* \
	usr/lib${SYSTEM_BITS}/libQt6LabsFolderListModel.so* \
	usr/lib${SYSTEM_BITS}/libQt6LabsPlatform.so* \
	usr/lib${SYSTEM_BITS}/libQt6LabsQmlModels.so* \
	usr/lib${SYSTEM_BITS}/libQt6Multimedia.so* \
	usr/lib${SYSTEM_BITS}/libQt6MultimediaQuick.so* \
	usr/lib${SYSTEM_BITS}/libQt6MultimediaWidgets.so* \
	usr/lib${SYSTEM_BITS}/libQt6Network.so* \
	usr/lib${SYSTEM_BITS}/libQt6OpenGL.so* \
	usr/lib${SYSTEM_BITS}/libQt6OpenGLWidgets.so* \
	usr/lib${SYSTEM_BITS}/libQt6Positioning.so* \
	usr/lib${SYSTEM_BITS}/libQt6PositioningQuick.so* \
	usr/lib${SYSTEM_BITS}/libQt6PrintSupport.so* \
	usr/lib${SYSTEM_BITS}/libQt6Qml.so* \
	usr/lib${SYSTEM_BITS}/libQt6QmlCore.so* \
	usr/lib${SYSTEM_BITS}/libQt6QmlMeta.so* \
	usr/lib${SYSTEM_BITS}/libQt6QmlModels.so* \
	usr/lib${SYSTEM_BITS}/libQt6QmlWorkerScript.so* \
	usr/lib${SYSTEM_BITS}/libQt6Quick.so* \
	usr/lib${SYSTEM_BITS}/libQt6QuickControls2.so* \
	usr/lib${SYSTEM_BITS}/libQt6QuickControls2Basic.so* \
	usr/lib${SYSTEM_BITS}/libQt6QuickControls2BasicStyleImpl.so* \
	usr/lib${SYSTEM_BITS}/libQt6QuickControls2Fusion.so* \
	usr/lib${SYSTEM_BITS}/libQt6QuickControls2FusionStyleImpl.so* \
	usr/lib${SYSTEM_BITS}/libQt6QuickControls2Impl.so* \
	usr/lib${SYSTEM_BITS}/libQt6QuickDialogs2.so* \
	usr/lib${SYSTEM_BITS}/libQt6QuickDialogs2QuickImpl.so* \
	usr/lib${SYSTEM_BITS}/libQt6QuickDialogs2Utils.so* \
	usr/lib${SYSTEM_BITS}/libQt6QuickEffects.so* \
	usr/lib${SYSTEM_BITS}/libQt6QuickLayouts.so* \
	usr/lib${SYSTEM_BITS}/libQt6QuickParticles.so* \
	usr/lib${SYSTEM_BITS}/libQt6QuickShapes.so* \
	usr/lib${SYSTEM_BITS}/libQt6QuickTemplates2.so* \
	usr/lib${SYSTEM_BITS}/libQt6QuickWidgets.so* \
	usr/lib${SYSTEM_BITS}/libQt6Sensors.so* \
	usr/lib${SYSTEM_BITS}/libQt6SerialPort.so* \
	usr/lib${SYSTEM_BITS}/libQt6ShaderTools.so* \
	usr/lib${SYSTEM_BITS}/libQt6Sql.so* \
	usr/lib${SYSTEM_BITS}/libQt6Svg.so* \
	usr/lib${SYSTEM_BITS}/libQt6SvgWidgets.so* \
	usr/lib${SYSTEM_BITS}/libQt6Test.so* \
	usr/lib${SYSTEM_BITS}/libQt6TextToSpeech.so* \
	usr/lib${SYSTEM_BITS}/libQt6UiTools.so* \
	usr/lib${SYSTEM_BITS}/libQt6WaylandClient.so* \
	usr/lib${SYSTEM_BITS}/libQt6WaylandCompositor.so* \
	usr/lib${SYSTEM_BITS}/libQt6WaylandEglCompositorHwIntegration.so* \
	usr/lib${SYSTEM_BITS}/libQt6Widgets.so* \
	usr/lib${SYSTEM_BITS}/libQt6XcbQpa.so* \
	usr/lib${SYSTEM_BITS}/libQt6Xml.so* \
	usr/lib${SYSTEM_BITS}/qt6/bin/qdbus \
	usr/lib${SYSTEM_BITS}/qt6/plugins/generic/* \
	usr/lib${SYSTEM_BITS}/qt6/plugins/iconengines/* \
	usr/lib${SYSTEM_BITS}/qt6/plugins/imageformats/libqgif.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/imageformats/libqicns.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/imageformats/libqico.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/imageformats/libqjp2.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/imageformats/libqjpeg.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/imageformats/libqsvg.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/imageformats/libqtga.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/imageformats/libqtiff.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/imageformats/libqwbmp.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/imageformats/libqwebp.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/networkinformation/* \
	usr/lib${SYSTEM_BITS}/qt6/plugins/platforminputcontexts/libcomposeplatforminputcontextplugin.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/platforminputcontexts/libibusplatforminputcontextplugin.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/platforms/libqlinuxfb.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/platforms/libqminimal.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/platforms/libqminimalegl.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/platforms/libqoffscreen.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/platforms/libqvkkhrdisplay.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/platforms/libqvnc.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/platforms/libqwayland.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/platforms/libqxcb.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/printsupport/* \
	usr/lib${SYSTEM_BITS}/qt6/plugins/qmltooling/libqmldbg_debugger.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/qmltooling/libqmldbg_inspector.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/qmltooling/libqmldbg_local.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/qmltooling/libqmldbg_messages.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/qmltooling/libqmldbg_native.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/qmltooling/libqmldbg_nativedebugger.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/qmltooling/libqmldbg_preview.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/qmltooling/libqmldbg_profiler.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/qmltooling/libqmldbg_quickeventreplay.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/qmltooling/libqmldbg_quickprofiler.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/qmltooling/libqmldbg_server.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/qmltooling/libqmldbg_tcp.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/sensors/* \
	usr/lib${SYSTEM_BITS}/qt6/plugins/sqldrivers/libqsqlite.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/texttospeech/libqtexttospeech_mock.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/tls/* \
	usr/lib${SYSTEM_BITS}/qt6/plugins/wayland-decoration-client/* \
	usr/lib${SYSTEM_BITS}/qt6/plugins/wayland-graphics-integration-client/* \
	usr/lib${SYSTEM_BITS}/qt6/plugins/wayland-graphics-integration-server/* \
	usr/lib${SYSTEM_BITS}/qt6/plugins/wayland-shell-integration/libfullscreen-shell-v1.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/wayland-shell-integration/libivi-shell.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/wayland-shell-integration/libqt-shell.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/wayland-shell-integration/libxdg-shell.so \
	usr/lib${SYSTEM_BITS}/qt6/plugins/xcbglintegrations/* \
	usr/lib${SYSTEM_BITS}/qt6/qml/Qt/labs/StyleKit \
	usr/lib${SYSTEM_BITS}/qt6/qml/Qt/labs/assetdownloader \
	usr/lib${SYSTEM_BITS}/qt6/qml/Qt/labs/folderlistmodel \
	usr/lib${SYSTEM_BITS}/qt6/qml/Qt/labs/platform \
	usr/lib${SYSTEM_BITS}/qt6/qml/Qt/labs/qmlmodels \
	usr/lib${SYSTEM_BITS}/qt6/qml/Qt5Compat/* \
	usr/lib${SYSTEM_BITS}/qt6/qml/QtCore/* \
	usr/lib${SYSTEM_BITS}/qt6/qml/QtMultimedia/* \
	usr/lib${SYSTEM_BITS}/qt6/qml/QtPositioning/* \
	usr/lib${SYSTEM_BITS}/qt6/qml/QtQml/Models \
	usr/lib${SYSTEM_BITS}/qt6/qml/QtQml/WorkerScript \
	usr/lib${SYSTEM_BITS}/qt6/qml/QtQml/libqmlplugin.so \
	usr/lib${SYSTEM_BITS}/qt6/qml/QtQml/plugins.qmltypes \
	usr/lib${SYSTEM_BITS}/qt6/qml/QtQml/qmldir \
	usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/Controls/Basic \
	usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/Controls/Fusion \
	usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/Controls/designer \
	usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/Controls/impl \
	usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/Controls/libqtquickcontrols2plugin.so \
	usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/Controls/plugins.qmltypes \
	usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/Controls/qmldir \
	usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/Dialogs \
	usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/Effects \
	usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/Layouts \
	usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/Particles \
	usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/Shapes/libqmlshapesplugin.so \
	usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/Shapes/plugins.qmltypes \
	usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/Shapes/qmldir \
	usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/Templates \
	usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/Window \
	usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/libqtquick2plugin.so \
	usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/plugins.qmltypes \
	usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/qmldir \
	usr/lib${SYSTEM_BITS}/qt6/qml/QtQuick/tooling \
	usr/lib${SYSTEM_BITS}/qt6/qml/QtWayland/*

# required by network tray
strip_package qtkeychain \
	usr/lib${SYSTEM_BITS}/libqt6keychain.so*

# required by clipboard tray
strip_package zint \
	usr/lib${SYSTEM_BITS}/libzint.so*

# required by main menu
strip_package appstream \
	usr/lib${SYSTEM_BITS}/libAppStreamQt.so*
rename appstream appstream-qt $MODULE_PATH/packages/appstream-[0-9]*_stripped.txz

# required by spectacle
strip_package tesseract \
	usr/lib${SYSTEM_BITS}/libtesseract.so* \
	usr/share/tessdata/*

# also required by spectacle
strip_package leptonica \
	usr/lib${SYSTEM_BITS}/libleptonica.so*

strip_package qcoro \
	usr/lib${SYSTEM_BITS}/libQCoro6Core.so* \
	usr/lib${SYSTEM_BITS}/libQCoro6DBus.so*

### packages outside slackware repository

export QT=6

install_rust_toolchain

# kde common deps
for package in \
	audacious \
	extra-cmake-modules \
	exiv2 \
	plasma-wayland-protocols \
	kwindowsystem \
	kwayland \
	solid \
	kidletime \
	libkscreen \
	networkmanager-qt \
	polkit-qt6-1 \
; do
bash $SCRIPT_PATH/../common/deps/${package}/${package}.SlackBuild || exit 1
installpkg $MODULE_PATH/packages/${package}*.txz || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# kde common extras
for package in \
	audacious-plugins \
	featherpad \
	kimageformats \
; do
bash $SCRIPT_PATH/../common/extras/${package}/${package}.SlackBuild || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# kde deps
for package in \
	phonon \
	qca \
	pulseaudio-qt \
	libqaccessibilityclient \
	libkexiv2 \
	libkdcraw \
	cxx-rust-cssparser \
	kdsoap-ws-discovery-client \
	kColorPicker \
	kImageAnnotator \
; do
bash $SCRIPT_PATH/deps/${package}/${package}.SlackBuild || exit 1
installpkg $MODULE_PATH/packages/${package}*.txz || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# kde packages
for package in \
	attica \
	kitemmodels \
	kitemviews \
	kplotting \
	threadweaver \
	kcodecs \
	kdbusaddons \
	kcoreaddons \
	kguiaddons \
	kwidgetsaddons \
	sonnet \
	kconfig \
	karchive \
	ki18n \
	modemmanager-qt \
	bluez-qt \
	prison \
	kirigami \
	syntax-highlighting \
	kholidays \
	breeze-icons \
	kdnssd \
	kauth \
	kcrash \
	knotifications \
	kjobwidgets \
	kcompletion \
	kpackage \
	kunitconversion \
	kpty \
	kfilemetadata \
	syndication \
	kquickcharts \
	kcolorscheme \
	kstatusnotifieritem \
	kconfigwidgets \
	kservice \
	kglobalaccel \
	kiconthemes \
	kwallet \
	kdesu \
	ktextwidgets \
	kxmlgui \
	kbookmarks \
	kded \
	kio \
	knewstuff \
	kparts \
	kdeclarative \
	knotifyconfig \
	ktexteditor \
	kcmutils \
	ksvg \
	baloo \
	qqc2-desktop-style \
	purpose \
	krunner \
	frameworkintegration \
	kirigami-addons \
	kquickimageeditor \
	kpipewire \
	kdecoration \
	breeze \
	breeze-gtk \
	kglobalacceld \
	libksysguard \
	layer-shell-qt \
	plasma-activities \
	plasma-activities-stats \
	libplasma \
	kscreenlocker \
	knighttime \
	milou \
	kwin \
	kwrited \
	oxygen \
	plasma5support \
	kde-cli-tools \
	union \
	plasma-workspace \
	systemsettings \
	kinfocenter \
	plasma-desktop \
	kdeplasma-addons \
	plasma-nm \
	powerdevil \
	bluedevil \
	kmenuedit \
	polkit-kde-agent-1 \
	kscreen \
	sddm-kcm \
	kde-gtk-config \
	ksshaskpass \
	plasma-pa \
	kactivitymanagerd \
	xdg-desktop-portal-kde \
	plasma-integration \
	plasma-browser-integration \
	ksystemstats \
	plasma-systemmonitor \
	spectacle \
	baloo-widgets \
	ark \
	dolphin \
	dolphin-plugins \
	ffmpegthumbs \
	gwenview \
	kdenetwork-filesharing \
	kio-admin \
	kio-extras \
	kio-zeroconf \
	konsole \
	kqtquickcharts \
	okular \
	sddm \
; do
bash $SCRIPT_PATH/kde/${package}/${package}.SlackBuild || exit 1
installpkg $MODULE_PATH/packages/${package}-[0-9]*.txz || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# only required for building
rm $MODULE_PATH/packages/boost*.txz
rm $MODULE_PATH/packages/corrosion*.txz
rm $MODULE_PATH/packages/extra-cmake-modules*.txz
rm $MODULE_PATH/packages/libsass*.txz
rm $MODULE_PATH/packages/plasma-wayland-protocols*.txz
rm $MODULE_PATH/packages/python-lxml*.txz
rm $MODULE_PATH/packages/sassc*.txz

### fake root

install_packages

### install additional packages, including porteux utils

install_additional_packages

mkdir -p $MODULE_PATH/packages/usr/share/thumbnailers
cat > $MODULE_PATH/packages/usr/share/thumbnailers/pdfthumbnail.thumbnailer << 'EOF'
[Thumbnailer Entry]
TryExec=pdftocairo
Exec=sh -c "pdftocairo -png -singlefile -scale-to $0 - - <$1 >$2" %s %i %o
MimeType=application/pdf;
EOF

### copy build files to 05-devel

copy_to_devel

### copy language files to 08-multilanguage

copy_to_multilanguage

### module clean up

cd $MODULE_PATH/packages/ || exit 1

{
rm -fr boot/
rm -fr lib/
rm -fr lib64/
rm -fr usr/lib${SYSTEM_BITS}/qt5
rm -fr usr/lib${SYSTEM_BITS}/qt6/mkspecs
rm -fr usr/share/gdm
rm -fr usr/share/gnome
rm -fr usr/share/kde4
rm -fr usr/share/kdevappwizard
rm -fr usr/share/qlogging-categories6

find usr/share/wallpapers -mindepth 1 -maxdepth 1 ! \( -name "body-background.png" \) -exec rm -rf '{}' \; 2>/dev/null
find usr/share/icons -mindepth 1 -maxdepth 1 ! \( -name "breeze" -o -name "breeze-dark" -o -name "hicolor" \) -exec rm -rf '{}' \; 2>/dev/null

[ "$SYSTEM_BITS" == 64 ] && find usr/lib/ -mindepth 1 -maxdepth 1 ! \( -name "mozilla" -o -name "python*" \) -exec rm -rf '{}' \; 2>/dev/null
} >/dev/null 2>&1

strip_clean
strip_hard_all 'libexiv2.so*' 'libgwenviewlib.so*'

### copy cache files

prepare_files_for_cache_de

### generate cache files

generate_caches

### kde specific mime cache

find $PORTEUX_BUILDER_PATH/caches/mime -mindepth 1 -maxdepth 1 ! -name packages -exec cp -r -t $MODULE_PATH/packages/usr/share/mime/ {} +

restore_files_for_cache_de

### finalize

finalize
