#!/bin/bash

if [ `whoami` != root ]; then
	echo "Please enter root's password below:"
	/opt/porteux-scripts/xorg/psu $(realpath "$0")
	exit 0
fi

BASE_GITHUB_URL="https://raw.githubusercontent.com"
USER="porteux"
REPO="porteux"
FOLDER="porteux-scripts/porteux-app-store"
REPO_FOLDER_PATH="$BASE_GITHUB_URL/$USER/$REPO/main/$FOLDER"
APP_STORE_FILE="porteux-app-store.py"
MAX_AGE_HOURS=6
LOCAL_PATH=$(dirname "$0")

update_app(){
    /opt/porteux-scripts/gtkprogress.py -w "PorteuX App Store" -m "Updating App Store..." -t " " & prog=$!

    echo "Updating App Store..."
    echo "$APP_STORE_FILE"
    if wget -N "$REPO_FOLDER_PATH/$APP_STORE_FILE" -P "$LOCAL_PATH"; then
        LIST_DOWNLOADED=1
        chmod -R 755 "$LOCAL_PATH/$APP_STORE_FILE" > /dev/null 2>&1
    else
        echo "Error updating App Store"
    fi

    kill ${prog} > /dev/null 2>&1
}

if [ ! -f "$LOCAL_PATH/$APP_STORE_FILE" ]; then
    update_app
else
    file_time=$(stat -c %Y "$LOCAL_PATH/$APP_STORE_FILE")
    current_time=$(date +%s)
    time_diff=$((current_time - file_time))

    max_age_seconds=$((MAX_AGE_HOURS * 3600))

    if [ $time_diff -gt $max_age_seconds ]; then
        update_app
    fi
fi 

# run app store
"$LOCAL_PATH/porteux-app-store.py"
