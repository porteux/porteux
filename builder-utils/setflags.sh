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
    export KERNELVERSION="6.10.2"

    export SCRIPTPATH="$PWD"
    export PORTEUXBUILDERPATH="/tmp/porteux-builder-$PORTEUXBUILD"
    export MODULEPATH="$PORTEUXBUILDERPATH/$MODULENAME"
    export BUILDERUTILSPATH="$SCRIPTPATH/../builderutils"

    if [ ! $ARCH ]; then
        export ARCH=$(uname -m)
    fi
    
    export ARCHITECTURELEVEL="x86-64-v2"

    if [ ! $SYSTEMBITS ] && [ `getconf LONG_BIT` == "64" ]; then
        export SYSTEMBITS="64"
    else
        export SYSTEMBITS=
    fi

    export GCCFLAGS="-O3 -s -march=${ARCHITECTURELEVEL:-x86_64}"
    export NUMBERTHREADS=$(nproc --all)
    export REPOSITORY="http://slackware.uk/slackware/slackware$SYSTEMBITS-$SLACKWAREVERSION/slackware$SYSTEMBITS"
    export PATCHREPOSITORY="http://slackware.uk/slackware/slackware$SYSTEMBITS/patches"
    export SOURCEREPOSITORY="http://slackware.uk/slackware/slackware$SYSTEMBITS-$SLACKWAREVERSION/source"

    if [ "$SLACKWAREVERSION" != "current" ]; then
        export SLACKBUILDREPOSITORY="ftp://ftp.slackbuilds.org/pub/slackbuilds/$SLACKBUILDVERSION"
    else
        export SLACKBUILDREPOSITORY="https://cgit.ponce.cc/slackbuilds/plain"
    fi
}
