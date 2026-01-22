#!/bin/bash

DownloadFromSlackware() {
	echo -e "Building based on Slackware ${SLACKWAREVERSION} ${ARCH}...\n"

	sh $SCRIPTPATH/downloadPackages.sh $REPOSITORY || exit
}
