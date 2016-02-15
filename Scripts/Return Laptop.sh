#!/bin/sh

# Jonny Ford
#Scripts executed through the Casper Suite will automatically receive the first three variables in the following order:
# $1 = Mount point of the target drive
# $2 = Computer name
# $3 = Username when executed as a login or logout policy

# Determine OS version
osvers=$(sw_vers -productVersion | awk -F. '{print $2}')

dialog="This laptop is property of AKQA. Please return this laptop to AKQA."
description=`echo "$dialog"`
button1="OK"
jamfHelper="/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
icon="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns"

if [[ ${osvers} -lt 7 ]]; then

  "$jamfHelper" -windowType fs -description "$description" -button1 "$button1" -icon "$icon"
#-windowType utility
fi

if [[ ${osvers} -ge 7 ]]; then

  jamf displayMessage -message "$dialog"

fi

exit 0