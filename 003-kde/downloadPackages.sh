#!/bin/sh
source "$PWD/../builder-utils/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

DownloadPackage "accountsservice" &
DownloadPackage "ark" &
DownloadPackage "attica" &
DownloadPackage "baloo" &
DownloadPackage "baloo-widgets" &
DownloadPackage "bluedevil" &
DownloadPackage "bluez-qt" &
DownloadPackage "breeze" &
DownloadPackage "breeze-gtk" &
wait
DownloadPackage "breeze-icons" &
DownloadPackage "cfitsio" &
DownloadPackage "dolphin" &
DownloadPackage "dolphin-plugins" &
DownloadPackage "editorconfig-core-c" &
DownloadPackage "eglexternalplatform" &
DownloadPackage "egl-wayland" &
DownloadPackage "ffmpegthumbs" &
DownloadPackage "frameworkintegration" &
wait
DownloadPackage "graphene" &
DownloadPackage "gst-plugins-good" &
DownloadPackage "gwenview" &
DownloadPackage "hunspell" &
DownloadPackage "jasper" &
DownloadPackage "kactivities" &
DownloadPackage "kactivities-stats" &
wait
DownloadPackage "kactivitymanagerd" &
DownloadPackage "kapidox" &
DownloadPackage "karchive" &
DownloadPackage "kauth" &
DownloadPackage "kbookmarks" &
DownloadPackage "kcmutils" &
DownloadPackage "kcodecs" &
DownloadPackage "kcompletion" &
wait
DownloadPackage "kconfig" &
DownloadPackage "kconfigwidgets" &
DownloadPackage "kcoreaddons" &
DownloadPackage "kcrash" &
DownloadPackage "kdbusaddons" &
DownloadPackage "kdeclarative" &
DownloadPackage "kde-cli-tools" &
DownloadPackage "kdecoration" &
DownloadPackage "kded" &
wait
DownloadPackage "kde-gtk-config" &
DownloadPackage "kdelibs4support" &
DownloadPackage "kdenetwork-filesharing" &
DownloadPackage "kdeplasma-addons" &
DownloadPackage "kdesignerplugin" &
DownloadPackage "kdesu" &
DownloadPackage "kdnssd" &
DownloadPackage "keybinder3" &
wait
DownloadPackage "kfilemetadata" &
DownloadPackage "kgamma5" &
DownloadPackage "kglobalaccel" &
DownloadPackage "kguiaddons" &
DownloadPackage "kholidays" &
DownloadPackage "khotkeys" &
DownloadPackage "khtml" &
DownloadPackage "ki18n" &
wait
DownloadPackage "kiconthemes" &
DownloadPackage "kidletime" &
DownloadPackage "kinfocenter" &
DownloadPackage "kinit" &
DownloadPackage "kio" &
DownloadPackage "kio-extras" &
DownloadPackage "kirigami2" &
DownloadPackage "kitemmodels" &
wait
DownloadPackage "kitemviews" &
DownloadPackage "kjobwidgets" &
DownloadPackage "kjs" &
DownloadPackage "kjsembed" &
DownloadPackage "kmediaplayer" &
DownloadPackage "kmenuedit" &
DownloadPackage "knewstuff" &
DownloadPackage "knotifications" &
DownloadPackage "knotifyconfig" &
wait
DownloadPackage "konsole" &
DownloadPackage "kpackage" &
DownloadPackage "kparts" &
DownloadPackage "kpeople" &
DownloadPackage "kpipewire" &
DownloadPackage "kplotting" &
DownloadPackage "kpmcore" &
DownloadPackage "kpty" &
DownloadPackage "kqtquickcharts" &
DownloadPackage "kquickcharts" &
wait
DownloadPackage "krename" &
DownloadPackage "kross" &
DownloadPackage "krunner" &
DownloadPackage "kscreen" &
DownloadPackage "kscreenlocker" &
DownloadPackage "kservice" &
DownloadPackage "ksshaskpass" &
DownloadPackage "ksystemstats" &
DownloadPackage "ktexteditor" &
wait
DownloadPackage "ktextwidgets" &
DownloadPackage "kunitconversion" &
DownloadPackage "kwallet" &
DownloadPackage "kwayland" &
DownloadPackage "kwayland-integration" &
DownloadPackage "kwayland-server" &
DownloadPackage "kwidgetsaddons" &
DownloadPackage "kwin" &
DownloadPackage "kwindowsystem" &
wait
DownloadPackage "kwrited" &
DownloadPackage "kxmlgui" &
DownloadPackage "kxmlrpcclient" &
DownloadPackage "layer-shell-qt" &
DownloadPackage "libcanberra" &
DownloadPackage "libdbusmenu-qt" &
DownloadPackage "libdmtx" &
DownloadPackage "libkdcraw" &
DownloadPackage "libkexiv2" &
wait
DownloadPackage "libkipi" &
DownloadPackage "libkscreen" &
DownloadPackage "LibRaw" &
DownloadPackage "libksysguard" &
DownloadPackage "milou" &
DownloadPackage "modemmanager-qt" &
DownloadPackage "networkmanager-qt" &
DownloadPackage "okular" &
DownloadPackage "oxygen" &
wait
DownloadPackage "phonon" &
DownloadPackage "phonon-backend-gstreamer" &
DownloadPackage "plasma-browser-integration" &
DownloadPackage "plasma-desktop" &
DownloadPackage "plasma-framework" &
DownloadPackage "plasma-integration" &
DownloadPackage "plasma-nm" &
DownloadPackage "plasma-pa" &
wait
DownloadPackage "plasma-systemmonitor" &
DownloadPackage "plasma-workspace" &
DownloadPackage "polkit-kde-agent" &
DownloadPackage "polkit-qt" &
DownloadPackage "powerdevil" &
DownloadPackage "prison" &
DownloadPackage "purpose" &
wait
DownloadPackage "qca" &
DownloadPackage "qqc2-desktop-style" &
DownloadPackage "qrencode" &
DownloadPackage "sddm" &
DownloadPackage "solid" &
DownloadPackage "sonnet" &
DownloadPackage "spectacle" &
DownloadPackage "syndication" &
wait
DownloadPackage "syntax-highlighting" &
DownloadPackage "systemsettings" &
DownloadPackage "taglib" &
DownloadPackage "threadweaver" &
DownloadPackage "wayland-protocols" &
DownloadPackage "xcb-util-cursor" &
DownloadPackage "xdg-desktop-portal-kde" &
DownloadPackage "xorg-server-xwayland" &
wait

### slackware current only packages

if [ $SLACKWAREVERSION == "current" ]; then
	DownloadPackage "kColorPicker" &
	DownloadPackage "kImageAnnotator" &
	DownloadPackage "kio-admin" &
	DownloadPackage "zxing-cpp" &
	wait
fi

### packages that require specific striping

DownloadPackage "qt5" &
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
