#!/bin/bash
source "$BUILDER_UTILS_PATH/slackware-repository.sh"

generate_repository_urls

download_package "accountsservice" &
download_package "aspell" &
download_package "cairomm1" & # required by gnome-system-monitor
download_package "colord" &
download_package "cracklib" & # required by gnome-control-center
download_package "dconf" &
download_package "editorconfig-core-c" &
download_package "enchant" &
download_package "glibmm2" & # required by gnome-system-monitor
download_package "gst-plugins-bad-free" & # required by gtk4 plugin
wait_for_downloads
download_package "gst-plugins-good" & # required by nautilus media properties
download_package "gst-plugins-libav" & # required by nautilus media properties
download_package "gtk4" &
download_package "gtkmm4" & # required by gnome-system-monitor
download_package "hunspell" &
download_package "hyphen" &
download_package "libgtop" &
download_package "libgusb" &
download_package "libnma" &
download_package "libpwquality" & # required by gnome-control-center
wait_for_downloads
download_package "libsigc++3" & # required by gnome-system-monitor
download_package "libxklavier" &
download_package "libyaml" &
download_package "mozjs140" &
download_package "pangomm2" & # required by gnome-system-monitor
download_package "woff2" &
wait_for_downloads

### only download if not present

[ ! -f /usr/bin/clang ] && download_package "llvm" & # required by glycin and others
wait_for_downloads

### packages that require specific stripping

download_package "ibus" & # required by gtk4 to allow accented characters
wait_for_downloads

### temporary packages only for building

download_package "boost" &
download_package "c-ares" &
download_package "cups" & # required by gnome-settings-daemon
download_package "dbus-python" &
download_package "egl-wayland" &
download_package "iso-codes" & # required by gnome-desktop, gnome-control-center and ibus
download_package "krb5" &
download_package "libsass" & # required by libadwaita
download_package "libwnck3" &
download_package "openldap" & # required by appstream
wait_for_downloads
download_package "python-pip" &
download_package "sassc" & # required by libadwaita
download_package "vulkan-sdk" & # required by gtksourceview
download_package "xtrans" &
wait_for_downloads

