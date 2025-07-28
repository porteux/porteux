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

### packages outside Slackware repository ###

# required by featherpad
installpkg $MODULEPATH/packages/hunspell*.txz || exit 1

currentPackage=FeatherPad
mkdir $MODULEPATH/${currentPackage,,} && cd $MODULEPATH/${currentPackage,,}
info=$(DownloadLatestFromGithub "tsujan" ${currentPackage})
version=${info#* }
filename=${info% *}
tar xvf ${currentPackage}-${version}.tar.xz && rm ${currentPackage}-${version}.tar.xz || exit 1
cd ${currentPackage}*
cmake -B build -S . -DCMAKE_CXX_FLAGS:STRING="$GCCFLAGS" -DCMAKE_BUILD_TYPE=release -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=/usr/lib${SYSTEMBITS}
make -C build -j${NUMBERTHREADS} DESTDIR="$MODULEPATH/${currentPackage,,}/package" install
cd $MODULEPATH/${currentPackage,,}/package
makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/${currentPackage,,}-$version-$ARCH-1.txz
rm -fr $MODULEPATH/${currentPackage,,}

currentPackage=audacious
QT=6 sh $SCRIPTPATH/../common/audacious/${currentPackage}.SlackBuild || exit 1
installpkg $MODULEPATH/packages/${currentPackage}*.txz
rm -fr $MODULEPATH/${currentPackage}

currentPackage=audacious-plugins
QT=6 sh $SCRIPTPATH/../common/audacious/${currentPackage}.SlackBuild || exit 1
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

# extract package from here https://www.linuxquestions.org/questions/slackware-14/building-the-plasma6-for-slackware-current-in-the-ktown-style-a-build-based-on-the-alienbob%27s-ktown-4175735773/page89.html#post6560591
KDE6PACKAGES=/tmp/packages
[ ! -d $KDE6PACKAGES ] && echo "Couldn't find KDE packages. Extract them to /tmp/packages" && exit 1

DE_LATEST_VERSION=$(find $KDE6PACKAGES -type f -name "plasma-desktop-*" | cut -d "-" -f 3)

echo "Building KDE Plasma ${DE_LATEST_VERSION}..."
MODULENAME=$MODULENAME-${DE_LATEST_VERSION}

find $KDE6PACKAGES -type f -name "ark*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "attica-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "baloo-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "baloo-widgets*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "bluedevil*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "bluez-qt*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "breeze-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "breeze-grub*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "breeze-gtk*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "breeze-icons*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "ddcutil*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "dolphin*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "dolphin-plugins*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "ffmpegthumbs*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "frameworkintegration-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "gwenview*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kColorPicker*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kImageAnnotator*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kactivitymanagerd*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kapidox*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "karchive-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kauth-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kbookmarks-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kcmutils-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kcodecs-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kcolorscheme*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kcompletion-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kconfig-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kconfigwidgets-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kcoreaddons-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kcrash-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kdbusaddons-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kde-cli-tools*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kde-gtk-config*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kdeclarative-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kdecoration*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kded-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kdenetwork-filesharing*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kdeplasma-addons*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kdesu-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kdnssd-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kfilemetadata-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kglobalaccel-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kglobalacceld*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kguiaddons-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "ki18n-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kiconthemes-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kidletime-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kinfocenter*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kio-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kio-admin*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kio-extras*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kio-gdrive*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kio-zeroconf*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kirigami-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kirigami-addons*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kitemmodels-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kitemviews-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kjobwidgets-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kmenuedit*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "knewstuff-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "knotifications-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "knotifyconfig-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "konsole*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kpackage-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kparts-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kpeople-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kpeoplevcard*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kpipewire*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kplotting-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kpty-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kqtquickcharts-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kquickcharts-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "krunner-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kscreen*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kscreenlocker*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kservice-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "ksshaskpass*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kstatusnotifieritem*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "ksvg*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "ksystemstats*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "ktexteditor-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "ktextwidgets-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kunitconversion-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kuserfeedback*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kwallet-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kwayland-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kwayland-integration*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kwidgetsaddons-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kwin-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kwindowsystem-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kwrited*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "kxmlgui-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "layer-shell-qt*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "libkdcraw*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "libkexiv2*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "libkipi*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "libkscreen*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "libksysguard*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "libplasma*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "libqaccessibilityclient*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "milou*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "modemmanager*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "networkmanager-qt*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "okular*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "oxygen-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "oxygen-fonts*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "oxygen-gtk2*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "phonon-4*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "phonon-backend-gstreamer*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "phonon-backend-mpv*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "phonon-backend-vlc*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "plasma-activities*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "plasma-activities-stats*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "plasma-browser-integration*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "plasma-desktop*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "plasma-integration*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "plasma-nm*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "plasma-pa*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "plasma-systemmonitor*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "plasma-workspace*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "plasma5support*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "polkit-kde-agent*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "polkit-qt*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "powerdevil*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "prison-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "purpose-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "pulseaudio-qt*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "qca*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "qcoro*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "qqc2-desktop-style-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "sddm*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "sddm-kcm*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "solid-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "sonnet-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "spectacle*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "syndication-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "syntax-highlighting-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "systemsettings*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "threadweaver-6*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "wayland-utils*" -exec cp {} $MODULEPATH/packages/ \;
find $KDE6PACKAGES -type f -name "xdg-desktop-portal-kde*" -exec cp {} $MODULEPATH/packages/ \;

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
