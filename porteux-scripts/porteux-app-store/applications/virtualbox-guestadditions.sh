#!/bin/bash

if [ ! "$(find /mnt/live/memory/images/ -maxdepth 1 -name "*05-devel*")" ] || [ ! "$(find /mnt/live/memory/images/ -maxdepth 1 -name "*06-crippled_sources*")" ]; then
    echo "Both 'devel' and 'crippled-sources' modules need to be activated."
    exit 1
fi

CURRENTPACKAGE=virtualbox-guestadditions
OUTPUTDIR="$PORTDIR/optional"
BUILDDIR="/tmp/$CURRENTPACKAGE-builder"
MOUNTDIR="/mnt/$CURRENTPACKAGE"
rm -fr "$BUILDDIR"
rm -fr "$MOUNTDIR"
mkdir "$BUILDDIR"
mkdir "$MOUNTDIR"

MODULEDIR="$BUILDDIR/$CURRENTPACKAGE-module"
mkdir "$MODULEDIR"

ARCH=$(uname -m)

if [[ ! "$1" || "$1" == "--activate-module" ]]; then
    # download the latest version
    REPOSITORY="http://download.virtualbox.org/virtualbox"
    wget -T 15 -P "$BUILDDIR" "$REPOSITORY/LATEST.TXT"
    CURRENTVERSION=$(cat $BUILDDIR/LATEST.TXT)
    LATESTFILE="VBoxGuestAdditions_${CURRENTVERSION}.iso"
    wget -T 15 -P "$BUILDDIR" "$REPOSITORY/$CURRENTVERSION/$LATESTFILE"
    INSTALLERPATH="$BUILDDIR/$LATESTFILE"
else
    # use file provided by the user
    INSTALLERPATH="$1"
    CURRENTVERSION=$(find "$INSTALLERPATH" -name "*.[0-9]*" | sort -V | tail -n 1)
fi

# mount and install
mount "$INSTALLERPATH" "$MOUNTDIR"
sh "$MOUNTDIR/VBoxLinuxAdditions.run" --nox11

# set configuration
cp -r --parents /etc/rc.d/{rc.vboxadd,rc.vboxadd-service,rc.vboxadd-x11} $MODULEDIR/ 2>/dev/null
cp -r --parents /etc/rc.d/init.d/{vboxdrv,vboxballoonctrl-service,vboxautostart-service,vboxweb-service} $MODULEDIR/ 2>/dev/null
for a in \`seq 0 6\`; do
    cp -r --parents /etc/rc.d/rc${a}.d/{K[0-9][0-9]vbox*,S[0-9][0-9]vbox*} $MODULEDIR/ 2>/dev/null
done
cp -r --parents /etc/vbox/vbox.cfg $MODULEDIR/ 2>/dev/null
cp -r --parents /etc/vbox/filelist $MODULEDIR/ 2>/dev/null
cp -r --parents /etc/udev/rules.d/60-vbox* $MODULEDIR/ 2>/dev/null
cp -r --parents /etc/xdg/autostart/vboxclient.desktop $MODULEDIR/ 2>/dev/null
cp -r --parents /lib/modules/$(uname -r)/misc/{vboxguest.ko,vboxsf.ko,vboxvideo.ko,vboxpci.ko,vboxnetadp.ko,vboxnetflt.ko,vboxdrv.ko} $MODULEDIR/ 2>/dev/null
cp -r --parents /opt/VBoxGuestAdditions-* $MODULEDIR/ 2>/dev/null
cp -r --parents /sbin/mount.vboxsf $MODULEDIR/ 2>/dev/null
cp -r --parents /usr/bin/{VBoxClient,VBoxClient-all,VBoxControl} $MODULEDIR/ 2>/dev/null
cp -r --parents /usr/sbin/VBoxService $MODULEDIR/ 2>/dev/null
cp -r --parents /var/lib/VBoxGuestAdditions $MODULEDIR/ 2>/dev/null

# strip
rm -fr $MODULEDIR/opt/VBoxGuestAdditions-${CURRENTVERSION}/src
rm -fr $MODULEDIR/opt/VBoxGuestAdditions-${CURRENTVERSION}/LICENSE

# Build the xzm module
KERNELVERSION=$(uname -r | awk -F- '{print$1}')
MODULEFILENAME="$CURRENTPACKAGE-$CURRENTVERSION-porteux-k.$KERNELVERSION-$ARCH.xzm"
/opt/porteux-scripts/porteux-app-store/module-builder.sh "$MODULEDIR" "$OUTPUTDIR/$MODULEFILENAME"

# cleanup
umount "$MOUNTDIR"
rm -fr "$MOUNTDIR"
rm -fr "$BUILDDIR"
