#!/bin/bash

copy_to_devel() {
	mkdir -p "$PORTEUX_BUILDER_PATH"/05-devel/packages
	cd "$MODULE_PATH"/packages || exit 1
	find . -regex '.*\.\(a\|c\|cmake\|deps\|gir\|h\|hpp\|hxx\|in\|m4\|make\|mk\|o\|pc\|prl\|pyi\|spec\|vapi\)$' -exec cp --parents -t "$PORTEUX_BUILDER_PATH"/05-devel/packages {} +
	cp -r --parents usr/lib/python*/site-packages/*-info "$PORTEUX_BUILDER_PATH"/05-devel/packages > /dev/null 2>&1
	cp -r --parents usr/share/gettext/its "$PORTEUX_BUILDER_PATH"/05-devel/packages > /dev/null 2>&1
	cp -r --parents usr/share/glib-2.0/codegen "$PORTEUX_BUILDER_PATH"/05-devel/packages > /dev/null 2>&1
}

copy_to_multilanguage() {
	mkdir -p "$PORTEUX_BUILDER_PATH"/08-multilanguage/packages
	cd "$MODULE_PATH"/packages || exit 1
	[ -e usr/share/locale ] && cp -r --parents usr/share/locale "$PORTEUX_BUILDER_PATH"/08-multilanguage/packages
	[ -e usr/share/X11/locale ] && cp -r --parents usr/share/X11/locale "$PORTEUX_BUILDER_PATH"/08-multilanguage/packages
	find usr/share -type f -name "*.qm" -exec cp --parents -t "$PORTEUX_BUILDER_PATH"/08-multilanguage/packages {} +
}

install_packages() {
	cd "$MODULE_PATH"/packages || exit 1
	ROOT=./ installpkg *.t?z || exit 1
	rm *.t?z
}

install_additional_packages() {
	cd "$MODULE_PATH"/packages || exit 1
	# need to copy otherwise package install log will leak the package path
	cp "$SCRIPT_PATH"/packages/*.t?z . || exit 1
	install_packages
}

# not using rust from slackware because it's much slower
install_rust_toolchain() {
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --profile minimal --default-toolchain stable -y
	rm -fr $HOME/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/share/doc 2>/dev/null
	export PATH=$HOME/.cargo/bin/:$PATH
	command -v cargo > /dev/null || { echo "Error: failed to install rust toolchain." >&2; exit 1; }
}

make_module() {
	local zstd_flags="-comp zstd -b 256K -Xcompression-level 22"
	mksquashfs "${1}" "${2}" $zstd_flags -noappend || return 1
}

finalize() {
	local build_date
	build_date=$(date +%Y%m%d)

	# generate module version file
	mkdir -p "$MODULE_PATH"/packages/etc/porteux
	echo $MODULE_NAME.xzm:$build_date > "$MODULE_PATH"/packages/etc/porteux/$MODULE_NAME.ver

	# create module
	make_module "$MODULE_PATH"/packages/ "$MODULE_PATH"/$MODULE_NAME-$PORTEUX_BUILD-$build_date.xzm || { echo "Error: failed to create module $MODULE_NAME." >&2; exit 1; }

	# script clean up
	rm -fr "${MODULE_PATH:?}"/packages/
}

is_root() {
	[ "$(id -u)" -eq 0 ]
}

elevate_if_needed() {
	is_root && return 0
	local script="$1"
	shift
	echo "Please enter admin's password below:"
	su -c "$(printf '%q ' "$(realpath "$script")" "$@")"
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

	ROOT=./ installpkg "${package}"*.t?z || { echo "strip_package: failed to install $package" >&2; exit 1; }
	mkdir "${package}-stripped"

	local keep
	shift # remove package name param
	for keep in "$@"; do
		cp --parents -alf $keep "${package}-stripped" || { echo "strip_package: $package has no match for $keep" >&2; exit 1; }
	done

	cd "${package}-stripped" || exit 1
	makepkg ${MAKEPKG_FLAGS} "$MODULE_PATH/packages/${out_base}_stripped.txz" > /dev/null 2>&1 || { echo "strip_package: failed to create ${out_base}_stripped.txz" >&2; exit 1; }

	rm -fr "$workdir" && cd "$MODULE_PATH" || exit 1
}