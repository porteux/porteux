#!/bin/bash
source "$BUILDER_UTILS_PATH/slackware-repository.sh"

generate_repository_urls

download_package "a52dec" &
download_package "alsa-lib" &
download_package "alsa-plugins" &
download_package "alsa-utils" &
download_package "atkmm" &
download_package "at-spi2-core" &
download_package "audiofile" &
download_package "cairo" &
wait
download_package "cairomm" &
download_package "cargo-c" & # required by librsvg
download_package "cdparanoia-III" &
download_package "cryptsetup" &
download_package "db48" & # required by bluez (obexd)
download_package "dejavu-fonts-ttf" &
download_package "desktop-file-utils" &
download_package "djvulibre" &
download_package "esound" &
download_package "flac" &
wait
download_package "fontconfig" &
download_package "freeglut" &
download_package "fribidi" &
download_package "gcr" &
download_package "gcr4" & # required by gvfs 1.54+
download_package "giflib" &
download_package "glew" &
download_package "glibmm" &
download_package "glib-networking" & # required by flatpak
download_package "glu" &
wait
download_package "gnome-themes-extra" &
download_package "gnupg2" & # required by flatpak
download_package "gobject-introspection" &
download_package "gparted" &
download_package "gpgmepp" & # required by poppler-glib
download_package "graphene" & # required by libgstopengl
download_package "graphite2" &
download_package "gsl" &
download_package "gst-plugins-base" & # required by bluetooth audio
download_package "gstreamer" & # required by bluetooth audio
download_package "gtkmm3" &
wait
download_package "gvfs" &
download_package "hicolor-icon-theme" &
download_package "iceauth" &
download_package "json-c" &
download_package "json-glib" &
download_package "lame" &
download_package "lcms" &
download_package "lcms2" &
download_package "libao" &
download_package "libasyncns" &
wait
download_package "libatasmart" &
download_package "libblockdev" &
download_package "libbluray" &
download_package "libbytesize" &
download_package "libcanberra" & # required by pipewire
download_package "libcddb" &
download_package "libcdio" &
download_package "libcdio-paranoia" &
download_package "libdecor" & # required by xorg-server-xwayland
download_package "libdeflate" & # required by libtiff
wait
download_package "libdisplay-info" & # required by some DEs and mpv to have vaapi
download_package "libdmx" &
download_package "libdrm" &
download_package "libdvdnav" &
download_package "libdvdread" &
download_package "libedit" &
download_package "libepoxy" &
download_package "libevdev" &
download_package "libevent" &
download_package "libexif" &
wait
download_package "libfontenc" &
download_package "libglade" &
download_package "libglvnd" &
download_package "libgphoto2" &
download_package "libical" &
download_package "libICE" &
download_package "libinput" &
download_package "libjpeg-turbo" &
download_package "libmad" &
download_package "libmtp" &
wait
download_package "libnotify" &
download_package "libnvme" & # required by udisks 2.10.0+
download_package "libogg" &
download_package "libopusenc" &
download_package "libpciaccess" &
download_package "libpng" &
download_package "libproxy" & # required by flatpak
download_package "libsamplerate" &
download_package "libsecret" &
download_package "libsfdo" & # required by labwc
wait
download_package "libsigc++" &
download_package "libSM" &
download_package "libsndfile" &
download_package "libsoup3" & # required by gvfs (gvfsd-http)
download_package "libssh" &
download_package "libtheora" &
download_package "libtiff" &
download_package "libunwind" &
download_package "libva" &
download_package "libvdpau" &
wait
download_package "libvisual" &
download_package "libvorbis" &
download_package "libvpx" &
download_package "libwacom" &
download_package "libwebp" &
download_package "libXau" &
download_package "libXaw" &
download_package "libxcb" &
download_package "libXcomposite" &
download_package "libXcursor" &
wait
download_package "libxcvt" &
download_package "libXdamage" &
download_package "libXdmcp" &
download_package "libXevie" &
download_package "libXext" &
download_package "libXfixes" &
download_package "libXfont2" &
download_package "libXfontcache" &
download_package "libXft" &
download_package "libXi" &
wait
download_package "libXinerama" &
download_package "libxkbcommon" &
download_package "libxkbfile" &
download_package "libXmu" &
download_package "libXp" &
download_package "libXpm" &
download_package "libXpresent" &
download_package "libXrandr" &
download_package "libXrender" &
download_package "libXres" &
wait
download_package "libXScrnSaver" &
download_package "libxshmfence" &
download_package "libxslt" &
download_package "libXt" &
download_package "libXtst" &
download_package "libXv" &
download_package "libXvMC" &
download_package "libXxf86dga" &
download_package "libXxf86misc" &
download_package "libXxf86vm" &
wait
download_package "mkfontscale" &
download_package "mobile-broadband-provider-info" &
download_package "mpg123" &
download_package "mtdev" &
download_package "npth" & # required by flatpak
download_package "ocl-icd" &
download_package "openjpeg" &
download_package "opus" &
download_package "opusfile" &
download_package "opus-tools" &
wait
download_package "orc" &
download_package "pango" &
download_package "pangomm" &
download_package "pixman" &
download_package "poppler" &
download_package "pycairo" &
download_package "pygobject3" &
download_package "pyxdg" &
download_package "rdesktop" &
download_package "sbc" &
wait
download_package "sdl" &
download_package "SDL2" &
download_package "seatd" & # required by labwc
download_package "setxkbmap" &
download_package "shared-mime-info" &
download_package "speex" &
download_package "speexdsp" &
download_package "startup-notification" &
download_package "svgalib" &
download_package "udisks2" &
wait
download_package "upower" &
download_package "v4l-utils" &
download_package "volume_key" & # required by udisks 2.10.0+
download_package "vorbis-tools" &
download_package "wavpack" &
download_package "wayland" &
download_package "wayland-utils" &
download_package "wlroots" & # required by labwc
download_package "x11-skel" &
download_package "xauth" &
wait
download_package "xbacklight" &
download_package "xcb-util" &
download_package "xcb-util-cursor" & # required by VirtualBox
download_package "xcb-util-errors" & # required by labwc
download_package "xcb-util-image" &
download_package "xcb-util-keysyms" &
download_package "xcb-util-renderutil" &
download_package "xcb-util-wm" &
download_package "xclipboard" &
download_package "xdg-user-dirs" &
wait
download_package "xdg-utils" &
download_package "xev" &
download_package "xhost" &
download_package "xinit" &
download_package "xkbcomp" &
download_package "xkeyboard-config" &
download_package "xkill" &
download_package "xmessage" &
download_package "xmodmap" &
download_package "xorg-server-xwayland" & # required by labwc
wait
download_package "xprop" &
download_package "xrandr" &
download_package "xrdb" &
download_package "xset" &
download_package "xsetroot" &
download_package "xterm" &
download_package "xvinfo" &
wait

### packages that require specific stripping

download_package "llvm" &
download_package "mesa" &
download_package "noto-fonts-ttf" &
download_package "pulseaudio" &
download_package "sound-theme-freedesktop" & # required by test sound in many DEs
download_package "vulkan-sdk" &
wait

### temporary packages only for building

download_package "cups" & # to build gtk+3
download_package "gperf" & # to build flatpak
download_package "nghttp2" & # to build appstream
download_package "nghttp3" & # to build appstream
download_package "ngtcp2" & # to build appstream
download_package "pyparsing" & # to build flatpak
download_package "python-Jinja2" & # required by libei
download_package "python-MarkupSafe" & # required by libei
download_package "socat" & # to build flatpak
download_package "xtrans" & # to build xorg
wait

