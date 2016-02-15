#!/bin/sh

# Jonny Ford 
# Date of Compile: 04/12/2014
# Should have last priority After Casper Reboot
# Version 3

#Scripts executed through the Casper Suite will automatically receive the first three variables in the following order:
# $1 = Mount point of the target drive
# $2 = Computer name
# $3 = Username when executed as a login or logout policy

# Define variables
awk="/usr/bin/awk"
consoleuser=$(/bin/ls -l /dev/console | /usr/bin/awk '{print $3}')
cp="/bin/cp"
dscl="/usr/bin/dscl"
dsconfigad="/usr/sbin/dsconfigad"
dseditgroup="/usr/sbin/dseditgroup"
echo="/bin/echo"
find="/usr/bin/find"
grep="/usr/bin/grep"
ipconfig="/usr/sbin/ipconfig"
JAMF='/usr/local/jamf/bin/jamf'
kickstart="/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart"
killall="/usr/bin/killall"
launchctl="/bin/launchctl"
ln="/bin/ln"
logdir="/Library/Logs"
mkdir="/bin/mkdir"
mv="/bin/mv"
networksetup="/usr/sbin/networksetup"
perl="/usr/bin/perl"
sleep="/bin/sleep"
systemsetup="/usr/sbin/systemsetup"
perl="/usr/bin/perl"
plistbuddy="/usr/libexec/PlistBuddy"
rm="/bin/rm"
touch="/usr/bin/touch"
uuid=$(/usr/sbin/ioreg -rd1 -c IOPlatformExpertDevice | /usr/bin/grep -i "UUID" | /usr/bin/cut -c27-62)
osvers=$(sw_vers -productVersion | awk -F. '{print $2}')
sw_vers=$(sw_vers -productVersion)
sw_build=$(sw_vers -buildVersion)


#####################################################
#	#	
#	End-User Profile Settings & System Setup #
#	#
#####################################################

# Remove info files on all 
rm -R /System/Library/User\ Template/Non_localized/Downloads/About\ Downloads.lpdf
rm -R /System/Library/User\ Template/Non_localized/Documents/About\ Stacks.lpdf

# Files save to HDD by default (instead of iCloud)
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Remove iBooks and Maps from Dock
rm -rf /System/Library/CoreServices/Dock.app/Contents/Resources/com.apple.dockfixup.plist

# Turn off DS_Store file creation on network volumes
defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.desktopservices DSDontWriteNetworkStores true

# Disable external accounts (i.e. accounts stored on drives other than the boot drive.)
defaults write /Library/Preferences/com.apple.loginwindow EnableExternalAccounts -bool false

# Remove Web Security from Cisco AnyConnect
sudo /opt/cisco/anyconnect/bin/websecurity_uninstall.sh

# Run Built-in Unix Maintenance Scripts (Rotate & delete log files)
sudo periodic daily weekly monthly

# Purge System Log
/bin/rm -rf /var/log/system.log

# Delete Built-in Applications
sudo rm -rf /Applications/GarageBand.app
sudo rm -rf /Applications/Game\ Center.app

# Flush Policy History for Computer in JAMF Software Server Upon Reimage
jamf flushPolicyHistory

# Enable Automatically Change Timezone
defaults write /Library/Preferences/com.apple.timezone.auto Active -bool true

##################################################
#   #
#   Finder Preferences #
#   #
##################################################

# Show "Mounted Server Shares, External and Internal Hard Disks" on the main Finder Desktop
defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Hide /Opt/ Folder under root drive
chflags hidden /opt/
chflags hidden /private/
chflags hidden /usr/

##################################################
#   #
#   System Preferences #
#   #
##################################################

# Turn on and enable SSH for JAMF Client
sudo JAMF startSSH
sudo systemsetup -setremotelogin on

# Enable VNC and Remote Management
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -clientopts -setvnclegacy -vnclegacy yes
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -clientopts -setvncpw -vncpw "b0c12th$"
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -restart -agent -console
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -users admin -privs -DeleteFiles -ControlObserve -TextMessages -OpenQuitApps -GenerateReports -RestartShutDown -SendFiles -ChangeSettings -restart -agent -menu
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -clientopts -setmenuextra -menuextra no

