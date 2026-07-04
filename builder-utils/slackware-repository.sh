#!/bin/bash

generate_repository_urls() {
	rm -f $MODULE_PATH/packages/FILE_LIST
	rm -f $MODULE_PATH/packages/server-packages.txt
	mkdir -p $MODULE_PATH/packages > /dev/null 2>&1
	cd $MODULE_PATH/packages
	
	# Get repository packages list
	wget --tries=3 --retry-connrefused $REPOSITORY/FILE_LIST -O FILE_LIST -q > /dev/null 2>&1 || wget --tries=3 --retry-connrefused $REPOSITORY/FILELIST.TXT -O FILE_LIST -q > /dev/null 2>&1 || exit
	rm server-packages.txt > /dev/null 2>&1

	# Cleanup server packages list
	while IFS= read -r line; do
		if [[ $line == -* ]] && [[ $line == *txz ]]; then
			echo "${line#*./}" >> server-packages.txt
		fi
	done < FILE_LIST

	# Sort server packages list
	sort -o server-packages.txt{,}
}

download_package() {
	cd $MODULE_PATH/packages

	# if the package is already present don't download it again
	if find . -type f -name "${1}[-_][0-9]*" | grep -q .; then
		return
	fi

	package_url=$(grep "/${1}[-_][0-9]\+" server-packages.txt)
	if [ ! -z $package_url ]; then
		echo "Downloading: $package_url..."
		wget --tries=3 --retry-connrefused $REPOSITORY/$package_url -q > /dev/null 2>&1 || exit
	fi
}
