#!/bin/bash

set -eufo pipefail
echo "configure-system.sh"

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
sudo scutil --set LocalHostName $(echo "$DEVICE_NAME" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
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
echo "done. note that some of these changes require a logout/restart to take effect"
