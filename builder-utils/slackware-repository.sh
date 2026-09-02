#!/bin/bash

SERVER_PACKAGES_LIST="$MODULE_PATH/server-packages.txt"
DOWNLOAD_FAILURE_FLAG="$MODULE_PATH/download-failed"

generate_repository_urls() {
	local file_list="$MODULE_PATH/FILE_LIST"
	mkdir -p "$MODULE_PATH"/packages
	rm -f "$DOWNLOAD_FAILURE_FLAG"
	trap 'rm -f "$SERVER_PACKAGES_LIST"' EXIT

	# Get repository packages list
	wget --tries=3 --retry-connrefused $REPOSITORY/FILE_LIST -O "$file_list" -q > /dev/null 2>&1 || wget --tries=3 --retry-connrefused $REPOSITORY/FILELIST.TXT -O "$file_list" -q > /dev/null 2>&1 || { echo "Error: cannot download package list from $REPOSITORY" >&2; exit 1; }

	# Cleanup and sort server packages list
	awk '/^-/ && /txz$/ { print substr($0, index($0, "./") + 2) }' "$file_list" | sort > "$SERVER_PACKAGES_LIST"

	rm -f "$file_list"
}

download_package() {
	cd "$MODULE_PATH"/packages || { touch "$DOWNLOAD_FAILURE_FLAG"; exit 1; }

	# if the package is already present don't download it again
	if find . -maxdepth 1 -type f -name "${1}[-_][0-9]*" | grep -q .; then
		return
	fi

	local package_url
	package_url=$(grep "/${1//./\\.}[-_][0-9]\+" "$SERVER_PACKAGES_LIST" | head -n1)
	if [ -z "$package_url" ]; then
		echo "Error: package $1 not found in repository $REPOSITORY" >&2
		touch "$DOWNLOAD_FAILURE_FLAG"
		exit 1
	fi
	local package_file
	package_file=${package_url##*/}

	echo "Downloading: $package_url..."
	wget --tries=3 --retry-connrefused "$REPOSITORY/$package_url" -O ".$package_file.part" -q > /dev/null 2>&1 || { rm -f ".$package_file.part"; echo "Error: failed to download $REPOSITORY/$package_url" >&2; touch "$DOWNLOAD_FAILURE_FLAG"; exit 1; }
	mv ".$package_file.part" "$package_file" || { echo "Error: failed to download $REPOSITORY/$package_url" >&2; touch "$DOWNLOAD_FAILURE_FLAG"; exit 1; }
}

wait_for_downloads() {
	wait
	if [ -f "$DOWNLOAD_FAILURE_FLAG" ]; then
		rm -f "$DOWNLOAD_FAILURE_FLAG"
		echo "Error: one or more packages could not be downloaded." >&2
		exit 1
	fi
}
