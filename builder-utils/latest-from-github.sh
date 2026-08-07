#!/bin/bash

download_master_from_github() {
	local owner="$1"
	local repo="$2"
	local branch="${3:-master}"
	local tarball="${repo}-${branch}.tar.gz"
	wget "https://github.com/${owner}/${repo}/archive/refs/heads/${branch}.tar.gz" -O "$tarball" || return 1
	tar xf "$tarball" || return 1
	date -r "${repo}-${branch}" +%Y%m%d
}

get_latest_versions_tag_from_github() {
	local repository="$1"
	local project="$2"
	local filter_out_version="$3"
	local versions
	versions=$(curl -s https://github.com/${repository}/${project}/tags/ | grep -oP "(?<=/${repository}/${project}/archive/refs/tags/)[^\"]+(?=\.tar\.gz)" | uniq | grep -Ev "alpha|beta|rc[0-9]")
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
	local filename tag version release_url tag_url content_disposition
	tag=$(get_latest_version_tag_from_github "${repository}" "${project}" "${filter_out_version}")
	if [ -z "$tag" ]; then
		echo "Error: cannot detect latest ${project} version from github" >&2
		return 1
	fi
	version=${tag##*/}
	version=${version//[^0-9._]/}
	release_url="https://github.com/${repository}/${project}/releases/download/${tag}/${project}-${version}.tar"
	tag_url="https://github.com/${repository}/${project}/archive/refs/tags/${tag}.tar.gz"

	local url wget_output
	for url in "${release_url}.xz" "${release_url}.gz" "${tag_url}"; do
		content_disposition=""
		wget_output=$(wget --server-response --content-disposition "$url" 2>&1) || continue
		content_disposition=$(echo "$wget_output" | grep -i "content-disposition:")
		[ -n "$content_disposition" ] && break
	done

	if [ -z "$content_disposition" ]; then
		echo "Error: cannot download ${project} ${version} from github" >&2
		return 1
	fi

	filename=${content_disposition#*filename=}

	echo "$filename $version"
}
