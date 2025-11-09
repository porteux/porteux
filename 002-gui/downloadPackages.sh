#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

GenerateRepositoryUrls

DownloadPackage "a52dec" &
DownloadPackage "alsa-lib" &
DownloadPackage "alsa-plugins" &
DownloadPackage "alsa-utils" &
DownloadPackage "at-spi2-atk" &
DownloadPackage "at-spi2-core" &
DownloadPackage "atk" &
DownloadPackage "atkmm" &
DownloadPackage "audiofile" &
wait
DownloadPackage "cairo" &
DownloadPackage "cairomm" &
DownloadPackage "cargo-c" & # required by librsvg
DownloadPackage "cdparanoia-III" &
DownloadPackage "cryptsetup" &
DownloadPackage "db48" & # required by bluez (obexd)
DownloadPackage "dejavu-fonts-ttf" &
DownloadPackage "desktop-file-utils" &
DownloadPackage "djvulibre" &
DownloadPackage "esound" &
wait
DownloadPackage "exiv2" &
DownloadPackage "flac" &
DownloadPackage "fontconfig" &
DownloadPackage "freeglut" &
DownloadPackage "freetype" &
DownloadPackage "fribidi" &
DownloadPackage "gcr" &
DownloadPackage "gcr4" & # required by gvfs 1.54+
DownloadPackage "giflib" &
DownloadPackage "glew" &
wait
DownloadPackage "glibmm" &
DownloadPackage "glu" &
DownloadPackage "gnome-themes-extra" &
DownloadPackage "gobject-introspection" &
DownloadPackage "gparted" &
DownloadPackage "graphene" & # required by libgstopengl
DownloadPackage "graphite2" &
DownloadPackage "gsl" &
DownloadPackage "gst-plugins-base" & # required by bluetooth audio
DownloadPackage "gstreamer" & # required by bluetooth audio
wait
DownloadPackage "gtkmm3" &
DownloadPackage "gvfs" &
DownloadPackage "harfbuzz" &
DownloadPackage "hicolor-icon-theme" &
DownloadPackage "iceauth" &
DownloadPackage "intel-vaapi-driver" &
DownloadPackage "json-c" &
DownloadPackage "json-glib" &
DownloadPackage "labwc" &
DownloadPackage "lame" &
wait
DownloadPackage "lcms" &
DownloadPackage "lcms2" &
DownloadPackage "libICE" &
DownloadPackage "libSM" &
DownloadPackage "libXau" &
DownloadPackage "libXScrnSaver" &
DownloadPackage "libXaw" &
DownloadPackage "libXcomposite" &
DownloadPackage "libXcursor" &
DownloadPackage "libXdamage" &
wait
DownloadPackage "libXdmcp" &
DownloadPackage "libXevie" &
DownloadPackage "libXext" &
DownloadPackage "libXfixes" &
DownloadPackage "libXfont2" &
DownloadPackage "libXfontcache" &
DownloadPackage "libXft" &
DownloadPackage "libXi" &
DownloadPackage "libXinerama" &
DownloadPackage "libXmu" &
wait
DownloadPackage "libXp" &
DownloadPackage "libXpm" &
DownloadPackage "libXpresent" &
DownloadPackage "libXrandr" &
DownloadPackage "libXrender" &
DownloadPackage "libXres" &
DownloadPackage "libXt" &
DownloadPackage "libXtst" &
DownloadPackage "libXv" &
DownloadPackage "libXvMC" &
wait
DownloadPackage "libXxf86dga" &
DownloadPackage "libXxf86misc" &
DownloadPackage "libXxf86vm" &
DownloadPackage "libao" &
DownloadPackage "libasyncns" &
DownloadPackage "libatasmart" &
DownloadPackage "libblockdev" &
DownloadPackage "libbluray" &
DownloadPackage "libbytesize" &
DownloadPackage "libcanberra" & # required by pipewire
wait
DownloadPackage "libcddb" &
DownloadPackage "libcdio" &
DownloadPackage "libcdio-paranoia" &
DownloadPackage "libdeflate" & # required by libtiff
DownloadPackage "libdisplay-info" & # required by some DEs and mpv to have vaapi
DownloadPackage "libdmx" &
DownloadPackage "libdrm" &
DownloadPackage "libdvdnav" &
DownloadPackage "libdvdread" &
DownloadPackage "libedit" &
wait
DownloadPackage "libepoxy" &
DownloadPackage "libevdev" &
DownloadPackage "libevent" &
DownloadPackage "libexif" &
DownloadPackage "libfontenc" &
DownloadPackage "libglade" &
DownloadPackage "libglvnd" &
DownloadPackage "libgphoto2" &
DownloadPackage "libical" &
DownloadPackage "libinput" &
wait
DownloadPackage "libjpeg-turbo" &
DownloadPackage "libmad" &
DownloadPackage "libmtp" &
DownloadPackage "libnotify" &
DownloadPackage "libnvme" & # required by udisks 2.10.0+
DownloadPackage "libogg" &
DownloadPackage "libopusenc" &
DownloadPackage "libpciaccess" &
DownloadPackage "libpng" &
DownloadPackage "libsamplerate" &
wait
DownloadPackage "libsecret" &
DownloadPackage "libsfdo" & # required by labwc
DownloadPackage "libsigc++" &
DownloadPackage "libsndfile" &
DownloadPackage "libsoup3" & # required by gvfs (gvfsd-http)
DownloadPackage "libssh" &
DownloadPackage "libtheora" &
DownloadPackage "libtiff" &
DownloadPackage "libunwind" &
DownloadPackage "libva" &
wait
DownloadPackage "libvdpau" &
DownloadPackage "libvisual" &
DownloadPackage "libvorbis" &
DownloadPackage "libvpx" &
DownloadPackage "libwacom" &
DownloadPackage "libwebp" &
DownloadPackage "libxcvt" &
DownloadPackage "libxkbcommon" &
DownloadPackage "libxkbfile" &
DownloadPackage "libxcb" &
DownloadPackage "libxshmfence" &
wait
DownloadPackage "libxslt" &
DownloadPackage "mkfontscale" &
DownloadPackage "mobile-broadband-provider-info" &
DownloadPackage "mpg123" &
DownloadPackage "mtdev" &
DownloadPackage "ocl-icd" &
DownloadPackage "openjpeg" &
DownloadPackage "opus" &
DownloadPackage "opus-tools" &
DownloadPackage "opusfile" &
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

### packages that require specific striping

DownloadPackage "llvm" &
DownloadPackage "mesa" &
DownloadPackage "pulseaudio" &
DownloadPackage "vulkan-sdk" &
wait

### temporary packages only for building

DownloadPackage "cups" & # to build gtk+3
DownloadPackage "xtrans" & # to build xorg
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
