#!/bin/bash

CopyToDevel() {
	mkdir -p "$PORTEUXBUILDERPATH"/05-devel/packages > /dev/null 2>&1
	cd "$MODULEPATH"/packages
	find . -regex '.*\.\(h\|c\|m4\|cmake\|a\|o\|pc\|gir\|deps\|vapi\|in\)$' -exec cp --parents {} "$PORTEUXBUILDERPATH"/05-devel/packages \;
	cp -r --parents usr/lib/python*/site-packages/*-info "$PORTEUXBUILDERPATH"/05-devel/packages > /dev/null 2>&1
}

CopyToMultiLanguage() {
	mkdir -p "$PORTEUXBUILDERPATH"/08-multilanguage/packages > /dev/null 2>&1
	cd "$MODULEPATH"/packages
	[ -e usr/share/featherpad/translations ] && cp -r --parents usr/share/featherpad/translations "$PORTEUXBUILDERPATH"/08-multilanguage/packages
	[ -e usr/share/locale ] && cp -r --parents usr/share/locale "$PORTEUXBUILDERPATH"/08-multilanguage/packages
	[ -e usr/share/libfm-qt/translations ] && cp -r --parents usr/share/libfm-qt/translations "$PORTEUXBUILDERPATH"/08-multilanguage/packages
	[ -e usr/share/lximage-qt/translations ] && cp -r --parents usr/share/lximage-qt/translations "$PORTEUXBUILDERPATH"/08-multilanguage/packages
	[ -e usr/share/lxqt/translations ] && cp -r --parents usr/share/lxqt/translations "$PORTEUXBUILDERPATH"/08-multilanguage/packages
	[ -e usr/share/lxqt-archiver/translations ] && cp -r --parents usr/share/lxqt-archiver/translations "$PORTEUXBUILDERPATH"/08-multilanguage/packages
	[ -e usr/share/obconf-qt/translations ] && cp -r --parents usr/share/obconf-qt/translations "$PORTEUXBUILDERPATH"/08-multilanguage/packages
	[ -e usr/share/pavucontrol-qt/translations ] && cp -r --parents usr/share/pavucontrol-qt/translations "$PORTEUXBUILDERPATH"/08-multilanguage/packages
	[ -e usr/share/pcmanfm-qt/translations ] && cp -r --parents usr/share/pcmanfm-qt/translations "$PORTEUXBUILDERPATH"/08-multilanguage/packages
	[ -e usr/share/qps/translations ] && cp -r --parents usr/share/qps/translations "$PORTEUXBUILDERPATH"/08-multilanguage/packages
	[ -e usr/share/qterminal/translations ] && cp -r --parents usr/share/qterminal/translations "$PORTEUXBUILDERPATH"/08-multilanguage/packages
	[ -e usr/share/qtermwidget5/translations ] && cp -r --parents usr/share/qtermwidget5/translations "$PORTEUXBUILDERPATH"/08-multilanguage/packages
	[ -e usr/share/screengrab/translations ] && cp -r --parents usr/share/screengrab/translations "$PORTEUXBUILDERPATH"/08-multilanguage/packages
	[ -e usr/share/sddm/translations ] && cp -r --parents usr/share/sddm/translations "$PORTEUXBUILDERPATH"/08-multilanguage/packages
	[ -e usr/share/nm-tray ] && cp -r --parents usr/share/nm-tray/*.qm "$PORTEUXBUILDERPATH"/08-multilanguage/packages
	[ -e usr/share/X11/locale ] && cp -r --parents usr/share/X11/locale "$PORTEUXBUILDERPATH"/08-multilanguage/packages
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
	groupsList=$(groups)

	for entry in $groupsList; do
		if [[ "$entry" == "root" ]]; then
			return 0
		fi
	done

	return 1
}