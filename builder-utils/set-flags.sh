#!/bin/bash

set_flags() {
	MODULE_NAME="$1"

	export KERNEL_VERSION="7.1.6"
	export ARCHITECTURE_LEVEL="x86-64-v2"
	export GCC_CFLAGS="-O3 -march=$ARCHITECTURE_LEVEL -mtune=generic -fno-semantic-interposition -fno-trapping-math -fno-unwind-tables -fno-asynchronous-unwind-tables -ffunction-sections -fdata-sections -flto=auto -fno-plt -fipa-pta -fno-ident -fmodulo-sched -fmodulo-sched-allow-regmoves -floop-nest-optimize -fdevirtualize-at-ltrans -fipa-reorder-for-locality -fgcse-sm -fgcse-las -favoid-store-forwarding"
	export GCC_CXXFLAGS="$GCC_CFLAGS -fvisibility-inlines-hidden"
	export LDFLAGS="-Wl,--gc-sections -Wl,--as-needed -Wl,--build-id=none -Wl,-O2 -Wl,--strip-all -Wl,--sort-common -Wl,--sort-section=alignment -Wl,-z,pack-relative-relocs -Wl,-z,noseparate-code -Wl,--hash-style=gnu"
	export CLANG_CFLAGS="-O3 -march=$ARCHITECTURE_LEVEL -mtune=generic -fno-semantic-interposition -fno-trapping-math -fno-unwind-tables -fno-asynchronous-unwind-tables -ffunction-sections -fdata-sections -flto=auto -fno-plt -fno-ident -faddrsig -fveclib=libmvec -Wno-unused-command-line-argument -mllvm -enable-dfa-jump-thread"
	export CLANG_CXXFLAGS="$CLANG_CFLAGS -fvisibility-inlines-hidden -fwhole-program-vtables -fstrict-vtable-pointers"
	export LLDFLAGS="${LDFLAGS/-Wl,--sort-common/} -fuse-ld=lld -Wl,--icf=safe -Wl,--lto-O3 -Wl,--lto-CGO3 -Wl,--lto-whole-program-visibility"
	export RUSTFLAGS="-Copt-level=3 -Ctarget-cpu=$ARCHITECTURE_LEVEL -Ztune-cpu=generic -Cstrip=symbols -Cforce-unwind-tables=no -Clto=fat -Clinker=clang -Clink-arg=-fuse-ld=lld -Clink-arg=-Wl,--gc-sections -Clink-arg=-Wl,-O2 -Clink-arg=-Wl,--strip-all -Clink-arg=-Wl,--icf=safe -Clink-arg=-Wl,--lto-O3 -Clink-arg=-Wl,--lto-CGO3 -Clink-arg=-Wl,--lto-whole-program-visibility -Clink-arg=-Wl,-z,pack-relative-relocs -Clink-arg=-Wl,--hash-style=gnu -Cllvm-args=-enable-dfa-jump-thread -Cpanic=unwind -Cdebuginfo=0 -Cembed-bitcode=yes -Zdylib-lto -Zlocation-detail=none -Zfmt-debug=shallow -Ccodegen-units=1"
	export RUSTC_BOOTSTRAP=1 # allows -Z unstable flags on stable compiler
	
	repo_root=$(realpath "$(dirname "$(realpath "$0")")"/..)

	if [ -d "${repo_root}"/.git ]; then
		export PORTEUX_VERSION=$(git -C "${repo_root}" -c safe.directory="${repo_root}" branch --show-current)
	fi

	if [ -z "$PORTEUX_VERSION" ]; then
		export PORTEUX_VERSION=$(date -r . +%Y%m%d)
	fi

	slackware_full_version=$(cat /etc/slackware-version)
	slackware_version=${slackware_full_version//* }

	if [[ $slackware_version == *"+" ]]; then
		export SLACKWARE_VERSION=current
		export PORTEUX_BUILD=current
	else
		echo "Fatal error: PorteuX can only be built in Slackware current environment." && exit 1
	fi

	export SCRIPT_PATH="$PWD"
	export PORTEUX_BUILDER_PATH="/tmp/porteux-builder-$PORTEUX_VERSION"
	export MODULE_PATH="$PORTEUX_BUILDER_PATH/$MODULE_NAME"
	export BUILDER_UTILS_PATH="$SCRIPT_PATH/../builder-utils"

	export ARCH=$(uname -m)
	export NUMBER_THREADS=$(nproc --all)
	export MAKEPKG_FLAGS="-l n -c n --compress -0"

	if [ -z ${SYSTEM_BITS+x} ] && [ "$(getconf LONG_BIT)" = "64" ]; then
		export SYSTEM_BITS="64"
	fi

	export SLACKWARE_DOMAIN="https://mirrors.slackware.com"
	#export SLACKWARE_DOMAIN="https://slackware.uk"
	#export SLACKWARE_DOMAIN="http://ftp.slackware.com/pub"
	export REPOSITORY="$SLACKWARE_DOMAIN/slackware/slackware$SYSTEM_BITS-$SLACKWARE_VERSION/slackware$SYSTEM_BITS"
}
