#!/bin/sh

# Jonny Ford
#Scripts executed through the Casper Suite will automatically receive the first three variables in the following order:
# $1 = Mount point of the target drive
# $2 = Computer name
# $3 = Username when executed as a login or logout policy
/usr/sbin/systemsetup -settimezone "Europe/London" -setnetworktimeserver "time.euro.apple.com" -setusingnetworktime on