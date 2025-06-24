#!/bin/bash

GenericStrip() {
	rm -R etc/bash_completion*
	rm -R etc/logrotate.d
	rm -R usr/doc
	rm -R usr/include
	rm -R usr/info
	rm -R usr/lib*/cmake
	rm -R usr/lib*/gnome-keyring
	rm -R usr/lib*/gtk*/include
	rm -R usr/lib*/pkgconfig
	rm -R usr/lib*/python2*
	rm -R usr/lib*/systemd
	rm -R usr/lib/python*/site-packages/*-info
	rm -R usr/man
	rm -R usr/share/*/translations
	rm -R usr/share/aclocal
	rm -R usr/share/bash-completion
	rm -R usr/share/cmake
	rm -R usr/share/devhelp
	rm -R usr/share/doc
	rm -R usr/share/gdb
	rm -R usr/share/gir-1.0
	rm -R usr/share/gnome-control-center
	rm -R usr/share/gtk-doc
	rm -R usr/share/help
	rm -R usr/share/icons/HighContrast
	rm -R usr/share/icons/hicolor/64x64
	rm -R usr/share/icons/hicolor/72x72
	rm -R usr/share/icons/hicolor/96x96
	rm -R usr/share/icons/hicolor/192x192
	rm -R usr/share/info
	rm -R usr/share/installed-tests
	rm -R usr/share/locale
	rm -R usr/share/man
	rm -R usr/share/metainfo/
	rm -R usr/share/pkgconfig
	rm -R usr/share/sounds
	rm -R usr/share/themes/HighContrast
	rm -R usr/share/vala
	rm -R usr/src
	rm -R var/lib/pkgtools/douninst.sh/
	rm -R var/lib/pkgtools/setup
	rm -R var/log/pkgtools
	rm -R var/log/setup
	rm -R var/man
	
	rm usr/share/applications/org.gnome.Vte*.desktop
	rm usr/share/pixmaps/*.xpm
	rm var/log/removed_packages
	rm var/log/removed_scripts
	rm var/log/removed_uninstall_scripts

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
	
	find . | xargs file | egrep -e "executable|shared object" | grep ELF | cut -f 1 -d : | xargs strip --strip-debug --strip-unneeded -R .comment -R .jcr -R .note -R .note.ABI-tag -R .note.gnu.build-id -R .note.gnu.gold-version -R .note.GNU-stack -R .note.gnu.property 2> /dev/null
}

AggressiveStrip() {
	find . | xargs file | egrep -e "executable" | grep ELF | cut -f 1 -d : | xargs strip --strip-all --strip-section-headers -R .comment -R .eh_frame -R .eh_frame_hdr -R .eh_frame_ptr -R .jcr -R .note -R .note.ABI-tag -R .note.gnu.build-id -R .note.gnu.gold-version -R .note.GNU-stack -R .note.gnu.property 2> /dev/null
}

AggressiveStripAll() {
	find . | xargs file | egrep -e "executable|shared object" | grep ELF | cut -f 1 -d : | xargs strip --strip-all --strip-section-headers -R .comment -R .eh_frame -R .eh_frame_hdr -R .eh_frame_ptr -R .jcr -R .note -R .note.ABI-tag -R .note.gnu.build-id -R .note.gnu.gold-version -R .note.GNU-stack -R .note.gnu.property 2> /dev/null
}

if [ "$1" ]; then
	"$1"
fi