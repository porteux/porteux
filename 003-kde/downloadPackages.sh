#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

GenerateRepositoryUrls

DownloadPackage "accountsservice" &
DownloadPackage "appstream" &
DownloadPackage "cfitsio" &
DownloadPackage "editorconfig-core-c" &
DownloadPackage "egl-wayland" &
DownloadPackage "eglexternalplatform" &
DownloadPackage "gst-plugins-good" &
wait
DownloadPackage "hunspell" &
DownloadPackage "jasper" &
DownloadPackage "keybinder3" &
DownloadPackage "libfyaml" &
DownloadPackage "libdmtx" &
DownloadPackage "libqaccessibilityclient" &
wait
DownloadPackage "libqalculate" &
DownloadPackage "LibRaw" &
DownloadPackage "openblas" &
DownloadPackage "polkit-qt" &
DownloadPackage "qrencode" &
DownloadPackage "xdpyinfo" &
DownloadPackage "zxing-cpp" &
wait

### packages that require specific striping

DownloadPackage "gcc-gfortran" & # required by spectable
DownloadPackage "opencv" & # required by spectable
DownloadPackage "phonon" & # required by dolphin and others
DownloadPackage "qt6" &
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt

### non-slackware repository

source "$BUILDERUTILSPATH/slackwarerepository.sh"
REPOSITORY="https://slackware.halpanet.org/kde6town/stable/current/${ARCH}"
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
DownloadPackage "ddcutil" &
DownloadPackage "dolphin" &
DownloadPackage "dolphin-plugins" &
DownloadPackage "ffmpegthumbs" &
DownloadPackage "frameworkintegration" &
DownloadPackage "gwenview" &
DownloadPackage "kactivitymanagerd" &
DownloadPackage "kapidox" &
wait
DownloadPackage "karchive" &
DownloadPackage "kauth" &
DownloadPackage "kbookmarks" &
DownloadPackage "kcmutils" &
DownloadPackage "kcodecs" &
DownloadPackage "kColorPicker" &
DownloadPackage "kcolorscheme" &
DownloadPackage "kcompletion" &
DownloadPackage "kconfig" &
DownloadPackage "kconfigwidgets" &
wait
DownloadPackage "kcoreaddons" &
DownloadPackage "kcrash" &
DownloadPackage "kdbusaddons" &
DownloadPackage "kdeclarative" &
DownloadPackage "kde-cli-tools" &
DownloadPackage "kdecoration" &
DownloadPackage "kded" &
DownloadPackage "kde-gtk-config" &
DownloadPackage "kdenetwork-filesharing" &
DownloadPackage "kdeplasma-addons" &
DownloadPackage "kdesu" &
wait
DownloadPackage "kdnssd" &
DownloadPackage "kfilemetadata" &
DownloadPackage "kglobalaccel" &
DownloadPackage "kglobalacceld" &
DownloadPackage "kguiaddons" &
DownloadPackage "kholidays" &
DownloadPackage "ki18n" &
DownloadPackage "kiconthemes" &
DownloadPackage "kidletime" &
DownloadPackage "kImageAnnotator" &
DownloadPackage "kinfocenter" &
wait
DownloadPackage "kio" &
DownloadPackage "kio-admin" &
DownloadPackage "kio-extras" &
DownloadPackage "kio-gdrive" &
DownloadPackage "kio-zeroconf" &
DownloadPackage "kirigami" &
DownloadPackage "kirigami-addons" &
DownloadPackage "kitemmodels" &
DownloadPackage "kitemviews" &
DownloadPackage "kjobwidgets" &
wait
DownloadPackage "kmenuedit" &
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
DownloadPackage "krunner" &
DownloadPackage "kscreen" &
DownloadPackage "kscreenlocker" &
DownloadPackage "kservice" &
DownloadPackage "ksshaskpass" &
DownloadPackage "kstatusnotifieritem" &
wait
DownloadPackage "ksvg" &
DownloadPackage "ksystemstats" &
DownloadPackage "ktexteditor" &
DownloadPackage "ktextwidgets" &
DownloadPackage "kunitconversion" &
DownloadPackage "kuserfeedback" &
DownloadPackage "kwallet" &
DownloadPackage "kwayland" &
DownloadPackage "kwayland-integration" &
DownloadPackage "kwidgetsaddons" &
wait
DownloadPackage "kwin" &
DownloadPackage "kwin-x11" &
DownloadPackage "kwindowsystem" &
DownloadPackage "kwrited" &
DownloadPackage "kxmlgui" &
DownloadPackage "layer-shell-qt" &
DownloadPackage "libkdcraw" &
DownloadPackage "libkexiv2" &
DownloadPackage "libkipi" &
DownloadPackage "libkscreen" &
DownloadPackage "libksysguard" &
wait
DownloadPackage "libplasma" &
DownloadPackage "libqaccessibilityclient" &
DownloadPackage "milou" &
DownloadPackage "modemmanager-qt" &
DownloadPackage "networkmanager-qt" &
DownloadPackage "okular" &
DownloadPackage "oxygen" &
DownloadPackage "plasma5support" &
DownloadPackage "plasma-activities" &
DownloadPackage "plasma-activities-stats" &
wait
DownloadPackage "plasma-browser-integration" &
DownloadPackage "plasma-desktop" &
DownloadPackage "plasma-integration" &
DownloadPackage "plasma-nm" &
DownloadPackage "plasma-pa" &
DownloadPackage "plasma-systemmonitor" &
DownloadPackage "plasma-workspace" &
wait
DownloadPackage "polkit-kde-agent" &
DownloadPackage "polkit-qt" &
DownloadPackage "powerdevil" &
DownloadPackage "prison" &
DownloadPackage "pulseaudio-qt" &
DownloadPackage "purpose" &
DownloadPackage "qca" &
wait
DownloadPackage "qcoro" &
DownloadPackage "qqc2-desktop-style" &
DownloadPackage "sddm" &
DownloadPackage "sddm-kcm" &
DownloadPackage "solid" &
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