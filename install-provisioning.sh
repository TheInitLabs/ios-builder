#!/usr/bin/env bash

# 2012 - Ben Clayton (benvium). Calvium Ltd
# Found at https://gist.github.com/2568707
#
# This script installs a .mobileprovision file without using Xcode. Unlike Xcode, it'll
# work over SSH.
#
# Requires Mac OS X (I'm using 10.7 and Xcode 4.3.2)
#
# IMPORTANT NOTE: You need to download and install the mpParse executable from http://idevblog.info/mobileprovision-files-structure-and-reading
# and place it in the same folder as this script for this to work.
#
# Usage installMobileProvisionFile.sh path/to/foobar.mobileprovision

if [ ! $# == 1 ]; then
echo "Usage: $0 (path/to/mobileprovision)"
exit
fi

mp=$1

uuid=`/usr/libexec/PlistBuddy -c 'Print :UUID' /dev/stdin <<< $(security cms -D -i ${mp})_`

echo "Found UUID $uuid"

output=~/Library/MobileDevice/Provisioning\ Profiles/$uuid.mobileprovision

echo "copying from $mp to $output.."
cp "$mp" "$output"

echo "done"
echo "$uuid"
