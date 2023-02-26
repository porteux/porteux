#!/bin/bash

LOCAL_PATH='/opt/porteux-scripts/porteux-app-store'

if [ `whoami` != root ]; then
	echo "Please enter root's password below:"
	/opt/porteux-scripts/xorg/psu "$LOCAL_PATH/porteux-app-store-live.sh"
	exit 0
fi

BASE_GITHUB_URL="https://raw.githubusercontent.com"
USER="porteux"
REPO="porteux"
FOLDER="porteux-scripts/porteux-app-store"
LIST_FILE="porteux-app-store-list"
MAX_AGE_HOURS=6
FILE_DOWNLOADED=0

update_files(){
    /opt/porteux-scripts/gtkprogress.py -w "PorteuX App Store" -m "Updating files..." -t " " &
	prog=$!

    download_list

    if [ $LIST_DOWNLOADED ]; then
        download_files "$LOCAL_PATH/$LIST_FILE"
        copy_icons
    fi

    kill ${prog} > /dev/null 2>&1
}

download_list(){
    echo "Downloading list file..."
    echo "$BASE_GITHUB_URL/$USER/$REPO/main/$FOLDER/$LIST_FILE"
    if wget -N "$BASE_GITHUB_URL/$USER/$REPO/main/$FOLDER/$LIST_FILE" -P "$LOCAL_PATH"; then
        LIST_DOWNLOADED=1
    fi
        echo "Error downloading list file"
}

download_files(){
    while read -r file_name; do
        if [ $file_name = porteux-app-store-live.sh ]; then
            continue
        fi
        destination_directory=$(dirname "$LOCAL_PATH/$file_name")
        mkdir -p "$destination_directory" > /dev/null 2>&1
        file_directory=$(dirname "$file_name")
        wget -N "$BASE_GITHUB_URL/$USER/$REPO/main/$FOLDER/$file_name" -P "$LOCAL_PATH/$file_directory"
        chmod -R 755 ${LOCAL_PATH}/${file_name} > /dev/null 2>&1
    done < "$1"
}

copy_icons(){
    chmod 644 ${LOCAL_PATH}/icons/* > /dev/null 2>&1
    cp ${LOCAL_PATH}/icons/* /usr/share/pixmaps > /dev/null 2>&1
}

if [ ! -f "$LOCAL_PATH/$LIST_FILE" ]; then
    update_files
else
    file_time=$(stat -c %Y "$LOCAL_PATH/$LIST_FILE")
    current_time=$(date +%s)
    time_diff=$((current_time - file_time))

    max_age_seconds=$((MAX_AGE_HOURS * 3600))

    if [ $time_diff -gt $max_age_seconds ]; then
        update_files
    fi
fi

# run app store
"$LOCAL_PATH/porteux-app-store.py"
