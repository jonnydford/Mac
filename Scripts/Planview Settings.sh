#!/bin/sh

# Jonny Ford 
# Date of Compile: 04/12/2014
# Version 2

# Set locale to English GB GBP
defaults write NSGlobalDomain AppleLocale "en_GB"
# Set Language to British English
defaults write NSGlobalDomain AppleLanguages -array "en"
# Turn off Safari Pop-up Blocker
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool true