#!/bin/sh

	# Check if setup has already run, if so quit. 

checkSetupDone()	{

	if [ -f $HOME/Library/Preferences/com.microsoft.Lync.plist ] ; then
		exit 0
	fi

}

populateUserInformation()	{

	# Get current username
	USERNAME=$( id -un )

	# Look up user email address
	EMAILADDRESS=$( dscl . -read /Users/$USERNAME EMailAddress | awk 'BEGIN {FS=" "} {print $2}' )

	# Write to plist 
	defaults write $HOME/Library/Preferences/com.microsoft.Lync UserIDMRU '( { LogonName = '\"$EMAILADDRESS\"'; UserID = '\"$EMAILADDRESS\"'; } )'
	
	# Accept license agreement - Prevents initial license agreement from appearing for each user
	defaults write $HOME/Library/Preferences/com.microsoft.Lync acceptedSLT140 -bool true

	# Do not show conference provider alert
	defaults write $HOME/Library/Preferences/com.microsoft.Lync DoNotShowConfProviderAlert -bool true

	# Do not show presence provider alert
	defaults write $HOME/Library/Preferences/com.microsoft.Lync DoNotShowPresenceProviderAlert -bool true

	# Do not show telephone provider alert
	defaults write $HOME/Library/Preferences/com.microsoft.Lync DoNotShowTelProviderAlert -bool true

}

checkSetupDone
populateUserInformation

exit 0