#!/bin/bash

isRoot() {
    [ "$(id -u)" -eq 0 ]
}

if ! isRoot; then
    echo "Please enter root's password below:"
    su -c "/opt/porteux-scripts/porteux-app-store/applications/libreoffice.sh $*"
    exit 0
fi


CURRENTPACKAGE=libreoffice
ARCH=$(uname -m)
CHANNEL=$([ "$1" ] && echo "$1" || echo "stable")
LANGUAGE=$([ "$2" ] && echo "$2" || echo "en-US")
ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")
MAJORVERSION=$(curl -s "http://download.documentfoundation.org/libreoffice/$CHANNEL/" | grep -oP 'a href="[0-9].*' | cut -d '"' -f 2 | cut -d / -f 1 | sort -V -r | head -1)
LATESTPACKAGE=$(curl -s "https://download.documentfoundation.org/libreoffice/$CHANNEL/$MAJORVERSION/rpm/$ARCH/" | grep -oP 'LibreOffice_.*' | cut -d '"' -f 1 | grep -oP ".*_Linux_x86-64_rpm.tar.gz$")
VERSION=$(echo "$LATESTPACKAGE" | cut -d _ -f 2)
OUTPUTDIR="$PORTDIR/modules"
BUILDDIR="/tmp/$CURRENTPACKAGE-builder"
MODULEDIR="$BUILDDIR/$CURRENTPACKAGE-module"
MODULEFILENAME="$CURRENTPACKAGE-$CHANNEL-$VERSION-$ARCH-${LANGUAGE}_porteux.xzm"

CURRENTUSER=$(loginctl user-status | head -n 1 | cut -d" " -f1)
CURRENTGROUP=$(id -gn "$CURRENTUSER")
[ ! "$CURRENTUSER" ] && CURRENTUSER=guest
USERHOMEFOLDER=$(getent passwd "$CURRENTUSER" | cut -d: -f6)
[ ! -e "$USERHOMEFOLDER" ] && USERHOMEFOLDER=home/guest

rm -fr "$BUILDDIR"
mkdir -p "$BUILDDIR" "$MODULEDIR"
cd "$BUILDDIR"

# download LibreOffice
wget -T 15 -q --show-progress "http://download.documentfoundation.org/libreoffice/$CHANNEL/$MAJORVERSION/rpm/$ARCH/$LATESTPACKAGE"
tar -xf LibreOffice_"$VERSION"*_Linux_x86-64_rpm.tar.gz
mv "$BUILDDIR"/LibreOffice_"$VERSION"*_Linux_x86-64_rpm/RPMS/* "$MODULEDIR"
rm -f "$BUILDDIR"/LibreOffice_"$VERSION"*_Linux_x86-64_rpm.tar.gz

# download helppack
wget -T 15 -q --show-progress "http://download.documentfoundation.org/libreoffice/$CHANNEL/$MAJORVERSION/rpm/$ARCH/LibreOffice_${VERSION}_Linux_x86-64_rpm_helppack_${LANGUAGE}.tar.gz"
tar -xf LibreOffice_"$VERSION"*_Linux_x86-64_rpm_helppack_"$LANGUAGE".tar.gz
mv "$BUILDDIR"/LibreOffice_"$VERSION"*_Linux_x86-64_rpm_helppack_"$LANGUAGE"/RPMS/* "$MODULEDIR"
rm -fr "$BUILDDIR"/LibreOffice_"$VERSION"*_Linux_x86-64_rpm_helppack_"$LANGUAGE"
rm -f "$BUILDDIR"/LibreOffice_"$VERSION"*_Linux_x86-64_rpm_helppack_"$LANGUAGE".tar.gz

if [[ "$LANGUAGE" != 'en-US' ]]; then
    # download langpack
    wget -T 15 -q --show-progress "http://download.documentfoundation.org/libreoffice/$CHANNEL/$MAJORVERSION/rpm/$ARCH/LibreOffice_${VERSION}_Linux_x86-64_rpm_langpack_${LANGUAGE}.tar.gz"
    tar -xf LibreOffice_"$VERSION"*_Linux_x86-64_rpm_langpack_"$LANGUAGE".tar.gz
    mv "$BUILDDIR"/LibreOffice_"$VERSION"*_Linux_x86-64_rpm_langpack_"$LANGUAGE"/RPMS/* "$MODULEDIR"
    rm -fr "$BUILDDIR"/LibreOffice_"$VERSION"*_Linux_x86-64_rpm_langpack_"$LANGUAGE"
    rm -f "$BUILDDIR"/LibreOffice_"$VERSION"*_Linux_x86-64_rpm_langpack_"$LANGUAGE".tar.gz

    mkdir -p "$MODULEDIR/root/.config/libreoffice/4/user/"
    cat > "$MODULEDIR/root/.config/libreoffice/4/user/registrymodifications.xcu" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<oor:items xmlns:oor="http://openoffice.org/2001/registry" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<item oor:path="/org.openoffice.Office.Linguistic/General"><prop oor:name="UILocale" oor:op="fuse"><value>${LANGUAGE}</value></prop></item>
</oor:items>
EOF

    mkdir -p "$MODULEDIR/${USERHOMEFOLDER}/.config/libreoffice/4/user"
    cp "$MODULEDIR/root/.config/libreoffice/4/user/registrymodifications.xcu" "$MODULEDIR/${USERHOMEFOLDER}/.config/libreoffice/4/user"

    chown -R "$CURRENTUSER":"$CURRENTGROUP" "$MODULEDIR/${USERHOMEFOLDER}"
fi

# extract all rpm
cd "$MODULEDIR"
for i in $(find . -type f -name "*.rpm" | sort); do rpm2cpio "$i" | cpio -idmv &>/dev/null; done
rm -f *.rpm

# strip
rm -fr "$MODULEDIR/var"
rm -fr "$MODULEDIR"/opt/libreoffice*/{readmes,CREDITS.fodt,LICENSE,LICENSE.fodt,LICENSE.html,NOTICE}

# fix double menu entries
find "$MODULEDIR/usr/share/applications/" -name "*.desktop" -delete
mv -f "$MODULEDIR"/opt/libreoffice*/share/xdg/*.desktop "$MODULEDIR/usr/share/applications"

# set SAL_USE_VCLPLUGIN=gtk
LO=$(find "$MODULEDIR"/opt/libreoffice*/program -name soffice | awk 'NR==1 {print $0}')
sed -i -e '/^#\ restore/i# Prefer GTK2\nexport SAL_USE_VCLPLUGIN=${SAL_USE_VCLPLUGIN:-gtk}\n' "$LO"

# to open PDFs LibreOffice needs libavahi libs, but it works if we create symlinks to any existing lib
cd "$(echo "$LO" | sed 's|soffice||')"
ln -s ./libabplo.so libavahi-client.so.3
ln -s ./libabplo.so libavahi-common.so.3

/opt/porteux-scripts/porteux-app-store/module-builder.sh "$MODULEDIR" "$OUTPUTDIR/$MODULEFILENAME" "$ACTIVATEMODULE"

# cleanup
rm -fr "$BUILDDIR" &>/dev/null