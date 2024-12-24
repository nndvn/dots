#!/bin/bash

set -eufo pipefail
echo "run_once_before_01-system.sh"

# update & upgrade
sudo apt autoremove && sudo apt update && sudo apt full-upgrade -y

# install requirements
sudo apt install zsh git gpg ufw

# change shell to zsh
sudo chsh -s /bin/zsh $USER
