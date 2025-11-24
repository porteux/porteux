#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

GenerateRepositoryUrls

DownloadPackage "accountsservice" &
DownloadPackage "aspell" &
DownloadPackage "cairomm1" & # required by gnome-system-monitor
DownloadPackage "colord" &
DownloadPackage "cracklib" # required by gnome-control-center
DownloadPackage "dconf" &
DownloadPackage "editorconfig-core-c" &
DownloadPackage "enchant" &
wait
DownloadPackage "gexiv2" &
DownloadPackage "hunspell" &
DownloadPackage "glib-networking" &
DownloadPackage "glibmm2" & # required by gnome-system-monitor
DownloadPackage "gperf" & # required by appstream
DownloadPackage "gst-plugins-bad-free" & # required by gtk4 plugin
DownloadPackage "gst-plugins-good" & # required by nautilus media properties
DownloadPackage "gst-plugins-libav" & # required by nautilus media properties
wait
DownloadPackage "gtk4" &
DownloadPackage "gtkmm4" & # required by gnome-system-monitor
DownloadPackage "hyphen" &
DownloadPackage "libgtop" &
DownloadPackage "libgusb" &
DownloadPackage "libnma" &
wait
DownloadPackage "libproxy" &
DownloadPackage "libsigc++3" & # required by gnome-system-monitor
DownloadPackage "libxklavier" &
DownloadPackage "libyaml" &
DownloadPackage "mozjs140" &
DownloadPackage "pangomm2" & # required by gnome-system-monitor
DownloadPackage "libpwquality" & # required by gnome-control-center
DownloadPackage "woff2" &
wait

### only download if not present

[ ! -f /usr/bin/clang ] && DownloadPackage "llvm" &  # required by glycin and others

### packages that require specific striping

DownloadPackage "ibus" & # required by gtk4 to allow accented characters

### temporary packages only for building

DownloadPackage "boost" &
DownloadPackage "c-ares" &
DownloadPackage "cups" & # required by gnome-settings-daemon
DownloadPackage "dbus-python" &
DownloadPackage "egl-wayland" &
DownloadPackage "iso-codes" & # required by gnome-desktop
DownloadPackage "krb5" &
wait
DownloadPackage "libsass" & # required by libadwaita
DownloadPackage "libwnck3" &
DownloadPackage "openldap" & # required by appstream
DownloadPackage "python-pip" &
DownloadPackage "sassc" & # required by libadwaita
DownloadPackage "vulkan-sdk" & # required by gtksourceview
DownloadPackage "xtrans" &
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt