#!/bin/bash

if [ ! "$(find /mnt/live/memory/images/ -maxdepth 1 -name "*05-devel*")" ] || [ ! "$(find /mnt/live/memory/images/ -maxdepth 1 -name "*06-crippled?sources*")" ]; then
    echo "Both 'devel' and 'crippled-sources' modules need to be activated."
    exit 1
fi

CURRENTPACKAGE=virtualbox
ARCH=$(uname -m)
OUTPUTDIR="$PORTDIR/optional"
BUILDDIR="/tmp/$CURRENTPACKAGE-builder"
rm -fr "$BUILDDIR"
mkdir "$BUILDDIR"

MODULEDIR="$BUILDDIR/$CURRENTPACKAGE-module"
mkdir "$MODULEDIR"

CURRENTUSER=$(loginctl user-status | head -n 1 | cut -d" " -f1)
CURRENTGROUP=$(id -gn "$CURRENTUSER")
[ ! $CURRENTUSER ] && CURRENTUSER=guest
USERHOMEFOLDER=$(getent passwd ${CURRENTUSER} | cut -d: -f6)
[ ! -e $USERHOMEFOLDER ] && USERHOMEFOLDER=home/guest

if [[ ! "$1" || "$1" == "--activate-module" ]]; then
    # download the latest version
    REPOSITORY="http://download.virtualbox.org/virtualbox"
    wget -T 15 -P "$BUILDDIR" "$REPOSITORY/LATEST.TXT"
    CURRENTVERSION=$(cat $BUILDDIR/LATEST.TXT)
    LATESTFILE=$(curl -s $REPOSITORY/"$CURRENTVERSION"/ | grep .run | cut -d "\"" -f2)
    wget -T 15 -P "$BUILDDIR" "$REPOSITORY/$CURRENTVERSION/$LATESTFILE"
    INSTALLERPATH="$BUILDDIR/$LATESTFILE"
else
    # use file provided by the user
    INSTALLERPATH="$1"
    CURRENTVERSION=$(ls "$INSTALLERPATH" -a | cut -d'-' -f2)
fi

# install
sh "$INSTALLERPATH" --nox11 || exit 1

# set configuration
mkdir -p $MODULEDIR/etc/rc.d/init.d $MODULEDIR/etc/rc.d/rc4.d
cat > $MODULEDIR/etc/rc.d/init.d/rc.virtualbox << EOF
#!/bin/sh
# VirtualBox Linux kernel modules init script
/sbin/depmod -a
/sbin/modprobe vboxdrv
/sbin/modprobe vboxnetadp
/sbin/modprobe vboxnetflt
EOF
chmod +x $MODULEDIR/etc/rc.d/init.d/rc.virtualbox
ln -sf /etc/rc.d/init.d/rc.virtualbox $MODULEDIR/etc/rc.d/rc4.d/S99virtualbox
find /etc /lib /usr /sbin | grep -E "vbox|virtualbox|VBox|VirtualBox" | xargs -i cp -r --parents {} $MODULEDIR/
cp -r --parents /sbin/{vbox*,rcvbox*} $MODULEDIR/
cp -r --parents /opt/VirtualBox $MODULEDIR/
for a in \`seq 0 6\`; do
    cp -r --parents /etc/rc.d/rc${a}.d/{K[0-9][0-9]vbox*,S[0-9][0-9]vbox*} $MODULEDIR/ 2>/dev/null
done
mkdir -p $MODULEDIR/${USERHOMEFOLDER}/.config/VirtualBox/
cat > $MODULEDIR/${USERHOMEFOLDER}/.config/VirtualBox/VirtualBox.xml << EOF
<?xml version="1.0"?>
<VirtualBox xmlns="http://www.virtualbox.org/" version="1.12-linux">
  <Global>
    <ExtraData>
      <ExtraDataItem name="GUI/UpdateDate" value="never"/>
    </ExtraData>
  </Global>
</VirtualBox>
EOF
chown -R "$CURRENTUSER":"$CURRENTGROUP" "$MODULEDIR/${USERHOMEFOLDER}"

# strip
rm -fr $MODULEDIR/opt/VirtualBox/additions
rm -fr $MODULEDIR/opt/VirtualBox/src
rm -fr $MODULEDIR/usr/include
rm -fr $MODULEDIR/usr/src
find $MODULEDIR/opt/VirtualBox/nls -mindepth 1 -maxdepth 1 -type f ! \( -name "qt_en.qm" -o -name "VirtualBox_en.qm" \) -delete

# remove virtualbox from the machine
/opt/VirtualBox/uninstall.sh &>/dev/null

# Build the xzm module
find $MODULEDIR -type d -exec chmod 755 {} +
chown root:root $MODULEDIR/opt/VirtualBox/VirtualBox
chmod -s $MODULEDIR/opt/VirtualBox/VirtualBox
chmod +s $MODULEDIR/opt/VirtualBox/VirtualBoxVM
KERNELVERSION=$(uname -r | awk -F- '{print$1}')
MODULEFILENAME="$CURRENTPACKAGE-$CURRENTVERSION-k.$KERNELVERSION-$ARCH_porteux.xzm"
ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")
/opt/porteux-scripts/porteux-app-store/module-builder.sh "$MODULEDIR" "$OUTPUTDIR/$MODULEFILENAME" "$ACTIVATEMODULE"

# cleanup
rm -fr "$BUILDDIR"
