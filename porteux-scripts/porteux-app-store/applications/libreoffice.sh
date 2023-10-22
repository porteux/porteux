#!/bin/bash

# This script has been modified and adapted for PorteuX
#
# This is LibreOffice build script of xzm module for Porteus
# Version 2019-05-18 (2)

# Copyright 2019 Blaze admin at ublaze.ru
# All rights reserved.
#
# Redistribution and use of this script, with or without modification, is
# permitted provided that the following conditions are met:
#
# 1. Redistributions of this script must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED
#  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO
#  EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
#  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
#  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
#  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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

ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")

rm -rf $TMP
mkdir -p $TMP $PKG
cd $TMP

# Download LibreOffice
wget -T 15 -q --show-progress http://download.documentfoundation.org/libreoffice/$CHANNEL/"$VERSION"/rpm/'x86_64'/LibreOffice\_"$VERSION"'_Linux_x86-64_'rpm.tar.gz
tar -xf LibreOffice_"$VERSION"'_Linux_x86-64_'rpm.tar.gz
rm -f $TMP/LibreOffice_"$VERSION".*'_Linux_x86-64_'rpm/RPMS/libreoffice?.?-dict-{es,fr}-*.rpm
mv $TMP/LibreOffice_"$VERSION".*'_Linux_x86-64_'rpm/RPMS/* $PKG
rm -rf $TMP/LibreOffice_"$VERSION".*'_Linux_x86-64_'rpm
rm -f $TMP/LibreOffice_"$VERSION"'_Linux_x86-64_'rpm.tar.gz

# Download helppack
wget -T 15 -q --show-progress http://download.documentfoundation.org/libreoffice/$CHANNEL/"$VERSION"/rpm/'x86_64'/LibreOffice\_"$VERSION"'_Linux_x86-64_rpm_helppack_'"$LOLANG".tar.gz
tar -xf LibreOffice_"$VERSION"'_Linux_x86-64_rpm_helppack_'"$LOLANG".tar.gz
mv $TMP/LibreOffice_"$VERSION".*'_Linux_x86-64_rpm_helppack_'"$LOLANG"/RPMS/* $PKG
rm -rf $TMP/LibreOffice_"$VERSION".*'_Linux_x86-64_rpm_helppack_'"$LOLANG"
rm -f $TMP/LibreOffice_"$VERSION"'_Linux_x86-64_rpm_helppack_'"$LOLANG".tar.gz

if [[ "$LOLANG" != 'en-US' ]]; then
    # Download langpack
    wget -T 15 -q --show-progress http://download.documentfoundation.org/libreoffice/$CHANNEL/"$VERSION"/rpm/'x86_64'/LibreOffice\_"$VERSION"'_Linux_x86-64_rpm_langpack_'"$LOLANG".tar.gz
    tar -xf LibreOffice_"$VERSION"'_Linux_x86-64_rpm_langpack_'"$LOLANG".tar.gz
    mv $TMP/LibreOffice_"$VERSION".*'_Linux_x86-64_rpm_langpack_'"$LOLANG"/RPMS/* $PKG
    rm -rf $TMP/LibreOffice_"$VERSION".*'_Linux_x86-64_rpm_langpack_'"$LOLANG"
    rm -f $TMP/LibreOffice_"$VERSION"'_Linux_x86-64_rpm_langpack_'"$LOLANG".tar.gz
fi

# Extract all rpm
cd $PKG
for i in `find . -type f | fgrep .rpm | sort`; do rpm2cpio $i | cpio -idmv &>/dev/null; done
rm -f *.rpm

# Cleaning of LO
rm -rf $PKG/var
rm -rf $PKG/opt/libreoffice?.?/{readmes,CREDITS.fodt,LICENSE,LICENSE.fodt,LICENSE.html,NOTICE}

# Fix of double menu entries
find $PKG/usr/share/applications/ -name *.desktop -delete
mv -f $PKG/opt/libreoffice?.?/share/xdg/*.desktop $PKG/usr/share/applications

# set SAL_USE_VCLPLUGIN=gtk
LO=$(find $PKG/opt/libreoffice*/program -name soffice | awk 'NR==1 {print $0}')
sed -i -e '/^#\ restore/i# Prefer GTK2\nexport SAL_USE_VCLPLUGIN=${SAL_USE_VCLPLUGIN:-gtk}\n' $LO

cd $(echo $LO | sed 's|soffice||')
ln -s ./libabplo.so libavahi-client.so.3
ln -s ./libabplo.so libavahi-common.so.3

/opt/porteux-scripts/porteux-app-store/module-builder.sh "$PKG" "$MODULEPATH" "$ACTIVATEMODULE"
rm -rf $PKG 2> /dev/null