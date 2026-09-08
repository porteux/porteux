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

create_module() {
    dir2xzm "$INPUT_DIR" -o="$1" -q >/dev/null || { echo "Error: could not create module '$1'." >&2; exit 1; }
}

if [ ! -w "$OUTPUT_DIR" ]; then
    create_module "/tmp/$MODULE_FILE_NAME"
    echo "Destination ${2%/*} is not writable. New module placed in /tmp and not activated."
elif [ ! -f "$OUTPUT_FILE_PATH" ]; then
    create_module "$OUTPUT_FILE_PATH"
    if [[ "$@" == *"--activate-module"* ]] && [ ! -d "/mnt/live/memory/images/$MODULE_FILE_NAME" ]; then
        activate "$OUTPUT_FILE_PATH" -q >/dev/null || { echo "Module placed in $OUTPUT_DIR, but it could not be activated." >&2; exit 1; }
    fi
    echo "Module placed in $OUTPUT_DIR"
else
    create_module "/tmp/$MODULE_FILE_NAME"
    echo "Module $MODULE_FILE_NAME was already in $OUTPUT_DIR. New module placed in /tmp and not activated."
fi
