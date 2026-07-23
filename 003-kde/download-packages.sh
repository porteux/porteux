#!/bin/bash
source "$BUILDER_UTILS_PATH/slackware-repository.sh"

generate_repository_urls

download_package "accountsservice" &
download_package "cfitsio" &
download_package "editorconfig-core-c" &
download_package "eglexternalplatform" &
download_package "egl-wayland" &
download_package "gst-plugins-good" &
download_package "hunspell" &
download_package "jasper" &
download_package "keybinder3" &
download_package "libdmtx" &
wait
download_package "libqaccessibilityclient" &
download_package "libqalculate" &
download_package "LibRaw" &
download_package "openblas" &
download_package "qca" &
download_package "qrencode" &
download_package "xdpyinfo" &
download_package "zxing-cpp" &
wait
download_package "ark" &
download_package "attica" &
download_package "baloo" &
download_package "baloo-widgets" &
download_package "bluedevil" &
download_package "bluez-qt" &
download_package "breeze" &
download_package "breeze-grub" &
download_package "breeze-gtk" &
download_package "breeze-icons" &
wait
download_package "dolphin" &
download_package "dolphin-plugins" &
download_package "ffmpegthumbs" &
download_package "frameworkintegration" &
download_package "gwenview" &
download_package "kactivitymanagerd" &
download_package "kapidox" &
download_package "karchive" &
download_package "kauth" &
download_package "kbookmarks" &
wait
download_package "kcmutils" &
download_package "kcodecs" &
download_package "kColorPicker" &
download_package "kcolorscheme" &
download_package "kcompletion" &
download_package "kconfig" &
download_package "kconfigwidgets" &
download_package "kcoreaddons" &
download_package "kcrash" &
download_package "kdbusaddons" &
wait
download_package "kdeclarative" &
download_package "kde-cli-tools" &
download_package "kdecoration" &
download_package "kded" &
download_package "kde-gtk-config" &
download_package "kdenetwork-filesharing" &
download_package "kdeplasma-addons" &
download_package "kdesu" &
download_package "kdnssd" &
download_package "kfilemetadata" &
wait
download_package "kglobalaccel" &
download_package "kglobalacceld" &
download_package "kguiaddons" &
download_package "kholidays" &
download_package "ki18n" &
download_package "kiconthemes" &
download_package "kImageAnnotator" &
download_package "kinfocenter" &
download_package "kio" &
wait
download_package "kio-admin" &
download_package "kio-extras" &
download_package "kio-gdrive" &
download_package "kio-zeroconf" &
download_package "kirigami" &
download_package "kirigami-addons" &
download_package "kitemmodels" &
download_package "kitemviews" &
download_package "kjobwidgets" &
download_package "kmenuedit" &
wait
download_package "knewstuff" &
download_package "knighttime" &
download_package "knotifications" &
download_package "knotifyconfig" &
download_package "konsole" &
download_package "kpackage" &
download_package "kparts" &
download_package "kpeople" &
download_package "kpeoplevcard" &
download_package "kpipewire" &
wait
download_package "kplotting" &
download_package "kpty" &
download_package "kqtquickcharts" &
download_package "kquickcharts" &
download_package "kquickimageeditor" &
download_package "krunner" &
download_package "kscreen" &
download_package "kscreenlocker" &
download_package "kservice" &
download_package "ksshaskpass" &
wait
download_package "kstatusnotifieritem" &
download_package "ksvg" &
download_package "ksystemstats" &
download_package "ktexteditor" &
download_package "ktextwidgets" &
download_package "kunitconversion" &
download_package "kwallet" &
download_package "kwayland-integration" &
wait
download_package "kwidgetsaddons" &
download_package "kwin" &
download_package "kwin-x11" &
download_package "kwrited" &
download_package "kxmlgui" &
download_package "layer-shell-qt" &
download_package "libkdcraw" &
download_package "libkexiv2" &
wait
download_package "libksysguard" &
download_package "libplasma" &
download_package "libqaccessibilityclient" &
download_package "milou" &
download_package "modemmanager-qt" &
download_package "okular" &
download_package "oxygen" &
download_package "plasma5support" &
wait
download_package "plasma-activities" &
download_package "plasma-activities-stats" &
download_package "plasma-browser-integration" &
download_package "plasma-desktop" &
download_package "plasma-integration" &
download_package "plasma-nm" &
download_package "plasma-pa" &
download_package "plasma-systemmonitor" &
download_package "plasma-workspace" &
download_package "polkit-kde-agent" &
wait
download_package "powerdevil" &
download_package "prison" &
download_package "pulseaudio-qt" &
download_package "purpose" &
download_package "qqc2-desktop-style" &
download_package "sddm" &
download_package "sddm-kcm" &
download_package "sonnet" &
download_package "spectacle" &
wait
download_package "syndication" &
download_package "syntax-highlighting" &
download_package "systemsettings" &
download_package "threadweaver" &
download_package "xdg-desktop-portal-kde" &
wait

### packages that require specific stripping

download_package "appstream" & # required by main menu
download_package "gcc-gfortran" & # required by spectacle
download_package "leptonica" & # required by spectacle
download_package "opencv" & # required by spectacle
download_package "phonon" & # required by dolphin and others
download_package "qcoro" &
download_package "qt6" &
download_package "qtkeychain" & # required by network tray
download_package "tesseract" & # required by spectacle
download_package "zint" & # required by clipboard tray
wait

rm FILE_LIST
rm server-packages.txt
