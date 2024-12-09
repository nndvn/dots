#!/bin/bash

set -eufo pipefail
echo "run_once_before_03-firewall.sh"

# check if ufw is active
ufw_status=$(sudo ufw status | grep -w "Status:")

if [[ $ufw_status == *"Status: active"* ]]; then
    echo "ufw is active"
else
    echo "ufw is inactive"
    sudo ufw enable
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow in on tailscale0
    # sudo ufw limit in 22369/tcp
    sudo ufw reload
fi
