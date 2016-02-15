#!/bin/bash

netBIOSname="$(dsconfigad -show | awk '/Computer Account/{print toupper($NF)}' | sed 's/$$//')"
if [ "$netBIOSname" == "" ];then
	exit 0
fi

computerName="$(scutil --get ComputerName | tr '[:lower:]' '[:upper:]')"

if [ "$computerName" != "$netBIOSname" ];then
	scutil --set ComputerName "$netBIOSname"
	scutil --set LocalHostName "$netBIOSname"
	diskutil rename / "$netBIOSname"
fi