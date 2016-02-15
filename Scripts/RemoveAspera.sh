#!/bin/sh 
#
# Remove Connect
# if user is non-admin, only remove local user installation
# if user is admin, remove local user and system wide
# 
#
# 2.2 only installs to /   Gives option to install to other volume but...
# 2.3 allows you to install where ever you want
# 2.6 is a java based installer
# 2.7 only allows users to install to /Applications or $user_install_root/Library/Application Support
# 2.8 only allows users to install to /Applications or $user_install_root/Applications
#
# ============================================================================= #

# comment out to debug
#set -v off

# allow users to bypass prompts with a "-f" for force flag
# Parse command line options
USAGE="Usage: `basename $0` [-f] "
force="no"
while getopts f OPT; do
    case "$OPT" in
        f)
            echo "forcing full uninstall"
            force="yes"
            break
            ;;
        \?)
            # getopts issues an error message
            echo $USAGE >&2
            exit 1
            ;;
    esac
done

# get current os version
os_version=`sw_vers | grep ProductVersion | awk {' print $2 '}`

# break it into pieces
IFS="."
set $os_version
major=$1
minor=$2
patch=$3

# see if we are running 10.6 or higher
is_10_6_or_later="no"
if [ "$major" -ge "10" ]; then
  if [ "$minor" -ge "6" ]; then
    is_10_6_or_later="yes"
  fi
fi

# get uninstaller name and directory
uninstaller_dir=`dirname "$0"`
uninstaller_dir=`cd $uninstaller_dir && pwd`
uninstaller_name=`basename "$0"`
uninstaller="$uninstaller_dir/$uninstaller_name"

# use this file's path to figure out which user installed 
# in case a user is running as root from a user install
user_install="no"
user_install_root="$HOME"
IFS="/"
set $uninstaller_dir
root=$2
username=$3
if [ "$USERNAME" = "root" ]; then
    user_install_root="/$root/$username"
fi

# check for user install 
if [ -d "$user_install_root/Applications/Aspera Connect.app" ]; then
    user_install="yes"
fi

# see if this is a system wide uninstall
system_wide_install="no"
if [ -d "/Applications/Aspera Connect.app" ]; then
  system_wide_install="yes"
fi

# see if Enterprise Server is installed
if [ -d /Applications/Aspera\ Enterprise\ Server.app ]; then
  entsrv_installed="yes"
else
  entsrv_installed="no"
fi

# check for admin priveleges
user=`whoami`
# grep returns 0 if it finds a match.  1 if no match
/usr/sbin/dseditgroup -o checkmember admin | grep yes > /dev/null
if [ $? -ne 0 ]; then
  is_admin="no"
else
  is_admin="yes"
fi

# non-admin can only uninstall local user bits
# if user is admin and system wide install, attempt system wide uninstall
# if admin, system wide install and on 10.6 or later we must run as root
if [ "$system_wide_install" = "no" ]; then
  echo "Uninstalling Aspera Connect for user $username"
else
  if [ "$is_10_6_or_later" = "yes" ]; then 
    if [ "$user" != "root" ]; then
      echo "For Mac OS 10.6 and later system wide uninstall must be run as root"
      echo "Please try : sudo $0"
      exit 1
    fi
  fi
  if [ "$is_admin" = "no" ]; then
    echo "Sorry, you must be an admin to uninstall a system wide installation of Aspera Connect"
    exit 1
  else
    echo "Uninstalling Aspera Connect system wide"
  fi
fi

# see if the user wants to keep preferences and/or web installer
if [ "$force" = "no" ]; then
  while true; do
      read -p "Would you like to keep your Connect Preferences? (yes or no) " yn
      case $yn in
          [Yy]* ) remove_preferences="no";  break;;
          [Nn]* ) remove_preferences="yes"; break;;
          * ) echo "Please answer yes or no.";;
      esac
  done

  while true; do
      read -p "Would you like to keep the Aspera Web Installer? (yes or no) " yn
      case $yn in
          [Yy]* ) remove_web_installer="no"; break;;
          [Nn]* ) remove_web_installer="yes"; break;;
          * ) echo "Please answer yes or no.";;
      esac
  done
else
  remove_preferences="yes"
  remove_web_installer="yes"
fi

# change into a directory that won't be getting removed
cd $HOME

# kill crypt and connect
ps -Ax | grep -i asperacrypt   | sed /grep/d | awk '{ print $1 }' | xargs kill -9
ps -Ax | grep -i asperaconnect | sed /grep/d | awk '{ print $1 }' | xargs kill -9

function remove_file {
  rm -f "$1" 2>/dev/null || echo "Warning: could not remove $1"
}

function remove_directory {
  rm -rf "$1" 2>/dev/null || echo "Warning: could not remove directory $1"
}

