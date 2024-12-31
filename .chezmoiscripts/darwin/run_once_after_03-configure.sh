#!/bin/bash
# https://mths.be/macos
# https://macos-defaults.com

set -eufo pipefail
echo "03-configure.sh"

# pre-flight checks
# closing any system preferences panes, to prevent them from overriding changes
# killall "System Preferences"
# killall "System Settings"
# in macos monterey and earlier
osascript -e 'tell application "System Preferences" to quit'
# in macos ventura and later
osascript -e 'tell application "System Settings" to quit'

# set computer name, hostname, local hostname
sudo scutil --set ComputerName "$DEVICE_NAME"
sudo scutil --set LocalHostName $(echo "$DEVICE_NAME" | tr ' ' '-')
sudo scutil --set HostName $(echo "$DEVICE_NAME.local" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')

# dock
defaults write com.apple.dock "tilesize" -int "64"
defaults write com.apple.dock "magnification" -bool "true"
defaults write com.apple.dock "largesize" -int "128"
# defaults write com.apple.dock "mineffect" -string "genie"
defaults write com.apple.dock "mineffect" -string "suck"
defaults write com.apple.dock "show-recents" -bool "false"
# https://stackoverflow.com/a/72106853
# wipe all default app icons
defaults write com.apple.dock "persistent-apps" -array
# add app icons
for dockItem in {/System/Applications/{"Launchpad","System Settings"},/Applications/{"Brave Browser","Warp","Zed"}}.app; do
    defaults write com.apple.dock "persistent-apps" -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$dockItem</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
done
killall Dock

# finder
defaults write com.apple.finder "AppleShowAllFiles" -bool "true"
defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"
defaults write com.apple.finder "ShowHardDrivesOnDesktop" -bool "false"
defaults write com.apple.finder "ShowExternalHardDrivesOnDesktop" -bool "false"
defaults write com.apple.finder "ShowRemovableMediaOnDesktop" -bool "false"
defaults write com.apple.finder "ShowMountedServersOnDesktop" -bool "false"
killall Finder

# menu bar
defaults write com.apple.menuextra.clock "ShowSeconds" -bool "true"
defaults -currentHost write com.apple.Spotlight MenuItemHidden -bool "true"

# todo: set default browser
# todo: spotlight > raycast
# todo: spotlight off
# sudo mdutil -i off / # turn indexing off
# sudo rm -rf /.Spotlight* # delete spotlight folder
# sudo mdutil -i on / # turn indexing on
# sudo mdutil -E / # rebuild

# tailscale
# todo: need to open tailscale
# sudo tailscale up --operator=$USER

# done
echo "done. note that some of these changes require a logout/restart to take effect"
