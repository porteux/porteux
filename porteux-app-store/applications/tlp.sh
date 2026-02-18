#!/bin/bash

if [ ! "$(find /mnt/live/memory/images/ -maxdepth 1 -name "*05-devel*")" ]; then
    echo "The 'devel' module needs to be activated to build and run TLP."
    exit 1
fi

if [ `whoami` != root ]; then
    echo "Please enter root's password below:"
    su -c "/opt/porteux-scripts/porteux-app-store/applications/tlp.sh"
    exit 0
fi

CURRENTPACKAGE=TLP
FRIENDLYPACKAGENAME="tlp"
ARCH="noarch"
ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")
FULLVERSION=$(curl -s https://api.github.com/repos/linrunner/${CURRENTPACKAGE}/releases/latest | grep "\"tag_name\":" | cut -d \" -f 4 | head -n 1)
VERSION="${FULLVERSION//[vV]}"
APPLICATIONURL=https://github.com/linrunner/${CURRENTPACKAGE}/archive/refs/tags/${VERSION}.tar.gz
OUTPUTDIR="${PORTDIR}/modules/"
BUILDDIR="/tmp/${CURRENTPACKAGE}-builder"
MODULEDIR=${BUILDDIR}/${CURRENTPACKAGE}-${VERSION}-1.${ARCH}

striptease(){
    rm -rf "${MODULEDIR}"/usr/lib/systemd
	rm -rf "${MODULEDIR}"/usr/share/bash-completion
	rm -rf "${MODULEDIR}"/usr/share/fish
	rm -rf "${MODULEDIR}"/usr/share/metainfo
	rm -rf "${MODULEDIR}"/usr/share/zsh
}

rm -fr "${BUILDDIR}"
mkdir "${BUILDDIR}" && cd "${BUILDDIR}"

wget -T 15 --content-disposition "${APPLICATIONURL}" -P "${BUILDDIR}" || exit 1
tar xvf ${CURRENTPACKAGE}-${VERSION}.tar.gz
cd ${CURRENTPACKAGE}-${VERSION}
make install DESTDIR="${MODULEDIR}" 

striptease

/opt/porteux-scripts/porteux-app-store/module-builder.sh "${MODULEDIR}" "${OUTPUTDIR}/${FRIENDLYPACKAGENAME}-${VERSION}-${ARCH}_porteux.xzm" "${ACTIVATEMODULE}"

# cleanup
rm -fr "${BUILDDIR}" 2> /dev/null
