#!/bin/bash

SetFlags() {
	MODULENAME="$1"

	export KERNELVERSION="6.17.7"
	export ARCHITECTURELEVEL="x86-64-v2"
	export GCCFLAGS="-O3 -march=$ARCHITECTURELEVEL -mtune=generic -fno-semantic-interposition -fno-trapping-math -ftree-vectorize -fno-unwind-tables -fno-asynchronous-unwind-tables -ffunction-sections -fdata-sections -flto=auto -fno-ident -fmodulo-sched -floop-parallelize-all -fuse-linker-plugin"
	export LDFLAGS="-Wl,--gc-sections -Wl,--as-needed -Wl,--build-id=none -Wl,-O2 -Wl,--strip-all -Wl,--sort-section=alignment -Wl,-sort-common"
	export CLANGFLAGS="-O3 -march=$ARCHITECTURELEVEL -mtune=generic -fno-semantic-interposition -fno-trapping-math -ftree-vectorize -fno-unwind-tables -fno-asynchronous-unwind-tables -ffunction-sections -fdata-sections -flto=auto -Wno-unused-command-line-argument"
	export LLDFLAGS="${LDFLAGS/ -Wl,-sort-common/} -fuse-ld=lld -Wl,--icf=safe -Wl,--lto-O3"
	export RUSTFLAGS="-Copt-level=s -Ctarget-cpu=$ARCHITECTURELEVEL -Ztune-cpu=generic -Clink-arg=-ffunction-sections -Clink-arg=-fdata-sections -Cforce-unwind-tables=no -Clto=thin -Clinker=clang -Clink-arg=-fuse-ld=lld -Clink-arg=-Wl,--gc-sections -Wl,--as-needed -Wl,--build-id=none -Clink-arg=-Wl,-O2 -Clink-arg=-Wl,--strip-all -Clink-arg=-Wl,--icf=safe -Cpanic=abort -Cdebuginfo=0 -Cembed-bitcode=yes -Cincremental=yes -Zdylib-lto -Zlocation-detail=none" # -Ccodegen-units=1
	export RUSTC_BOOTSTRAP=1 # allows -Z unstable flags on stable compiler

	export PORTEUXVERSION=$(git -C "$PWD" branch --show-current)
	systemFullVersion=$(cat /etc/slackware-version)
	systemVersion=${systemFullVersion//* }

	if [[ $systemVersion != *"+" ]]; then
		export SLACKWAREVERSION=$systemVersion
		export PORTEUXBUILD=stable
	else
		export SLACKWAREVERSION=current
		export PORTEUXBUILD=current
	fi

	export SCRIPTPATH="$PWD"
	export PORTEUXBUILDERPATH="/tmp/porteux-builder-$PORTEUXBUILD"
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
	export PATCHREPOSITORY="$SLACKWAREDOMAIN/slackware/slackware$SYSTEMBITS/patches"
	export SOURCEREPOSITORY="$SLACKWAREDOMAIN/slackware/slackware$SYSTEMBITS-$SLACKWAREVERSION/source"
	export SLACKBUILDREPOSITORY="ftp://ftp.slackbuilds.org/pub/slackbuilds/${systemVersion%\+}"
}
