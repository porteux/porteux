#!/bin/bash

source "$PWD/../builder-utils/setflags.sh"

MODULENAME="000-kernel"

SetFlags "${MODULENAME}"

source "$BUILDERUTILSPATH/downloadfromslackware.sh"
source "$BUILDERUTILSPATH/helper.sh"
source "$BUILDERUTILSPATH/latestfromgithub.sh"

if ! isRoot; then
	echo "Please enter admin's password below:"
	su -c "$0 $1"
	exit
fi

if [ ! -f ${SYSTEMBITS}bit.config ]; then
	echo "File ${SYSTEMBITS}bit.config is required in this folder." && exit 1
fi

if [ "$1" ]; then
	export KERNELVERSION="$1"
fi

KERNELMAJORVERSION=${KERNELVERSION:0:1}
KERNELMINORVERSION=$(echo ${KERNELVERSION} | cut -d. -f2)
[ ${KERNELMINORVERSION} ] && KERNELMINORVERSION=.${KERNELMINORVERSION}
KERNELPATCHVERSION=$(echo ${KERNELVERSION} | cut -d. -f3)
[ ${KERNELPATCHVERSION} ] && KERNELPATCHVERSION=.${KERNELPATCHVERSION}
CRIPPLEDMODULENAME="06-crippled-sources-${KERNELVERSION}"

### create module folder

mkdir -p $MODULEPATH/packages > /dev/null 2>&1

### set compiler

if [ ${CLANG:-no} = "yes" ]; then
	if [ ! -f /usr/bin/clang ]; then
		DownloadFromSlackware
		installpkg $MODULEPATH/packages/libxml2*.txz > /dev/null 2>&1
		rm $MODULEPATH/packages/libxml2*.txz > /dev/null 2>&1
		installpkg $MODULEPATH/packages/llvm*.txz > /dev/null 2>&1
		rm $MODULEPATH/packages/llvm*.txz > /dev/null 2>&1
	fi
	EXTRAFLAGS="LLVM=1 CC=clang"
	BUILDPARAMS="$CLANGFLAGS -Wno-incompatible-pointer-types-discards-qualifiers"
	COMPILER="Clang"
else
	BUILDPARAMS="$GCCFLAGS"
	COMPILER="GCC"
fi

echo "Building kernel ${KERNELVERSION} $ARCH using ${COMPILER}..."

rm -fr ${MODULEPATH} && mkdir -p ${MODULEPATH}
cp ${SCRIPTPATH}/linux-${KERNELVERSION}.tar.?z ${MODULEPATH} 2>/dev/null
cp ${SCRIPTPATH}/kernel-firmware*.txz ${MODULEPATH} 2>/dev/null

### download packages from slackware repositoriesg

echo "Downloading kernel source code..."
if [ ! -f linux-${KERNELVERSION}.tar.?z ]; then
	wget -P ${MODULEPATH} https://mirrors.edge.kernel.org/pub/linux/kernel/v${KERNELMAJORVERSION}.x/linux-${KERNELVERSION}.tar.xz > /dev/null 2>&1 || { echo "Fail to download kernel source code."; exit 1; }
fi

echo "Extracting kernel source code..."
tar xf ${MODULEPATH}/linux-${KERNELVERSION}.tar.?z -C ${MODULEPATH}
rm ${MODULEPATH}/linux-${KERNELVERSION}.tar.?z

echo "Copying .config file..."
cp ${SCRIPTPATH}/${SYSTEMBITS}bit.config ${MODULEPATH}/linux-${KERNELVERSION}/.config || exit 1

echo "Building kernel headers..."
mkdir -p ${MODULEPATH}/../05-devel/packages
wget -P $MODULEPATH ${SLACKWAREDOMAIN}/slackware/slackware-current/source/k/kernel-headers.SlackBuild > /dev/null 2>&1 || exit 1
KERNEL_SOURCE=${MODULEPATH}/linux-${KERNELVERSION} sh ${MODULEPATH}/kernel-headers.SlackBuild > /dev/null 2>&1
mv /tmp/kernel-headers-*.txz ${MODULEPATH}/../05-devel/packages
rm ${MODULEPATH}/kernel-headers.SlackBuild

echo "Downloading AUFS..."
git clone https://github.com/sfjro/aufs-standalone ${MODULEPATH}/aufs_sources > /dev/null 2>&1 || { echo "Fail to download AUFS."; exit 1; }
git -C ${MODULEPATH}/aufs_sources checkout origin/aufs${KERNELMAJORVERSION}${KERNELMINORVERSION}${KERNELPATCHVERSION} > /dev/null 2>&1 || git -C ${MODULEPATH}/aufs_sources checkout origin/aufs${KERNELMAJORVERSION}${KERNELMINORVERSION} > /dev/null 2>&1 || git -C ${MODULEPATH}/aufs_sources checkout origin/aufs${KERNELMAJORVERSION}.x-rcN > /dev/null 2>&1 || { echo "Fail to download AUFS for this kernel version."; exit 1; }

