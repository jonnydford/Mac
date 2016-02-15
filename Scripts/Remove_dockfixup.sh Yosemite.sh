#!/usr/bin/env bash    
FILE=/System/Library/CoreServices/Dock.app/Contents/Resources/com.apple.dockfixup.plist

# if the file exists, delete the file
if [ -f $FILE ]
then
  rm -rf /System/Library/CoreServices/Dock.app/Contents/Resources/com.apple.dockfixup.plist
fi