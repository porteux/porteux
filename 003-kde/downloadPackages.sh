#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

GenerateRepositoryUrls

DownloadPackage "accountsservice" &
DownloadPackage "cfitsio" &
DownloadPackage "editorconfig-core-c" &
DownloadPackage "egl-wayland" &
DownloadPackage "eglexternalplatform" &
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

### packages that require specific stripping

DownloadPackage "appstream" & # required by main menu
DownloadPackage "gcc-gfortran" & # required by spectacle
DownloadPackage "opencv" & # required by spectacle
DownloadPackage "phonon" & # required by dolphin and others
DownloadPackage "qcoro" &
DownloadPackage "qt6" &
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt

### non-slackware repository

REPOSITORY="https://slackware.halpanet.org/kde6town/stable/current/${ARCH}"
#REPOSITORY="https://slackware.nl/alien-kde/current/testing/${ARCH}"

GenerateRepositoryUrls

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
DownloadPackage "kColorPicker" & # luckycyborg repo
DownloadPackage "kcolorpicker" & # alienbob repo
DownloadPackage "kcolorscheme" &
DownloadPackage "kcompletion" &
DownloadPackage "kconfig" &
DownloadPackage "kconfigwidgets" &
DownloadPackage "kcoreaddons" &
DownloadPackage "kcrash" &
wait
DownloadPackage "kdbusaddons" &
DownloadPackage "kdeclarative" &
DownloadPackage "kde-cli-tools" &
DownloadPackage "kdecoration" &
DownloadPackage "kded" &
DownloadPackage "kde-gtk-config" &
DownloadPackage "kdenetwork-filesharing" &
DownloadPackage "kdeplasma-addons" &
DownloadPackage "kdesu" &
DownloadPackage "kdnssd" &
wait
DownloadPackage "kfilemetadata" &
DownloadPackage "kglobalaccel" &
DownloadPackage "kglobalacceld" &
DownloadPackage "kguiaddons" &
DownloadPackage "kholidays" &
DownloadPackage "ki18n" &
DownloadPackage "kiconthemes" &
DownloadPackage "kidletime" &
DownloadPackage "kImageAnnotator" & # luckycyborg repo
DownloadPackage "kimageannotator" & # alienbob repo
wait
DownloadPackage "kinfocenter" &
DownloadPackage "kio" &
DownloadPackage "kio-admin" &
DownloadPackage "kio-extras" &
DownloadPackage "kio-gdrive" &
DownloadPackage "kio-zeroconf" &
DownloadPackage "kirigami" &
DownloadPackage "kirigami-addons" &
DownloadPackage "kitemmodels" &
DownloadPackage "kitemviews" &
wait
DownloadPackage "kjobwidgets" &
DownloadPackage "kmenuedit" &
DownloadPackage "knewstuff" &
DownloadPackage "knighttime" &
DownloadPackage "knotifications" &
DownloadPackage "knotifyconfig" &
DownloadPackage "konsole" &
DownloadPackage "kpackage" &
DownloadPackage "kparts" &
DownloadPackage "kpeople" &
wait
DownloadPackage "kpeoplevcard" &
DownloadPackage "kpipewire" &
DownloadPackage "kplotting" &
DownloadPackage "kpty" &
DownloadPackage "kqtquickcharts" &
DownloadPackage "kquickcharts" &
DownloadPackage "kquickimageeditor" &
DownloadPackage "krunner" &
DownloadPackage "kscreen" &
DownloadPackage "kscreenlocker" &
wait
DownloadPackage "kservice" &
DownloadPackage "ksshaskpass" &
DownloadPackage "kstatusnotifieritem" &
DownloadPackage "ksvg" &
DownloadPackage "ksystemstats" &
DownloadPackage "ktexteditor" &
DownloadPackage "ktextwidgets" &
DownloadPackage "kunitconversion" &
DownloadPackage "kuserfeedback" &
DownloadPackage "kwallet" &
wait
DownloadPackage "kwayland" &
DownloadPackage "kwayland-integration" &
DownloadPackage "kwidgetsaddons" &
DownloadPackage "kwin" &
DownloadPackage "kwin-x11" &
DownloadPackage "kwindowsystem" &
DownloadPackage "kwrited" &
DownloadPackage "kxmlgui" &
DownloadPackage "layer-shell-qt" &
DownloadPackage "libkdcraw" &
wait
DownloadPackage "libkexiv2" &
DownloadPackage "libkipi" &
DownloadPackage "libkscreen" &
DownloadPackage "libksysguard" &
DownloadPackage "libplasma" &
DownloadPackage "libqaccessibilityclient" &
DownloadPackage "milou" &
DownloadPackage "modemmanager-qt" &
DownloadPackage "networkmanager-qt" &
DownloadPackage "okular" &
wait
DownloadPackage "oxygen" &
DownloadPackage "plasma5support" &
DownloadPackage "plasma-activities" &
DownloadPackage "plasma-activities-stats" &
DownloadPackage "plasma-browser-integration" &
DownloadPackage "plasma-desktop" &
DownloadPackage "plasma-integration" &
DownloadPackage "plasma-nm" &
DownloadPackage "plasma-pa" &
DownloadPackage "plasma-systemmonitor" &
wait
DownloadPackage "plasma-workspace" &
DownloadPackage "polkit-kde-agent" &
DownloadPackage "powerdevil" &
DownloadPackage "prison" &
DownloadPackage "pulseaudio-qt" &
DownloadPackage "purpose" &
DownloadPackage "qqc2-desktop-style" &
DownloadPackage "sddm" &
DownloadPackage "sddm-kcm" &
DownloadPackage "solid" &
wait
DownloadPackage "sonnet" &
DownloadPackage "spectacle" &
DownloadPackage "syndication" &
DownloadPackage "syntax-highlighting" &
DownloadPackage "systemsettings" &
DownloadPackage "threadweaver" &
DownloadPackage "xdg-desktop-portal-kde" &
wait

rm FILE_LIST
rm serverPackages.txt
