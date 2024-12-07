#!/bin/bash

set -eufo pipefail
echo "run_once_before_04-docker.sh"

if [ $(command -v docker) ]; then
    echo "docker already installed: $(docker --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
else
    echo "docker not found, installing docker"
    curl -fsSL https://get.docker.com -o get-docker.sh
    # sudo sh ./get-docker.sh --dry-run
    sudo sh ./get-docker.sh
fi

# sudo groupadd docker
sudo usermod -aG docker $USER
