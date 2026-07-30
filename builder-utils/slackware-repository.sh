#!/bin/bash

SERVER_PACKAGES_LIST="$MODULE_PATH/server-packages.txt"

generate_repository_urls() {
	local file_list="$MODULE_PATH/FILE_LIST"
	mkdir -p $MODULE_PATH/packages

	# Get repository packages list
	wget --tries=3 --retry-connrefused $REPOSITORY/FILE_LIST -O "$file_list" -q > /dev/null 2>&1 || wget --tries=3 --retry-connrefused $REPOSITORY/FILELIST.TXT -O "$file_list" -q > /dev/null 2>&1 || { echo "Error: cannot download package list from $REPOSITORY" >&2; exit 1; }

	# Cleanup and sort server packages list
	awk '/^-/ && /txz$/ { print substr($0, index($0, "./") + 2) }' "$file_list" | sort > "$SERVER_PACKAGES_LIST"

	rm -f "$file_list"
}

download_package() {
	cd $MODULE_PATH/packages || exit 1

	# if the package is already present don't download it again
	if find . -type f -name "${1}[-_][0-9]*" | grep -q .; then
		return
	fi

	local package_url
	package_url=$(grep "/${1}[-_][0-9]\+" "$SERVER_PACKAGES_LIST" | head -n1)
	if [ -z "$package_url" ]; then
		echo "Error: package $1 not found in repository $REPOSITORY" >&2
		exit 1
	fi
	echo "Downloading: $package_url..."
	wget --tries=3 --retry-connrefused $REPOSITORY/$package_url -q > /dev/null 2>&1 || { echo "Error: failed to download $REPOSITORY/$package_url" >&2; exit 1; }
}