function remove_file_w_wildcard {
  if [ -d "$1" ]; then
    files=`find "$1" -type f -name "$2"`
    IFS='
'
    file_array=$files
    for filename in $file_array
    do
      rm -rf "$filename" 2>/dev/null || echo "Warning: unable to remove file $filename"
    done
  fi
}

function remove_directory_w_wildcard {
  if [ -d "$1" ]; then
    find "$1" -type d -name "$2" >/dev/null 2>&1
    directories=`find "$1" -type d -name "$2"`
    IFS='
'
    directory_array=$directories
    for directory in $directory_array
    do
      rm -rf "$directory" 2>/dev/null || echo "Warning: unable to remove directory $directory"
    done
  fi
}

# unregister protocol handler
if [ "$system_wide_install" = "no" ]; then
  "$HOME/Applications/Aspera Connect.app/Contents/MacOS/asperaconnect" --unregister-protocol-user
else
  "/Applications/Aspera Connect.app/Contents/MacOS/asperaconnect" --unregister-protocol-system
fi

# check for custom install location
connect_support_root="$user_install_root/Library/Application Support/Aspera/Aspera Connect"
connect_path_file="$connect_support_root/etc/asperaconnect.path"
if [ -f "$connect_path_file" ]; then
  # we might want to warn if this file isn't found
  connect_install_root=`cat "$connect_path_file"`
  connect_bundle_name="Aspera Connect.app"
  connect_bundle="$connect_install_root/$connect_bundle_name"
  remove_directory "$connect_bundle"
fi

remove_directory "$connect_support_root"

# remove system install
if [ "$is_admin" == "yes" ]; then
  remove_directory /Applications/Aspera\ Connect.app
  remove_directory /Applications/Aspera\ Crypt.app
  remove_directory /Library/Application\ Support/Aspera/Aspera\ Connect

  remove_directory /Library/Internet\ Plug-Ins/Aspera\ Web.plugin
  remove_directory /Library/Internet\ Plug-Ins/Aspera\ Web.webplugin
  # this is for versioned plugin dirs
  remove_directory_w_wildcard "/Library/Internet Plug-Ins" "Aspera Web*"

  if [ $remove_web_installer = "yes" ]; then
    remove_directory /Library/Application\ Support/Aspera/Install
    remove_directory /Library/Internet\ Plug-Ins/Aspera\ Installer.plugin
  fi

  # remove Aspera Application Support directory if it is empty
  if [ -e /Library/Application\ Support/Aspera ]; then
    if [ "$(ls -A /Library/Application\ Support/Aspera)" ]; then
      echo "Keeping /Library/Application\ Support/Aspera directory since it is not empty"
    else
      remove_directory /Library/Application\ Support/Aspera
    fi
  fi

  remove_file_w_wildcard "/Library/Logs/Aspera" "aspera-connect*"
  remove_file_w_wildcard "/Library/Logs/Aspera" "connect*"
  remove_file_w_wildcard "/Library/Logs/Aspera" "aspera-webinstaller-plugin*.log"
  if [ "$entsrv_installed" = "no" ]; then
    remove_file  /Library/Logs/Aspera/aspera-scp*.log
  fi
  # only remove log directory if it is empty
  if [ -e /Library/Logs/Aspera ]; then
    if [ "$(ls -A /Library/Logs/Aspera)" ]; then
      echo "Keeping /Library/Logs/Aspera directory since it is not empty"
    else
      remove_directory /Library/Logs/Aspera
    fi
  fi

  remove_directory /Library/Receipts/AsperaConnect.pkg
  remove_directory /Library/Receipts/asperaconnect.pkg
  remove_directory_w_wildcard "/var/db/receipts" "connect*"
fi

# remove local user install

