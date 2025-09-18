#!/bin/bash

if [ "$(uname -m)" != "x86_64" ]; then
    echo "Unsupported system architecture"
    exit 1
fi

if [ `whoami` != root ]; then
    echo "Please enter root's password below:"
    su -c "/opt/porteux-scripts/porteux-app-store/applications/brave.sh $1 $2 $3"
    exit 0
fi

if [ "$#" -lt 1 ]; then
    echo "Usage:   $0 [channel] [language] [optional: --activate-module]"
    echo "If no language is specified, en-US will be set"
    echo "Channels available: stable"
    echo ""
    echo "Example: $0 stable pt-BR"
    exit 1
fi

CURRENTPACKAGE=brave-browser
FRIENDLYPACKAGENAME="brave"
ARCH=$(uname -m)
CHANNEL=$([ "$1" ] && echo "$1" || echo "stable")
LANGUAGE=$([ "$2" ] && echo "$2" || echo "en-US")
ACTIVATEMODULE=$([[ "$@" == *"--activate-module"* ]] && echo "--activate-module")
FULLVERSION=$(curl -s https://api.github.com/repos/brave/${CURRENTPACKAGE}/releases/latest | grep "\"tag_name\":" | cut -d \" -f 4 | head -n 1)
VERSION="${FULLVERSION//[vV]}"
APPLICATIONURL=https://github.com/brave/${CURRENTPACKAGE}/releases/download/v${VERSION}/${CURRENTPACKAGE}-${VERSION}-1.${ARCH}.rpm
OUTPUTDIR="${PORTDIR}/modules/"
BUILDDIR="/tmp/${CURRENTPACKAGE}-builder"
MODULEDIR=${BUILDDIR}/${CURRENTPACKAGE}-${VERSION}-1.${ARCH}

locale_striptease(){
    find ${MODULEDIR}/opt/brave.com/brave/locales -mindepth 1 -maxdepth 1 \( -type f -o -type d \) ! \( -name "en-US.*" -o -name "en_US.*" -o -name "${LANGUAGE}.*" \) -delete
    find ${MODULEDIR}/opt/brave.com/brave/resources/brave_extension/_locales -mindepth 1 -maxdepth 1 -type d ! \( -name "en" -o -name "${LANGUAGE//-/_}" \) -exec rm -rf {} +
}

striptease(){
    rm -rf ${MODULEDIR}/usr/share/man
    locale_striptease
}

rm -fr "${BUILDDIR}"
mkdir "${BUILDDIR}" && cd "${BUILDDIR}"

wget -T 15 --content-disposition "${APPLICATIONURL}" -P "${BUILDDIR}" || exit 1
rpm2cpio "${MODULEDIR}.rpm" | cpio -idmv -D "${MODULEDIR}" || exit 1
sed -i "s|Exec=|Exec=env LANGUAGE=${LANGUAGE} |g" "${MODULEDIR}/usr/share/applications/${CURRENTPACKAGE}.desktop"

striptease

/opt/porteux-scripts/porteux-app-store/module-builder.sh "${MODULEDIR}" "${OUTPUTDIR}/${FRIENDLYPACKAGENAME}-${VERSION}-${ARCH}-${LANGUAGE}_porteux.xzm" "${ACTIVATEMODULE}"

# cleanup
rm -fr "${BUILDDIR}" 2> /dev/null
