#!/bin/bash

## refresh network settings
networksetup -detectnewhardware
sleep 2

echo "Configuring Wireless Settings"
networksetup -listallhardwareports > /tmp/wireless
cat /tmp/wireless | while read line
do
	test=$(echo "$line" | grep -i Wi-Fi )
	if [ "$test" != "" ];then
		read -r line
		interface=$(echo "$line" | awk -F':' '{ print $2 }')
		echo "$interface" > /tmp/wireless
		break
	fi
done
en=$(cat /tmp/wireless)
/usr/sbin/networksetup -setairportnetwork $en "AKQA-WiFi" "abfedcba456876337722889911"

exit 0