cd $MODULEPATH/linux-${KERNELVERSION}

echo "Patching AUFS..."
rm ../aufs_sources/tmpfs-idr.patch # this patch isn't useful
cp -r ../aufs_sources/{fs,Documentation} .
cp ../aufs_sources/include/uapi/linux/aufs_type.h include/uapi/linux
for i in ../aufs_sources/*.patch; do
	patch -N -p1 < "$i" > /dev/null 2>&1 || { echo "Failed to add AUFS patch '${i}'."; exit 1; }
done
rm -fr ../aufs_sources

if [ ! -f ${MODULEPATH}/kernel-firmware-*.txz ]; then
	echo "Downloading firmware in the background..."
	DOWNLOADINGFIRMWARE=true
	(
		wget -r -nd --no-parent -w 2 ${SLACKWAREDOMAIN}/slackware/slackware64-current/slackware64/a/ -A kernel-firmware-*.txz -P ${MODULEPATH} > /dev/null 2>&1 & PID1=$! || { echo "Fail to download firmware."; exit 1; }
	) &
fi

# this allows CONFIG_DEBUG_KERNEL=n
sed -i "s|select DEBUG_KERNEL||g" init/Kconfig

echo "Building vmlinuz (this may take a while)..."
make olddefconfig > /dev/null 2>&1 && make -j${NUMBERTHREADS} KCFLAGS="$BUILDPARAMS" ${EXTRAFLAGS} || { echo "Fail to build kernel."; exit 1; }
cp -f arch/x86/boot/bzImage ../vmlinuz

echo "Installing modules..."
make -j${NUMBERTHREADS} INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH=../ modules_install > /dev/null 2>&1

echo "Installing firmwares..."
make -j${NUMBERTHREADS} INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH=../ firmware_install > /dev/null 2>&1

cd ..

echo "Creating symlinks..."
dir=$(ls lib/modules/)
rm lib/modules/$dir/build lib/modules/$dir/source > /dev/null 2>&1
ln -sf /usr/src/linux lib/modules/$dir/build
ln -sf /usr/src/linux lib/modules/$dir/source

if [ $DOWNLOADINGFIRMWARE ]; then
	# wait for firmware download to finish
	wait $PID1
fi

echo "Extracting firmware..."
mkdir firmware && tar xf kernel-firmware-*.txz -C firmware > /dev/null 2>&1
rm kernel-firmware-*.txz
cd firmware && mv install/doinst.sh . && sh ./doinst.sh

echo "Adding firmware..."
# manually copy intel bluetooth firmwares until kernel fixes drivers/bluetooth/btintel.c
mkdir -p ${MODULEPATH}/lib/firmware/intel > /dev/null 2>&1
cp lib/firmware/intel/ibt* ${MODULEPATH}/lib/firmware/intel

# add firmware based on modules.dep
cd lib
modulesDependencies=$(ls ../../lib/modules/*/modules.dep)
modulesPath=${modulesDependencies%/modules.dep}

