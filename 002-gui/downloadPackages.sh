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
DownloadPackage "cairomm" &
wait
DownloadPackage "cdparanoia-III" &
DownloadPackage "cryptsetup" &
DownloadPackage "db48" & # required by bluez (obexd)
DownloadPackage "dejavu-fonts-ttf" &
DownloadPackage "desktop-file-utils" &
DownloadPackage "djvulibre" &
DownloadPackage "esound" &
DownloadPackage "exiv2" &
DownloadPackage "flac" &
DownloadPackage "fontconfig" &
DownloadPackage "freeglut" &
wait
DownloadPackage "freetype" &
DownloadPackage "fribidi" &
DownloadPackage "gcr" &
DownloadPackage "gdk-pixbuf2" &
DownloadPackage "giflib" &
DownloadPackage "glew" &
DownloadPackage "glibmm" &
DownloadPackage "glu" &
DownloadPackage "gnome-themes-extra" &
DownloadPackage "gobject-introspection" &
DownloadPackage "gparted" &
DownloadPackage "graphene" & # required by libgstopengl
DownloadPackage "graphite2" &
wait
DownloadPackage "gsettings-desktop-schemas" &
DownloadPackage "gsl" &
DownloadPackage "gst-plugins-base" & # required by bluetooth audio
DownloadPackage "gstreamer" & # required by bluetooth audio
DownloadPackage "gtkmm3" &
DownloadPackage "gvfs" &
DownloadPackage "harfbuzz" &
DownloadPackage "hicolor-icon-theme" &
DownloadPackage "iceauth" &
DownloadPackage "intel-vaapi-driver" &
DownloadPackage "json-c" &
DownloadPackage "json-glib" &
DownloadPackage "lame" &
DownloadPackage "lcms2" &
wait
DownloadPackage "lcms" &
DownloadPackage "libao" &
DownloadPackage "libasyncns" &
DownloadPackage "libatasmart" &
DownloadPackage "libblockdev" &
DownloadPackage "libbluray" &
DownloadPackage "libbytesize" &
DownloadPackage "libcaca" &
DownloadPackage "libcanberra" & # required by pipewire
DownloadPackage "libcddb" &
DownloadPackage "libcdio" &
DownloadPackage "libcdio-paranoia" &
DownloadPackage "libdmx" &
wait
DownloadPackage "libdrm" &
DownloadPackage "libdvdnav" &
DownloadPackage "libdvdread" &
DownloadPackage "libedit" &
DownloadPackage "libepoxy" &
DownloadPackage "libevdev" &
DownloadPackage "libevent" &
DownloadPackage "libexif" &
DownloadPackage "libfontenc" &
DownloadPackage "libglade" &
DownloadPackage "libglvnd" &
wait
DownloadPackage "libgphoto2" &
DownloadPackage "libical" &
DownloadPackage "libinput" &
DownloadPackage "libICE" &
DownloadPackage "libjpeg-turbo" &
DownloadPackage "libmad" &
DownloadPackage "libmtp" &
DownloadPackage "libnotify" &
DownloadPackage "libogg" &
DownloadPackage "libopusenc" &
DownloadPackage "libpciaccess" &
wait
DownloadPackage "libpng" &
DownloadPackage "libsamplerate" &
DownloadPackage "libsecret" &
DownloadPackage "libsigc++" &
DownloadPackage "libSM" &
DownloadPackage "libsndfile" &
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
DownloadPackage "libXau" &
DownloadPackage "libXaw" &
DownloadPackage "libxcb" &
DownloadPackage "libXcomposite" &
wait
DownloadPackage "libXcursor" &
DownloadPackage "libXdamage" &
DownloadPackage "libXdmcp" &
DownloadPackage "libXevie" &
DownloadPackage "libXext" &
DownloadPackage "libXfixes" &
DownloadPackage "libXfont2" &
DownloadPackage "libXfontcache" &
DownloadPackage "libXft" &
DownloadPackage "libXi" &
DownloadPackage "libXinerama" &
DownloadPackage "libxkbcommon" &
wait
DownloadPackage "libxkbfile" &
DownloadPackage "libXmu" &
DownloadPackage "libXp" &
DownloadPackage "libXpm" &
DownloadPackage "libXpresent" &
DownloadPackage "libXrandr" &
DownloadPackage "libXrender" &
DownloadPackage "libXres" &
DownloadPackage "libXScrnSaver" &
DownloadPackage "libxcvt" &
DownloadPackage "libxshmfence" &
DownloadPackage "libxslt" &
DownloadPackage "libXt" &
wait
DownloadPackage "libXtst" &
DownloadPackage "libXv" &
DownloadPackage "libXvMC" &
DownloadPackage "libXxf86dga" &
DownloadPackage "libXxf86misc" &
DownloadPackage "libXxf86vm" &
DownloadPackage "mesa" &
DownloadPackage "mkfontscale" &
DownloadPackage "mobile-broadband-provider-info" &
DownloadPackage "mpg123" &
DownloadPackage "mtdev" &
wait
DownloadPackage "ocl-icd" &
DownloadPackage "openjpeg" &
DownloadPackage "opus" &
DownloadPackage "opusfile" &
DownloadPackage "opus-tools" &
DownloadPackage "orc" &
DownloadPackage "pango" &
DownloadPackage "pangomm" &
DownloadPackage "pixman" &
DownloadPackage "poppler" &
DownloadPackage "pulseaudio" &
wait
DownloadPackage "pycairo" &
DownloadPackage "pygobject3" &
DownloadPackage "pyxdg" &
DownloadPackage "rdesktop" &
DownloadPackage "sbc" &
DownloadPackage "setxkbmap" &
DownloadPackage "sdl" &
DownloadPackage "SDL2" &
DownloadPackage "shared-mime-info" &
DownloadPackage "speex" &
DownloadPackage "speexdsp" &
wait
DownloadPackage "startup-notification" &
DownloadPackage "svgalib" &
DownloadPackage "udisks2" &
DownloadPackage "upower" &
DownloadPackage "v4l-utils" &
DownloadPackage "vorbis-tools" &
DownloadPackage "wavpack" &
DownloadPackage "wayland" &
DownloadPackage "wayland-utils" &
DownloadPackage "x11-skel" &
DownloadPackage "xauth" &
wait
DownloadPackage "xbacklight" &
DownloadPackage "xcb-util" &
DownloadPackage "xcb-util-cursor" & # required by VirtualBox
DownloadPackage "xcb-util-image" &
DownloadPackage "xcb-util-keysyms" &
DownloadPackage "xcb-util-renderutil" &
DownloadPackage "xcb-util-wm" &
wait
DownloadPackage "xclipboard" &
DownloadPackage "xdg-user-dirs" &
DownloadPackage "xdg-utils" &
DownloadPackage "xev" &
DownloadPackage "xhost" &
DownloadPackage "xinit" &
DownloadPackage "xkbcomp" &
DownloadPackage "xkeyboard-config" &
DownloadPackage "xkill" &
wait
DownloadPackage "xmessage" &
DownloadPackage "xmodmap" &
DownloadPackage "xprop" &
DownloadPackage "xrandr" &
DownloadPackage "xrdb" &
DownloadPackage "xset" &
DownloadPackage "xsetroot" &
DownloadPackage "xterm" &
DownloadPackage "xvinfo" &
wait

