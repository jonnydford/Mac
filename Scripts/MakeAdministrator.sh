#!/bin/sh

# Jonny Ford 
# Date of Compile: 08/12/2014
# Version 1

# Get username of current logged in user
USERNAME=`who |grep console| awk '{print $1}'`

# give current logged user admin rights
/usr/sbin/dseditgroup -o edit -a $USERNAME -t user admin
exit 0