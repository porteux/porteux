#!/bin/bash

DownloadLatestFromGithub() {
	repository="$1"
	project="$2"
	filename=
	versions=$(curl -s https://github.com/${repository}/${project}/tags/ | grep "/${repository}/${project}/releases/tag/" | grep -oP "(?<=/${repository}/${project}/releases/tag/)[^\"]+" | uniq | grep -v "alpha" | grep -v "beta" | grep -v "rc[0-9]")
	[ -n "$3" ] && versions=$(echo "$versions" | grep -v "$3")	
	versionNormalized=$(echo "${versions//_/.}" | sort -V -r | head -n 1)
	[[ ${versions} == *"${versionNormalized}"* ]] && version=${versionNormalized} || version=${versionNormalized//./_}
	releaseUrl="https://github.com/${repository}/${project}/releases/download/${version}/${project}-${version//[^0-9._]/}.tar"
	tagUrl="https://github.com/${repository}/${project}/archive/refs/tags/${version}.tar.gz"
	validUrl=

	if wget --spider "${releaseUrl}.xz" > /dev/null 2>&1; then
		validUrl="${releaseUrl}.xz"
	elif wget --spider "${releaseUrl}.gz" > /dev/null 2>&1; then
		validUrl="${releaseUrl}.gz"
	else
		validUrl=${tagUrl}
	fi

	contentDisposition=$(wget --server-response --content-disposition $validUrl 2>&1 | grep -i "content-disposition:")

	filename=${contentDisposition#*filename=}
	version="${version//[^0-9._]/}"
	
	echo "$filename $version"
}
