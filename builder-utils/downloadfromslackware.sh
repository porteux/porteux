#!/bin/sh

DownloadFromSlackware() {
	echo -e "Building based on Slackware ${SLACKWAREVERSION} ${ARCH}...\n"

	if [ $SLACKWAREVERSION != "current" ]; then
		sh $SCRIPTPATH/downloadPackages.sh $PATCHREPOSITORY || exit
	fi

	sh $SCRIPTPATH/downloadPackages.sh $REPOSITORY || exit
}
