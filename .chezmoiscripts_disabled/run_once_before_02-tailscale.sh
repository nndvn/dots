#!/bin/bash

set -eufo pipefail
echo "run_once_before-02_tailscale.sh"

if [ $(command -v tailscale) ]; then
    echo "tailscale already installed: $(tailscale --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
else
    echo "tailscale not found, installing tailscale"
    curl -fsSL https://pkgs.tailscale.com/stable/debian/bookworm.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
    curl -fsSL https://pkgs.tailscale.com/stable/debian/bookworm.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
    sudo apt update
    sudo apt install tailscale -y
    sudo tailscale up --operator=$USER
fi

tailscale status
