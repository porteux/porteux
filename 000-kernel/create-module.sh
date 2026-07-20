#!/bin/bash

MODULE_NAME="000-kernel"

source "$PWD/../builder-utils/set-flags.sh"

set_flags "$MODULE_NAME"

source "$BUILDER_UTILS_PATH/helper.sh"
source "$BUILDER_UTILS_PATH/latest-from-github.sh"
source "$BUILDER_UTILS_PATH/slackware-repository.sh"

elevate_if_needed "$0" "$@"

if [ ! -f ${SYSTEM_BITS}bit.config ]; then
	echo "File ${SYSTEM_BITS}bit.config is required in this folder." && exit 1
fi

if [ "$1" ]; then
	export KERNEL_VERSION="$1"
fi

IFS='.' read -r KERNEL_MAJOR_VERSION KERNEL_MINOR_VERSION KERNEL_PATCH_VERSION <<< "$KERNEL_VERSION"
CRIPPLED_MODULE_NAME="06-crippled-sources-${KERNEL_VERSION}"

### create module folder

rm -fr "${MODULE_PATH:?MODULE_PATH is unset}"
mkdir -p $MODULE_PATH/packages > /dev/null 2>&1

### download packages from slackware repository

if [ ${ONLY_HEADERS:-no} != "yes" ]; then
	bash $SCRIPT_PATH/download-packages.sh || exit 1
fi

### set compiler and linker

if [ ${CLANG:-no} = "yes" ]; then
	installpkg $MODULE_PATH/packages/libxml2*.txz > /dev/null 2>&1
	rm $MODULE_PATH/packages/libxml2*.txz > /dev/null 2>&1
	installpkg $MODULE_PATH/packages/llvm*.txz > /dev/null 2>&1
	rm $MODULE_PATH/packages/llvm*.txz > /dev/null 2>&1

	COMPILER="Clang"
	EXTRA_FLAGS="CC=clang LLVM=1 LLVM_IAS=1"
	BUILD_PARAMS="$CLANG_CFLAGS"
	LINK_PARAMS="${LLDFLAGS/-Wl,-O2/-Wl,-O1}"
else
	COMPILER="GCC"
	BUILD_PARAMS="$GCC_CFLAGS"
	LINK_PARAMS="$LDFLAGS"
fi

# remove flags that are not compatible with the kernel
BUILD_PARAMS=$(echo "$BUILD_PARAMS" | sed \
	-e 's/-fno-plt//g' \
	-e 's/-flto=auto//g')
LINK_PARAMS=$(echo "$LINK_PARAMS" | sed \
	-e 's/-z,/-z /g' \
	-e 's/-Wl,//g' \
	-e 's/--gc-sections//g' \
	-e 's/--strip-all//g' \
	-e 's/--icf=safe//g' \
	-e 's/--optimize-bb-jumps//g' \
	-e 's/-fuse-ld=lld//g')

echo -e "Building kernel ${KERNEL_VERSION} using ${COMPILER}...\n"

cp ${SCRIPT_PATH}/linux-${KERNEL_VERSION}.tar.?z ${MODULE_PATH} 2>/dev/null
cp ${SCRIPT_PATH}/kernel-firmware*.txz ${MODULE_PATH}/packages 2>/dev/null

echo "Downloading kernel source code..."
if ! ls linux-${KERNEL_VERSION}.tar.?z 1> /dev/null 2>&1; then
	wget -P ${MODULE_PATH} https://mirrors.edge.kernel.org/pub/linux/kernel/v${KERNEL_MAJOR_VERSION}.x/linux-${KERNEL_VERSION}.tar.xz > /dev/null 2>&1 || { echo "Failed to download kernel source code."; exit 1; }
fi

echo "Extracting kernel source code..."
tar xf ${MODULE_PATH}/linux-${KERNEL_VERSION}.tar.?z -C ${MODULE_PATH}
rm ${MODULE_PATH}/linux-${KERNEL_VERSION}.tar.?z

echo "Copying .config file..."
cp ${SCRIPT_PATH}/${SYSTEM_BITS}bit.config ${MODULE_PATH}/linux-${KERNEL_VERSION}/.config || exit 1

