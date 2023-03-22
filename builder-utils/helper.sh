#!/bin/sh

CopyToDevel() {
	mkdir -p $PORTEUXBUILDERPATH/05-devel/packages  > /dev/null 2>&1
	cd $MODULEPATH/packages
	find . -regex '.*\.\(h\|c\|m4\|cmake\|a\|o\|pc\|gir\|deps\|vapi\)$' -exec cp --parents {} $PORTEUXBUILDERPATH/05-devel/packages \;
}

InstallAdditionalPackages() {
	installpkg --root "$MODULEPATH"/packages "$SCRIPTPATH"/packages/*.txz
}

Finalize() {
	# generate module version file
	mkdir -p $MODULEPATH/packages/etc/porteux
	touch $MODULEPATH/packages/etc/porteux/$MODULENAME.ver
	echo $MODULENAME.xzm:$(date +%Y%m%d) > $MODULEPATH/packages/etc/porteux/$MODULENAME.ver

	# create module
	zstdFlags="-comp zstd -b 256K -Xcompression-level 22"
	mksquashfs $MODULEPATH/packages/ $MODULEPATH/$MODULENAME-$SLACKWAREVERSION-$(date +%Y%m%d).xzm $zstdFlags -noappend

	# script clean up
	rm -fr $MODULEPATH/packages/
	rm -fr /tmp/SBo/
}
