#!/bin/sh

# Jonny Ford 
# Date of Compile: 05/01/2015
# Should have last priority After Casper Reboot
# Version 1

#Scripts executed through the Casper Suite will automatically receive the first three variables in the following order:
# $1 = Mount point of the target drive
# $2 = Computer name
# $3 = Username when executed as a login or logout policy

STATUS=`sudo -u $3 defaults read com.apple.finder AppleShowAllFiles`
if [ $STATUS == TRUE ];
then
    sudo -u $3 defaults write com.apple.finder AppleShowAllFiles FALSE
else
     sudo -u $3 defaults write com.apple.finder AppleShowAllFiles TRUE
fi
killall Finder