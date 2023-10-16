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
	export KERNELVERSION="6.5.7"

    export SCRIPTPATH="$PWD"
    export PORTEUXBUILDERPATH="/tmp/porteux-builder-$PORTEUXBUILD"
    export MODULEPATH="$PORTEUXBUILDERPATH/$MODULENAME"
    export BUILDERUTILSPATH="$SCRIPTPATH/../builderutils"

    if [ ! $ARCH ]; then
        export ARCH=$(uname -m)
    fi

    if [ ! $SYSTEMBITS ] && [ `getconf LONG_BIT` == "64" ]; then
        export SYSTEMBITS="64"
    elif [ $SYSTEMBITS == "32" ]; then
        export SYSTEMBITS=
    fi

	NUMBERTHREADS=$(nproc --all)

    export REPOSITORY="ftp://ftp.slackware.com/pub/slackware/slackware$SYSTEMBITS-$SLACKWAREVERSION/slackware$SYSTEMBITS"
    export PATCHREPOSITORY="ftp://ftp.slackware.com/pub/slackware/slackware$SYSTEMBITS/patches"
    export SOURCEREPOSITORY="ftp://ftp.slackware.com/pub/slackware/slackware$SYSTEMBITS-$SLACKWAREVERSION/source"

    if [ "$SLACKWAREVERSION" != "current" ]; then
        export SLACKBUILDREPOSITORY="ftp://ftp.slackbuilds.org/pub/slackbuilds/$SLACKBUILDVERSION"
    else
        export SLACKBUILDREPOSITORY="https://cgit.ponce.cc/slackbuilds/plain"
    fi
}
