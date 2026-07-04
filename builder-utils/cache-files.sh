#!/bin/bash

prepare_files_for_cache_de() {
	mkdir -p $PORTEUX_BUILDER_PATH/caches > /dev/null 2>&1
	cp -r $PORTEUX_BUILDER_PATH/caches/ $PORTEUX_BUILDER_PATH/caches-bkp
	prepare_files_for_cache
}

prepare_files_for_cache() {
	# ldconfig to fix/update broken symlinks
	ldconfig -r $MODULE_PATH/packages/

	# copy mime packages to build /usr/share/mime/mime.cache
	mkdir -p $PORTEUX_BUILDER_PATH/caches/mime/packages > /dev/null 2>&1
	cp $MODULE_PATH/packages/usr/share/mime/packages/* $PORTEUX_BUILDER_PATH/caches/mime/packages > /dev/null 2>&1

	# copy desktop files to build /usr/share/applications/mimeinfo.cache
	mkdir $PORTEUX_BUILDER_PATH/caches/applications > /dev/null 2>&1
	cp $MODULE_PATH/packages/usr/share/applications/*.desktop $PORTEUX_BUILDER_PATH/caches/applications/ > /dev/null 2>&1

	# copy glib schemas to build /usr/share/glib-2.0/schemas/gschemas.compiled
	mkdir $PORTEUX_BUILDER_PATH/caches/schemas > /dev/null 2>&1
	cp $MODULE_PATH/packages/usr/share/glib-2.0/schemas/*.xml $PORTEUX_BUILDER_PATH/caches/schemas/ > /dev/null 2>&1

	# copy gdkpixbuf files to build /usr/lib$SYSTEM_BITS/gdk-pixbuf-2.0/2.10.0/loaders.cache
	mkdir -p $PORTEUX_BUILDER_PATH/caches/gdk-pixbuf-2.0/2.10.0/loaders > /dev/null 2>&1
	cp $MODULE_PATH/packages/usr/lib$SYSTEM_BITS/gdk-pixbuf-2.0/2.10.0/loaders/*.so $PORTEUX_BUILDER_PATH/caches/gdk-pixbuf-2.0/2.10.0/loaders > /dev/null 2>&1
}

generate_caches_de() {
	generate_caches
	rm -r $PORTEUX_BUILDER_PATH/caches
	mv $PORTEUX_BUILDER_PATH/caches-bkp $PORTEUX_BUILDER_PATH/caches
}

generate_caches() {
	if [ "$(ls -A $PORTEUX_BUILDER_PATH/caches/mime)" ]; then
		mkdir -p $MODULE_PATH/packages/usr/share/mime > /dev/null 2>&1
		update-mime-database $PORTEUX_BUILDER_PATH/caches/mime
		cp $PORTEUX_BUILDER_PATH/caches/mime/mime.cache $MODULE_PATH/packages/usr/share/mime/
	fi

	if [ "$(ls -A $PORTEUX_BUILDER_PATH/caches/applications)" ]; then
		mkdir -p $MODULE_PATH/packages/usr/share/applications > /dev/null 2>&1
		update-desktop-database $PORTEUX_BUILDER_PATH/caches/applications
		cp -r $PORTEUX_BUILDER_PATH/caches/applications/mimeinfo.cache $MODULE_PATH/packages/usr/share/applications/
	fi

	if [ "$(ls -A $PORTEUX_BUILDER_PATH/caches/schemas)" ]; then
		mkdir -p $MODULE_PATH/packages/usr/share/glib-2.0/schemas > /dev/null 2>&1
		glib-compile-schemas $PORTEUX_BUILDER_PATH/caches/schemas
		cp -r $PORTEUX_BUILDER_PATH/caches/schemas/gschemas.compiled $MODULE_PATH/packages/usr/share/glib-2.0/schemas/
	fi

	if [ "$(ls -A $PORTEUX_BUILDER_PATH/caches/gdk-pixbuf-2.0/2.10.0/loaders)" ]; then
		mkdir -p $MODULE_PATH/packages/usr/lib$SYSTEM_BITS/gdk-pixbuf-2.0/2.10.0 > /dev/null 2>&1
		gdk-pixbuf-query-loaders $PORTEUX_BUILDER_PATH/caches/gdk-pixbuf-2.0/2.10.0/loaders/*.so > $MODULE_PATH/packages/usr/lib$SYSTEM_BITS/gdk-pixbuf-2.0/2.10.0/loaders.cache
		sed -i "s|$PORTEUX_BUILDER_PATH/caches|/usr/lib$SYSTEM_BITS|g" $MODULE_PATH/packages/usr/lib$SYSTEM_BITS/gdk-pixbuf-2.0/2.10.0/loaders.cache
	fi
}
