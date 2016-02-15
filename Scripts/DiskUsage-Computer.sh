#!/bin/sh
####################################################################################################
#
# ABOUT
#
#   Disk Usage
#
####################################################################################################
#
# HISTORY
#
#   Version 1.0, 8-Dec-2014, Dan K. Snelson
#
####################################################################################################
# Import logging functions
#source /path/to/logging/script/logging.sh
####################################################################################################

loggedInUser=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`
loggedInUserHome=`dscl . -read /Users/$loggedInUser | grep NFSHomeDirectory: | cut -c 19- | head -n 1`
machineName=`scutil --get LocalHostName`

/bin/echo "`now` *** Calculate Disk Usage for / ***" >> $logFile

/usr/bin/du -axrg / | sort -nr | head -n 75 > $loggedInUserHome/Desktop/$machineName-ComputerDiskUsage.txt


exit 0      ## Success
exit 1      ## Failure