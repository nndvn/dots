#!/bin/sh
# https://mths.be/macos
# https://macos-defaults.com

set -eufo pipefail

echo "run_once_after_configure-defaults.sh"

# pre-flight checks
# closing any system preferences panes, to prevent them from overriding changes
# killall "System Preferences"
# killall "System Settings"
osascript -e 'tell application "System Preferences" to quit'
# osascript -e 'tell application "System Settings" to quit'

# set computer name, hostname, local hostname
# sudo scutil --set ComputerName
# sudo scutil --set HostName
# sudo scutil --set LocalHostName

# dock
defaults write com.apple.dock tilesize -int 69
defaults write com.apple.dock magnification -bool true
# defaults write com.apple.dock largesize -int 128
defaults write com.apple.dock mineffect -string "genie"
# defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock autohide -bool false
defaults write com.apple.dock autohide-delay -float 0
# defaults write com.apple.dock autohide-time-modifier -float 2
# defaults write com.apple.dock persistent-apps -array # wipe all default app icons
killall Dock

# finder
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
# defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
# defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
killall Finder

# done
echo "note that some of these changes require a logout/restart to take effect"