if [ "$user_install" = "yes" -o "$force" = "yes" ]; then
  remove_directory "$user_install_root/Aspera Connect.app"
  remove_directory "$user_install_root/Applications/Aspera Connect.app"
  remove_directory "$user_install_root/Applications/Aspera Crypt.app"
  if [ -e "$user_install_root/Applications" ]; then
    if [ "$(ls -A "$user_install_root/Applications" | sed /\.DS_Store/d)" ]; then
      echo "Keeping $user_install_root/Applications directory since it is not empty"
    else
      remove_directory "$user_install_root/Applications"
    fi
  fi

  remove_directory "$user_install_root/Library/Application Support/Applications"
  remove_directory "$user_install_root/Library/Application Support/Aspera Connect.app"
  remove_directory "$user_install_root/Library/Application Support/Aspera Crypt.app"
  remove_directory "$user_install_root/Library/Application Support/Aspera/Aspera Connect"
  remove_file  "$user_install_root/Library/Application Support/Aspera/.aspera_installer_output.log"
  remove_file  "$user_install_root/Library/Application Support/Aspera/.aspera_installer.log"
 
  remove_directory "$user_install_root/Library/Internet Plug-Ins/Aspera Web.plugin"
  remove_directory "$user_install_root/Library/Internet Plug-Ins/Aspera Web.webplugin"
  remove_directory_w_wildcard "$user_install_root/Library/Internet Plug-Ins" "Aspera Web*" 

  if [ "$remove_web_installer" = "yes" ]; then
    remove_directory "$user_install_root/Library/Application Support/Aspera/Install"
    remove_directory "$user_install_root/Library/Internet Plug-Ins/Aspera Installer.plugin"
    # browser specific plugins
    # chrome
    remove_directory "$user_install_root/Library/Application Support/Google/Chrome/Default/Extensions/aljbeaimggdioicepilcjnkphjobddok" 
    # firefox
    if [ -e "$user_install_root/Library/Application Support/Firefox/Profiles" ]; then
      remove_directory_w_wildcard "$user_install_root/Library/Application Support/Firefox/Profiles" "*asperasoft.com*"  
    fi
  fi

  if [ -e "$user_install_root/Library/Application Support/Aspera" ]; then
    if [ "$(ls -A "$user_install_root/Library/Application Support/Aspera")" ]; then
      echo "Keeping $user_install_root/Library/Application\ Support/Aspera directory since it is not empty"
    else
      remove_directory "$user_install_root/Library/Application Support/Aspera"
    fi
  fi

  # only remove log directory if it is empty
  remove_file_w_wildcard "$user_install_root/Library/Logs" "aspera-connect*.log" 
  remove_file_w_wildcard "$user_install_root/Library/Logs" "connect*.log"
  remove_file_w_wildcard "$user_install_root/Library/Logs" "aspera-webinstaller*.log"
  if [ "$entsrv_installed" = "no" ]; then
    remove_file_w_wildcard "$user_install_root/Library/Logs" "aspera-scp*"
  fi
  if [ -e "$user_install_root/Library/Logs/Aspera" ]; then
    if [ "$(ls -A "$user_install_root/Library/Logs/Aspera")" ]; then
      echo "Keeping $user_install_root/Library/Logs/Aspera directory since it is not empty"
    else
      remove_directory "$user_install_root/Library/Logs/Aspera" 
    fi
  fi

  remove_directory "$user_install_root/Library/Receipts/AsperaConnect.pkg"
  remove_directory "$user_install_root/Library/Receipts/asperaconnect.pkg"
  remove_file  "$user_install_root/Library/Receipts/com.asperasoft.connect.bom"
  remove_file  "$user_install_root/Library/Receipts/com.asperasoft.connect.plist"
fi

if [ $remove_preferences = "yes" ]; then
  remove_directory "$user_install_root/.aspera/connect"
  if [ -e "$user_install_root/.aspera" ] ; then
    if [ "$(ls -A "$user_install_root/.aspera")" ] ; then
      echo "Keeping $user_install_root/.aspera since it is not empty"
    else
      remove_directory "$user_install_root/.aspera"
    fi
  fi
  remove_file "$user_install_root/Library/Preferences/com.asperasoft.Aspera Connect.plist"
  remove_file "$user_install_root/Library/Preferences/com.asperasoft.Crypt.plist"
fi
  
# report success

echo "Aspera Connect has successfully been uninstalled"
if [ $remove_preferences = "no" ]; then
  echo "Your Connect preferences have been preserved"
fi
if [ $remove_web_installer = "no" ]; then
  echo "Aspera Web Installer is still installed"
fi

#!/bin/sh 
#
# Remove Connect
# if user is non-admin, only remove local user installation
# if user is admin, remove local user and system wide
# 
#
# 2.2 only installs to /   Gives option to install to other volume but...
# 2.3 allows you to install where ever you want
# 2.6 is a java based installer
# 2.7 only allows users to install to /Applications or $user_install_root/Library/Application Support
# 2.8 only allows users to install to /Applications or $user_install_root/Applications
#
# ============================================================================= #

# comment out to debug
#set -v off

# allow users to bypass prompts with a "-f" for force flag
# Parse command line options
USAGE="Usage: `basename $0` [-f] "
force="no"
while getopts f OPT; do
    case "$OPT" in
        f)
            echo "forcing full uninstall"
            force="yes"
            break
            ;;
        \?)
            # getopts issues an error message
            echo $USAGE >&2
            exit 1
            ;;
    esac
done

# get current os version
os_version=`sw_vers | grep ProductVersion | awk {' print $2 '}`

# break it into pieces
IFS="."
set $os_version
major=$1
minor=$2
patch=$3

# see if we are running 10.6 or higher
is_10_6_or_later="no"
if [ "$major" -ge "10" ]; then
  if [ "$minor" -ge "6" ]; then
    is_10_6_or_later="yes"
  fi
fi

# get uninstaller name and directory
uninstaller_dir=`dirname "$0"`
uninstaller_dir=`cd $uninstaller_dir && pwd`
uninstaller_name=`basename "$0"`
uninstaller="$uninstaller_dir/$uninstaller_name"

