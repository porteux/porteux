#!/bin/bash
# script to build nvidia driver module -- works for both i586 and x86_64 architectures

# switch to root
if [ $(whoami) != root ]; then
	echo "Please enter root's password below:"
	su -c "$0 $1"
	exit
fi

[ `getconf LONG_BIT` = "64" ] && SYSTEMBITS=64
MODULESFOLDER=$(readlink -f $PORTDIR/modules)
INSTALLERFOLDER=/tmp/nvidia
mkdir $INSTALLERFOLDER

# add ABI compatible setting
echo '
Section "ServerFlags"
    Option         "IgnoreABI" "1" 
EndSection' >> /etc/X11/xorg.conf

echo "Creating memory changes file..."
sync; echo 3 > /proc/sys/vm/drop_caches
tar cf /tmp/nvidia.tar.xz --exclude={"*/.*","*/.wh.*",".cache","dev","home","mnt","opt","root","run","tmp","var","etc/cups","etc/udev","etc/profile.d","etc/porteux","lib/firmware","lib/modules/*porteux/modules.*"} -C /mnt/live/memory changes || exit 1

echo "Extracting memory changes file..."
tar xf /tmp/nvidia.tar.xz --strip 1 -C $INSTALLERFOLDER || exit 1

echo  "Cleaning up driver directory..."
find $INSTALLERFOLDER -name '*.la' -delete
find $INSTALLERFOLDER -type f -maxdepth 1 -delete
find $INSTALLERFOLDER -type l -maxdepth 1 -delete
find $INSTALLERFOLDER/etc/ -type f -maxdepth 1 -delete
find $INSTALLERFOLDER/etc/ -type d ! -iname 'modprobe.d' ! -iname 'OpenCL' ! -iname 'vulkan' ! -iname 'X11' -maxdepth 1 -exec rm -rf '{}' '+'
rm -f $INSTALLERFOLDER/usr/bin/nvidia-debugdump
rm -f $INSTALLERFOLDER/usr/bin/nvidia-installer
rm -f $INSTALLERFOLDER/usr/bin/nvidia-uninstall
rm -f $INSTALLERFOLDER/etc/X11/xorg.conf.nvidia-xconfig-original
rm -rf $INSTALLERFOLDER/usr/{man,src}
rm -f $INSTALLERFOLDER/usr/bin/gnome-keyring-daemon
rm -rf $INSTALLERFOLDER/usr/lib$SYSTEMBITS/{gio,gtk-2.0,gtk-3.0}
rm -f $INSTALLERFOLDER/usr/lib$SYSTEMBITS/{libXvMCgallium.*,libgsm.*,libudev.*,libunrar.*}
rm -rf $INSTALLERFOLDER/usr/local
rm -rf $INSTALLERFOLDER/usr/share/{glib-2.0,man,mime,pixmaps}
rm -f $INSTALLERFOLDER/usr/{,local/}share/applications/mimeinfo.cache
rm -rf $INSTALLERFOLDER/usr/share/doc/NVIDIA_GLX-1.0/{html,samples,LICENSE,NVIDIA_Changelog,README.txt}

# optional stripping
if [[ "$@" == *"--strip"* ]]; then
	rm -f $INSTALLERFOLDER/usr/lib/libnvidia-compiler.so*
	rm -f $INSTALLERFOLDER/usr/lib$SYSTEMBITS/libcudadebugger.so*
	rm -f $INSTALLERFOLDER/usr/lib$SYSTEMBITS/libnvidia-compiler.so*
	rm -f $INSTALLERFOLDER/usr/lib$SYSTEMBITS/libnvidia-rtcore.so*
	rm -f $INSTALLERFOLDER/usr/lib$SYSTEMBITS/libnvoptix.so*
	rm -f $INSTALLERFOLDER/usr/lib$SYSTEMBITS/libnvidia-gtk2*
fi

# disable nouveau
mkdir -p $INSTALLERFOLDER/etc/modprobe.d 2>/dev/null
echo 'blacklist nouveau
options nouveau modeset=0' > $INSTALLERFOLDER/etc/modprobe.d/nvidia-installer-disable-nouveau.conf

# get driver version
DRIVERFILE=$(find lib$SYSTEMBITS/libEGL_nvidia.so* \! -type l)
DRIVERVERSION=$(echo $DRIVERFILE | cut -d'.' -f3-)

# build xzm module
echo "Creating driver module..."
if [[ "$@" == *"--strip"* ]]; then
	MODULEFILENAME=08-nvidia-$DRIVERVERSION-k.$(uname -r)-stripped-$(arch).xzm
else
	MODULEFILENAME=08-nvidia-$DRIVERVERSION-k.$(uname -r)-$(arch).xzm
fi
dir2xzm $INSTALLERFOLDER/ -o=/tmp/$MODULEFILENAME || exit 1
mv /tmp/$MODULEFILENAME $MODULESFOLDER || exit 1

# clean up
rm -f /tmp/nvidia.tar.gz
rm -f /tmp/nvidia.xzm
rm -rf $INSTALLERFOLDER

echo "Nvidia driver module has been placed in $MODULESFOLDER"
