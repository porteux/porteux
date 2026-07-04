#!/bin/bash

MODULE_NAME="003-cinnamon"

source "$PWD/../builder-utils/set-flags.sh"

set_flags "$MODULE_NAME"

source "$BUILDER_UTILS_PATH/cache-files.sh"
source "$BUILDER_UTILS_PATH/generic-strip.sh"
source "$BUILDER_UTILS_PATH/helper.sh"
source "$BUILDER_UTILS_PATH/slackware-repository.sh"

elevate_if_needed "$0" "$@"

if [[ ${ALLOWTEST:-no} == no ]]; then
	export TESTRELEASES="master.|alpha|beta|rc[0-9]|unstable"
else
	export TESTRELEASES="master."
fi

LATESTVERSION=$(curl -s https://github.com/linuxmint/cinnamon/tags/ | grep "/linuxmint/cinnamon/releases/tag/" | grep -oP "(?<=/linuxmint/cinnamon/releases/tag/)[^\"]+" | uniq | grep -Ev "cjs-|${TESTRELEASES}" | sort -Vr | head -1)
echo -e "Building Cinnamon ${LATESTVERSION} based on Slackware ${SLACKWARE_VERSION} ${ARCH}...\n"
MODULE_NAME="$MODULE_NAME-${LATESTVERSION}"

### create module folder

mkdir -p $MODULE_PATH/packages > /dev/null 2>&1
cd $MODULE_PATH

### download packages from slackware repository

bash $SCRIPT_PATH/download-packages.sh

### packages outside slackware repository

export SESSIONTEMPLATE=cinnamon
export ICONTHEME=Yaru-blue

# required by lightdm
installpkg $MODULE_PATH/packages/libxklavier*.txz || exit 1

# cinnamon common
for package in \
	audacious \
	audacious-plugins \
	ffmpegthumbnailer \
	lightdm \
	lightdm-gtk-greeter \
	vte \
	libnma \
	network-manager-applet \
	mate-polkit \
	gsound \
	zenity \
	libpeas \
	libgxps \
	gtksourceview4 \
	gnome-screenshot \
; do
bash $SCRIPT_PATH/../common/${package}/${package}.SlackBuild || exit 1
installpkg $MODULE_PATH/packages/${package}*.txz || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# required from now on
installpkg $MODULE_PATH/packages/aspell*.txz || exit 1
installpkg $MODULE_PATH/packages/colord*.txz || exit 1
installpkg $MODULE_PATH/packages/enchant*.txz || exit 1
installpkg $MODULE_PATH/packages/gspell*.txz || exit 1
installpkg $MODULE_PATH/packages/iso-codes*.txz || exit 1
installpkg $MODULE_PATH/packages/libappindicator*.txz || exit 1
installpkg $MODULE_PATH/packages/libdbusmenu*.txz || exit 1
installpkg $MODULE_PATH/packages/libgee*.txz || exit 1
installpkg $MODULE_PATH/packages/libgtop*.txz || exit 1
installpkg $MODULE_PATH/packages/libhandy*.txz || exit 1
installpkg $MODULE_PATH/packages/libindicator*.txz || exit 1
installpkg $MODULE_PATH/packages/libsoup*.txz || exit 1
installpkg $MODULE_PATH/packages/libspectre*.txz || exit 1
installpkg $MODULE_PATH/packages/libwnck3*.txz || exit 1
installpkg $MODULE_PATH/packages/python-six*.txz || exit 1

# required only for building
installpkg $MODULE_PATH/packages/libgsf*.txz || exit 1
rm $MODULE_PATH/packages/libgsf*.txz
installpkg $MODULE_PATH/packages/python-build*.txz || exit 1
rm $MODULE_PATH/packages/python-build*.txz
installpkg $MODULE_PATH/packages/python-flit-core*.txz || exit 1
rm $MODULE_PATH/packages/python-flit-core*.txz
installpkg $MODULE_PATH/packages/python-installer*.txz || exit 1
rm $MODULE_PATH/packages/python-installer*.txz
installpkg $MODULE_PATH/packages/python-pip*.txz || exit 1
rm $MODULE_PATH/packages/python-pip*.txz
installpkg $MODULE_PATH/packages/python-pyproject-hooks*.txz || exit 1
rm $MODULE_PATH/packages/python-pyproject-hooks*.txz
installpkg $MODULE_PATH/packages/python-wheel*.txz || exit 1
rm $MODULE_PATH/packages/python-wheel*.txz
installpkg $MODULE_PATH/packages/xtrans*.txz || exit 1
rm $MODULE_PATH/packages/xtrans*.txz

# cinnamon deps
for package in \
	python-tinycss2 \
	xdotool \
	python-pytz \
	libtimezonemap \
	python-setproctitle \
	python-ptyprocess \
	python-pam \
	libgnomekbd \
	cogl \
	clutter \
	caribou \
	python-pexpect \
	python-polib \
	python-xapp \
; do
bash $SCRIPT_PATH/deps/${package}/${package}.SlackBuild || exit 1
installpkg $MODULE_PATH/packages/${package}*.txz || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# required only for building
rm $MODULE_PATH/packages/cogl*.txz
rm $MODULE_PATH/packages/clutter*.txz

# cinnamon common extras
for package in \
	file-roller \
; do
bash $SCRIPT_PATH/../common/${package}/${package}.SlackBuild || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

# cinnamon extras
for package in \
	gnome-terminal \
	gnome-system-monitor \
	xapp-symbolic-icons \
	yaru-icon-theme \
; do
bash $SCRIPT_PATH/extras/${package}/${package}.SlackBuild || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

cd $MODULE_PATH
pip install pysass # required by cinnamon project

installpkg $MODULE_PATH/packages/mozjs*.txz || exit 1

# cinnamon packages
for package in \
	cjs \
	cinnamon-desktop \
	xapp \
	cinnamon-session \
	cinnamon-settings-daemon \
	cinnamon-menus \
	cinnamon-control-center \
	muffin \
	nemo \
	nemo-extensions \
	cinnamon-screensaver \
	cinnamon \
	xreader \
	xviewer \
	xed \
; do
bash $SCRIPT_PATH/cinnamon/${package}/${package}.SlackBuild || exit 1
installpkg $MODULE_PATH/packages/${package}*.txz || exit 1
find $MODULE_PATH -mindepth 1 -maxdepth 1 ! \( -name "packages" \) -exec rm -rf '{}' \; 2>/dev/null
done

### packages that require specific stripping

strip_package gettext-tools \
	usr/bin/msgfmt \
	usr/lib$SYSTEM_BITS/libgettextlib* \
	usr/lib$SYSTEM_BITS/libgettextsrc*
	
strip_package iso-codes \
	usr/share/xml/iso-codes/iso_3166-1.xml \
	usr/share/xml/iso-codes/iso_3166.xml \
	usr/share/xml/iso-codes/iso_639-2.xml \
	usr/share/xml/iso-codes/iso_639-3.xml \
	usr/share/xml/iso-codes/iso_639.xml \
	usr/share/xml/iso-codes/iso_639_3.xml

current_package=ibus
mkdir $MODULE_PATH/${current_package} && cd $MODULE_PATH/${current_package}
mv $MODULE_PATH/packages/${current_package}*.txz .
package_file_name=$(ls * -a | rev | cut -d . -f 2- | rev)
ROOT=./ installpkg ${current_package}*.txz && rm ${current_package}*.txz
rm usr/share/applications/org.freedesktop.IBus.Setup.desktop
rm -fr usr/share/ibus/dicts
rm -fr var/lib/pkgtools
rm -f var/log/packages
rm -fr var/log/pkgtools
rm -f var/log/setup
rm -f var/log/scripts
mkdir ${current_package}-stripped
rsync -av * ${current_package}-stripped/ --exclude=${current_package}-stripped/
cd ${current_package}-stripped
makepkg ${MAKEPKG_FLAGS} $MODULE_PATH/packages/${package_file_name}_stripped.txz > /dev/null 2>&1
rm -fr $MODULE_PATH/${current_package} && cd $MODULE_PATH

### fake root

cd $MODULE_PATH/packages && ROOT=./ installpkg *.t?z
rm *.t?z

### install additional packages, including porteux utils

install_additional_packages

### fix some .desktop files

sed -i "s|image/avif|image/avif;image/jxl|g" $MODULE_PATH/packages/usr/share/applications/xviewer.desktop

### disable some services

echo "Hidden=true" >> $MODULE_PATH/packages/etc/xdg/autostart/cinnamon-settings-daemon-color.desktop

### TEMPORARY: remove some xed plugins that doesn't work with new pygobject 3.52.x

rm -fr $MODULE_PATH/packages/usr/lib${SYSTEM_BITS}/xed/plugins/bracket-complete
rm -fr $MODULE_PATH/packages/usr/lib${SYSTEM_BITS}/xed/plugins/joinlines
rm -fr $MODULE_PATH/packages/usr/lib${SYSTEM_BITS}/xed/plugins/open-uri-context-menu
rm -fr $MODULE_PATH/packages/usr/lib${SYSTEM_BITS}/xed/plugins/textsize
rm $MODULE_PATH/packages/usr/lib${SYSTEM_BITS}/xed/plugins/joinlines.plugin
rm $MODULE_PATH/packages/usr/lib${SYSTEM_BITS}/xed/plugins/sort.plugin
rm $MODULE_PATH/packages/usr/lib${SYSTEM_BITS}/xed/plugins/textsize.plugin

### copy build files to 05-devel

copy_to_devel

### copy language files to 08-multilanguage

copy_to_multilanguage

### module clean up

cd $MODULE_PATH/packages/

{
rm etc/xdg/autostart/blueman.desktop
rm usr/bin/js[0-9]*
rm usr/lib${SYSTEM_BITS}/libappindicator.*
rm usr/lib${SYSTEM_BITS}/libdbusmenu-gtk.*
rm usr/lib${SYSTEM_BITS}/libindicator.*
rm usr/libexec/indicator-loader

rm -fr etc/dbus-1/system.d
rm -fr etc/dconf
rm -fr etc/geoclue
rm -fr etc/opt
rm -fr usr/lib${SYSTEM_BITS}/aspell
rm -fr usr/lib${SYSTEM_BITS}/glade
rm -fr usr/lib${SYSTEM_BITS}/graphene-1.0
rm -fr usr/lib${SYSTEM_BITS}/gtk-2.0
rm -fr usr/lib*/python*/site-packages/pip*
rm -fr usr/lib*/python*/site-packages/psutil/tests
rm -fr usr/share/gdm
rm -fr usr/share/glade/pixmaps
rm -fr usr/share/gnome
rm -fr usr/share/gtksourceview-2.0
rm -fr usr/share/gtksourceview-3.0
rm -fr usr/share/libdbusmenu
rm -fr usr/share/pixmaps
rm -fr usr/share/Thunar
rm -fr var/lib/AccountsService

[ "$SYSTEM_BITS" == 64 ] && find usr/lib/ -mindepth 1 -maxdepth 1 ! \( -name "python*" \) -exec rm -rf '{}' \; 2>/dev/null
find usr/share/cinnamon/faces -mindepth 1 -maxdepth 1 ! \( -name "user-generic*" \) -exec rm -rf '{}' \; 2>/dev/null
find usr/share/cinnamon/thumbnails/cursors -mindepth 1 -maxdepth 1 ! \( -name "Adwaita*" -o -name "Paper*" -o -name "unknown*" -o -name "Yaru*" \) -exec rm -rf '{}' \; 2>/dev/null
} >/dev/null 2>&1

mv $MODULE_PATH/packages/usr/lib${SYSTEM_BITS}/libmozjs-* $MODULE_PATH/
mv $MODULE_PATH/packages/usr/lib${SYSTEM_BITS}/libvte-* $MODULE_PATH/
generic_strip
aggressive_strip_all
mv $MODULE_PATH/libvte-* $MODULE_PATH/packages/usr/lib${SYSTEM_BITS}
mv $MODULE_PATH/libmozjs-* $MODULE_PATH/packages/usr/lib${SYSTEM_BITS}

### copy cache files

prepare_files_for_cache_de

### generate cache files

generate_caches_de

### finalize

finalize
