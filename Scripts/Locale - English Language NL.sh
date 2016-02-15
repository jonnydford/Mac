#!/bin/sh

# Jonny Ford 
# Date of Compile: 10/12/2014
# Should have last priority After Casper Reboot
# Version 1

#Scripts executed through the Casper Suite will automatically receive the first three variables in the following order:
# $1 = Mount point of the target drive
# $2 = Computer name
# $3 = Username when executed as a login or logout policy

# Set locale to English NL
# Note you may need to restart for settings to fully apply
defaults write NSGlobalDomain AppleLocale "en_NL"
defaults write NSGlobalDomain AppleLanguages -array "en" "nl" "de" "fr"