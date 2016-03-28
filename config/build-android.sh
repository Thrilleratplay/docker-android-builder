#!/bin/bash
cd /root/android

repo init -u $REPO -b $BRANCH
repo sync -f

# Uncomment for Cyanogenmod
# vendor/cm/get-prebuilts

source build/envsetup.sh

if [ -z "$DEVICE" ]; then
  brunch
else
  DEVICE_LC=$(echo $DEVICE | tr '[A-Z]' '[a-z]')
  brunch $DEVICE
fi
