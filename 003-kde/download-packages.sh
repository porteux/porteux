#!/bin/bash
source "$BUILDER_UTILS_PATH/slackware-repository.sh"

generate_repository_urls

download_package "accountsservice" &
download_package "boost" &
download_package "cfitsio" &
download_package "corrosion" &
download_package "ddcutil" &
download_package "editorconfig-core-c" &
download_package "eglexternalplatform" &
download_package "egl-wayland" &
download_package "gst-plugins-good" &
download_package "highway" & # required by spectacle
wait_for_downloads
download_package "hunspell" &
download_package "jasper" &
download_package "kdsoap" &
download_package "keybinder3" &
download_package "libdmtx" &
download_package "libqalculate" &
download_package "LibRaw" &
download_package "libsass" &
download_package "python-lxml" &
wait_for_downloads
download_package "qrencode" &
download_package "sassc" &
download_package "xdpyinfo" &
download_package "zxing-cpp" &
wait_for_downloads

### packages that require specific stripping

download_package "appstream" & # required by main menu
download_package "leptonica" & # required by spectacle
download_package "qcoro" &
download_package "qt6" &
download_package "qtkeychain" & # required by network tray
download_package "tesseract" & # required by spectacle
download_package "zint" & # required by clipboard tray
wait_for_downloads
