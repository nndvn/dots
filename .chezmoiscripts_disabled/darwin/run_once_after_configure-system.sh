#!/bin/bash

set -eufo pipefail
gum log -sl debug "$(basename "$0")"

# change shell
if [[ "$SHELL" == "$(which zsh)" ]]; then
    echo "current shell is zsh"
else
    echo "current shell is not zsh, set zsh as default shell..."
    sudo chsh -s $(which zsh) $USER
fi

# pre-flight checks
# closing any system preferences panes, to prevent them from overriding changes
# killall "System Preferences"
# killall "System Settings"
# in macos monterey and earlier
osascript -e 'tell application "System Preferences" to quit'
# in macos ventura and later
osascript -e 'tell application "System Settings" to quit'

# set computer name, hostname, local hostname
# sudo scutil --set ComputerName "$DEVICE_NAME"
# sudo scutil --set LocalHostName $(echo "$DEVICE_NAME" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
# sudo scutil --set HostName $(echo "$DEVICE_NAME.local" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')

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
gum log -sl info 'Done applying macOS settings'
gum log -sl warn 'Note that some of these changes may require a logout/restart to take effect'