# use this file's path to figure out which user installed 
# in case a user is running as root from a user install
user_install="no"
user_install_root="$HOME"
IFS="/"
set $uninstaller_dir
root=$2
username=$3
if [ "$USERNAME" = "root" ]; then
    user_install_root="/$root/$username"
fi

# check for user install 
if [ -d "$user_install_root/Applications/Aspera Connect.app" ]; then
    user_install="yes"
fi

# see if this is a system wide uninstall
system_wide_install="no"
if [ -d "/Applications/Aspera Connect.app" ]; then
  system_wide_install="yes"
fi

# see if Enterprise Server is installed
if [ -d /Applications/Aspera\ Enterprise\ Server.app ]; then
  entsrv_installed="yes"
else
  entsrv_installed="no"
fi

# check for admin priveleges
user=`whoami`
# grep returns 0 if it finds a match.  1 if no match
/usr/sbin/dseditgroup -o checkmember admin | grep yes > /dev/null
if [ $? -ne 0 ]; then
  is_admin="no"
else
  is_admin="yes"
fi

# non-admin can only uninstall local user bits
# if user is admin and system wide install, attempt system wide uninstall
# if admin, system wide install and on 10.6 or later we must run as root
if [ "$system_wide_install" = "no" ]; then
  echo "Uninstalling Aspera Connect for user $username"
else
  if [ "$is_10_6_or_later" = "yes" ]; then 
    if [ "$user" != "root" ]; then
      echo "For Mac OS 10.6 and later system wide uninstall must be run as root"
      echo "Please try : sudo $0"
      exit 1
    fi
  fi
  if [ "$is_admin" = "no" ]; then
    echo "Sorry, you must be an admin to uninstall a system wide installation of Aspera Connect"
    exit 1
  else
    echo "Uninstalling Aspera Connect system wide"
  fi
fi

# see if the user wants to keep preferences and/or web installer
if [ "$force" = "no" ]; then
  while true; do
      read -p "Would you like to keep your Connect Preferences? (yes or no) " yn
      case $yn in
          [Yy]* ) remove_preferences="no";  break;;
          [Nn]* ) remove_preferences="yes"; break;;
          * ) echo "Please answer yes or no.";;
      esac
  done

  while true; do
      read -p "Would you like to keep the Aspera Web Installer? (yes or no) " yn
      case $yn in
          [Yy]* ) remove_web_installer="no"; break;;
          [Nn]* ) remove_web_installer="yes"; break;;
          * ) echo "Please answer yes or no.";;
      esac
  done
else
  remove_preferences="yes"
  remove_web_installer="yes"
fi

# change into a directory that won't be getting removed
cd $HOME

# kill crypt and connect
ps -Ax | grep -i asperacrypt   | sed /grep/d | awk '{ print $1 }' | xargs kill -9
ps -Ax | grep -i asperaconnect | sed /grep/d | awk '{ print $1 }' | xargs kill -9

function remove_file {
  rm -f "$1" 2>/dev/null || echo "Warning: could not remove $1"
}

function remove_directory {
  rm -rf "$1" 2>/dev/null || echo "Warning: could not remove directory $1"
}

function remove_file_w_wildcard {
  if [ -d "$1" ]; then
    files=`find "$1" -type f -name "$2"`
    IFS='
'
    file_array=$files
    for filename in $file_array
    do
      rm -rf "$filename" 2>/dev/null || echo "Warning: unable to remove file $filename"
    done
  fi
}

function remove_directory_w_wildcard {
  if [ -d "$1" ]; then
    find "$1" -type d -name "$2" >/dev/null 2>&1
    directories=`find "$1" -type d -name "$2"`
    IFS='
'
    directory_array=$directories
    for directory in $directory_array
    do
      rm -rf "$directory" 2>/dev/null || echo "Warning: unable to remove directory $directory"
    done
  fi
}

# unregister protocol handler
if [ "$system_wide_install" = "no" ]; then
  "$HOME/Applications/Aspera Connect.app/Contents/MacOS/asperaconnect" --unregister-protocol-user
else
  "/Applications/Aspera Connect.app/Contents/MacOS/asperaconnect" --unregister-protocol-system
fi

# check for custom install location
connect_support_root="$user_install_root/Library/Application Support/Aspera/Aspera Connect"
connect_path_file="$connect_support_root/etc/asperaconnect.path"
if [ -f "$connect_path_file" ]; then
  # we might want to warn if this file isn't found
  connect_install_root=`cat "$connect_path_file"`
  connect_bundle_name="Aspera Connect.app"
  connect_bundle="$connect_install_root/$connect_bundle_name"
  remove_directory "$connect_bundle"
fi

remove_directory "$connect_support_root"

