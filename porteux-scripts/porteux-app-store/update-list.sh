#!/bin/bash

ls -d */* | sed 's|*||g' > porteux-app-store-list
ls | xargs -n 1 basename | sed 's|*||g' >> porteux-app-store-list
