#!/bin/bash

if [ "$#" -lt 2 ]; then
    echo "Usage:   $0 [input directory] [output file path] [optional: --activate-module]"
    exit 1
fi

INPUT_DIR=$(readlink -f "$1")
OUTPUT_FILE_PATH=$(readlink -f "$2")
if [ -n "$OUTPUT_FILE_PATH" ]; then
    MODULE_FILE_NAME="${OUTPUT_FILE_PATH##*/}"
else
    MODULE_FILE_NAME="${2##*/}"
fi
OUTPUT_DIR=${OUTPUT_FILE_PATH%/*}

if [ ! -w "$OUTPUT_DIR" ]; then
    dir2xzm "$INPUT_DIR" -o="/tmp/$MODULE_FILE_NAME" -q &>/dev/null || exit 1
    echo "Destination ${2%/*} is not writable. New module placed in /tmp and not activated."
elif [ ! -f "$OUTPUT_FILE_PATH" ]; then
    dir2xzm "$INPUT_DIR" -o="$OUTPUT_FILE_PATH" -q &>/dev/null || exit 1
    echo "Module placed in $OUTPUT_DIR"
    if [[ "$@" == *"--activate-module"* ]] && [ ! -d "/mnt/live/memory/images/$MODULE_FILE_NAME" ]; then
        activate "$OUTPUT_FILE_PATH" -q &>/dev/null
    fi
else
    dir2xzm "$INPUT_DIR" -o="/tmp/$MODULE_FILE_NAME" -q &>/dev/null || exit 1
    echo "Module $MODULE_FILE_NAME was already in $OUTPUT_DIR. New module placed in /tmp and not activated."
fi