cd $MODULE_PATH/linux-${KERNEL_VERSION} || exit 1

if [ ${OVERLAYFS:-no} = "yes" ]; then
	echo "Patching OverlayFS dynamic layers support..."
	patch -N -p1 < ${SCRIPT_PATH}/0002-overlayfs-dynamic-layers.patch > /dev/null 2>&1 || { echo "Failed to apply OverlayFS dynamic layers patch."; exit 1; }
	sed -i "s|CONFIG_OVERLAY_FS_METACOPY=y|# CONFIG_OVERLAY_FS_METACOPY is not set|" .config
elif [ ${AUFSNG:-no} = "yes" ]; then
	echo "Downloading AUFS-NG..."
	git clone --depth 1 https://github.com/fulalas/aufs-ng fs/aufs-ng > /dev/null 2>&1 || { echo "Failed to download AUFS-NG."; exit 1; }
	grep -q 'source "fs/aufs-ng/Kconfig"' fs/Kconfig || sed -i '/source "fs\/overlayfs\/Kconfig"/a source "fs/aufs-ng/Kconfig"' fs/Kconfig
	grep -q 'source "fs/aufs-ng/Kconfig"' fs/Kconfig || { echo "Failed to register fs/aufs-ng/Kconfig: anchor line not found in fs/Kconfig."; exit 1; }
	grep -q 'CONFIG_AUFSNG_FS' fs/Makefile || sed -i '/obj-\$(CONFIG_OVERLAY_FS)\s*+= overlayfs\//a obj-$(CONFIG_AUFSNG_FS)\t+= aufs-ng/' fs/Makefile
	grep -q 'CONFIG_AUFSNG_FS' fs/Makefile || { echo "Failed to register fs/aufs-ng in fs/Makefile: anchor line not found."; exit 1; }
	sed -i '/^CONFIG_AUFSNG_FS/d' .config
	echo "CONFIG_AUFSNG_FS=y" >> .config
