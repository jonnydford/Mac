#!/bin/bash
#
# MDM Profile Update Script
#
# Created by Love Bååk 2015-05-08
# Special thanks to Mattias Hedlund, rtrouton and jamfnation threads!
#
# This script checks proper communication with internal servers and ensuring
# that the JSS is reachable and then updates the MDM profile 
#

internalServer='10.2.20.94'

ping -c 1 -t300 $internalServer 2>/dev/null 1>/dev/null
if [ "$?" = 0 ]
    then
        echo "Server is reachable. Proceeding with JSS check..."
    else
        echo "Server is not reachable. Exiting..."
        exit 1
fi

# Verifies that the client machine can communicate with the JSS server 

jss_connection=`/usr/local/jamf/bin/jamf checkJSSConnection -retry 2 > /dev/null; echo $?`

if [[ "$jss_connection" -gt 0 ]]; then
    echo "Machine cannot connect to the JSS. Exiting..."
    exit 2
elif [[ "$jss_connection" -eq 0 ]]; then
    echo "Machine can connect to the JSS. Proceeding with MDM profile update..."
        sleep 5
        /usr/local/jamf/bin/jamf removeMdmProfile -verbose
    echo "MDM Profiles have been removed"
        sleep 5
        /usr/local/jamf/bin/jamf manage -verbose
    echo "MDM Profiles have been re-added"
        sleep 5
        /usr/local/jamf/bin/jamf recon
    echo "Inventory submitted"
        sleep 5
fi

echo "All done!"

exit 0