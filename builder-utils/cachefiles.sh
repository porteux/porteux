#!/bin/sh

PrepareFilesForCacheDE() {
    cp -r $PORTEUXBUILDERPATH/caches/ $PORTEUXBUILDERPATH/caches-bkp
    PrepareFilesForCache
}

PrepareFilesForCache() {
	# ldconfig to fix/update broken symlinks
	ldconfig -r $MODULEPATH/packages/

	# copy mime packages to build /usr/share/mime/mime.cache
	mkdir -p $PORTEUXBUILDERPATH/caches/mime/packages > /dev/null 2>&1
	cp $MODULEPATH/packages/usr/share/mime/packages/* $PORTEUXBUILDERPATH/caches/mime/packages > /dev/null 2>&1

	# copy desktop files to build /usr/share/applications/mimeinfo.cache
	mkdir $PORTEUXBUILDERPATH/caches/applications > /dev/null 2>&1
	cp $MODULEPATH/packages/usr/share/applications/*.desktop $PORTEUXBUILDERPATH/caches/applications/ > /dev/null 2>&1

	# copy glib schemas to build /usr/share/glib-2.0/schemas/gschemas.compiled
	mkdir $PORTEUXBUILDERPATH/caches/schemas > /dev/null 2>&1
	cp $MODULEPATH/packages/usr/share/glib-2.0/schemas/*.xml $PORTEUXBUILDERPATH/caches/schemas/ > /dev/null 2>&1

	# copy gdkpixbuf files to build /usr/lib64/gdk-pixbuf-2.0/2.10.0/loaders.cache
	mkdir -p $PORTEUXBUILDERPATH/caches/gdk-pixbuf-2.0/2.10.0/loaders > /dev/null 2>&1
	cp $MODULEPATH/packages/usr/lib$SYSTEMBITS/gdk-pixbuf-2.0/2.10.0/loaders/*.so $PORTEUXBUILDERPATH/caches/gdk-pixbuf-2.0/2.10.0/loaders > /dev/null 2>&1
}

GenerateCachesDE() {
    GenerateCaches
    rm -r $PORTEUXBUILDERPATH/caches
    mv $PORTEUXBUILDERPATH/caches-bkp $PORTEUXBUILDERPATH/caches
}

GenerateCaches() {
	mkdir -p $MODULEPATH/packages/usr/share/mime > /dev/null 2>&1
	update-mime-database $PORTEUXBUILDERPATH/caches/mime
	cp $PORTEUXBUILDERPATH/caches/mime/mime.cache $MODULEPATH/packages/usr/share/mime/

	mkdir -p $MODULEPATH/packages/usr/share/applications > /dev/null 2>&1
	update-desktop-database $PORTEUXBUILDERPATH/caches/applications
	cp -r $PORTEUXBUILDERPATH/caches/applications/mimeinfo.cache $MODULEPATH/packages/usr/share/applications/

	mkdir -p $MODULEPATH/packages/usr/share/glib-2.0/schemas > /dev/null 2>&1
	glib-compile-schemas $PORTEUXBUILDERPATH/caches/schemas
	cp -r $PORTEUXBUILDERPATH/caches/schemas/gschemas.compiled $MODULEPATH/packages/usr/share/glib-2.0/schemas/

	mkdir -p $MODULEPATH/packages/usr/lib$SYSTEMBITS/gdk-pixbuf-2.0/2.10.0 > /dev/null 2>&1
	gdk-pixbuf-query-loaders $PORTEUXBUILDERPATH/caches/gdk-pixbuf-2.0/2.10.0/loaders/*.so > $MODULEPATH/packages/usr/lib$SYSTEMBITS/gdk-pixbuf-2.0/2.10.0/loaders.cache
	sed -i "s|$PORTEUXBUILDERPATH/caches|/usr/lib$SYSTEMBITS|g" $MODULEPATH/packages/usr/lib$SYSTEMBITS/gdk-pixbuf-2.0/2.10.0/loaders.cache
}
