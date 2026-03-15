#!/bin/bash

SetFlags() {
	MODULENAME="$1"

	export KERNELVERSION="6.19.6"
	export ARCHITECTURELEVEL="x86-64-v2"
	export GCCFLAGS="-O3 -march=$ARCHITECTURELEVEL -mtune=generic -fno-semantic-interposition -fno-trapping-math -ftree-vectorize -fno-unwind-tables -fno-asynchronous-unwind-tables -ffunction-sections -fdata-sections -flto=auto -fno-plt -mpclmul -fipa-pta -fno-ident -fmodulo-sched -fuse-linker-plugin"
	export LDFLAGS="-Wl,--gc-sections -Wl,--as-needed -Wl,--build-id=none -Wl,-O2 -Wl,--strip-all -Wl,--sort-common -Wl,--sort-section=alignment -Wl,-z,pack-relative-relocs"
	export CLANGFLAGS="-O3 -march=$ARCHITECTURELEVEL -mtune=generic -fno-semantic-interposition -fno-trapping-math -ftree-vectorize -fno-unwind-tables -fno-asynchronous-unwind-tables -ffunction-sections -fdata-sections -flto=auto -fno-plt -mpclmul -faddrsig -Wno-unused-command-line-argument -mllvm -enable-dfa-jump-thread"
	export LLDFLAGS="${LDFLAGS/-Wl,-sort-common/} -fuse-ld=lld -Wl,--icf=safe -Wl,--lto-O3 -Wl,--pack-dyn-relocs=relr -Wl,-z,rodynamic"
	export RUSTFLAGS="-Copt-level=3 -Ctarget-cpu=$ARCHITECTURELEVEL -Ztune-cpu=generic -Cstrip=symbols -Clink-arg=-ffunction-sections -Clink-arg=-fdata-sections -Cforce-unwind-tables=no -Clto=fat -Clinker=clang -Clink-arg=-fuse-ld=lld -Clink-arg=-Wl,--gc-sections -Clink-arg=-Wl,-O2 -Clink-arg=-Wl,--strip-all -Clink-arg=-Wl,--icf=safe -Clink-arg=-Wl,--lto-O3 -Clink-arg=-Wl,-z,pack-relative-relocs -Cllvm-args=-enable-dfa-jump-thread -Cpanic=unwind -Cdebuginfo=0 -Cembed-bitcode=yes -Zdylib-lto -Zlocation-detail=none -Ccodegen-units=1"
	export RUSTC_BOOTSTRAP=1 # allows -Z unstable flags on stable compiler
	
	current_folder=$(dirname "$(realpath "$0")")
	git config --global --add safe.directory "${current_folder}"/.. 2>/dev/null
	export PORTEUXVERSION=$(git -C "${current_folder}"/.. branch --show-current)
	[ ! $PORTEUXVERSION ] && PORTEUXVERSION=$(date -r . +%Y%m%d)
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
	export MAKEPKGFLAGS="-l y -c n --compress -0"

	if [ -z ${SYSTEMBITS+x} ] && [ "$(getconf LONG_BIT)" = "64" ]; then
		export SYSTEMBITS="64"
	fi

	export SLACKWAREDOMAIN="https://mirrors.slackware.com"
	#export SLACKWAREDOMAIN="https://slackware.uk"
	#export SLACKWAREDOMAIN="http://ftp.slackware.com/pub"
	export REPOSITORY="$SLACKWAREDOMAIN/slackware/slackware$SYSTEMBITS-$SLACKWAREVERSION/slackware$SYSTEMBITS"
}
