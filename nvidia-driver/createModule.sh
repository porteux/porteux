#!/bin/bash
# script to build nvidia driver module -- works for both i586 and x86_64 architectures

# root check
if [ `whoami` != root ]; then
	su -c "$0"
	exit
fi

MODULESFOLDER=$(readlink -f /mnt/live/porteux/modules)
INSTALLERFOLDER=/tmp/nvidia
mkdir $INSTALLERFOLDER

# add ABI compatible setting
echo '
Section "ServerFlags"
    Option         "IgnoreABI" "1" 
EndSection' >> /etc/X11/xorg.conf

echo "Creating memory changes file..."
sync; echo 3 > /proc/sys/vm/drop_caches
tar czf /tmp/nvidia.tar.gz --exclude={"*/.*","*/.wh.*",".cache","dev","home","mnt","opt","root","run","tmp","var","etc/bootcmd.cfg","etc/ld.so.cache","etc/fstab","etc/random-seed","etc/cups","etc/udev","etc/profile.d","etc/porteux","etc/X11/xorg.conf.nvidia-xconfig-original","lib/firmware","lib/modules/*porteux/modules.*","usr/man","usr/src","usr/bin/gnome-keyring-daemon","usr/lib/gio","usr/lib/gtk-2.0","usr/lib/gtk-3.0","usr/lib/libXvMCgallium.so.1","usr/lib/libbrscandec2.so.1","usr/lib/libgsm.so.1","usr/lib/libudev.so.1","usr/lib/libunrar.so.5","usr/lib64/gio","usr/lib64/gtk-2.0","usr/lib64/gtk-3.0","usr/lib64/libXvMCgallium.so.1","usr/lib64/libbrscandec2.so.1","usr/lib64/libgsm.so.1","usr/lib64/libudev.so.1","usr/lib64/libunrar.so.5","usr/local","usr/share/glib-2.0","usr/share/mime","usr/share/pixmaps","usr/share/applications/mimeinfo.cache","usr/local/share/applications/mimeinfo.cache","usr/share/doc/NVIDIA_GLX-1.0/html","usr/share/doc/NVIDIA_GLX-1.0/sample","usr/share/doc/NVIDIA_GLX-1.0/LICENSE","usr/share/doc/NVIDIA_GLX-1.0/NVIDIA_Changelog","usr/share/doc/NVIDIA_GLX-1.0/README.txt"} -C /mnt/live/memory changes || exit 1

echo "Extracting memory changes file..."
tar xf /tmp/nvidia.tar.gz --strip 1 -C $INSTALLERFOLDER || exit 1

echo  "Cleaning up driver directory..."
rm -rf $INSTALLERFOLDER/{.cache,dev,home,mnt,opt,root,run,tmp,var}
find $INSTALLERFOLDER -name '*.la' -delete
find $INSTALLERFOLDER -type f -maxdepth 1 -delete
find $INSTALLERFOLDER -type l -maxdepth 1 -delete
find $INSTALLERFOLDER/etc/ -type f -maxdepth 1 -delete
find $INSTALLERFOLDER/etc/ -type d ! -iname 'modprobe.d' ! -iname 'OpenCL' ! -iname 'vulkan' ! -iname 'X11' ! -iname 'etc' -maxdepth 1 -exec rm -rf '{}' '+'
rm -f $INSTALLERFOLDER/usr/bin/nvidia-debugdump
rm -f $INSTALLERFOLDER/usr/bin/nvidia-installer
rm -f $INSTALLERFOLDER/usr/bin/nvidia-uninstall
rm -f $INSTALLERFOLDER/etc/X11/xorg.conf.nvidia-xconfig-original
rm -rf $INSTALLERFOLDER/lib/firmware
rm -f $INSTALLERFOLDER/lib/modules/*porteux/modules.*
rm -rf $INSTALLERFOLDER/usr/{man,src}
rm -f $INSTALLERFOLDER/usr/bin/gnome-keyring-daemon
rm -rf $INSTALLERFOLDER/usr/lib/{gio,gtk-2.0,gtk-3.0}
rm -f $INSTALLERFOLDER/usr/lib/{libXvMCgallium.so.1,libbrscandec2.so.1,libgsm.so.1,libudev.so.1,libunrar.so.5}
rm -rf $INSTALLERFOLDER/usr/lib64/{gio,gtk-2.0,gtk-3.0}
rm -f $INSTALLERFOLDER/usr/lib64/{libXvMCgallium.so.1,libbrscandec2.so.1,libgsm.so.1,libudev.so.1,libunrar.so.5}
rm -rf $INSTALLERFOLDER/usr/local
rm -rf $INSTALLERFOLDER/usr/share/{glib-2.0,man,mime,pixmaps}
rm -f $INSTALLERFOLDER/usr/{,local/}share/applications/mimeinfo.cache
rm -rf $INSTALLERFOLDER/usr/share/doc/NVIDIA_GLX-1.0/{html,samples,LICENSE,NVIDIA_Changelog,README.txt}

# optional stripping
if [[ "$@" == *"--strip"* ]]; then
	rm -f $INSTALLERFOLDER/usr/lib/libnvidia-compiler.so*
	rm -f $INSTALLERFOLDER/usr/lib64/libcudadebugger.so*
	rm -f $INSTALLERFOLDER/usr/lib64/libnvidia-compiler.so*
	rm -f $INSTALLERFOLDER/usr/lib64/libnvidia-rtcore.so*
	rm -f $INSTALLERFOLDER/usr/lib64/libnvoptix.so*
	rm -f $INSTALLERFOLDER/usr/lib64/libnvidia-gtk2*
fi

# copy blacklist
cp --parents /etc/modprobe.d/nvidia-installer-disable-nouveau.conf $INSTALLERFOLDER

# get driver version
[ `getconf LONG_BIT` = "64" ] && SYSTEMBITS=64
LIBDIR=/usr/lib$SYSTEMBITS
DRIVERFILE=$(find $LIBDIR/libEGL_nvidia.so* \! -type l)
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
