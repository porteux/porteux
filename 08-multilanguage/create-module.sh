#!/bin/bash

MODULE_NAME="08-multilanguage"

source "$PWD/../builder-utils/set-flags.sh"

set_flags "$MODULE_NAME"

source "$BUILDER_UTILS_PATH/helper.sh"

elevate_if_needed "$0" "$@"

echo -e "Building ${MODULE_NAME} based on Slackware ${SLACKWARE_VERSION} ${ARCH}...\n"

### create module folder

mkdir -p $MODULE_PATH/packages > /dev/null 2>&1
cd $MODULE_PATH || exit 1

### download packages from slackware repository

bash $SCRIPT_PATH/download-packages.sh || exit 1

### fake root

install_packages

### module clean up

{
rm $MODULE_PATH/packages/var/log/removed_packages
rm $MODULE_PATH/packages/var/log/removed_scripts
rm $MODULE_PATH/packages/var/log/removed_uninstall_scripts

rm -fr $MODULE_PATH/packages/usr/lib/
rm -fr $MODULE_PATH/packages/var/lib/pkgtools/douninst.sh
rm -fr $MODULE_PATH/packages/var/lib/pkgtools/setup
rm -fr $MODULE_PATH/packages/var/log/pkgtools
rm -fr $MODULE_PATH/packages/var/log/setup

find $MODULE_PATH/packages -type f -name '*.desktop' -exec rm -f {} +
} >/dev/null 2>&1

### finalize

finalize
