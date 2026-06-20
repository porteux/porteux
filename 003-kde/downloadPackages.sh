#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

GenerateRepositoryUrls

DownloadPackage "accountsservice" &
DownloadPackage "cfitsio" &
DownloadPackage "editorconfig-core-c" &
DownloadPackage "eglexternalplatform" &
DownloadPackage "egl-wayland" &
DownloadPackage "gst-plugins-good" &
DownloadPackage "hunspell" &
DownloadPackage "jasper" &
DownloadPackage "keybinder3" &
DownloadPackage "libdmtx" &
wait
DownloadPackage "libqaccessibilityclient" &
DownloadPackage "libqalculate" &
DownloadPackage "LibRaw" &
DownloadPackage "openblas" &
DownloadPackage "polkit-qt" &
DownloadPackage "qca" &
DownloadPackage "qrencode" &
DownloadPackage "xdpyinfo" &
DownloadPackage "zxing-cpp" &
wait
DownloadPackage "ark" &
DownloadPackage "attica" &
DownloadPackage "baloo" &
DownloadPackage "baloo-widgets" &
DownloadPackage "bluedevil" &
DownloadPackage "bluez-qt" &
DownloadPackage "breeze" &
DownloadPackage "breeze-grub" &
DownloadPackage "breeze-gtk" &
DownloadPackage "breeze-icons" &
wait
DownloadPackage "dolphin" &
DownloadPackage "dolphin-plugins" &
DownloadPackage "ffmpegthumbs" &
DownloadPackage "frameworkintegration" &
DownloadPackage "gwenview" &
DownloadPackage "kactivitymanagerd" &
DownloadPackage "kapidox" &
DownloadPackage "karchive" &
DownloadPackage "kauth" &
DownloadPackage "kbookmarks" &
wait
DownloadPackage "kcmutils" &
DownloadPackage "kcodecs" &
DownloadPackage "kColorPicker" &
DownloadPackage "kcolorscheme" &
DownloadPackage "kcompletion" &
DownloadPackage "kconfig" &
DownloadPackage "kconfigwidgets" &
DownloadPackage "kcoreaddons" &
DownloadPackage "kcrash" &
DownloadPackage "kdbusaddons" &
wait
DownloadPackage "kdeclarative" &
DownloadPackage "kde-cli-tools" &
DownloadPackage "kdecoration" &
DownloadPackage "kded" &
DownloadPackage "kde-gtk-config" &
DownloadPackage "kdenetwork-filesharing" &
DownloadPackage "kdeplasma-addons" &
DownloadPackage "kdesu" &
DownloadPackage "kdnssd" &
DownloadPackage "kfilemetadata" &
wait
DownloadPackage "kglobalaccel" &
DownloadPackage "kglobalacceld" &
DownloadPackage "kguiaddons" &
DownloadPackage "kholidays" &
DownloadPackage "ki18n" &
DownloadPackage "kiconthemes" &
DownloadPackage "kidletime" &
DownloadPackage "kImageAnnotator" &
DownloadPackage "kinfocenter" &
DownloadPackage "kio" &
wait
DownloadPackage "kio-admin" &
DownloadPackage "kio-extras" &
DownloadPackage "kio-gdrive" &
DownloadPackage "kio-zeroconf" &
DownloadPackage "kirigami" &
DownloadPackage "kirigami-addons" &
DownloadPackage "kitemmodels" &
DownloadPackage "kitemviews" &
DownloadPackage "kjobwidgets" &
DownloadPackage "kmenuedit" &
wait
DownloadPackage "knewstuff" &
DownloadPackage "knighttime" &
DownloadPackage "knotifications" &
DownloadPackage "knotifyconfig" &
DownloadPackage "konsole" &
DownloadPackage "kpackage" &
DownloadPackage "kparts" &
DownloadPackage "kpeople" &
DownloadPackage "kpeoplevcard" &
DownloadPackage "kpipewire" &
wait
DownloadPackage "kplotting" &
DownloadPackage "kpty" &
DownloadPackage "kqtquickcharts" &
DownloadPackage "kquickcharts" &
DownloadPackage "kquickimageeditor" &
DownloadPackage "krunner" &
DownloadPackage "kscreen" &
DownloadPackage "kscreenlocker" &
DownloadPackage "kservice" &
DownloadPackage "ksshaskpass" &
wait
DownloadPackage "kstatusnotifieritem" &
DownloadPackage "ksvg" &
DownloadPackage "ksystemstats" &
DownloadPackage "ktexteditor" &
DownloadPackage "ktextwidgets" &
DownloadPackage "kunitconversion" &
DownloadPackage "kuserfeedback" &
DownloadPackage "kwallet" &
DownloadPackage "kwayland" &
DownloadPackage "kwayland-integration" &
wait
DownloadPackage "kwidgetsaddons" &
DownloadPackage "kwin" &
DownloadPackage "kwindowsystem" &
DownloadPackage "kwin-x11" &
DownloadPackage "kwrited" &
DownloadPackage "kxmlgui" &
DownloadPackage "layer-shell-qt" &
DownloadPackage "libkdcraw" &
DownloadPackage "libkexiv2" &
DownloadPackage "libkipi" &
wait
DownloadPackage "libkscreen" &
DownloadPackage "libksysguard" &
DownloadPackage "libplasma" &
DownloadPackage "libqaccessibilityclient" &
DownloadPackage "milou" &
DownloadPackage "modemmanager-qt" &
DownloadPackage "networkmanager-qt" &
DownloadPackage "okular" &
DownloadPackage "oxygen" &
DownloadPackage "plasma5support" &
wait
DownloadPackage "plasma-activities" &
DownloadPackage "plasma-activities-stats" &
DownloadPackage "plasma-browser-integration" &
DownloadPackage "plasma-desktop" &
DownloadPackage "plasma-integration" &
DownloadPackage "plasma-nm" &
DownloadPackage "plasma-pa" &
DownloadPackage "plasma-systemmonitor" &
DownloadPackage "plasma-workspace" &
DownloadPackage "polkit-kde-agent" &
wait
DownloadPackage "powerdevil" &
DownloadPackage "prison" &
DownloadPackage "pulseaudio-qt" &
DownloadPackage "purpose" &
DownloadPackage "qqc2-desktop-style" &
DownloadPackage "sddm" &
DownloadPackage "sddm-kcm" &
DownloadPackage "solid" &
DownloadPackage "sonnet" &
DownloadPackage "spectacle" &
wait
DownloadPackage "syndication" &
DownloadPackage "syntax-highlighting" &
DownloadPackage "systemsettings" &
DownloadPackage "threadweaver" &
DownloadPackage "xdg-desktop-portal-kde" &
wait

### packages that require specific stripping

DownloadPackage "appstream" & # required by main menu
DownloadPackage "gcc-gfortran" & # required by spectacle
DownloadPackage "leptonica" & # required by spectacle
DownloadPackage "opencv" & # required by spectacle
DownloadPackage "phonon" & # required by dolphin and others
DownloadPackage "qcoro" &
DownloadPackage "qt6" &
DownloadPackage "qtkeychain" & # required by network tray
DownloadPackage "tesseract" & # required by spectacle
DownloadPackage "zint" & # required by clipboard tray
wait

rm FILE_LIST
rm serverPackages.txt