### slackware specific version packages

if [ $SLACKWAREVERSION == "current" ]; then
	DownloadPackage "cargo-c" & # required by librsvg
	DownloadPackage "gcr4" & # required by gvfs 1.54+
	DownloadPackage "labwc" &
	DownloadPackage "libdeflate" & # required by libtiff 
	DownloadPackage "libdisplay-info" & # required by some DEs and mpv to have vaapi
	DownloadPackage "libnvme" & # required by udisks 2.10.0+
	DownloadPackage "libsfdo" & # required by labwc
	wait
	DownloadPackage "libsoup3" & # required by gvfs (gvfsd-http)
	DownloadPackage "seatd" & # required by labwc
	DownloadPackage "volume_key" & # required by udisks 2.10.0+
	DownloadPackage "wlroots" & # required by labwc
	DownloadPackage "xorg-server-xwayland" & # required by labwc
	DownloadPackage "xcb-util-errors" & # required by labwc
	wait
else
	DownloadPackage "librsvg" &
	DownloadPackage "libsoup" & # required by gvfs (gvfsd-http)
	wait
fi

### packages that require specific striping

DownloadPackage "llvm" &
DownloadPackage "vulkan-sdk" &
wait

### temporary packages for further building

DownloadPackage "cups" & # to build gtk+3
DownloadPackage "xtrans" & # to build xorg
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
