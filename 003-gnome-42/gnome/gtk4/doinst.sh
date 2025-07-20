config() {
	NEW="$1"
	OLD="$(dirname $NEW)/$(basename $NEW .new)"
	# If there's no config file by that name, mv it over:
	if [ ! -r $OLD ]; then
		mv $NEW $OLD
	elif [ "$(cat $OLD | md5sum)" = "$(cat $NEW | md5sum)" ]; then # toss the redundant copy
		rm $NEW
	fi
	# Otherwise, we leave the .new copy for the admin to consider...
}

chroot . rm -f /usr/share/icons/*/icon-theme.cache 1> /dev/null 2> /dev/null
chroot . /usr/bin/glib-compile-schemas /usr/share/glib-2.0/schemas/ 1> /dev/null 2> /dev/null
chroot . /usr/bin/gio-querymodules /usr/lib64/gtk-4.0/4.0.0/media 1> /dev/null 2> /dev/null
chroot . /usr/bin/gio-querymodules /usr/lib64/gtk-4.0/4.0.0/printbackends 1> /dev/null 2> /dev/null
