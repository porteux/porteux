#!/bin/bash

SetFlags() {
	MODULENAME="$1"

	export KERNELVERSION="6.15.2"
	export ARCHITECTURELEVEL="x86-64-v2"
	export GCCFLAGS="-O3 -march=$ARCHITECTURELEVEL -mtune=generic -fno-semantic-interposition -fno-trapping-math -ftree-vectorize -fno-unwind-tables -fno-asynchronous-unwind-tables -ffunction-sections -fdata-sections -Wl,--gc-sections -Wl,--as-needed -Wl,--build-id=none -flto=auto -Wl,-O1 -fno-ident -s -fmodulo-sched -floop-parallelize-all -fuse-linker-plugin -Wl,-sort-common"
	export CLANGFLAGS="-O3 -march=$ARCHITECTURELEVEL -mtune=generic -fno-semantic-interposition -fno-trapping-math -ftree-vectorize -fno-unwind-tables -fno-asynchronous-unwind-tables -ffunction-sections -fdata-sections -Wl,--gc-sections -Wl,--as-needed -Wl,--build-id=none -flto=auto -Wl,-O2 -Wno-unused-command-line-argument"
	export RUSTFLAGS="-Copt-level=s -Ctarget-cpu=$ARCHITECTURELEVEL -Clink-arg=-ffunction-sections -Clink-arg=-fdata-sections -Cforce-unwind-tables=no -Clink-arg=-Wl,--gc-sections -Clink-arg=-Wl,--as-needed -Clink-arg=-Wl,--build-id=none -Clto=fat -Cpanic=abort -Cdebuginfo=0 -Cembed-bitcode=yes -Cincremental=yes -Ccodegen-units=16" #-Zdylib-lto -Zlocation-detail=none"

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

	if [ -z ${SYSTEMBITS+x} ] && [ `getconf LONG_BIT` == "64" ]; then
		export SYSTEMBITS="64"
	fi

	export SLACKWAREDOMAIN="http://ftp.slackware.com/pub"
	#export SLACKWAREDOMAIN="https://mirrors.slackware.com"
	#export SLACKWAREDOMAIN="https://slackware.uk"
	export REPOSITORY="$SLACKWAREDOMAIN/slackware/slackware$SYSTEMBITS-$SLACKWAREVERSION/slackware$SYSTEMBITS"
	export PATCHREPOSITORY="$SLACKWAREDOMAIN/slackware/slackware$SYSTEMBITS/patches"
	export SOURCEREPOSITORY="$SLACKWAREDOMAIN/slackware/slackware$SYSTEMBITS-$SLACKWAREVERSION/source"
	export SLACKBUILDREPOSITORY="ftp://ftp.slackbuilds.org/pub/slackbuilds/${systemVersion%\+}"
}