# Clear current software update preferences 
sudo softwareupdate --schedule off
# Start auto downloading updates again
sudo softwareupdate --schedule on
# Edit the plist to reflect
defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticCheckEnabled -bool true
defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticDownload -bool true
defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist CriticalUpdateInstall -bool true
# Check for updates 
sudo softwareupdate --background-critical

# Enable location services
/bin/launchctl unload /System/Library/LaunchDaemons/com.apple.locationd.plist
uuid=$(/usr/sbin/system_profiler SPHardwareDataType | grep "Hardware UUID" | cut -c22-57)
/usr/bin/defaults write /var/db/locationd/Library/Preferences/ByHost/com.apple.locationd."$uuid" LocationServicesEnabled -int 1
/usr/bin/defaults write /var/db/locationd/Library/Preferences/ByHost/com.apple.locationd.notbackedup."$uuid" LocationServicesEnabled -int 1
/usr/sbin/chown -R _locationd:_locationd /var/db/locationd
/bin/launchctl load /System/Library/LaunchDaemons/com.apple.locationd.plist

# Enable Automatically Change Timezone
defaults write /Library/Preferences/com.apple.timezone.auto Active -bool true

# Refresh Network Adapters
networksetup -detectnewhardware
networksetup -createnetworkservice Thunderbolt\ Ethernet 'Thunderbolt Ethernet'

# Enable Fast User Switching option
defaults write /Library/Preferences/.GlobalPreferences MultipleSessionEnabled -bool true

# Turn hard-disk sleep off
sudo systemsetup -setharddisksleep Never

# Enable Firewall
sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1

# Disable Gatekeeper re-arm
sudo defaults write /Library/Preferences/com.apple.security GKAutoRearm -bool NO
sudo spctl --master-disable

# Change the computer accounts password to never change on AD (can fix some unbinding issues)
dsconfigad -passinterval 0

#####################################################
#	#	
#	Default User Profile and Settings #
#	#
#####################################################

# Sleeping for 15 seconds to allow the new default User Template folder to be moved into place
sleep 15

# Disable “Application Downloaded from the internet” message
sudo defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.LaunchServices LSQuarantine -bool no
defaults write com.apple.LaunchServices LSQuarantine -bool no

# Checks the system default user template for the presence
# of the Library/Preferences directory.
#
# If the directory is not found, it is created and then the
# iCloud and Diagnostic pop-up settings are set to be disabled.

if [[ ${osvers} -ge 7 ]]; then

 for USER_TEMPLATE in "/System/Library/User Template"/*
  do
    /usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant DidSeeCloudSetup -bool TRUE
    /usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant GestureMovieSeen none
    /usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant LastSeenCloudProductVersion "${sw_vers}"
    /usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant LastSeenBuddyBuildVersion "${sw_build}"
  done

 # Checks the existing user folders in /Users for the presence
 # of the Library/Preferences directory.
 #
 # If the directory is not found, it is created and then the
 # iCloud and Diagnostic pop-up settings are set to be disabled.

 for USER_HOME in /Users/*
  do
    USER_UID=`basename "${USER_HOME}"`
    if [ ! "${USER_UID}" = "Shared" ] 
    then 
      if [ ! -d "${USER_HOME}"/Library/Preferences ]
      then
        mkdir -p "${USER_HOME}"/Library/Preferences
        chown "${USER_UID}" "${USER_HOME}"/Library
        chown "${USER_UID}" "${USER_HOME}"/Library/Preferences
      fi
      if [ -d "${USER_HOME}"/Library/Preferences ]
      then
        /usr/bin/defaults write "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant DidSeeCloudSetup -bool TRUE
        /usr/bin/defaults write "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant GestureMovieSeen none
        /usr/bin/defaults write "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant LastSeenCloudProductVersion "${sw_vers}"
        /usr/bin/defaults write "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant LastSeenBuddyBuildVersion "${sw_build}"
        chown "${USER_UID}" "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant.plist
      fi
    fi
  done
fi

# Turn off most Time Machine settings
defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true
defaults write /Library/Preferences/com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true
defaults write /Library/Preferences/com.apple.TimeMachine AutoBackup -boolean NO
