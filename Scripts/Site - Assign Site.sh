#!/bin/bash
## Variables
jssAPIUser=$4
jssAPIPassword=$5
jssURL=$6
# https://jss.emea.akqa.net:8443/JSSResource
serial=`system_profiler SPHardwareDataType | awk '/Serial/ {print $4}'`
newComputerSite=$7

Amsterdam=3
Berlin=1
Ciklum=16
Gothenburg=11
Gurgaon=7
HongKong=9
London=8
Milan=13
Paris=5
Portland=14
SaoPaulo=10
Shanghai=4
Tokyo=2
Venice=15

## XML File
apiData="<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?><computer><general><site><id>${newComputerSite}</id></site></general></computer>"
## Commands
/usr/bin/curl -s -v -u  ${jssAPIUser}:${jssAPIPassword} -X PUT -H "Content-Type: text/xml" -d "${apiData}" "${jssURL}/computers/serialnumber/${serial}"
exit 0
