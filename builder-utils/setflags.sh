#!/bin/sh

SetFlags() {
	MODULENAME="$1"

	systemFullVersion=$(cat /etc/slackware-version)

	if [[ ${systemFullVersion//* } != *"+" ]]; then
		export SLACKWAREVERSION=15.0
		export PORTEUXBUILD=stable
	else
		export SLACKWAREVERSION=current
		export PORTEUXBUILD=current
	fi

	export SLACKBUILDVERSION=$SLACKWAREVERSION
	export KERNELVERSION="6.10.6"

	export SCRIPTPATH="$PWD"
	export PORTEUXBUILDERPATH="/tmp/porteux-builder-$PORTEUXBUILD"
	export MODULEPATH="$PORTEUXBUILDERPATH/$MODULENAME"
	export BUILDERUTILSPATH="$SCRIPTPATH/../builderutils"

	if [ ! $ARCH ]; then
		export ARCH=$(uname -m)
	fi
	
	export ARCHITECTURELEVEL="x86-64-v2"

	if [ `getconf LONG_BIT` == "64" ]; then
		export SYSTEMBITS="64"
	fi

	export GCCFLAGS="-O3 -march=${ARCHITECTURELEVEL:-x86_64} -mtune=generic -s -fuse-linker-plugin -Wl,--as-needed -Wl,-O1 -Wl,--strip-all"
	export CLANGFLAGS="-O3 -march=${ARCHITECTURELEVEL:-x86_64} -mtune=generic"
	export NUMBERTHREADS=$(nproc --all)
	export SLACKWAREDOMAIN="http://ftp.slackware.com/pub"
	#export SLACKWAREDOMAIN="http://slackware.uk"
	export REPOSITORY="$SLACKWAREDOMAIN/slackware/slackware$SYSTEMBITS-$SLACKWAREVERSION/slackware$SYSTEMBITS"
	export PATCHREPOSITORY="$SLACKWAREDOMAIN/slackware/slackware$SYSTEMBITS/patches"
	export SOURCEREPOSITORY="$SLACKWAREDOMAIN/slackware/slackware$SYSTEMBITS-$SLACKWAREVERSION/source"

	if [ "$SLACKWAREVERSION" != "current" ]; then
		export SLACKBUILDREPOSITORY="ftp://ftp.slackbuilds.org/pub/slackbuilds/$SLACKBUILDVERSION"
	else
		export SLACKBUILDREPOSITORY="https://cgit.ponce.cc/slackbuilds/plain"
	fi
}
