#!/bin/bash
# script to build nvidia driver module -- works for both i586 and x86_64 architectures

# switch to root
if [ $(whoami) != root ]; then
	echo "Please enter root's password below:"
	su -c "$0 $1"
	exit
fi

[ `getconf LONG_BIT` = "64" ] && SYSTEMBITS=64
OUTPUTDIR="$PORTDIR/modules"
INSTALLERDIR=/tmp/nvidia
MODULEDIR=$INSTALLERDIR/nvidia-module
mkdir -p $INSTALLERDIR/nvidia-module

# add ABI compatible setting
echo '
Section "ServerFlags"
    Option         "IgnoreABI" "1" 
EndSection' >> /etc/X11/xorg.conf

echo "Creating memory changes file..."
sync; echo 3 > /proc/sys/vm/drop_caches
tar cf $INSTALLERDIR/nvidia.tar.xz --exclude={"*/.*","*/.wh.*",".cache","dev","home","mnt","opt","root","run","tmp","var","etc/cups","etc/udev","etc/profile.d","etc/porteux","lib/firmware","lib/modules/*porteux/modules.*"} -C /mnt/live/memory changes || exit 1

echo "Extracting memory changes file..."
tar xf $INSTALLERDIR/nvidia.tar.xz --strip 1 -C $MODULEDIR || exit 1

echo  "Cleaning up driver directory..."
find $MODULEDIR -name '*.la' -delete
find $MODULEDIR -type f -maxdepth 1 -delete
find $MODULEDIR -type l -maxdepth 1 -delete
find $MODULEDIR/etc/ -maxdepth 1 \( -type f -o -type d \) ! \( -name "modprobe.d" -o -name "OpenCL" -o -name "vulkan" \) -delete 2>/dev/null
rm -f $MODULEDIR/usr/bin/nvidia-debugdump
rm -f $MODULEDIR/usr/bin/nvidia-installer
rm -f $MODULEDIR/usr/bin/nvidia-uninstall
rm -f $MODULEDIR/etc/X11/xorg.conf.nvidia-xconfig-original
rm -rf $MODULEDIR/usr/{man,src}
rm -f $MODULEDIR/usr/bin/gnome-keyring-daemon
rm -rf $MODULEDIR/usr/lib$SYSTEMBITS/{gio,gtk-2.0,gtk-3.0}
rm -f $MODULEDIR/usr/lib$SYSTEMBITS/{libXvMCgallium.*,libgsm.*,libudev.*,libunrar.*}
rm -rf $MODULEDIR/usr/local
rm -rf $MODULEDIR/usr/share/{glib-2.0,man,mime,pixmaps}
rm -f $MODULEDIR/usr/{,local/}share/applications/mimeinfo.cache
rm -rf $MODULEDIR/usr/share/doc/NVIDIA_GLX-1.0/{html,samples,LICENSE,NVIDIA_Changelog,README.txt}

# strip
mkdir -p $MODULEDIR/../nostrip

if [ "$SYSTEMBITS" = 64 ]; then
	mkdir -p $MODULEDIR/../nostrip64
fi

mv $MODULEDIR/usr/lib/libnvcuvid.* $MODULEDIR/../nostrip &>/dev/null
mv $MODULEDIR/usr/lib/libnvidia-encode.* $MODULEDIR/../nostrip &>/dev/null
mv $MODULEDIR/usr/lib/libnvidia-eglcore.* $MODULEDIR/../nostrip &>/dev/null
mv $MODULEDIR/usr/lib/libnvidia-glvkspirv.* $MODULEDIR/../nostrip &>/dev/null
mv $MODULEDIR/usr/lib/libnvidia-gpucomp.* $MODULEDIR/../nostrip &>/dev/null
mv $MODULEDIR/usr/lib/libnvidia-nvvm.* $MODULEDIR/../nostrip &>/dev/null
mv $MODULEDIR/usr/lib/libnvidia-tls.* $MODULEDIR/../nostrip &>/dev/null
mv $MODULEDIR/usr/lib/vdpau $MODULEDIR/../nostrip &>/dev/null

if [ "$SYSTEMBITS" = 64 ]; then
	mv $MODULEDIR/usr/lib64/libnvcuvid.* $MODULEDIR/../nostrip64 &>/dev/null
	mv $MODULEDIR/usr/lib64/libnvidia-eglcore.* $MODULEDIR/../nostrip64 &>/dev/null
	mv $MODULEDIR/usr/lib64/libnvidia-encode.* $MODULEDIR/../nostrip64 &>/dev/null
	mv $MODULEDIR/usr/lib64/libnvidia-glvkspirv.* $MODULEDIR/../nostrip64 &>/dev/null
	mv $MODULEDIR/usr/lib64/libnvidia-gpucomp.* $MODULEDIR/../nostrip64 &>/dev/null
	mv $MODULEDIR/usr/lib64/libnvidia-nvvm.* $MODULEDIR/../nostrip64 &>/dev/null
	mv $MODULEDIR/usr/lib64/libnvidia-tls.* $MODULEDIR/../nostrip64 &>/dev/null
	mv $MODULEDIR/usr/lib64/vdpau $MODULEDIR/../nostrip64 &>/dev/null
fi

find $MODULEDIR | xargs file | egrep -e "shared object" | grep ELF | cut -f 1 -d : | xargs strip -S --strip-unneeded -R .note.gnu.gold-version -R .comment -R .note -R .note.gnu.build-id -R .note.ABI-tag -R .eh_frame -R .eh_frame_ptr -R .note -R .comment -R .note.GNU-stack -R .jcr -R .eh_frame_hdr 2> /dev/null

mv $MODULEDIR/../nostrip/* $MODULEDIR/usr/lib &>/dev/null

if [ "$SYSTEMBITS" = 64 ]; then
	mv $MODULEDIR/../nostrip64/* $MODULEDIR/usr/lib64 &>/dev/null
fi

# disable nouveau
mkdir -p $MODULEDIR/etc/modprobe.d 2>/dev/null
echo 'blacklist nouveau
options nouveau modeset=0' > $MODULEDIR/etc/modprobe.d/nvidia-installer-disable-nouveau.conf

# get driver version
DRIVERFILE=$(find /usr/lib$SYSTEMBITS/libEGL_nvidia.so* \! -type l)
DRIVERVERSION=$(echo $DRIVERFILE | cut -d'.' -f3-)

# build xzm module
echo "Creating driver module..."
MODULEFILENAME=08-nvidia-$DRIVERVERSION-k.$(uname -r)-$(arch).xzm

if [ ! -w "$OUTPUTDIR" ]; then
    dir2xzm -q ${MODULEDIR} -o=/tmp/${MODULEFILENAME} || exit 1
    sync
    echo "Destination $OUTPUTDIR is not writable. New module placed in /tmp and not activated."
elif [ ! -f "$OUTPUTDIR"/"$MODULEFILENAME" ]; then
	dir2xzm -q ${MODULEDIR} -o="$OUTPUTDIR"/${MODULEFILENAME} || exit 1
	sync
    echo "Module placed in $OUTPUTDIR"
else
    dir2xzm -q ${MODULEDIR} -o=/tmp/${MODULEFILENAME} || exit 1
    sync
    echo "Module $MODULEFILENAME was already in $OUTPUTDIR. New module placed in /tmp and not activated."
fi

# clean up
rm -rf $INSTALLERDIR

echo "Finished successfully"
