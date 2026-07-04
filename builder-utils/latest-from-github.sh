#!/bin/bash

get_latest_version_tag_from_github() {
	repository="$1"
	project="$2"
	filter_out_version="$3"
	versions=$(curl -s https://github.com/${repository}/${project}/tags/ | grep -oP "(?<=/${repository}/${project}/releases/tag/)[^\"]+" | uniq | grep -v "alpha" | grep -v "beta" | grep -v "rc[0-9]")
	[ -n "$filter_out_version" ] && versions=$(echo "$versions" | grep -Ev "$filter_out_version")
	version_normalized=$(echo "${versions//_/.}" | sort -V -r | head -n 1)
	[[ ${versions} == *"${version_normalized}"* ]] && version=${version_normalized} || version=${version_normalized//./_}

	echo "${version}"
}

download_latest_from_github() {
	repository="$1"
	project="$2"
	filter_out_version="$3"
	filename=
	version=$(get_latest_version_tag_from_github "${repository}" "${project}" "${filter_out_version}")
	release_url="https://github.com/${repository}/${project}/releases/download/${version}/${project}-${version//[^0-9._]/}.tar"
	tag_url="https://github.com/${repository}/${project}/archive/refs/tags/${version}.tar.gz"
	valid_url=

	if wget --spider "${release_url}.xz" > /dev/null 2>&1; then
		valid_url="${release_url}.xz"
	elif wget --spider "${release_url}.gz" > /dev/null 2>&1; then
		valid_url="${release_url}.gz"
	else
		valid_url=${tag_url}
	fi

	content_disposition=$(wget --server-response --content-disposition $valid_url 2>&1 | grep -i "content-disposition:")

	filename=${content_disposition#*filename=}
	version="${version//[^0-9._]/}"

	echo "$filename $version"
}
