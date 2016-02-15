#!/bin/bash

########################################################################
# Created By: Jonny Ford
# Creation Date: January 8th 2015
# Deletes all files within the users Keychain folder
########################################################################

USER=$(ls -l /dev/console | awk '{print $3}')

#Delete Keychain for $USER (local user)
rm -rf /Users/$USER/Library/Keychains/*