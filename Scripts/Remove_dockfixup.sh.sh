#!/usr/bin/env bash    
FILE=/Library/Preferences/com.apple.dockfixup.plist

# if the file exists, delete the file
if [ -f $FILE ]
then
  rm -rf /Library/Preferences/com.apple.dockfixup.plist
fi