#!/bin/bash

generate_repository_urls() {
	rm -f $MODULE_PATH/packages/FILE_LIST
	rm -f $MODULE_PATH/packages/server-packages.txt
	mkdir -p $MODULE_PATH/packages > /dev/null 2>&1
	cd $MODULE_PATH/packages || exit 1

	# Get repository packages list
	wget --tries=3 --retry-connrefused $REPOSITORY/FILE_LIST -O FILE_LIST -q > /dev/null 2>&1 || wget --tries=3 --retry-connrefused $REPOSITORY/FILELIST.TXT -O FILE_LIST -q > /dev/null 2>&1 || { echo "Error: cannot download package list from $REPOSITORY" >&2; exit 1; }
	rm server-packages.txt > /dev/null 2>&1

	# Cleanup server packages list
	local line
	while IFS= read -r line; do
		if [[ $line == -* ]] && [[ $line == *txz ]]; then
			echo "${line#*./}" >> server-packages.txt
		fi
	done < FILE_LIST

	# Sort server packages list
	sort -o server-packages.txt{,}
}

download_package() {
	cd $MODULE_PATH/packages || exit 1

	# if the package is already present don't download it again
	if find . -type f -name "${1}[-_][0-9]*" | grep -q .; then
		return
	fi

	local package_url
	package_url=$(grep "/${1}[-_][0-9]\+" server-packages.txt)
	if [ ! -z $package_url ]; then
		echo "Downloading: $package_url..."
		wget --tries=3 --retry-connrefused $REPOSITORY/$package_url -q > /dev/null 2>&1 || { echo "Error: failed to download $REPOSITORY/$package_url" >&2; exit 1; }
	fi
}
