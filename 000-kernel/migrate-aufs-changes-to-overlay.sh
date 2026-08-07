#!/bin/bash
# Convert a PorteuX aufs "changes" directory to overlayfs upper/work layout.
#
#   migrate-aufs-changes.sh <changes-dir> [--dry-run]
#
# What it does:
#   1. Restructures <changes-dir> so its content lives in <changes-dir>/upper
#      and creates an empty <changes-dir>/work  (overlayfs needs both;
#      aufs used the directory directly).
#   2. Converts aufs whiteouts to overlayfs whiteouts:
#        .wh.<name>          ->  character device 0:0 named <name>
#        .wh..wh..opq        ->  trusted.overlay.opaque=y xattr on the dir
#   3. Removes aufs bookkeeping entries (.wh..wh.aufs, .wh..wh.orph,
#      .wh..wh.plnk, .wh..wh..tmp).  NOTE: pseudo-link (hardlink across
#      branches) bookkeeping is dropped; files remain, but hardlink
#      identity that aufs emulated across layers is not preserved.
#
# Requirements: run as root, on a filesystem supporting mknod and
# trusted.* xattrs (ext4/xfs/btrfs/f2fs are fine; FAT is not).
# Requires the 'setfattr' tool (attr package).
#
# The conversion is idempotent: running it twice is safe.

set -u

DIR="${1:?usage: migrate-aufs-changes.sh <changes-dir> [--dry-run]}"
DRY="${2:-}"

[ "$(id -u)" = 0 ] || { echo "must run as root" >&2; exit 1; }
[ -d "$DIR" ] || { echo "'$DIR' is not a directory" >&2; exit 1; }
DIR=$(realpath -- "$DIR") || exit 1
command -v setfattr > /dev/null || { echo "setfattr not found (install attr)" >&2; exit 1; }

run() {
	if [ "$DRY" = "--dry-run" ]; then
		echo "would: $*"
	else
		"$@" || { echo "FAILED: $*" >&2; exit 1; }
	fi
}

cd "$DIR" || exit 1

### sanity: refuse to run on a mounted aufs/overlay branch
escaped_dir=$(printf '%s' "$DIR" | sed 's#[][\\.^$*+?(){}|]#\\&#g')
if grep -qE "(^|[=:])$escaped_dir(,|:|/| |$)" /proc/mounts; then
	echo "'$DIR' appears to be part of an active mount; unmount first." >&2
	exit 1
fi

### 1. restructure into upper/ + work/
if [ ! -d upper ]; then
	echo "* moving content into $DIR/upper"
	run mkdir upper
	for entry in * .[!.]* ..?*; do
		[ -e "$entry" ] || [ -L "$entry" ] || continue
		case "$entry" in upper|work) continue ;; esac
		run mv -- "$entry" upper/
	done
fi
[ -d work ] || run mkdir work

scan_root=upper
[ -d upper ] || scan_root=.

### 2. drop aufs bookkeeping
echo "* removing aufs bookkeeping entries"
while IFS= read -r -d '' f; do
	run rm -rf -- "$f"
done < <(find "$scan_root" -depth \( -name '.wh..wh.aufs' -o -name '.wh..wh.orph' \
	-o -name '.wh..wh.plnk' -o -name '.wh..wh..tmp' \) -print0 2>/dev/null)

### 3. opaque directory markers
echo "* converting opaque directory markers"
while IFS= read -r -d '' f; do
	d=$(dirname -- "$f")
	run setfattr -n trusted.overlay.opaque -v y -- "$d"
	run rm -f -- "$f"
done < <(find "$scan_root" -name '.wh..wh..opq' -print0 2>/dev/null)

### 4. whiteouts
echo "* converting whiteouts"
while IFS= read -r -d '' f; do
	d=$(dirname -- "$f")
	name=$(basename -- "$f")
	target="$d/${name#.wh.}"
	if [ -e "$target" ]; then
		echo "  warning: '$target' exists, dropping whiteout '$f'"
		run rm -f -- "$f"
		continue
	fi
	run mknod -- "$target" c 0 0
	run rm -f -- "$f"
done < <(find "$scan_root" -name '.wh.*' ! -name '.wh..wh.*' -print0 2>/dev/null)

echo "done. Mount with:"
echo "  mount -t overlay overlay -o lowerdir+=<module...>,upperdir=$DIR/upper,workdir=$DIR/work,maxlayers=<n> <mountpoint>"
