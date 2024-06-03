#!/bin/sh

if [ ! "$(find /mnt/live/memory/images/ -maxdepth 1 -name "*05-devel*")" ]; then
	echo "05-devel module needs to be activated"
	exit 1
fi

# switch to root
if [ $(whoami) != root ]; then
	echo "Please enter root's password below:"
	su -c "$0 $1"
	exit
fi

source "$PWD/../builder-utils/setflags.sh"

MODULENAME="000-kernel"

SetFlags "${MODULENAME}"

source "$PWD/../builder-utils/latestfromgithub.sh"

if [ ! -f ${SYSTEMBITS}bit.config ]; then
	echo "File ${SYSTEMBITS}bit.config is required in this folder." && exit 1
fi

if [ "$1" ]; then
	export KERNELVERSION="$1"
fi

echo "Building kernel version ${KERNELVERSION}..."
echo "Initial setup..."

KERNELMAJORVERSION=${KERNELVERSION:0:1}
KERNELMINORVERSION=$(echo ${KERNELVERSION} | cut -d. -f2)
CRIPPLEDMODULENAME="06-crippled_sources-${KERNELVERSION}"

rm -fr ${MODULEPATH} && mkdir -p ${MODULEPATH}
cp ${SCRIPTPATH}/linux-${KERNELVERSION}.tar.xz ${MODULEPATH} 2>/dev/null
cp ${SCRIPTPATH}/kernel-firmware*.txz ${MODULEPATH} 2>/dev/null

echo "Downloading kernel source code..."
if [ ! -f linux-${KERNELVERSION}.tar.xz ]; then
	wget -P ${MODULEPATH} https://mirrors.edge.kernel.org/pub/linux/kernel/v${KERNELMAJORVERSION}.x/linux-${KERNELVERSION}.tar.xz > /dev/null 2>&1 || { echo "Fail to download kernel source code."; exit 1; }
fi

echo "Extracting kernel source code..."
tar xf ${MODULEPATH}/linux-${KERNELVERSION}.tar.xz -C ${MODULEPATH}
rm ${MODULEPATH}/linux-${KERNELVERSION}.tar.xz

echo "Copying .config file..."
cp ${SCRIPTPATH}/${SYSTEMBITS}bit.config ${MODULEPATH}/linux-${KERNELVERSION}/.config || exit 1

echo "Building kernel headers..."
mkdir -p ${MODULEPATH}/../05-devel/packages
wget -P $MODULEPATH http://ftp.slackware.com/pub/slackware/slackware-current/source/k/kernel-headers.SlackBuild > /dev/null 2>&1 || exit 1
KERNEL_SOURCE=${MODULEPATH}/linux-${KERNELVERSION} sh ${MODULEPATH}/kernel-headers.SlackBuild > /dev/null 2>&1
mv /tmp/kernel-headers-*.txz ${MODULEPATH}/../05-devel/packages
rm ${MODULEPATH}/kernel-headers.SlackBuild

echo "Downloading AUFS..."
git clone https://github.com/sfjro/aufs-standalone ${MODULEPATH}/aufs_sources > /dev/null 2>&1 || { echo "Fail to download AUFS."; exit 1; }
git -C ${MODULEPATH}/aufs_sources checkout origin/aufs${KERNELMAJORVERSION}.${KERNELMINORVERSION} > /dev/null 2>&1 || git -C ${MODULEPATH}/aufs_sources checkout origin/aufs${KERNELMAJORVERSION}.x-rcN > /dev/null 2>&1 || { echo "Fail to download AUFS for this kernel version."; exit 1; }

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
		wget -r -nd --no-parent -w 2 http://slackware.uk/slackware/slackware64-current/slackware64/a/ -A kernel-firmware-*.txz -P ${MODULEPATH} > /dev/null 2>&1 || { echo "Fail to download firmware."; exit 1; }
	) &
fi

echo "Building vmlinuz (this may take a while)..."
make olddefconfig > /dev/null 2>&1 && make -j${NUMBERTHREADS} "KCFLAGS=-O3 -march=${ARCHITECTURELEVEL} -s -feliminate-unused-debug-types -pipe -Wp,-D_FORTIFY_SOURCE=2 -Wformat -Wformat-security -fasynchronous-unwind-tables -Wp,-D_REENTRANT -ftree-loop-distribute-patterns -Wl,-z -Wl,now -Wl,-z -Wl,relro -fno-semantic-interposition -fno-trapping-math -Wl,-sort-common -Wl,--enable-new-dtags -fno-tree-vectorize -mpopcnt -fivopts -fmodulo-sched -mrelax-cmpxchg-loop" || { echo "Fail to build kernel."; exit 1; }
cp -f arch/x86/boot/bzImage ../vmlinuz
make clean

