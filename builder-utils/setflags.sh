#!/bin/bash

SetFlags() {
	MODULENAME="$1"

	export KERNELVERSION="6.15"
	export ARCHITECTURELEVEL="x86-64-v2"
	export GCCFLAGS="-O3 -march=$ARCHITECTURELEVEL -mtune=generic -fno-semantic-interposition -fno-trapping-math -fomit-frame-pointer -ftree-vectorize -s -fmodulo-sched -floop-parallelize-all -fuse-linker-plugin -Wl,--as-needed -Wl,-O1 -Wl,-sort-common"
	export CLANGFLAGS="-O3 -march=$ARCHITECTURELEVEL -mtune=generic -fno-semantic-interposition -fno-trapping-math -fomit-frame-pointer -ftree-vectorize"
	export RUSTFLAGS="-Copt-level=3 -Ctarget-cpu=$ARCHITECTURELEVEL -Clto=fat -Zdylib-lto -Cpanic=abort -Cstrip=debuginfo -Cembed-bitcode=yes -Ccodegen-units=1 -Zlocation-detail=none"

	export GCC_LTO_COMPRESSION=zstd
	export GCC_LTO_COMPRESSION_LEVEL=19

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
	#export SLACKWAREDOMAIN="http://slackware.uk"
	export REPOSITORY="$SLACKWAREDOMAIN/slackware/slackware$SYSTEMBITS-$SLACKWAREVERSION/slackware$SYSTEMBITS"
	export PATCHREPOSITORY="$SLACKWAREDOMAIN/slackware/slackware$SYSTEMBITS/patches"
	export SOURCEREPOSITORY="$SLACKWAREDOMAIN/slackware/slackware$SYSTEMBITS-$SLACKWAREVERSION/source"
	export SLACKBUILDREPOSITORY="ftp://ftp.slackbuilds.org/pub/slackbuilds/${systemVersion%\+}"
}
