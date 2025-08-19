#!/bin/bash

GenericStrip() {
	rm usr/share/pixmaps/*.xpm
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
	rm -fr usr/share/bash-completion
	rm -fr usr/share/cmake
	rm -fr usr/share/devhelp
	rm -fr usr/share/doc
	rm -fr usr/share/fish
	rm -fr usr/share/gdb
	rm -fr usr/share/gir-1.0
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
	rm -fr usr/share/zsh
	rm -fr usr/src
	rm -fr var/lib/pkgtools/douninst.sh/
	rm -fr var/lib/pkgtools/setup
	rm -fr var/log/pkgtools
	rm -fr var/log/setup
	rm -fr var/man

	find . -name '*.a' -delete
	find . -name '*.c' -delete
	find . -name '*.cmake' -delete
	find . -name '*.deps' -delete
	find . -name '*.gir' -delete
	find . -name '*.h' -delete
	find . -name '*.la' -delete
	find . -name '*.m4' -delete
	find . -name '*.o' -delete
	find . -name '*.pc' -delete
	find . -name '*.prl' -delete
	find . -name '*.vapi' -delete
	find . -name 'AUTHORS*' -delete
	find . -name 'COPYING*' -delete
	find . -name 'LICENSE*' -delete
	find . -name 'README*' -delete

	find usr/ -type d -empty -delete

	find usr/share/mime/ -mindepth 1 -maxdepth 1 -not -name packages -exec rm -rf '{}' \; 2>/dev/null

	find . | xargs file | egrep -e "executable|shared object" | grep ELF | cut -f 1 -d : | xargs strip --strip-debug --strip-unneeded -R .comment* -R .note -R .note.ABI-tag -R .note.gnu.build-id -R .note.gnu.gold-version -R .note.GNU-stack 2> /dev/null
} > /dev/null 2>&1

AggressiveStrip() {
	[[ $(strip --help | grep "strip-section-headers") ]] && stripSectionHeaders="--strip-section-headers"
	find . | xargs file | egrep -e "executable" | grep ELF | cut -f 1 -d : | xargs strip --strip-all ${stripSectionHeaders} -R .comment* -R .eh_frame* -R .note -R .note.ABI-tag -R .note.gnu.build-id -R .note.gnu.gold-version -R .note.GNU-stack 2> /dev/null
} > /dev/null 2>&1

AggressiveStripAll() {
	[[ $(strip --help | grep "strip-section-headers") ]] && stripSectionHeaders="--strip-section-headers"
	find . | xargs file | egrep -e "executable|shared object" | grep ELF | cut -f 1 -d : | xargs strip --strip-all ${stripSectionHeaders} -R .comment* -R .eh_frame* -R .note -R .note.ABI-tag -R .note.gnu.build-id -R .note.gnu.gold-version -R .note.GNU-stack 2> /dev/null
} > /dev/null 2>&1

if [ "$1" ]; then
	"$1"
fi