#!/bin/bash

PRGNAM=libreoffice
CHANNEL=$([ "$1" ] && echo "$1" || echo "stable")
LOLANG=$([ "$2" ] && echo "$2" || echo "en-US")
VERSION=$(curl -sv http://download.documentfoundation.org/libreoffice/$CHANNEL/ 2>/dev/null | grep [0-9].[0-9].[0-9] | sort -u | tail -1 | cut -d'"' -f4 | tr -d /)
ARCH=$(uname -m)

TMP=/tmp/$PRGNAM-builder
PKG=$TMP/$PRGNAM-module
OUTPUTDIR="$PORTDIR/modules"
MODULEFILENAME=$PRGNAM-$VERSION-$CHANNEL-$ARCH-$LOLANG.xzm
MODULEPATH=$OUTPUTDIR/$MODULEFILENAME

CURRENTUSER=$(loginctl user-status | head -n 1 | cut -d" " -f1)
CURRENTGROUP=$(id -gn "$CURRENTUSER")
[ ! $CURRENTUSER ] && CURRENTUSER=guest
USERHOMEFOLDER=$(getent passwd ${CURRENTUSER} | cut -d: -f6)
[ ! -e $USERHOMEFOLDER ] && USERHOMEFOLDER=home/guest

rm -rf $TMP
mkdir -p $TMP $PKG
cd $TMP

# download LibreOffice
wget -T 15 -q --show-progress http://download.documentfoundation.org/libreoffice/$CHANNEL/"$VERSION"/rpm/'x86_64'/LibreOffice\_"$VERSION"'_Linux_x86-64_'rpm.tar.gz
tar -xf LibreOffice_"$VERSION"'_Linux_x86-64_'rpm.tar.gz
rm -f $TMP/LibreOffice_"$VERSION".*'_Linux_x86-64_'rpm/RPMS/libreoffice?.?-dict-{es,fr}-*.rpm
mv $TMP/LibreOffice_"$VERSION".*'_Linux_x86-64_'rpm/RPMS/* $PKG
rm -rf $TMP/LibreOffice_"$VERSION".*'_Linux_x86-64_'rpm
rm -f $TMP/LibreOffice_"$VERSION"'_Linux_x86-64_'rpm.tar.gz

# download helppack
wget -T 15 -q --show-progress http://download.documentfoundation.org/libreoffice/$CHANNEL/"$VERSION"/rpm/'x86_64'/LibreOffice\_"$VERSION"'_Linux_x86-64_rpm_helppack_'"$LOLANG".tar.gz
tar -xf LibreOffice_"$VERSION"'_Linux_x86-64_rpm_helppack_'"$LOLANG".tar.gz
mv $TMP/LibreOffice_"$VERSION".*'_Linux_x86-64_rpm_helppack_'"$LOLANG"/RPMS/* $PKG
rm -rf $TMP/LibreOffice_"$VERSION".*'_Linux_x86-64_rpm_helppack_'"$LOLANG"
rm -f $TMP/LibreOffice_"$VERSION"'_Linux_x86-64_rpm_helppack_'"$LOLANG".tar.gz

if [[ "$LOLANG" != 'en-US' ]]; then
    # download langpack
    wget -T 15 -q --show-progress http://download.documentfoundation.org/libreoffice/$CHANNEL/"$VERSION"/rpm/'x86_64'/LibreOffice\_"$VERSION"'_Linux_x86-64_rpm_langpack_'"$LOLANG".tar.gz
    tar -xf LibreOffice_"$VERSION"'_Linux_x86-64_rpm_langpack_'"$LOLANG".tar.gz
    mv $TMP/LibreOffice_"$VERSION".*'_Linux_x86-64_rpm_langpack_'"$LOLANG"/RPMS/* $PKG
    rm -rf $TMP/LibreOffice_"$VERSION".*'_Linux_x86-64_rpm_langpack_'"$LOLANG"
    rm -f $TMP/LibreOffice_"$VERSION"'_Linux_x86-64_rpm_langpack_'"$LOLANG".tar.gz

    mkdir -p "$MODULEDIR/root/.config/libreoffice/4/user/"
    cat > "$MODULEDIR/root/.config/libreoffice/4/user/registrymodifications.xcu" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<oor:items xmlns:oor="http://openoffice.org/2001/registry" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<item oor:path="/org.openoffice.Office.Linguistic/General"><prop oor:name="UILocale" oor:op="fuse"><value>${LOLANG}</value></prop></item>
</oor:items>
EOF

    mkdir -p "$MODULEDIR/${USERHOMEFOLDER}/.config/libreoffice/4/user"
    cp "$MODULEDIR/root/.config/libreoffice/4/user/registrymodifications.xcu" "$MODULEDIR/${USERHOMEFOLDER}/.config/libreoffice/4/user"

    chown -R "$CURRENTUSER":"$CURRENTGROUP" "$MODULEDIR/${USERHOMEFOLDER}"
fi

# extract all rpm
cd $PKG
for i in `find . -type f | fgrep .rpm | sort`; do rpm2cpio $i | cpio -idmv &>/dev/null; done
rm -f *.rpm

# strip
rm -rf $PKG/var
rm -rf $PKG/opt/libreoffice?.?/{readmes,CREDITS.fodt,LICENSE,LICENSE.fodt,LICENSE.html,NOTICE}

# fix double menu entries
find $PKG/usr/share/applications/ -name *.desktop -delete
mv -f $PKG/opt/libreoffice?.?/share/xdg/*.desktop $PKG/usr/share/applications

# set SAL_USE_VCLPLUGIN=gtk
LO=$(find $PKG/opt/libreoffice*/program -name soffice | awk 'NR==1 {print $0}')
sed -i -e '/^#\ restore/i# Prefer GTK2\nexport SAL_USE_VCLPLUGIN=${SAL_USE_VCLPLUGIN:-gtk}\n' $LO

# to open PDFs LibreOffice needs libavahi libs, but it works if we create symlinks to any existing lib
cd $(echo $LO | sed 's|soffice||')
ln -s ./libabplo.so libavahi-client.so.3
ln -s ./libabplo.so libavahi-common.so.3

ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")
/opt/porteux-scripts/porteux-app-store/module-builder.sh "$PKG" "$MODULEPATH" "$ACTIVATEMODULE"
rm -rf $PKG 2> /dev/null
