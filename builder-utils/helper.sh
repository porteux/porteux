#!/bin/bash

copy_to_devel() {
	mkdir -p "$PORTEUX_BUILDER_PATH"/05-devel/packages > /dev/null 2>&1
	cd "$MODULE_PATH"/packages || exit 1
	find . -regex '.*\.\(h\|c\|m4\|make\|cmake\|a\|o\|pc\|gir\|deps\|vapi\|in\)$' -exec cp --parents {} "$PORTEUX_BUILDER_PATH"/05-devel/packages \;
	cp -r --parents usr/lib/python*/site-packages/*-info "$PORTEUX_BUILDER_PATH"/05-devel/packages > /dev/null 2>&1
	cp -r --parents usr/share/gettext/its "$PORTEUX_BUILDER_PATH"/05-devel/packages > /dev/null 2>&1
	cp -r --parents usr/share/glib-2.0/codegen "$PORTEUX_BUILDER_PATH"/05-devel/packages > /dev/null 2>&1
}

copy_to_multilanguage() {
	mkdir -p "$PORTEUX_BUILDER_PATH"/08-multilanguage/packages > /dev/null 2>&1
	cd "$MODULE_PATH"/packages || exit 1
	[ -e usr/share/locale ] && cp -r --parents usr/share/locale "$PORTEUX_BUILDER_PATH"/08-multilanguage/packages
	[ -e usr/share/X11/locale ] && cp -r --parents usr/share/X11/locale "$PORTEUX_BUILDER_PATH"/08-multilanguage/packages
	find usr/share -type f -name "*.qm" -exec cp --parents {} "$PORTEUX_BUILDER_PATH"/08-multilanguage/packages \;
}

install_additional_packages() {
	cd "$MODULE_PATH"/packages || exit 1
	cp "$SCRIPT_PATH"/packages/*.t?z .
	ROOT=./ installpkg *.t?z
	rm *.t?z
}

make_module() {
	local zstd_flags="-comp zstd -b 256K -Xcompression-level 22"
	mksquashfs "${1}" "${2}" $zstd_flags -noappend || exit 1
}

finalize() {
	# generate module version file
	mkdir -p "$MODULE_PATH"/packages/etc/porteux
	echo $MODULE_NAME.xzm:$(date +%Y%m%d) > "$MODULE_PATH"/packages/etc/porteux/$MODULE_NAME.ver

	# create module
	make_module "$MODULE_PATH"/packages/ "$MODULE_PATH"/$MODULE_NAME-$PORTEUX_BUILD-$(date +%Y%m%d).xzm

	# script clean up
	rm -fr "$MODULE_PATH"/packages/
}

is_root() {
	[ "$(id -u)" -eq 0 ]
}

elevate_if_needed() {
	is_root && return 0
	echo "Please enter admin's password below:"
	su -c "$(printf '%q ' "$@")"
	exit
}

strip_package() {
	local package="$1"
	local workdir="$MODULE_PATH/$package"
	rm -rf "$workdir"
	mkdir -p "$workdir" && cd "$workdir" || { echo "strip_package: cannot enter $workdir" >&2; exit 1; }

	mv "$MODULE_PATH"/packages/"${package}"-[0-9]* . || { echo "strip_package: $package package not found in $MODULE_PATH/packages" >&2; exit 1; }

	local pkg_file out_base
	pkg_file=$(ls "${package}"-[0-9]*.t?z | head -n1)
	out_base=${pkg_file%.*}

	ROOT=./ installpkg "${package}"*.txz
	mkdir "${package}-stripped"

	local keep
	shift # remove package name param
	for keep in "$@"; do
		cp --parents -af $keep "${package}-stripped"
	done

	cd "${package}-stripped" || exit 1
	makepkg ${MAKEPKG_FLAGS} "$MODULE_PATH/packages/${out_base}_stripped.txz" > /dev/null 2>&1

	rm -fr "$workdir" && cd "$MODULE_PATH" || exit 1
}