for dependency in $(cat $modulesDependencies | cut -d':' -f1); do
	firmwares=$(modinfo -F firmware $modulesPath/$dependency)
	for firmware in $firmwares; do
		# expand all target files just in case some of them have wildcard
		targetFiles=$(ls firmware/$firmware 2>/dev/null)
		while IFS= read -r targetFile; do
			cp -Pu --parents "$targetFile" ../../lib > /dev/null 2>&1
			# If it's a symlink also copy the real files it's pointing to
			if [ -L "$targetFile" ]; then
				originPath="$targetFile"
				cp -u --parents ${originPath%/*}/$(readlink "$targetFile") ../../lib > /dev/null 2>&1
			fi			
		done <<< "$targetFiles"
	done
done

cd ../..

echo "Downloading and installing sof for Intel..."
currentPackage=sof-bin
info=$(DownloadLatestFromGithub "thesofproject" "sof-bin")
version=${info#* }
filename=${info% *}
tar xvf $filename > /dev/null 2>&1 && rm $filename
mkdir -p ${MODULEPATH}/lib/firmware/intel
cd ${currentPackage}*
mv sof ${MODULEPATH}/lib/firmware/intel
mv sof-tplg ${MODULEPATH}/lib/firmware/intel
cd ..

echo "Creating kernel xzm module..."
mkdir -p ${MODULEPATH}/${MODULENAME}
mv lib ${MODULEPATH}/${MODULENAME}

# create kernel module xzm module
MakeModule ${MODULEPATH}/${MODULENAME} "${MODULENAME}-${KERNELVERSION}.xzm" > /dev/null 2>&1

echo "Creating crippled xzm module..."
CRIPPLEDSOURCEPATH=${MODULEPATH}/${CRIPPLEDMODULENAME}/usr/src
mkdir -p ${CRIPPLEDSOURCEPATH}
mv ${MODULEPATH}/linux-${KERNELVERSION} ${CRIPPLEDSOURCEPATH}
mkdir ${CRIPPLEDSOURCEPATH}/linux-${KERNELVERSION}/build/
mv ${CRIPPLEDSOURCEPATH}/linux-${KERNELVERSION}/.config ${CRIPPLEDSOURCEPATH}/linux-${KERNELVERSION}/build/config
ln -sf linux-${KERNELVERSION} ${CRIPPLEDSOURCEPATH}/linux

# strip crippled
mv ${CRIPPLEDSOURCEPATH}/linux-${KERNELVERSION}/arch/x86 ${CRIPPLEDSOURCEPATH}
rm -rf ${CRIPPLEDSOURCEPATH}/linux-${KERNELVERSION}/arch
mkdir ${CRIPPLEDSOURCEPATH}/linux-${KERNELVERSION}/arch
mv ${CRIPPLEDSOURCEPATH}/x86 ${CRIPPLEDSOURCEPATH}/linux-${KERNELVERSION}/arch/

rm -rf ${CRIPPLEDSOURCEPATH}/linux-${KERNELVERSION}/arch/x86/boot/bzImage > /dev/null 2>&1
rm -rf ${CRIPPLEDSOURCEPATH}/linux-${KERNELVERSION}/arch/x86/boot/compressed/vmlinux > /dev/null 2>&1
rm -rf ${CRIPPLEDSOURCEPATH}/linux-${KERNELVERSION}/Documentation > /dev/null 2>&1
rm -rf ${CRIPPLEDSOURCEPATH}/linux-${KERNELVERSION}/drivers > /dev/null 2>&1
rm -rf ${CRIPPLEDSOURCEPATH}/linux-${KERNELVERSION}/firmware > /dev/null 2>&1
rm -rf ${CRIPPLEDSOURCEPATH}/linux-${KERNELVERSION}/fs > /dev/null 2>&1
rm -rf ${CRIPPLEDSOURCEPATH}/linux-${KERNELVERSION}/net > /dev/null 2>&1
rm -rf ${CRIPPLEDSOURCEPATH}/linux-${KERNELVERSION}/sound > /dev/null 2>&1
rm -rf ${CRIPPLEDSOURCEPATH}/linux-${KERNELVERSION}/.tmp_versions > /dev/null 2>&1
rm -rf ${CRIPPLEDSOURCEPATH}/linux-${KERNELVERSION}/tools/testing/ > /dev/null 2>&1
rm -rf ${CRIPPLEDSOURCEPATH}/linux-${KERNELVERSION}/vmlinux* > /dev/null 2>&1

find ${CRIPPLEDSOURCEPATH}/linux-${KERNELVERSION} -regex '.*\.\(a\|bin\|elf\|exe\|o\|patch\|txt\|xsl\|xz\|ko\|zst\|json\|py\)$' -delete
find ${CRIPPLEDSOURCEPATH}/linux-${KERNELVERSION} -name ".*" -exec rm -fr {} \; -print > /dev/null 2>&1
find ${CRIPPLEDSOURCEPATH}/linux-${KERNELVERSION} -name "COPYING" -exec rm -fr {} \; -print > /dev/null 2>&1
find ${CRIPPLEDSOURCEPATH}/linux-${KERNELVERSION} -name "CREDITS" -exec rm -fr {} \; -print > /dev/null 2>&1
find ${CRIPPLEDSOURCEPATH}/linux-${KERNELVERSION} -name "LICENSE*" -exec rm -fr {} \; -print > /dev/null 2>&1
find ${CRIPPLEDSOURCEPATH}/linux-${KERNELVERSION} -name "MAINTAINERS*" -exec rm -fr {} \; -print > /dev/null 2>&1
find ${CRIPPLEDSOURCEPATH}/linux-${KERNELVERSION} -name "README*" -exec rm -fr {} \; -print > /dev/null 2>&1

mv ${CRIPPLEDSOURCEPATH}/linux-${KERNELVERSION}/build/config ${CRIPPLEDSOURCEPATH}/linux-${KERNELVERSION}/build/.config

find ${CRIPPLEDSOURCEPATH} | xargs strip --strip-all -R .comment -R .eh_frame -R .eh_frame_hdr -R .eh_frame_ptr -R .jcr -R .note -R .note.ABI-tag -R .note.gnu.build-id -R .note.gnu.gold-version -R .note.GNU-stack 2> /dev/null

# create crippled xzm module
MakeModule ${MODULEPATH}/${CRIPPLEDMODULENAME} ${CRIPPLEDMODULENAME}.xzm > /dev/null 2>&1

echo "Cleaning up..."
rm -r ${MODULEPATH}/${MODULENAME} > /dev/null 2>&1
rm -r ${MODULEPATH}/${CRIPPLEDMODULENAME} > /dev/null 2>&1
rm -r ${MODULEPATH}/firmware > /dev/null 2>&1
rm -r ${MODULEPATH}/packages > /dev/null 2>&1
rm -r ${MODULEPATH}/sof* > /dev/null 2>&1

echo "Finished successfully."