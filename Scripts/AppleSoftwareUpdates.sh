#!/bin/sh

# Jonny Ford 
# Date of Compile: 18/02/2015
# Should have last priority After Casper Reboot
# Version 1

#Scripts executed through the Casper Suite will automatically receive the first three variables in the following order:
# $1 = Mount point of the target drive
# $2 = Computer name
# $3 = Username when executed as a login or logout policy

# Start auto downloading updates again
sudo softwareupdate --schedule on

# Disable Beta Software
defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AllowPreReleaseInstallation -bool false

# Automatic Check Enabled
defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticCheckEnabled -bool TRUE

# Automatic Critical Updates Install
defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist CriticalUpdateInstall -bool TRUE

# Auto update OS and Apps
defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool TRUE

# Auto ask user to restart once updates are installed
defaults write /Library/Preferences/com.apple.commerce AutoUpdateRestartRequired -bool TRUE