# remove system install
if [ "$is_admin" == "yes" ]; then
  remove_directory /Applications/Aspera\ Connect.app
  remove_directory /Applications/Aspera\ Crypt.app
  remove_directory /Library/Application\ Support/Aspera/Aspera\ Connect

  remove_directory /Library/Internet\ Plug-Ins/Aspera\ Web.plugin
  remove_directory /Library/Internet\ Plug-Ins/Aspera\ Web.webplugin
  # this is for versioned plugin dirs
  remove_directory_w_wildcard "/Library/Internet Plug-Ins" "Aspera Web*"

  if [ $remove_web_installer = "yes" ]; then
    remove_directory /Library/Application\ Support/Aspera/Install
    remove_directory /Library/Internet\ Plug-Ins/Aspera\ Installer.plugin
  fi

  # remove Aspera Application Support directory if it is empty
  if [ -e /Library/Application\ Support/Aspera ]; then
    if [ "$(ls -A /Library/Application\ Support/Aspera)" ]; then
      echo "Keeping /Library/Application\ Support/Aspera directory since it is not empty"
    else
      remove_directory /Library/Application\ Support/Aspera
    fi
  fi

  remove_file_w_wildcard "/Library/Logs/Aspera" "aspera-connect*"
  remove_file_w_wildcard "/Library/Logs/Aspera" "connect*"
  remove_file_w_wildcard "/Library/Logs/Aspera" "aspera-webinstaller-plugin*.log"
  if [ "$entsrv_installed" = "no" ]; then
    remove_file  /Library/Logs/Aspera/aspera-scp*.log
  fi
  # only remove log directory if it is empty
  if [ -e /Library/Logs/Aspera ]; then
    if [ "$(ls -A /Library/Logs/Aspera)" ]; then
      echo "Keeping /Library/Logs/Aspera directory since it is not empty"
    else
      remove_directory /Library/Logs/Aspera
    fi
  fi

  remove_directory /Library/Receipts/AsperaConnect.pkg
  remove_directory /Library/Receipts/asperaconnect.pkg
  remove_directory_w_wildcard "/var/db/receipts" "connect*"
fi

# remove local user install

if [ "$user_install" = "yes" -o "$force" = "yes" ]; then
  remove_directory "$user_install_root/Aspera Connect.app"
  remove_directory "$user_install_root/Applications/Aspera Connect.app"
  remove_directory "$user_install_root/Applications/Aspera Crypt.app"
  if [ -e "$user_install_root/Applications" ]; then
    if [ "$(ls -A "$user_install_root/Applications" | sed /\.DS_Store/d)" ]; then
      echo "Keeping $user_install_root/Applications directory since it is not empty"
    else
      remove_directory "$user_install_root/Applications"
    fi
  fi

  remove_directory "$user_install_root/Library/Application Support/Applications"
  remove_directory "$user_install_root/Library/Application Support/Aspera Connect.app"
  remove_directory "$user_install_root/Library/Application Support/Aspera Crypt.app"
  remove_directory "$user_install_root/Library/Application Support/Aspera/Aspera Connect"
  remove_file  "$user_install_root/Library/Application Support/Aspera/.aspera_installer_output.log"
  remove_file  "$user_install_root/Library/Application Support/Aspera/.aspera_installer.log"
 
  remove_directory "$user_install_root/Library/Internet Plug-Ins/Aspera Web.plugin"
  remove_directory "$user_install_root/Library/Internet Plug-Ins/Aspera Web.webplugin"
  remove_directory_w_wildcard "$user_install_root/Library/Internet Plug-Ins" "Aspera Web*" 

  if [ "$remove_web_installer" = "yes" ]; then
    remove_directory "$user_install_root/Library/Application Support/Aspera/Install"
    remove_directory "$user_install_root/Library/Internet Plug-Ins/Aspera Installer.plugin"
    # browser specific plugins
    # chrome
    remove_directory "$user_install_root/Library/Application Support/Google/Chrome/Default/Extensions/aljbeaimggdioicepilcjnkphjobddok" 
    # firefox
    if [ -e "$user_install_root/Library/Application Support/Firefox/Profiles" ]; then
      remove_directory_w_wildcard "$user_install_root/Library/Application Support/Firefox/Profiles" "*asperasoft.com*"  
    fi
  fi

  if [ -e "$user_install_root/Library/Application Support/Aspera" ]; then
    if [ "$(ls -A "$user_install_root/Library/Application Support/Aspera")" ]; then
      echo "Keeping $user_install_root/Library/Application\ Support/Aspera directory since it is not empty"
    else
      remove_directory "$user_install_root/Library/Application Support/Aspera"
    fi
  fi

  # only remove log directory if it is empty
  remove_file_w_wildcard "$user_install_root/Library/Logs" "aspera-connect*.log" 
  remove_file_w_wildcard "$user_install_root/Library/Logs" "connect*.log"
  remove_file_w_wildcard "$user_install_root/Library/Logs" "aspera-webinstaller*.log"
  if [ "$entsrv_installed" = "no" ]; then
    remove_file_w_wildcard "$user_install_root/Library/Logs" "aspera-scp*"
  fi
  if [ -e "$user_install_root/Library/Logs/Aspera" ]; then
    if [ "$(ls -A "$user_install_root/Library/Logs/Aspera")" ]; then
      echo "Keeping $user_install_root/Library/Logs/Aspera directory since it is not empty"
    else
      remove_directory "$user_install_root/Library/Logs/Aspera" 
    fi
  fi

  remove_directory "$user_install_root/Library/Receipts/AsperaConnect.pkg"
  remove_directory "$user_install_root/Library/Receipts/asperaconnect.pkg"
  remove_file  "$user_install_root/Library/Receipts/com.asperasoft.connect.bom"
  remove_file  "$user_install_root/Library/Receipts/com.asperasoft.connect.plist"