else
	echo "Downloading AUFS..."
	git clone https://github.com/sfjro/aufs-standalone ${MODULE_PATH}/aufs_sources > /dev/null 2>&1 || { echo "Failed to download AUFS."; exit 1; }
	git -C ${MODULE_PATH}/aufs_sources checkout origin/aufs${KERNEL_MAJOR_VERSION}.${KERNEL_MINOR_VERSION}.${KERNEL_PATCH_VERSION} > /dev/null 2>&1 || git -C ${MODULE_PATH}/aufs_sources checkout origin/aufs${KERNEL_MAJOR_VERSION}.${KERNEL_MINOR_VERSION} > /dev/null 2>&1 || git -C ${MODULE_PATH}/aufs_sources checkout origin/aufs${KERNEL_MAJOR_VERSION}.x-rcN > /dev/null 2>&1 || { echo "Failed to download AUFS for this kernel version."; exit 1; }

	echo "Patching kernel with AUFS..."
	rm ../aufs_sources/tmpfs-idr.patch # this patch isn't useful
	cp -r ../aufs_sources/fs .
	cp ../aufs_sources/include/uapi/linux/aufs_type.h include/uapi/linux
	for i in ../aufs_sources/*.patch; do
		patch -N -p1 < "$i" > /dev/null 2>&1 || { echo "Failed to add AUFS patch '${i}'."; exit 1; }
	done
	rm -fr ../aufs_sources
fi

echo "Patching dead code elimination support..."
patch -N -p1 < ${SCRIPT_PATH}/0001-dead-code-elimination.patch > /dev/null 2>&1 || { echo "Failed to apply dead code elimination patch."; exit 1; }

echo "Patching ntfs colon character support..."
patch -N -p1 < ${SCRIPT_PATH}/0003-ntfs-allow-colon-in-filenames.patch > /dev/null 2>&1 || { echo "Failed to apply ntfs colon support patch."; exit 1; }

# temp fix -- since 6.17.x the kernel is asking for firmware versions that are still not available
if [ -f drivers/net/wireless/intel/iwlwifi/cfg/rf-hr.c ]; then
	sed -i "s|#define IWL_HR_UCODE_API_MAX.*|#define IWL_HR_UCODE_API_MAX	89|g" drivers/net/wireless/intel/iwlwifi/cfg/rf-hr.c
	sed -i "s|#define IWL_HR_UCODE_API_MIN.*|#define IWL_HR_UCODE_API_MIN	77|g" drivers/net/wireless/intel/iwlwifi/cfg/rf-hr.c
	sed -i "s|IWL_QU_B_HR_B_MODULE_FIRMWARE(IWL_HR_UCODE_API_MAX)|IWL_QU_B_HR_B_MODULE_FIRMWARE(77)|g"  drivers/net/wireless/intel/iwlwifi/cfg/rf-hr.c
	sed -i "s|IWL_QU_C_HR_B_MODULE_FIRMWARE(IWL_HR_UCODE_API_MAX)|IWL_QU_C_HR_B_MODULE_FIRMWARE(77)|g"  drivers/net/wireless/intel/iwlwifi/cfg/rf-hr.c
	sed -i "s|IWL_QUZ_A_HR_B_MODULE_FIRMWARE(IWL_HR_UCODE_API_MAX)|IWL_QUZ_A_HR_B_MODULE_FIRMWARE(77)|g"  drivers/net/wireless/intel/iwlwifi/cfg/rf-hr.c
fi

echo "Building kernel headers..."
current_package=kernel-headers
KERNEL_SOURCE=${MODULE_PATH}/linux-${KERNEL_VERSION} sh ${SCRIPT_PATH}/extras/${current_package}/${current_package}.SlackBuild || exit 1
mkdir -p ${MODULE_PATH}/../05-devel/packages
mv ${MODULE_PATH}/packages/${current_package}*.txz ${MODULE_PATH}/../05-devel/packages
rm -fr $MODULE_PATH/${current_package} && cd $MODULE_PATH || exit 1

if [ ${ONLY_HEADERS:-no} = "yes" ]; then
	rm -fr ${MODULE_PATH}
	exit 0
fi

echo "Building vmlinuz (this may take a while)..."
cd $MODULE_PATH/linux-${KERNEL_VERSION} || exit 1
sed -i "s|select DEBUG_KERNEL||g" init/Kconfig # this allows CONFIG_DEBUG_KERNEL to be disabled
make olddefconfig > /dev/null 2>&1
make -j${NUMBER_THREADS} KBUILD_LDFLAGS="$LINK_PARAMS" LDFLAGS_MODULE="$LINK_PARAMS" KCFLAGS="$BUILD_PARAMS" ${EXTRA_FLAGS} || { echo "Failed to build kernel."; exit 1; }
cp -f arch/x86/boot/bzImage $MODULE_PATH/vmlinuz

echo "Installing modules..."
make -j${NUMBER_THREADS} INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH=../ modules_install > /dev/null 2>&1

cd $MODULE_PATH || exit 1

kernel_modules_folder=$(ls $MODULE_PATH/lib/modules/)
rm $MODULE_PATH/lib/modules/$kernel_modules_folder/build > /dev/null 2>&1

echo "Installing firmwares..."
current_package=kernel-firmware
mkdir $MODULE_PATH/${current_package} && cd $MODULE_PATH/${current_package} || exit 1
tar xf $MODULE_PATH/packages/kernel-firmware*.txz > /dev/null 2>&1
rm $MODULE_PATH/packages/kernel-firmware*.txz
sh install/doinst.sh > /dev/null 2>&1

# manually copy intel bluetooth firmwares until kernel fixes drivers/bluetooth/btintel.c
mkdir -p ${MODULE_PATH}/lib/firmware/intel > /dev/null 2>&1
cp lib/firmware/intel/ibt* ${MODULE_PATH}/lib/firmware/intel

modules_dependencies=$(ls $MODULE_PATH/lib/modules/*/modules.dep)
modules_path=${modules_dependencies%/modules.dep}
for dependency in $(cat $modules_dependencies | cut -d':' -f1); do
	firmwares=$(modinfo -F firmware $modules_path/$dependency)
	for firmware in $firmwares; do
		# expand all target files just in case some of them have wildcard
		target_files=$(ls lib/firmware/$firmware 2>/dev/null)
		while IFS= read -r target_file; do
			cp -Pu --parents "$target_file" $MODULE_PATH > /dev/null 2>&1
			# if it's a symlink also copy the real files it's pointing to
			if [ -L "$target_file" ]; then
				origin_path="$target_file"
				cp -u --parents ${origin_path%/*}/$(readlink "$target_file") $MODULE_PATH > /dev/null 2>&1
			fi			
		done <<< "$target_files"
	done
done

cd $MODULE_PATH || exit 1

echo "Downloading and installing sof for Intel..."
current_package=sof-bin
info=$(download_latest_from_github "thesofproject" "sof-bin")
filename=${info% *}
tar xf $filename > /dev/null 2>&1 && rm $filename
mkdir -p ${MODULE_PATH}/lib/firmware/intel
cd ${current_package}* || exit 1
mv sof* ${MODULE_PATH}/lib/firmware/intel

echo "Creating symlinks of duplicate firmwares..."
hash_list=$(mktemp)
declare -A seen_hashes
find ${MODULE_PATH}/lib/firmware -type f -print0 | xargs -0 -r -P"$NUMBER_THREADS" stdbuf -oL sha256sum > "$hash_list"
while IFS= read -r line; do
    file_hash="${line:0:64}"
    file_path="${line:65}"
    file_path="$(echo -e "${file_path}" | sed -e 's/^[[:space:]]*//')"

    # if we've already seen this hash, it's a duplicate
    if [[ -n "${seen_hashes[$file_hash]}" ]]; then
        original="${seen_hashes[$file_hash]}"

        if [[ -f "$file_path" ]]; then
            rm "$file_path"

            # create relative symlink
            rel_link=$(realpath --relative-to="$(dirname "$file_path")" "$original")
            ln -s "$rel_link" "$file_path"
        fi
    else
        seen_hashes["$file_hash"]="$file_path"
    fi
done < "$hash_list"

rm "$hash_list"

cd $MODULE_PATH || exit 1

echo "Creating kernel xzm module..."
mkdir -p ${MODULE_PATH}/${MODULE_NAME}
mv lib ${MODULE_PATH}/${MODULE_NAME}
make_module ${MODULE_PATH}/${MODULE_NAME} "${MODULE_NAME}-${KERNEL_VERSION}-$(date +%Y%m%d).xzm" > /dev/null || { echo "Error: failed to create kernel module." >&2; exit 1; }

echo "Creating crippled xzm module..."
CRIPPLED_SOURCE_PATH=${MODULE_PATH}/${CRIPPLED_MODULE_NAME}/usr/src
mkdir -p ${CRIPPLED_SOURCE_PATH}
mv ${MODULE_PATH}/linux-${KERNEL_VERSION} ${CRIPPLED_SOURCE_PATH}
mv ${CRIPPLED_SOURCE_PATH}/linux-${KERNEL_VERSION}/.config ${CRIPPLED_SOURCE_PATH}/linux-${KERNEL_VERSION}/config
ln -sf linux-${KERNEL_VERSION} ${CRIPPLED_SOURCE_PATH}/linux
mkdir -p ${MODULE_PATH}/${CRIPPLED_MODULE_NAME}/lib/modules/$kernel_modules_folder
ln -sf /usr/src/linux ${MODULE_PATH}/${CRIPPLED_MODULE_NAME}/lib/modules/$kernel_modules_folder/build

# strip crippled
{
mv ${CRIPPLED_SOURCE_PATH}/linux-${KERNEL_VERSION}/arch/x86 ${CRIPPLED_SOURCE_PATH}
rm -rf ${CRIPPLED_SOURCE_PATH}/linux-${KERNEL_VERSION}/arch
mkdir ${CRIPPLED_SOURCE_PATH}/linux-${KERNEL_VERSION}/arch
mv ${CRIPPLED_SOURCE_PATH}/x86 ${CRIPPLED_SOURCE_PATH}/linux-${KERNEL_VERSION}/arch/

rm -rf ${CRIPPLED_SOURCE_PATH}/linux-${KERNEL_VERSION}/arch/x86/boot/bzImage > /dev/null 2>&1
rm -rf ${CRIPPLED_SOURCE_PATH}/linux-${KERNEL_VERSION}/arch/x86/boot/compressed/vmlinux > /dev/null 2>&1
rm -rf ${CRIPPLED_SOURCE_PATH}/linux-${KERNEL_VERSION}/Documentation > /dev/null 2>&1
rm -rf ${CRIPPLED_SOURCE_PATH}/linux-${KERNEL_VERSION}/drivers > /dev/null 2>&1
rm -rf ${CRIPPLED_SOURCE_PATH}/linux-${KERNEL_VERSION}/firmware > /dev/null 2>&1
rm -rf ${CRIPPLED_SOURCE_PATH}/linux-${KERNEL_VERSION}/fs > /dev/null 2>&1
rm -rf ${CRIPPLED_SOURCE_PATH}/linux-${KERNEL_VERSION}/net > /dev/null 2>&1
rm -rf ${CRIPPLED_SOURCE_PATH}/linux-${KERNEL_VERSION}/sound > /dev/null 2>&1
rm -rf ${CRIPPLED_SOURCE_PATH}/linux-${KERNEL_VERSION}/.tmp_versions > /dev/null 2>&1
rm -rf ${CRIPPLED_SOURCE_PATH}/linux-${KERNEL_VERSION}/tools/testing/ > /dev/null 2>&1
rm -rf ${CRIPPLED_SOURCE_PATH}/linux-${KERNEL_VERSION}/vmlinux* > /dev/null 2>&1

find ${CRIPPLED_SOURCE_PATH}/linux-${KERNEL_VERSION} -regex '.*\.\(a\|bin\|elf\|exe\|o\|patch\|txt\|xsl\|xz\|ko\|zst\|json\|py\)$' -delete
find ${CRIPPLED_SOURCE_PATH}/linux-${KERNEL_VERSION} -name ".*" -exec rm -fr {} \; -print > /dev/null 2>&1
find ${CRIPPLED_SOURCE_PATH}/linux-${KERNEL_VERSION} -name "COPYING" -exec rm -fr {} \; -print > /dev/null 2>&1
find ${CRIPPLED_SOURCE_PATH}/linux-${KERNEL_VERSION} -name "CREDITS" -exec rm -fr {} \; -print > /dev/null 2>&1
find ${CRIPPLED_SOURCE_PATH}/linux-${KERNEL_VERSION} -name "LICENSE*" -exec rm -fr {} \; -print > /dev/null 2>&1
find ${CRIPPLED_SOURCE_PATH}/linux-${KERNEL_VERSION} -name "MAINTAINERS*" -exec rm -fr {} \; -print > /dev/null 2>&1
find ${CRIPPLED_SOURCE_PATH}/linux-${KERNEL_VERSION} -name "README*" -exec rm -fr {} \; -print > /dev/null 2>&1
find ${CRIPPLED_SOURCE_PATH}/linux-${KERNEL_VERSION}/scripts -xtype l -delete

mv ${CRIPPLED_SOURCE_PATH}/linux-${KERNEL_VERSION}/config ${CRIPPLED_SOURCE_PATH}/linux-${KERNEL_VERSION}/.config

find ${CRIPPLED_SOURCE_PATH} | xargs strip --strip-all -R .comment -R .eh_frame -R .eh_frame_hdr -R .eh_frame_ptr -R .jcr -R .note -R .note.ABI-tag -R .note.gnu.build-id -R .note.gnu.gold-version -R .note.GNU-stack 2> /dev/null
} >/dev/null 2>&1

make_module ${MODULE_PATH}/${CRIPPLED_MODULE_NAME} ${CRIPPLED_MODULE_NAME}-$(date +%Y%m%d).xzm > /dev/null || { echo "Error: failed to create crippled kernel module." >&2; exit 1; }

echo "Cleaning up..."
rm -fr ${MODULE_PATH}/kernel-firmware > /dev/null 2>&1 
rm -fr ${MODULE_PATH}/${MODULE_NAME} > /dev/null 2>&1
rm -fr ${MODULE_PATH}/${CRIPPLED_MODULE_NAME} > /dev/null 2>&1
rm -fr ${MODULE_PATH}/firmware > /dev/null 2>&1
rm -fr ${MODULE_PATH}/packages > /dev/null 2>&1
rm -fr ${MODULE_PATH}/sof* > /dev/null 2>&1

echo "Finished successfully."