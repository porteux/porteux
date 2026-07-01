#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

GenerateRepositoryUrls

DownloadPackage "a52dec" &
DownloadPackage "alsa-lib" &
DownloadPackage "alsa-plugins" &
DownloadPackage "alsa-utils" &
DownloadPackage "atk" &
DownloadPackage "atkmm" &
DownloadPackage "at-spi2-atk" &
DownloadPackage "at-spi2-core" &
DownloadPackage "audiofile" &
DownloadPackage "cairo" &
wait
DownloadPackage "cairomm" &
DownloadPackage "cargo-c" & # required by librsvg
DownloadPackage "cdparanoia-III" &
DownloadPackage "cryptsetup" &
DownloadPackage "db48" & # required by bluez (obexd)
DownloadPackage "dejavu-fonts-ttf" &
DownloadPackage "desktop-file-utils" &
DownloadPackage "djvulibre" &
DownloadPackage "esound" &
DownloadPackage "flac" &
wait
DownloadPackage "fontconfig" &
DownloadPackage "freeglut" &
DownloadPackage "fribidi" &
DownloadPackage "gcr" &
DownloadPackage "gcr4" & # required by gvfs 1.54+
DownloadPackage "giflib" &
DownloadPackage "glew" &
DownloadPackage "glibmm" &
DownloadPackage "glib-networking" & # required by flatpak
DownloadPackage "glu" &
wait
DownloadPackage "gnome-themes-extra" &
DownloadPackage "gnupg2" & # required by flatpak
DownloadPackage "gobject-introspection" &
DownloadPackage "gparted" &
DownloadPackage "gpgmepp" & # required by poppler-glib
DownloadPackage "graphene" & # required by libgstopengl
DownloadPackage "graphite2" &
DownloadPackage "gsl" &
DownloadPackage "gst-plugins-base" & # required by bluetooth audio
DownloadPackage "gstreamer" & # required by bluetooth audio
DownloadPackage "gtkmm3" &
wait
DownloadPackage "gvfs" &
DownloadPackage "hicolor-icon-theme" &
DownloadPackage "iceauth" &
DownloadPackage "json-c" &
DownloadPackage "json-glib" &
DownloadPackage "lame" &
DownloadPackage "lcms" &
DownloadPackage "lcms2" &
DownloadPackage "libao" &
DownloadPackage "libasyncns" &
wait
DownloadPackage "libatasmart" &
DownloadPackage "libblockdev" &
DownloadPackage "libbluray" &
DownloadPackage "libbytesize" &
DownloadPackage "libcanberra" & # required by pipewire
DownloadPackage "libcddb" &
DownloadPackage "libcdio" &
DownloadPackage "libcdio-paranoia" &
DownloadPackage "libdecor" & # required by xorg-server-xwayland
DownloadPackage "libdeflate" & # required by libtiff
wait
DownloadPackage "libdisplay-info" & # required by some DEs and mpv to have vaapi
DownloadPackage "libdmx" &
DownloadPackage "libdrm" &
DownloadPackage "libdvdnav" &
DownloadPackage "libdvdread" &
DownloadPackage "libedit" &
DownloadPackage "libepoxy" &
DownloadPackage "libevdev" &
DownloadPackage "libevent" &
DownloadPackage "libexif" &
wait
DownloadPackage "libfontenc" &
DownloadPackage "libglade" &
DownloadPackage "libglvnd" &
DownloadPackage "libgphoto2" &
DownloadPackage "libical" &
DownloadPackage "libICE" &
DownloadPackage "libinput" &
DownloadPackage "libjpeg-turbo" &
DownloadPackage "libmad" &
DownloadPackage "libmtp" &
wait
DownloadPackage "libnotify" &
DownloadPackage "libnvme" & # required by udisks 2.10.0+
DownloadPackage "libogg" &
DownloadPackage "libopusenc" &
DownloadPackage "libpciaccess" &
DownloadPackage "libpng" &
DownloadPackage "libproxy" & # required by flatpak
DownloadPackage "libsamplerate" &
DownloadPackage "libsecret" &
DownloadPackage "libsfdo" & # required by labwc
wait
DownloadPackage "libsigc++" &
DownloadPackage "libSM" &
DownloadPackage "libsndfile" &
DownloadPackage "libsoup3" & # required by gvfs (gvfsd-http)
DownloadPackage "libssh" &
DownloadPackage "libtheora" &
DownloadPackage "libtiff" &
DownloadPackage "libunwind" &
DownloadPackage "libva" &
DownloadPackage "libvdpau" &
wait
DownloadPackage "libvisual" &
DownloadPackage "libvorbis" &
DownloadPackage "libvpx" &
DownloadPackage "libwacom" &
DownloadPackage "libwebp" &
DownloadPackage "libXau" &
DownloadPackage "libXaw" &
DownloadPackage "libxcb" &
DownloadPackage "libXcomposite" &
DownloadPackage "libXcursor" &
wait
DownloadPackage "libxcvt" &
DownloadPackage "libXdamage" &
DownloadPackage "libXdmcp" &
DownloadPackage "libXevie" &
DownloadPackage "libXext" &
DownloadPackage "libXfixes" &
DownloadPackage "libXfont2" &
DownloadPackage "libXfontcache" &
DownloadPackage "libXft" &
DownloadPackage "libXi" &
wait
DownloadPackage "libXinerama" &
DownloadPackage "libxkbcommon" &
DownloadPackage "libxkbfile" &
DownloadPackage "libXmu" &
DownloadPackage "libXp" &
DownloadPackage "libXpm" &
DownloadPackage "libXpresent" &
DownloadPackage "libXrandr" &
DownloadPackage "libXrender" &
DownloadPackage "libXres" &
wait
DownloadPackage "libXScrnSaver" &
DownloadPackage "libxshmfence" &
DownloadPackage "libxslt" &
DownloadPackage "libXt" &
DownloadPackage "libXtst" &
DownloadPackage "libXv" &
DownloadPackage "libXvMC" &
DownloadPackage "libXxf86dga" &
DownloadPackage "libXxf86misc" &
DownloadPackage "libXxf86vm" &
wait
DownloadPackage "mkfontscale" &
DownloadPackage "mobile-broadband-provider-info" &
DownloadPackage "mpg123" &
DownloadPackage "mtdev" &
DownloadPackage "npth" & # required by flatpak
DownloadPackage "ocl-icd" &
DownloadPackage "openjpeg" &
DownloadPackage "opus" &
DownloadPackage "opusfile" &
DownloadPackage "opus-tools" &
wait
DownloadPackage "orc" &
DownloadPackage "pango" &
DownloadPackage "pangomm" &
DownloadPackage "pixman" &
DownloadPackage "poppler" &
DownloadPackage "pycairo" &
DownloadPackage "pygobject3" &
DownloadPackage "pyxdg" &
DownloadPackage "rdesktop" &
DownloadPackage "sbc" &
wait
DownloadPackage "sdl" &
DownloadPackage "SDL2" &
DownloadPackage "seatd" & # required by labwc
DownloadPackage "setxkbmap" &
DownloadPackage "shared-mime-info" &
DownloadPackage "speex" &
DownloadPackage "speexdsp" &
DownloadPackage "startup-notification" &
DownloadPackage "svgalib" &
DownloadPackage "udisks2" &
wait
DownloadPackage "upower" &
DownloadPackage "v4l-utils" &
DownloadPackage "volume_key" & # required by udisks 2.10.0+
DownloadPackage "vorbis-tools" &
DownloadPackage "wavpack" &
DownloadPackage "wayland" &
DownloadPackage "wayland-utils" &
DownloadPackage "wlroots" & # required by labwc
DownloadPackage "x11-skel" &
DownloadPackage "xauth" &
wait
DownloadPackage "xbacklight" &
DownloadPackage "xcb-util" &
DownloadPackage "xcb-util-cursor" & # required by VirtualBox
DownloadPackage "xcb-util-errors" & # required by labwc
DownloadPackage "xcb-util-image" &
DownloadPackage "xcb-util-keysyms" &
DownloadPackage "xcb-util-renderutil" &
DownloadPackage "xcb-util-wm" &
DownloadPackage "xclipboard" &
DownloadPackage "xdg-user-dirs" &
wait
DownloadPackage "xdg-utils" &
DownloadPackage "xev" &
DownloadPackage "xhost" &
DownloadPackage "xinit" &
DownloadPackage "xkbcomp" &
DownloadPackage "xkeyboard-config" &
DownloadPackage "xkill" &
DownloadPackage "xmessage" &
DownloadPackage "xmodmap" &
DownloadPackage "xorg-server-xwayland" & # required by labwc
wait
DownloadPackage "xprop" &
DownloadPackage "xrandr" &
DownloadPackage "xrdb" &
DownloadPackage "xset" &
DownloadPackage "xsetroot" &
DownloadPackage "xterm" &
DownloadPackage "xvinfo" &
wait

### packages that require specific stripping

DownloadPackage "llvm" &
DownloadPackage "mesa" &
DownloadPackage "noto-fonts-ttf" &
DownloadPackage "pulseaudio" &
DownloadPackage "sound-theme-freedesktop" & # required by test sound in many DEs
DownloadPackage "vulkan-sdk" &
wait

### temporary packages only for building

DownloadPackage "cups" & # to build gtk+3
DownloadPackage "gperf" & # to build flatpak
DownloadPackage "ngtcp2" & # to build appstream
DownloadPackage "pyparsing" & # to build flatpak
DownloadPackage "python-Jinja2" & # required by libei
DownloadPackage "python-MarkupSafe" & # required by libei
DownloadPackage "socat" & # to build flatpak
DownloadPackage "xtrans" & # to build xorg
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
