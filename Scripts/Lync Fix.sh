#!/bin/bash

user=`who |grep console| awk '{print $1}'` #gets user name as variable

#pidLync=`ps -ef | grep Lync | grep -v "grep" | awk '{print $2}'`

killall "Microsoft Lync" #closes microsoft lync

sleep 10s #pauses for 10 secs

#removes preferences and caches
rm -rf /Users/$user/Library/Caches/com.microsoft.Lync
rm -rf /Users/$user/Documents/Microsoft\ User\ Data/Microsoft\ Lync\ Data
rm -rf /Users/$user/Library/Preferences/com.microsoft.Lync.plist
rm -rf /Users/$user/Library/Keychains/OC_KeyContainer*

lynckey=`security find-generic-password -l "Microsoft Lync" /Users/$user/Library/Keychains/login.keychain`
#deletes keychain entries
while [[ -n $lynckey ]] ; do
security delete-generic-password -l "Microsoft Lync" /Users/$user/Library/Keychains/login.keychain
lynckey=`security find-generic-password -l "Microsoft Lync" /Users/$user/Library/Keychains/login.keychain`
done