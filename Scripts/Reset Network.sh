#!/bin/bash

localDrive=$(diskutil info disk0s2 | grep "Volume Name:" | awk -F":" '{ print $2 }' | sed -e 's/^[ \t]*//g')
rm "/Volumes/$localDrive/Library/Preferences/SystemConfiguration/NetworkInterfaces.plist"
rm "/Volumes/$localDrive/Library/Preferences/SystemConfiguration/preferences.*"