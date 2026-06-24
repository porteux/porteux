#!/bin/bash

GenericStrip() {
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
	rm -fr usr/share/gir-1.0
	rm -fr usr/share/glib-2.0/codegen
	rm -fr usr/share/glib-2.0/gdb
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
	rm -fr usr/share/metainfo/
	rm -fr usr/share/pkgconfig
	rm -fr usr/share/sounds
	rm -fr usr/share/themes/HighContrast
	rm -fr usr/share/vala
	rm -fr usr/share/xdg-terminals
	rm -fr usr/share/zsh
	rm -fr usr/src
	rm -fr var/lib/pkgtools/douninst.sh/
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

	find usr/share/mime/ -mindepth 1 -maxdepth 1 -not -name packages -exec rm -rf '{}' \; 2>/dev/null

	find . | xargs file | grep -E -e "executable|shared object" | grep ELF | cut -f 1 -d : | xargs strip --strip-debug --strip-unneeded -R .comment* -R .note -R .note.ABI-tag -R .note.gnu.build-id -R .note.gnu.gold-version -R .note.GNU-stack 2> /dev/null
} > /dev/null 2>&1

AggressiveStrip() {
	[[ $(strip --help | grep "strip-section-headers") ]] && stripSectionHeaders="--strip-section-headers"
	find . | xargs file | grep -E -e "executable" | grep ELF | cut -f 1 -d : | xargs strip --strip-all ${stripSectionHeaders} -R .comment* -R .eh_frame* -R .note -R .note.ABI-tag -R .note.gnu.build-id -R .note.gnu.gold-version -R .note.GNU-stack 2> /dev/null
} > /dev/null 2>&1

AggressiveStripAll() {
	[[ $(strip --help | grep "strip-section-headers") ]] && stripSectionHeaders="--strip-section-headers"
	find . | xargs file | grep -E -e "executable|shared object" | grep ELF | cut -f 1 -d : | xargs strip --strip-all ${stripSectionHeaders} -R .comment* -R .eh_frame* -R .note -R .note.ABI-tag -R .note.gnu.build-id -R .note.gnu.gold-version -R .note.GNU-stack 2> /dev/null
} > /dev/null 2>&1

if [ "$1" ]; then
	"$1"
fi