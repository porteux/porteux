#!/bin/bash

download_master_from_github() {
	local owner="$1"
	local repo="$2"
	local branch="${3:-master}"
	local tarball="${repo}-${branch}.tar.gz"
	wget "https://github.com/${owner}/${repo}/archive/refs/heads/${branch}.tar.gz" -O "$tarball" || exit 1
	tar xf "$tarball" || exit 1
	date -r "${repo}-${branch}" +%Y%m%d
}

get_latest_versions_tag_from_github() {
	local repository="$1"
	local project="$2"
	local filter_out_version="$3"
	local versions
	versions=$(curl -s https://github.com/${repository}/${project}/tags/ | grep -oP "(?<=/${repository}/${project}/releases/tag/)[^\"]+" | uniq | grep -Ev "alpha|beta|rc[0-9]")
	[ -n "$filter_out_version" ] && versions=$(echo "$versions" | grep -Ev "$filter_out_version")
	echo "$versions" | sort -V -r | head -n 10
}

get_latest_version_tag_from_github() {
	get_latest_versions_tag_from_github "$1" "$2" "$3" | head -n 1
}

download_latest_from_github() {
	local repository="$1"
	local project="$2"
	local filter_out_version="$3"
	local filename version release_url tag_url content_disposition
	version=$(get_latest_version_tag_from_github "${repository}" "${project}" "${filter_out_version}")
	release_url="https://github.com/${repository}/${project}/releases/download/${version}/${project}-${version//[^0-9._]/}.tar"
	tag_url="https://github.com/${repository}/${project}/archive/refs/tags/${version}.tar.gz"

	local url
	for url in "${release_url}.xz" "${release_url}.gz" "${tag_url}"; do
		content_disposition=$(wget --server-response --content-disposition "$url" 2>&1 | grep -i "content-disposition:")
		[ -n "$content_disposition" ] && break
	done

	filename=${content_disposition#*filename=}
	version="${version//[^0-9._]/}"

	echo "$filename $version"
}