echo "Building modules (this may take a while)..."
make olddefconfig > /dev/null 2>&1 && make -j${NUMBERTHREADS} "KCFLAGS=-O3 -march=${ARCHITECTURELEVEL} -s" || { echo "Fail to build kernel."; exit 1; }
make -j${NUMBERTHREADS} INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH=../ modules_install > /dev/null 2>&1
make -j${NUMBERTHREADS} INSTALL_MOD_PATH=../ firmware_install > /dev/null 2>&1

cd ..

echo "Creating symlinks..."
dir=$(ls lib/modules/)
rm lib/modules/$dir/build lib/modules/$dir/source > /dev/null 2>&1
ln -sf /usr/src/linux lib/modules/$dir/build
ln -sf /usr/src/linux lib/modules/$dir/source

if [ $DOWNLOADINGFIRMWARE ]; then
	# wait for firmware download to finish
	wait
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

echo "Blacklisting..."
mkdir -p ${MODULEPATH}/${MODULENAME}/etc/modprobe.d
cat > ${MODULEPATH}/${MODULENAME}/etc/modprobe.d/b43_blacklist.conf <<EOF
blacklist b43
blacklist b43legacy
blacklist b44
blacklist bcma
blacklist brcm80211
blacklist brcmfmac
blacklist brcmsmac
blacklist ssb
EOF

cat > ${MODULEPATH}/${MODULENAME}/etc/modprobe.d/broadcom_blacklist.conf <<EOF
blacklist b43
blacklist bcma
blacklist brcmsmac
blacklist ssb
EOF

echo "Creating kernel xzm module..."
mv lib ${MODULEPATH}/${MODULENAME}

# strip kernel module
find ${MODULEPATH}/${MODULENAME} | xargs strip -S --strip-unneeded -R .comment -R .eh_frame -R .eh_frame_hdr -R .eh_frame_ptr -R .jcr -R .note -R .note.ABI-tag -R .note.gnu.build-id -R .note.gnu.gold-version -R .note.GNU-stack 2> /dev/null

# create kernel module xzm module
dir2xzm ${MODULEPATH}/${MODULENAME} -o=${MODULENAME}-${KERNELVERSION}.xzm -q > /dev/null 2>&1

echo "Creating crippled xzm module..."
CRIPPLEDSOURCEPATH=${MODULEPATH}/${CRIPPLEDMODULENAME}/usr/src
mkdir -p ${CRIPPLEDSOURCEPATH} && mv ${MODULEPATH}/linux-${KERNELVERSION} ${CRIPPLEDSOURCEPATH}
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

find ${CRIPPLEDSOURCEPATH}/linux-${KERNELVERSION} -regex '.*\.\(bin\|elf\|exe\|o\|patch\|txt\|xsl\|xz\|ko\|zst\|json\|py\)$' -delete
find ${CRIPPLEDSOURCEPATH}/linux-${KERNELVERSION} -type f -name ".*" -delete -print > /dev/null 2>&1
find ${CRIPPLEDSOURCEPATH}/linux-${KERNELVERSION} -type f -name "COPYING" -delete -print > /dev/null 2>&1
find ${CRIPPLEDSOURCEPATH}/linux-${KERNELVERSION} -type f -name "CREDITS" -delete -print > /dev/null 2>&1
find ${CRIPPLEDSOURCEPATH}/linux-${KERNELVERSION} -type f -name 'LICENSE*' -delete -print > /dev/null 2>&1
find ${CRIPPLEDSOURCEPATH}/linux-${KERNELVERSION} -type f -name 'MAINTAINERS*' -delete -print > /dev/null 2>&1
find ${CRIPPLEDSOURCEPATH}/linux-${KERNELVERSION} -type f -name "README*" -delete -print > /dev/null 2>&1

find ${CRIPPLEDSOURCEPATH} | xargs strip -S --strip-all -R .comment -R .eh_frame -R .eh_frame_hdr -R .eh_frame_ptr -R .jcr -R .note -R .note.ABI-tag -R .note.gnu.build-id -R .note.gnu.gold-version -R .note.GNU-stack 2> /dev/null

mkdir ${CRIPPLEDSOURCEPATH}/linux-${KERNELVERSION}/build
cp ${SCRIPTPATH}/${SYSTEMBITS}bit.config ${CRIPPLEDSOURCEPATH}/linux-${KERNELVERSION}/build/.config

# create crippled xzm module
dir2xzm ${MODULEPATH}/${CRIPPLEDMODULENAME} -q > /dev/null 2>&1

echo "Cleaning up..."
rm -r ${MODULEPATH}/${MODULENAME}
rm -r ${MODULEPATH}/${CRIPPLEDMODULENAME}
rm -r ${MODULEPATH}/firmware
rm -r ${MODULEPATH}/sof*

echo "Finished successfully."
