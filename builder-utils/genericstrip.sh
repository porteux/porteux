#!/bin/sh

GenericStrip() {
	if [ "$1" ]; then
		CURRENTDIR="$1"
	else
		CURRENTDIR="$PWD"
	fi

	rm -R "$CURRENTDIR"/usr/doc
	rm -R "$CURRENTDIR"/usr/include
	rm -R "$CURRENTDIR"/usr/man
	rm -R "$CURRENTDIR"/usr/src
	rm -R "$CURRENTDIR"/usr/info
	rm -R "$CURRENTDIR"/usr/share/aclocal
	rm -R "$CURRENTDIR"/usr/share/bash-completion
	rm -R "$CURRENTDIR"/usr/share/cmake
	rm -R "$CURRENTDIR"/usr/share/devhelp
	rm -R "$CURRENTDIR"/usr/share/doc
	rm -R "$CURRENTDIR"/usr/share/gdb
	rm -R "$CURRENTDIR"/usr/share/gir-1.0
	rm -R "$CURRENTDIR"/usr/share/gnome-control-center
	rm -R "$CURRENTDIR"/usr/share/gtk-doc
	rm -R "$CURRENTDIR"/usr/share/help
	rm -R "$CURRENTDIR"/usr/share/icons/HighContrast
	rm -R "$CURRENTDIR"/usr/share/icons/hicolor/64x64
	rm -R "$CURRENTDIR"/usr/share/icons/hicolor/72x72
	rm -R "$CURRENTDIR"/usr/share/icons/hicolor/96x96
	rm -R "$CURRENTDIR"/usr/share/icons/hicolor/128x128
	rm -R "$CURRENTDIR"/usr/share/icons/hicolor/192x192
	rm -R "$CURRENTDIR"/usr/share/icons/hicolor/256x256
	rm -R "$CURRENTDIR"/usr/share/icons/hicolor/512x512
	rm -R "$CURRENTDIR"/usr/share/locale
	rm -R "$CURRENTDIR"/usr/share/man
	rm -R "$CURRENTDIR"/usr/share/pkgconfig
	rm -R "$CURRENTDIR"/usr/share/sounds
	rm -R "$CURRENTDIR"/usr/share/themes/HighContrast
	rm -R "$CURRENTDIR"/usr/share/vala
	rm -R "$CURRENTDIR"/usr/share/xdg-desktop-portal
	rm -R "$CURRENTDIR"/usr/share/*/translations
	rm -R "$CURRENTDIR"/usr/lib/pkgconfig
	rm -R "$CURRENTDIR"/usr/lib64/pkgconfig
	rm -R "$CURRENTDIR"/usr/lib/cmake
	rm -R "$CURRENTDIR"/usr/lib/systemd
	rm -R "$CURRENTDIR"/usr/lib64/cmake
	rm -R "$CURRENTDIR"/usr/lib64/gnome-keyring
	rm -R "$CURRENTDIR"/usr/lib64/gtk-2.0/include
	rm -R "$CURRENTDIR"/usr/lib64/python2.7
	rm -R "$CURRENTDIR"/var/log/pkgtools
	rm -R "$CURRENTDIR"/var/log/setup
	rm -R "$CURRENTDIR"/var/lib/pkgtools/douninst.sh
	rm -R "$CURRENTDIR"/var/lib/pkgtools/setup
	
	rm "$CURRENTDIR"/usr/bin/gtk-demo
	rm "$CURRENTDIR"/usr/bin/gtk2-demo
	rm "$CURRENTDIR"/usr/bin/gtk3-demo
	rm "$CURRENTDIR"/usr/bin/gtk3-demo-application
	rm "$CURRENTDIR"/usr/share/applications/gtk3-demo.desktop
	rm "$CURRENTDIR"/usr/share/applications/gtk3-icon-browser.desktop
	rm "$CURRENTDIR"/usr/share/applications/gtk3-widget-factory.desktop
	rm "$CURRENTDIR"/usr/share/pixmaps/*.xpm
	rm "$CURRENTDIR"/var/log/removed_packages
	rm "$CURRENTDIR"/var/log/removed_scripts
	rm "$CURRENTDIR"/var/log/removed_uninstall_scripts

	find "$CURRENTDIR" -name 'AUTHORS*' -delete
	find "$CURRENTDIR" -name 'COPYING*' -delete
	find "$CURRENTDIR" -name 'README*' -delete
	find "$CURRENTDIR" -name 'LICENSE*' -delete
	find "$CURRENTDIR" -name '*.a' -delete
	find "$CURRENTDIR" -name '*.c' -delete
	find "$CURRENTDIR" -name '*.cmake' -delete
	find "$CURRENTDIR" -name '*.deps' -delete
	find "$CURRENTDIR" -name '*.gir' -delete
	find "$CURRENTDIR" -name '*.h' -delete
	find "$CURRENTDIR" -name '*.la' -delete
	find "$CURRENTDIR" -name '*.m4' -delete
	find "$CURRENTDIR" -name '*.o' -delete
	find "$CURRENTDIR" -name '*.pc' -delete
	find "$CURRENTDIR" -name '*.prl' -delete
	find "$CURRENTDIR" -name '*.vapi' -delete
	
	find "$CURRENTDIR"/usr/share/mime/ -mindepth 1 -maxdepth 1 -not -name packages -exec rm -rf '{}' \; 2>/dev/null

	find "$CURRENTDIR" | xargs file | grep "executable" | grep ELF | cut -f 1 -d : | xargs strip -S --strip-unneeded --remove-section=.note.gnu.gold-version --remove-section=.comment --remove-section=.note --remove-section=.note.gnu.build-id --remove-section=.note.ABI-tag 2> /dev/null

	find "$CURRENTDIR" | xargs file | grep "shared object" | grep ELF | cut -f 1 -d : | xargs strip -S --strip-unneeded --remove-section=.note.gnu.gold-version --remove-section=.comment --remove-section=.note --remove-section=.note.gnu.build-id --remove-section=.note.ABI-tag 2> /dev/null
}
