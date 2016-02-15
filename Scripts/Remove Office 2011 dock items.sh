#Written by Ashley Bligh 08/01/2016


killall cfprefsd
/usr/local/bin/dockutil --remove 'Microsoft Word' --allhomes --no-restart
/bin/sleep 5
/usr/local/bin/dockutil --remove 'Microsoft Excel' --allhomes --no-restart
/bin/sleep 5
/usr/local/bin/dockutil --remove 'Microsoft Outlook' --allhomes --no-restart
/bin/sleep 5
/usr/local/bin/dockutil --remove 'Microsoft PowerPoint' --allhomes --no-restart
/bin/sleep 5
/usr/local/bin/dockutil --add /Applications/Microsoft\ Excel.app --allhomes --no-restart
/bin/sleep 5
/usr/local/bin/dockutil --add /Applications/Microsoft\ Outlook.app --allhomes --no-restart
/bin/sleep 5
/usr/local/bin/dockutil --add /Applications/Microsoft\ PowerPoint.app --allhomes --no-restart
/bin/sleep 5
/usr/local/bin/dockutil --add /Applications/Microsoft\ Word.app --allhomes --no-restart
/bin/sleep 5
killall Dock

exit 0