fi

if [ $remove_preferences = "yes" ]; then
  remove_directory "$user_install_root/.aspera/connect"
  if [ -e "$user_install_root/.aspera" ] ; then
    if [ "$(ls -A "$user_install_root/.aspera")" ] ; then
      echo "Keeping $user_install_root/.aspera since it is not empty"
    else
      remove_directory "$user_install_root/.aspera"
    fi
  fi
  remove_file "$user_install_root/Library/Preferences/com.asperasoft.Aspera Connect.plist"
  remove_file "$user_install_root/Library/Preferences/com.asperasoft.Crypt.plist"
fi
  
# report success

echo "Aspera Connect has successfully been uninstalled"
if [ $remove_preferences = "no" ]; then
  echo "Your Connect preferences have been preserved"
fi
if [ $remove_web_installer = "no" ]; then
  echo "Aspera Web Installer is still installed"
fi

#!/bin/sh 
#
# Remove Connect
# if user is non-admin, only remove local user installation
# if user is admin, remove local user and system wide
# 
#
# 2.2 only installs to /   Gives option to install to other volume but...
# 2.3 allows you to install where ever you want
# 2.6 is a java based installer
# 2.7 only allows users to install to /Applications or $user_install_root/Library/Application Support
# 2.8 only allows users to install to /Applications or $user_install_root/Applications
#
# ============================================================================= #

# comment out to debug
#set -v off

# allow users to bypass prompts with a "-f" for force flag
# Parse command line options
USAGE="Usage: `basename $0` [-f] "
force="no"
while getopts f OPT; do
    case "$OPT" in
        f)
            echo "forcing full uninstall"
            force="yes"
            break
            ;;
        \?)
            # getopts issues an error message
            echo $USAGE >&2
            exit 1
            ;;
    esac
done

# get current os version
os_version=`sw_vers | grep ProductVersion | awk {' print $2 '}`

# break it into pieces
IFS="."
set $os_version
major=$1
minor=$2
patch=$3

# see if we are running 10.6 or higher
is_10_6_or_later="no"
if [ "$major" -ge "10" ]; then
  if [ "$minor" -ge "6" ]; then
    is_10_6_or_later="yes"
  fi
fi

# get uninstaller name and directory
uninstaller_dir=`dirname "$0"`
uninstaller_dir=`cd $uninstaller_dir && pwd`
uninstaller_name=`basename "$0"`
uninstaller="$uninstaller_dir/$uninstaller_name"

# use this file's path to figure out which user installed 
# in case a user is running as root from a user install
user_install="no"
user_install_root="$HOME"
IFS="/"
set $uninstaller_dir
root=$2
username=$3
if [ "$USERNAME" = "root" ]; then
    user_install_root="/$root/$username"
fi

# check for user install 
if [ -d "$user_install_root/Applications/Aspera Connect.app" ]; then
    user_install="yes"
fi

# see if this is a system wide uninstall
system_wide_install="no"
if [ -d "/Applications/Aspera Connect.app" ]; then
  system_wide_install="yes"
fi

# see if Enterprise Server is installed
if [ -d /Applications/Aspera\ Enterprise\ Server.app ]; then
  entsrv_installed="yes"
else
  entsrv_installed="no"
fi

# check for admin priveleges
user=`whoami`
# grep returns 0 if it finds a match.  1 if no match
/usr/sbin/dseditgroup -o checkmember admin | grep yes > /dev/null
if [ $? -ne 0 ]; then
  is_admin="no"
else
  is_admin="yes"
fi

# non-admin can only uninstall local user bits
# if user is admin and system wide install, attempt system wide uninstall
# if admin, system wide install and on 10.6 or later we must run as root
if [ "$system_wide_install" = "no" ]; then
  echo "Uninstalling Aspera Connect for user $username"
else
  if [ "$is_10_6_or_later" = "yes" ]; then 
    if [ "$user" != "root" ]; then
      echo "For Mac OS 10.6 and later system wide uninstall must be run as root"
      echo "Please try : sudo $0"
      exit 1
    fi
  fi
  if [ "$is_admin" = "no" ]; then
    echo "Sorry, you must be an admin to uninstall a system wide installation of Aspera Connect"
    exit 1
  else
    echo "Uninstalling Aspera Connect system wide"
  fi
