#!/bin/bash
# script to build nvidia driver module -- works for both i586 and x86_64 architectures

is_root() {
	[ "$(id -u)" -eq 0 ]
}

if ! is_root; then
	echo "Please enter admin's password below:"
	su -c "$(printf '%q ' "$(realpath "$0")" "$@")"
	exit
fi

[ "$(getconf LONG_BIT)" = "64" ] && SYSTEM_BITS=64
OUTPUT_DIR="$PORTDIR/modules"
INSTALLER_DIR=/tmp/nvidia
MODULE_DIR=$INSTALLER_DIR/nvidia-module
mkdir -p $INSTALLER_DIR/nvidia-module

# add ABI compatible setting
if ! grep -q '"IgnoreABI"' /etc/X11/xorg.conf 2>/dev/null; then
	echo '
Section "ServerFlags"
    Option         "IgnoreABI" "1"
EndSection' >> /etc/X11/xorg.conf
fi

echo "Creating memory changes file..."
sync; echo 3 > /proc/sys/vm/drop_caches
tar cf $INSTALLER_DIR/nvidia.tar.xz --exclude={"*/.*","*/.wh.*",".cache","dev","home","mnt","opt","root","run","tmp","var","etc/cups","etc/udev","etc/profile.d","etc/porteux","lib/firmware","lib/modules/*porteux/modules.*"} -C /mnt/live/memory changes || exit 1

echo "Extracting memory changes file..."
tar xf $INSTALLER_DIR/nvidia.tar.xz --strip 1 -C $MODULE_DIR || exit 1

echo "Cleaning up driver directory..."
find $MODULE_DIR -name '*.la' -delete
find $MODULE_DIR -type f -maxdepth 1 -delete
find $MODULE_DIR -type l -maxdepth 1 -delete
find $MODULE_DIR/etc/ -maxdepth 1 \( -type f -o -type d \) ! \( -name "modprobe.d" -o -name "OpenCL" -o -name "vulkan" \) -delete 2>/dev/null
rm -f $MODULE_DIR/usr/bin/nvidia-debugdump
rm -f $MODULE_DIR/usr/bin/nvidia-installer
rm -f $MODULE_DIR/usr/bin/nvidia-uninstall
rm -rf $MODULE_DIR/etc/X11/xorg.conf.d
rm -f $MODULE_DIR/etc/X11/xorg.conf.nvidia-xconfig-original
rm -rf $MODULE_DIR/usr/{man,src}
rm -f $MODULE_DIR/usr/bin/gnome-keyring-daemon
rm -rf $MODULE_DIR/usr/lib$SYSTEM_BITS/{gdk-pixbuf-2.0,gio,gtk-2.0,gtk-3.0}
rm -f $MODULE_DIR/usr/lib$SYSTEM_BITS/{libXvMCgallium.*,libgsm.*,libnvidia-gtk2.*,libudev.*,libunrar.*}
rm -rf $MODULE_DIR/usr/local
rm -rf $MODULE_DIR/usr/share/{glib-2.0,man,mime,pixmaps}
rm -f $MODULE_DIR/usr/{,local/}share/applications/mimeinfo.cache
rm -rf $MODULE_DIR/usr/share/doc/NVIDIA_GLX-1.0/{html,samples,LICENSE,NVIDIA_Changelog,README.txt}

# strip
mkdir -p $MODULE_DIR/../nostrip

if [ "$SYSTEM_BITS" = 64 ]; then
	mkdir -p $MODULE_DIR/../nostrip64
fi

