#!/bin/bash

set -eufo pipefail
echo "configure-system.sh"

# change shell
if [[ "$SHELL" == "$(which zsh)" ]]; then
    echo "current shell is zsh"
else
    echo "current shell is not zsh, set zsh as default shell..."
    sudo chsh -s $(which zsh) $USER
fi

# set hostname
sudo hostnamectl set-hostname $(echo "$DEVICE_NAME" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
sudo hostnamectl set-hostname "$DEVICE_NAME" --pretty

# done
echo "done. note that some of these changes require a logout/restart to take effect"
