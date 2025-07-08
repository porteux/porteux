#!/bin/bash

GenerateRepositoryUrls() {
	rm -f $MODULEPATH/packages/FILE_LIST
	rm -f $MODULEPATH/packages/serverPackages.txt
	mkdir -p $MODULEPATH/packages > /dev/null 2>&1
	cd $MODULEPATH/packages
	
	# Get repository packages list
	wget $1/FILE_LIST -O FILE_LIST -q > /dev/null 2>&1 || exit
	rm serverPackages.txt > /dev/null 2>&1

	# Cleanup server packages list
	while IFS= read -r line; do
		if [[ $line == -* ]] && [[ $line == *txz ]]; then
			echo "${line#*./}" >> serverPackages.txt
		fi
	done < FILE_LIST

	# Sort server packages list
	sort -o serverPackages.txt{,}
}

DownloadPackage() {
	cd $MODULEPATH/packages

	# if the package is already present don't download it again
	if find . -type f -name "${1}[-_][0-9]*" | grep -q .; then
		return
	fi

	packageUrl=`grep "/${1}[-_][0-9]\+" serverPackages.txt`
	if [ ! -z $packageUrl ]; then
		echo "Downloading: $packageUrl..."
		wget $REPOSITORY/$packageUrl -q > /dev/null 2>&1 || exit
	fi
}