mv $MODULE_DIR/usr/lib/libnvcuvid.* $MODULE_DIR/../nostrip &>/dev/null
mv $MODULE_DIR/usr/lib/libnvidia-encode.* $MODULE_DIR/../nostrip &>/dev/null
mv $MODULE_DIR/usr/lib/libnvidia-eglcore.* $MODULE_DIR/../nostrip &>/dev/null
mv $MODULE_DIR/usr/lib/libnvidia-glvkspirv.* $MODULE_DIR/../nostrip &>/dev/null
mv $MODULE_DIR/usr/lib/libnvidia-gpucomp.* $MODULE_DIR/../nostrip &>/dev/null
mv $MODULE_DIR/usr/lib/libnvidia-nvvm.* $MODULE_DIR/../nostrip &>/dev/null
mv $MODULE_DIR/usr/lib/libnvidia-tls.* $MODULE_DIR/../nostrip &>/dev/null
mv $MODULE_DIR/usr/lib/vdpau $MODULE_DIR/../nostrip &>/dev/null

if [ "$SYSTEM_BITS" = 64 ]; then
	mv $MODULE_DIR/usr/lib64/libnvcuvid.* $MODULE_DIR/../nostrip64 &>/dev/null
	mv $MODULE_DIR/usr/lib64/libnvidia-eglcore.* $MODULE_DIR/../nostrip64 &>/dev/null
	mv $MODULE_DIR/usr/lib64/libnvidia-encode.* $MODULE_DIR/../nostrip64 &>/dev/null
	mv $MODULE_DIR/usr/lib64/libnvidia-glvkspirv.* $MODULE_DIR/../nostrip64 &>/dev/null
	mv $MODULE_DIR/usr/lib64/libnvidia-gpucomp.* $MODULE_DIR/../nostrip64 &>/dev/null
	mv $MODULE_DIR/usr/lib64/libnvidia-nvvm.* $MODULE_DIR/../nostrip64 &>/dev/null
	mv $MODULE_DIR/usr/lib64/libnvidia-tls.* $MODULE_DIR/../nostrip64 &>/dev/null
	mv $MODULE_DIR/usr/lib64/vdpau $MODULE_DIR/../nostrip64 &>/dev/null
fi

find $MODULE_DIR | xargs file | grep -E -e "shared object" | grep ELF | cut -f 1 -d : | xargs strip --strip-all --strip-section-headers -R .comment* -R .eh_frame* -R .note -R .note.ABI-tag -R .note.gnu.build-id -R .note.gnu.gold-version -R .note.GNU-stack 2> /dev/null

mv $MODULE_DIR/../nostrip/* $MODULE_DIR/usr/lib &>/dev/null

if [ "$SYSTEM_BITS" = 64 ]; then
	mv $MODULE_DIR/../nostrip64/* $MODULE_DIR/usr/lib64 &>/dev/null
fi

# disable nouveau
mkdir -p $MODULE_DIR/etc/modprobe.d 2>/dev/null
echo 'blacklist nouveau
options nouveau modeset=0' > $MODULE_DIR/etc/modprobe.d/nvidia-installer-disable-nouveau.conf

# get driver version
DRIVER_FILE=$(find /usr/lib$SYSTEM_BITS/libEGL_nvidia.so* \! -type l)
DRIVER_VERSION=$(echo $DRIVER_FILE | cut -d'.' -f3-)

# build xzm module
echo "Creating driver module..."
MODULE_FILE_NAME=08-nvidia-$DRIVER_VERSION-k.$(uname -r)-$(uname -m).xzm

if [ ! -w "$OUTPUT_DIR" ]; then
	dir2xzm -q ${MODULE_DIR} -o=/tmp/${MODULE_FILE_NAME} || exit 1
	sync
	echo "Destination $OUTPUT_DIR is not writable. New module placed in /tmp and not activated."
elif [ ! -f "$OUTPUT_DIR"/"$MODULE_FILE_NAME" ]; then
	dir2xzm -q ${MODULE_DIR} -o="$OUTPUT_DIR"/${MODULE_FILE_NAME} || exit 1
	sync
	echo "Module placed in $OUTPUT_DIR"
else
	dir2xzm -q ${MODULE_DIR} -o=/tmp/${MODULE_FILE_NAME} || exit 1
	sync
	echo "Module $MODULE_FILE_NAME was already in $OUTPUT_DIR. New module placed in /tmp and not activated."
fi

# clean up
rm -rf $INSTALLER_DIR

echo "Finished successfully"
