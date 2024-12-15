#!/bin/bash

# various options for cmake based builds:
# CMAKE_BUILD_TYPE can specify a build (debug|release|...) build type
# LIB_SUFFIX can set the ${CMAKE_INSTALL_PREFIX}/lib${LIB_SUFFIX}
#	 useful for 64 bit distros
# LXQT_PREFIX changes default /usr/local prefix
# LXQT_JOB_NUM Number of jobs to run in parallel while building. Defauts to
#   whatever nproc returns.
# DO_BUILD flag if components should be built (default 1)
# DO_INSTALL flag if components should be installed (default 1)
# DO_INSTALL_ROOT flag if rights should be elevated during install (default 1)
#
# example:
# $ LIB_SUFFIX=64 ./build_all.sh
# or
# $ CMAKE_BUILD_TYPE=debug CMAKE_GENERATOR=Ninja CC=clang CXX=clang++ DO_INSTALL=0 ./build_all_cmake_projects.sh
# etc.

LXQT_PREFIX=/usr
CMAKE_BUILD_TYPE=release
LIB_SUFFIX=$ARCH
source "./cmake_repos.list"

if [[ -n "$LXQT_JOB_NUM" ]]; then
	JOB_NUM="$LXQT_JOB_NUM"
else
	JOB_NUM=`nproc`
fi
echo "Make job number: $JOB_NUM"

if [[ -n "$CMAKE_BUILD_TYPE" ]]; then
	CMAKE_BUILD_TYPE="-DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE"
else
	CMAKE_BUILD_TYPE="-DCMAKE_BUILD_TYPE=debug"
fi

if [[ -n "$LXQT_PREFIX" ]]; then
	CMAKE_INSTALL_PREFIX="-DCMAKE_INSTALL_PREFIX=$LXQT_PREFIX"
else
	CMAKE_INSTALL_PREFIX=""
fi

if [[ -n  "$CMAKE_GENERATOR" ]]; then
	if [[ "$CMAKE_GENERATOR" = "Ninja" ]]; then
		CMAKE_MAKE_PROGRAM="ninja"
		CMAKE_GENERATOR="$CMAKE_GENERATOR -DCMAKE_MAKE_PROGRAM=$CMAKE_MAKE_PROGRAM"
	fi
fi

[[ -n "$CMAKE_MAKE_PROGRAM" ]] || CMAKE_MAKE_PROGRAM="make"

if [[ -n "$LIB_SUFFIX" ]]; then
	CMAKE_LIB_SUFFIX="-DLIB_SUFFIX=$LIB_SUFFIX"
else
	CMAKE_LIB_SUFFIX=""
fi

ALL_CMAKE_FLAGS="$CMAKE_BUILD_TYPE $CMAKE_INSTALL_PREFIX $CMAKE_LIB_SUFFIX $CMAKE_GENERATOR"

for d in $CMAKE_REPOS $OPTIONAL_CMAKE_REPOS
do
	echo $'\n'$'\n'"Building: $d using externally specified options: $ALL_CMAKE_FLAGS"$'\n'
	mkdir -p "$MODULEPATH/lxqt/$d/build" && cd "$MODULEPATH/lxqt/$d/build" || exit 1
	
	FLTO=""
	[ "$d" != "lxqt-config" ] && [ "$d" != "lxqt-panel" ] && [ "$d" != "screengrab" ] && FLTO="-flto=auto"

	CXXFLAGS="$GCCFLAGS -Wp,-D_FORTIFY_SOURCE=2 -Wformat -Wformat-security -Wp,-D_REENTRANT -ftree-loop-distribute-patterns -Wl,-z -Wl,now -Wl,-z -Wl,relro -fno-semantic-interposition -fno-trapping-math -Wl,-sort-common -fvisibility-inlines-hidden ${FLTO}" cmake $ALL_CMAKE_FLAGS .. && "$CMAKE_MAKE_PROGRAM" -j$JOB_NUM || exit 1
	version=`git describe | cut -d- -f1`

	"$CMAKE_MAKE_PROGRAM" install DESTDIR=$MODULEPATH/lxqt/$d/package/$d-$version-$ARCH-1
	cd $MODULEPATH/lxqt/$d/package/$d-$version-$ARCH-1
	makepkg ${MAKEPKGFLAGS} $MODULEPATH/packages/$d-$version-$ARCH-1.txz
	installpkg $MODULEPATH/packages/$d-$version-$ARCH-1.txz
done
