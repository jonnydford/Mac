#!/bin/sh

# Jonny Ford
#Scripts executed through the Casper Suite will automatically receive the first three variables in the following order:
# $1 = Mount point of the target drive
# $2 = Computer name
# $3 = Username when executed as a login or logout policy

# Set Safari Preferences.
echo “Setting Safari to use StartHere as home page”
defaults write “${USERPREFS_DIR}/com.apple.Safari” HomePage “http://starthere.emea.akqa.local”
defaults write “${USERPREFS_DIR}/com.apple.Safari” ShowStatusBar -bool YES
defaults write “${USERPREFS_DIR}/com.apple.Safari” NewWindowBehavior -int 0
defaults write “${USERPREFS_DIR}/com.apple.Safari” NewTabBehavior -int 0

# Set Chrome Preferences.
defaults write “${USERPREFS_DIR}/com.google.Chrome” HomepageLocation “http://starthere.emea.akqa.local” 