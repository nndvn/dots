#!/bin/bash

set -eufo pipefail
echo "run_once_before_03-firewall.sh"

sudo ufw status
sudo ufw enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow in on tailscale0
sudo ufw limit in 22369/tcp
sudo ufw reload