fi

# see if the user wants to keep preferences and/or web installer
if [ "$force" = "no" ]; then
  while true; do
      read -p "Would you like to keep your Connect Preferences? (yes or no) " yn
      case $yn in
          [Yy]* ) remove_preferences="no";  break;;
          [Nn]* ) remove_preferences="yes"; break;;
          * ) echo "Please answer yes or no.";;
      esac
  done

  while true; do
      read -p "Would you like to keep the Aspera Web Installer? (yes or no) " yn
      case $yn in
          [Yy]* ) remove_web_installer="no"; break;;
          [Nn]* ) remove_web_installer="yes"; break;;
          * ) echo "Please answer yes or no.";;
      esac
  done
else
  remove_preferences="yes"
  remove_web_installer="yes"
fi

# change into a directory that won't be getting removed
cd $HOME

# kill crypt and connect
ps -Ax | grep -i asperacrypt   | sed /grep/d | awk '{ print $1 }' | xargs kill -9
ps -Ax | grep -i asperaconnect | sed /grep/d | awk '{ print $1 }' | xargs kill -9

function remove_file {
  rm -f "$1" 2>/dev/null || echo "Warning: could not remove $1"
}

function remove_directory {
  rm -rf "$1" 2>/dev/null || echo "Warning: could not remove directory $1"
}

function remove_file_w_wildcard {
  if [ -d "$1" ]; then
    files=`find "$1" -type f -name "$2"`
    IFS='
'
    file_array=$files
    for filename in $file_array
    do
      rm -rf "$filename" 2>/dev/null || echo "Warning: unable to remove file $filename"
    done
  fi
}

function remove_directory_w_wildcard {
  if [ -d "$1" ]; then
    find "$1" -type d -name "$2" >/dev/null 2>&1
    directories=`find "$1" -type d -name "$2"`
    IFS='
'
    directory_array=$directories
    for directory in $directory_array
    do
      rm -rf "$directory" 2>/dev/null || echo "Warning: unable to remove directory $directory"
    done
  fi
}

# unregister protocol handler
if [ "$system_wide_install" = "no" ]; then
  "$HOME/Applications/Aspera Connect.app/Contents/MacOS/asperaconnect" --unregister-protocol-user
else
  "/Applications/Aspera Connect.app/Contents/MacOS/asperaconnect" --unregister-protocol-system
fi

# check for custom install location
connect_support_root="$user_install_root/Library/Application Support/Aspera/Aspera Connect"
connect_path_file="$connect_support_root/etc/asperaconnect.path"
if [ -f "$connect_path_file" ]; then
  # we might want to warn if this file isn't found
  connect_install_root=`cat "$connect_path_file"`
  connect_bundle_name="Aspera Connect.app"
  connect_bundle="$connect_install_root/$connect_bundle_name"
  remove_directory "$connect_bundle"
fi

remove_directory "$connect_support_root"

# remove system install
if [ "$is_admin" == "yes" ]; then
  remove_directory /Applications/Aspera\ Connect.app
  remove_directory /Applications/Aspera\ Crypt.app
  remove_directory /Library/Application\ Support/Aspera/Aspera\ Connect

  remove_directory /Library/Internet\ Plug-Ins/Aspera\ Web.plugin
  remove_directory /Library/Internet\ Plug-Ins/Aspera\ Web.webplugin
  # this is for versioned plugin dirs
  remove_directory_w_wildcard "/Library/Internet Plug-Ins" "Aspera Web*"

  if [ $remove_web_installer = "yes" ]; then
    remove_directory /Library/Application\ Support/Aspera/Install
    remove_directory /Library/Internet\ Plug-Ins/Aspera\ Installer.plugin
  fi

  # remove Aspera Application Support directory if it is empty
  if [ -e /Library/Application\ Support/Aspera ]; then
    if [ "$(ls -A /Library/Application\ Support/Aspera)" ]; then
      echo "Keeping /Library/Application\ Support/Aspera directory since it is not empty"
    else
      remove_directory /Library/Application\ Support/Aspera
    fi
  fi

  remove_file_w_wildcard "/Library/Logs/Aspera" "aspera-connect*"
  remove_file_w_wildcard "/Library/Logs/Aspera" "connect*"
  remove_file_w_wildcard "/Library/Logs/Aspera" "aspera-webinstaller-plugin*.log"
  if [ "$entsrv_installed" = "no" ]; then
    remove_file  /Library/Logs/Aspera/aspera-scp*.log
  fi
  # only remove log directory if it is empty
  if [ -e /Library/Logs/Aspera ]; then
    if [ "$(ls -A /Library/Logs/Aspera)" ]; then
      echo "Keeping /Library/Logs/Aspera directory since it is not empty"
    else
      remove_directory /Library/Logs/Aspera
    fi
  fi

  remove_directory /Library/Receipts/AsperaConnect.pkg
  remove_directory /Library/Receipts/asperaconnect.pkg
  remove_directory_w_wildcard "/var/db/receipts" "connect*"
