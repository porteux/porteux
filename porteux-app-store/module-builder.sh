#!/bin/bash

if [ "$#" -lt 2 ]; then
    echo "Usage:   $0 [input directory] [output file path] [optional: --activate-module]"
    exit 1
fi

INPUTDIR=$(readlink -f "$1")
OUTPUTFILEPATH=$(readlink -f "$2")
if [ -n "$OUTPUTFILEPATH" ]; then
    MODULEFILENAME="${OUTPUTFILEPATH##*/}"
else
    MODULEFILENAME="${2##*/}"
fi
OUTPUTDIR=${OUTPUTFILEPATH%/*}

if [ ! -w "$OUTPUTDIR" ]; then
    dir2xzm "$INPUTDIR" -o="/tmp/$MODULEFILENAME" -q &>/dev/null || exit 1
    echo "Destination ${2%/*} is not writable. New module placed in /tmp and not activated."
elif [ ! -f "$OUTPUTFILEPATH" ]; then
    dir2xzm "$INPUTDIR" -o="$OUTPUTFILEPATH" -q &>/dev/null || exit 1
    echo "Module placed in $OUTPUTDIR"
    if [[ "$@" == *"--activate-module"* ]] && [ ! -d "/mnt/live/memory/images/$MODULEFILENAME" ]; then
        activate "$OUTPUTFILEPATH" -q &>/dev/null
    fi
else
    dir2xzm "$INPUTDIR" -o="/tmp/$MODULEFILENAME" -q &>/dev/null || exit 1
    echo "Module $MODULEFILENAME was already in $OUTPUTDIR. New module placed in /tmp and not activated."
fi
