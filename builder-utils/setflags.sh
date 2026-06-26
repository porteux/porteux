#!/bin/bash

SetFlags() {
	MODULENAME="$1"

	export KERNELVERSION="7.1.1"
	export ARCHITECTURELEVEL="x86-64-v2"
	export GCC_CFLAGS="-O3 -march=$ARCHITECTURELEVEL -mtune=generic -fno-semantic-interposition -fno-trapping-math -fno-unwind-tables -fno-asynchronous-unwind-tables -ffunction-sections -fdata-sections -flto=auto -fno-plt -fipa-pta -fno-ident -fmodulo-sched -fuse-linker-plugin -fgraphite-identity -floop-nest-optimize -fdevirtualize-at-ltrans -fipa-reorder-for-locality -fsched-pressure -fgcse-sm -fgcse-las -favoid-store-forwarding"
	export GCC_CXXFLAGS="$GCC_CFLAGS -fvisibility-inlines-hidden"
	export LDFLAGS="-Wl,--gc-sections -Wl,--as-needed -Wl,--build-id=none -Wl,-O2 -Wl,--strip-all -Wl,--sort-common -Wl,--sort-section=alignment -Wl,-z,pack-relative-relocs -Wl,-z,noseparate-code -Wl,--hash-style=gnu"
	export CLANG_CFLAGS="-O3 -march=$ARCHITECTURELEVEL -mtune=generic -fno-semantic-interposition -fno-trapping-math -fno-unwind-tables -fno-asynchronous-unwind-tables -ffunction-sections -fdata-sections -flto=auto -fno-plt -fno-common -faddrsig -fveclib=libmvec -Wno-unused-command-line-argument -mllvm -enable-dfa-jump-thread"
	export CLANG_CXXFLAGS="$CLANG_CFLAGS -fvisibility-inlines-hidden -fwhole-program-vtables -fstrict-vtable-pointers"
	export LLDFLAGS="${LDFLAGS/-Wl,--sort-common/} -fuse-ld=lld -Wl,--icf=safe -Wl,--lto-O3 -Wl,-z,rodynamic -Wl,--lto-whole-program-visibility"
	export RUSTFLAGS="-Copt-level=3 -Ctarget-cpu=$ARCHITECTURELEVEL -Ztune-cpu=generic -Cstrip=symbols -Cforce-unwind-tables=no -Clto=fat -Clinker=clang -Clink-arg=-fuse-ld=lld -Clink-arg=-Wl,--gc-sections -Clink-arg=-Wl,-O2 -Clink-arg=-Wl,--strip-all -Clink-arg=-Wl,--icf=safe -Clink-arg=-Wl,--lto-O3 -Clink-arg=-Wl,--lto-whole-program-visibility -Clink-arg=-Wl,-z,pack-relative-relocs -Clink-arg=-Wl,--hash-style=gnu -Cllvm-args=-enable-dfa-jump-thread -Cpanic=unwind -Cdebuginfo=0 -Cembed-bitcode=yes -Zdylib-lto -Zlocation-detail=none -Zfmt-debug=shallow -Ccodegen-units=1"
	export RUSTC_BOOTSTRAP=1 # allows -Z unstable flags on stable compiler
	
	if [ -d ../.git ]; then
		current_folder=$(dirname "$(realpath "$0")")
		export PORTEUXVERSION=$(git -C "${current_folder}"/.. -c safe.directory="${current_folder}"/.. branch --show-current)
	else
		export PORTEUXVERSION=$(date -r . +%Y%m%d)
	fi

	slackware_full_version=$(cat /etc/slackware-version)
	slackware_version=${slackware_full_version//* }

	if [[ $slackware_version == *"+" ]]; then
		export SLACKWAREVERSION=current
		export PORTEUXBUILD=current		
	else
		echo "Fatal error: PorteuX can only be built in Slackware current environment." && exit 1
	fi

	export SCRIPTPATH="$PWD"
	export PORTEUXBUILDERPATH="/tmp/porteux-builder-$PORTEUXVERSION"
	export MODULEPATH="$PORTEUXBUILDERPATH/$MODULENAME"
	export BUILDERUTILSPATH="$SCRIPTPATH/../builder-utils"

	export ARCH=$(uname -m)
	export NUMBERTHREADS=$(nproc --all)
	export MAKEPKGFLAGS="-l n -c n --compress -0"

	if [ -z ${SYSTEMBITS+x} ] && [ "$(getconf LONG_BIT)" = "64" ]; then
		export SYSTEMBITS="64"
	fi

	export SLACKWAREDOMAIN="https://mirrors.slackware.com"
	#export SLACKWAREDOMAIN="https://slackware.uk"
	#export SLACKWAREDOMAIN="http://ftp.slackware.com/pub"
	export REPOSITORY="$SLACKWAREDOMAIN/slackware/slackware$SYSTEMBITS-$SLACKWAREVERSION/slackware$SYSTEMBITS"
}