fi

# remove local user install

if [ "$user_install" = "yes" -o "$force" = "yes" ]; then
  remove_directory "$user_install_root/Aspera Connect.app"
  remove_directory "$user_install_root/Applications/Aspera Connect.app"
  remove_directory "$user_install_root/Applications/Aspera Crypt.app"
  if [ -e "$user_install_root/Applications" ]; then
    if [ "$(ls -A "$user_install_root/Applications" | sed /\.DS_Store/d)" ]; then
      echo "Keeping $user_install_root/Applications directory since it is not empty"
    else
      remove_directory "$user_install_root/Applications"
    fi
  fi

  remove_directory "$user_install_root/Library/Application Support/Applications"
  remove_directory "$user_install_root/Library/Application Support/Aspera Connect.app"
  remove_directory "$user_install_root/Library/Application Support/Aspera Crypt.app"
  remove_directory "$user_install_root/Library/Application Support/Aspera/Aspera Connect"
  remove_file  "$user_install_root/Library/Application Support/Aspera/.aspera_installer_output.log"
  remove_file  "$user_install_root/Library/Application Support/Aspera/.aspera_installer.log"
 
  remove_directory "$user_install_root/Library/Internet Plug-Ins/Aspera Web.plugin"
  remove_directory "$user_install_root/Library/Internet Plug-Ins/Aspera Web.webplugin"
  remove_directory_w_wildcard "$user_install_root/Library/Internet Plug-Ins" "Aspera Web*" 

  if [ "$remove_web_installer" = "yes" ]; then
    remove_directory "$user_install_root/Library/Application Support/Aspera/Install"
    remove_directory "$user_install_root/Library/Internet Plug-Ins/Aspera Installer.plugin"
    # browser specific plugins
    # chrome
    remove_directory "$user_install_root/Library/Application Support/Google/Chrome/Default/Extensions/aljbeaimggdioicepilcjnkphjobddok" 
    # firefox
    if [ -e "$user_install_root/Library/Application Support/Firefox/Profiles" ]; then
      remove_directory_w_wildcard "$user_install_root/Library/Application Support/Firefox/Profiles" "*asperasoft.com*"  
    fi
  fi

  if [ -e "$user_install_root/Library/Application Support/Aspera" ]; then
    if [ "$(ls -A "$user_install_root/Library/Application Support/Aspera")" ]; then
      echo "Keeping $user_install_root/Library/Application\ Support/Aspera directory since it is not empty"
    else
      remove_directory "$user_install_root/Library/Application Support/Aspera"
    fi
  fi

  # only remove log directory if it is empty
  remove_file_w_wildcard "$user_install_root/Library/Logs" "aspera-connect*.log" 
  remove_file_w_wildcard "$user_install_root/Library/Logs" "connect*.log"
  remove_file_w_wildcard "$user_install_root/Library/Logs" "aspera-webinstaller*.log"
  if [ "$entsrv_installed" = "no" ]; then
    remove_file_w_wildcard "$user_install_root/Library/Logs" "aspera-scp*"
  fi
  if [ -e "$user_install_root/Library/Logs/Aspera" ]; then
    if [ "$(ls -A "$user_install_root/Library/Logs/Aspera")" ]; then
      echo "Keeping $user_install_root/Library/Logs/Aspera directory since it is not empty"
    else
      remove_directory "$user_install_root/Library/Logs/Aspera" 
    fi
  fi

  remove_directory "$user_install_root/Library/Receipts/AsperaConnect.pkg"
  remove_directory "$user_install_root/Library/Receipts/asperaconnect.pkg"
  remove_file  "$user_install_root/Library/Receipts/com.asperasoft.connect.bom"
  remove_file  "$user_install_root/Library/Receipts/com.asperasoft.connect.plist"
fi

if [ $remove_preferences = "yes" ]; then
  remove_directory "$user_install_root/.aspera/connect"
  if [ -e "$user_install_root/.aspera" ] ; then
    if [ "$(ls -A "$user_install_root/.aspera")" ] ; then
      echo "Keeping $user_install_root/.aspera since it is not empty"
    else
      remove_directory "$user_install_root/.aspera"
    fi
  fi
  remove_file "$user_install_root/Library/Preferences/com.asperasoft.Aspera Connect.plist"
  remove_file "$user_install_root/Library/Preferences/com.asperasoft.Crypt.plist"
fi
  
# report success

echo "Aspera Connect has successfully been uninstalled"
if [ $remove_preferences = "no" ]; then
  echo "Your Connect preferences have been preserved"
fi
if [ $remove_web_installer = "no" ]; then
  echo "Aspera Web Installer is still installed"
fi


