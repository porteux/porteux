#!/bin/bash

STRIP_SECTIONS="-R .comment* -R .note -R .note.ABI-tag -R .note.gnu.build-id -R .note.gnu.gold-version -R .note.GNU-stack"

list_elf_files() {
	local type_pattern="$1"
	local exceptions=""
	[[ $2 == --exceptions=* ]] && exceptions="${2#--exceptions=}" && exceptions="${exceptions//,/|}"

	find . -type f -print0 | xargs -0 file -00 | while IFS= read -r -d '' binary_file && IFS= read -r -d '' file_type; do
		[[ $file_type == $type_pattern ]] || continue
		[[ -n $exceptions && ( ${binary_file##*/} == @($exceptions) || $binary_file == @($exceptions) ) ]] && continue
		printf '%s\0' "$binary_file"
	done
}

split_elf_files() {
	local executables="$1" shared_objects="$2"
	local exceptions=""
	[[ $3 == --exceptions=* ]] && exceptions="${3#--exceptions=}" && exceptions="${exceptions//,/|}"

	find . -type f -print0 | xargs -0 file -00 | while IFS= read -r -d '' binary_file && IFS= read -r -d '' file_type; do
		[[ -n $exceptions && ( ${binary_file##*/} == @($exceptions) || $binary_file == @($exceptions) ) ]] && continue
		case $file_type in
			*ELF*shared\ object*) printf '%s\0' "$binary_file" >> "$shared_objects" ;;
			*ELF*executable*) printf '%s\0' "$binary_file" >> "$executables" ;;
		esac
	done
}

strip_clean() {
	rm usr/share/pixmaps/*.xpm
	rm usr/X11/man
	rm var/log/removed_packages
	rm var/log/removed_scripts
	rm var/log/removed_uninstall_scripts

	rm -fr etc/bash_completion*
	rm -fr etc/logrotate.d
	rm -fr usr/doc
	rm -fr usr/include
	rm -fr usr/info
	rm -fr usr/lib*/cmake
	rm -fr usr/lib*/gtk*/include
	rm -fr usr/lib*/pkgconfig
	rm -fr usr/lib*/python2*
	rm -fr usr/lib*/systemd
	rm -fr usr/lib/python*/site-packages/*-info
	rm -fr usr/libexec/installed-tests
	rm -fr usr/man
	rm -fr usr/share/*/translations
	rm -fr usr/share/aclocal
	rm -fr usr/share/appdata
	rm -fr usr/share/bash-completion
	rm -fr usr/share/cmake
	rm -fr usr/share/devhelp
	rm -fr usr/share/doc
	rm -fr usr/share/fish
	rm -fr usr/share/gdb
	rm -fr usr/share/gettext
	rm -fr usr/share/gir-[0-9]*
	rm -fr usr/share/glib-[0-9]*/codegen
	rm -fr usr/share/glib-[0-9]*/gdb
	rm -fr usr/share/gtk-doc
	rm -fr usr/share/help
	rm -fr usr/share/icons/HighContrast
	rm -fr usr/share/icons/hicolor/64x64
	rm -fr usr/share/icons/hicolor/72x72
	rm -fr usr/share/icons/hicolor/96x96
	rm -fr usr/share/icons/hicolor/192x192
	rm -fr usr/share/info
	rm -fr usr/share/installed-tests
	rm -fr usr/share/locale
	rm -fr usr/share/man
	rm -fr usr/share/metainfo
	rm -fr usr/share/pkgconfig
	rm -fr usr/share/sounds
	rm -fr usr/share/themes/HighContrast
	rm -fr usr/share/vala
	rm -fr usr/share/xdg-terminals
	rm -fr usr/share/zsh
	rm -fr usr/src
	rm -fr var/lib/pkgtools/douninst.sh
	rm -fr var/lib/pkgtools/removed_packages
	rm -fr var/lib/pkgtools/removed_scripts
	rm -fr var/lib/pkgtools/setup
	rm -fr var/log/pkgtools
	rm -fr var/log/setup
	rm -fr var/man

	find . \( \
		-name '*.a' -o \
		-name '*.c' -o \
		-name '*.cpp' -o \
		-name '*.cmake' -o \
		-name '*.deps' -o \
		-name '*.gir' -o \
		-name '*.h' -o \
		-name '*.hpp' -o \
		-name '*.la' -o \
		-name '*.m4' -o \
		-name '*.make' -o \
		-name '*.mk' -o \
		-name '*.o' -o \
		-name '*.pc' -o \
		-name '*.prl' -o \
		-name '*.pyi' -o \
		-name '*.spec' -o \
		-name '*.vapi' -o \
		-name 'ABOUT-NLS' -o \
		-name 'AUTHORS*' -o \
		-name 'ChangeLog*' -o \
		-name 'COPYING*' -o \
		-name 'HACKING*' -o \
		-name 'INSTALL*' -o \
		-name 'LICENSE*' -o \
		-name 'NEWS*' -o \
		-name 'NOTICE*' -o \
		-name 'README*' -o \
		-name 'THANKS*' -o \
		-name 'TODO*' \
	\) -delete

	find usr/ -type d -empty -delete

	find usr/share/mime/ -mindepth 1 -maxdepth 1 -not -name packages -exec rm -rf '{}' \;

	list_elf_files '*ELF*@(executable|shared object)*' "$1" | xargs -0 -r strip --strip-debug --strip-unneeded $STRIP_SECTIONS
} > /dev/null 2>&1

strip_hard_exec() {
	list_elf_files '*ELF*executable*' "$1" | xargs -0 -r strip --strip-all --strip-section-headers -R .eh_frame* $STRIP_SECTIONS
} > /dev/null 2>&1

strip_hard_all() {
	local executables shared_objects
	executables=$(mktemp)
	shared_objects=$(mktemp)

	split_elf_files "$executables" "$shared_objects" "$1"

	xargs -0 -r strip --strip-all --strip-section-headers -R .eh_frame* $STRIP_SECTIONS < "$executables"
	xargs -0 -r strip --strip-all $STRIP_SECTIONS < "$shared_objects"

	rm -f "$executables" "$shared_objects"
} > /dev/null 2>&1

if [[ ${BASH_SOURCE[0]} == "$0" && -n $1 ]]; then
	"$@"
fi
