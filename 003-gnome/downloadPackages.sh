#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

GenerateRepositoryUrls

DownloadPackage "accountsservice" &
DownloadPackage "aspell" &
DownloadPackage "cairomm1" & # required by gnome-system-monitor
DownloadPackage "colord" &
DownloadPackage "cracklib" & # required by gnome-control-center
DownloadPackage "dconf" &
DownloadPackage "editorconfig-core-c" &
DownloadPackage "enchant" &
DownloadPackage "glibmm2" & # required by gnome-system-monitor
DownloadPackage "gst-plugins-bad-free" & # required by gtk4 plugin
wait
DownloadPackage "gst-plugins-good" & # required by nautilus media properties
DownloadPackage "gst-plugins-libav" & # required by nautilus media properties
DownloadPackage "gtk4" &
DownloadPackage "gtkmm4" & # required by gnome-system-monitor
DownloadPackage "hunspell" &
DownloadPackage "hyphen" &
DownloadPackage "libgtop" &
DownloadPackage "libgusb" &
DownloadPackage "libnma" &
DownloadPackage "libpwquality" & # required by gnome-control-center
wait
DownloadPackage "libsigc++3" & # required by gnome-system-monitor
DownloadPackage "libxklavier" &
DownloadPackage "libyaml" &
DownloadPackage "mozjs140" &
DownloadPackage "pangomm2" & # required by gnome-system-monitor
DownloadPackage "woff2" &
wait

### only download if not present

[ ! -f /usr/bin/clang ] && DownloadPackage "llvm" & # required by glycin and others
wait

### packages that require specific stripping

DownloadPackage "ibus" & # required by gtk4 to allow accented characters
wait

### temporary packages only for building

DownloadPackage "boost" &
DownloadPackage "c-ares" &
DownloadPackage "cups" & # required by gnome-settings-daemon
DownloadPackage "dbus-python" &
DownloadPackage "egl-wayland" &
DownloadPackage "iso-codes" & # required by gnome-desktop
DownloadPackage "krb5" &
DownloadPackage "libsass" & # required by libadwaita
DownloadPackage "libwnck3" &
DownloadPackage "openldap" & # required by appstream
wait
DownloadPackage "python-pip" &
DownloadPackage "sassc" & # required by libadwaita
DownloadPackage "vulkan-sdk" & # required by gtksourceview
DownloadPackage "xtrans" &
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
