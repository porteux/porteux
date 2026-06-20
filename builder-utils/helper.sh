#!/bin/bash

CopyToDevel() {
	mkdir -p "$PORTEUXBUILDERPATH"/05-devel/packages > /dev/null 2>&1
	cd "$MODULEPATH"/packages
	find . -regex '.*\.\(h\|c\|m4\|make\|cmake\|a\|o\|pc\|gir\|deps\|vapi\|in\)$' -exec cp --parents {} "$PORTEUXBUILDERPATH"/05-devel/packages \;
	cp -r --parents usr/lib/python*/site-packages/*-info "$PORTEUXBUILDERPATH"/05-devel/packages > /dev/null 2>&1
}

CopyToMultiLanguage() {
	mkdir -p "$PORTEUXBUILDERPATH"/08-multilanguage/packages > /dev/null 2>&1
	cd "$MODULEPATH"/packages
	[ -e usr/share/locale ] && cp -r --parents usr/share/locale "$PORTEUXBUILDERPATH"/08-multilanguage/packages
	[ -e usr/share/X11/locale ] && cp -r --parents usr/share/X11/locale "$PORTEUXBUILDERPATH"/08-multilanguage/packages
	find usr/share -type f -name "*.qm" -exec cp --parents {} "$PORTEUXBUILDERPATH"/08-multilanguage/packages \;
}

InstallAdditionalPackages() {
	cd "$MODULEPATH"/packages
	cp "$SCRIPTPATH"/packages/*.t?z .
	ROOT=./ installpkg *.t?z
	rm *.t?z
}

MakeModule() {
	zstdFlags="-comp zstd -b 256K -Xcompression-level 22"
	mksquashfs "${1}" "${2}" $zstdFlags -noappend
}

Finalize() {
	# generate module version file
	mkdir -p "$MODULEPATH"/packages/etc/porteux
	echo $MODULENAME.xzm:$(date +%Y%m%d) > "$MODULEPATH"/packages/etc/porteux/$MODULENAME.ver

	# create module
	MakeModule "$MODULEPATH"/packages/ "$MODULEPATH"/$MODULENAME-$PORTEUXBUILD-$(date +%Y%m%d).xzm

	# script clean up
	rm -fr "$MODULEPATH"/packages/
}

isRoot() {
	[ "$(id -u)" -eq 0 ]
}