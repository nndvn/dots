#!/bin/bash

set -eufo pipefail
echo "run_once_before_04-docker.sh"

curl -fsSL https://get.docker.com -o get-docker.sh
# sudo sh ./get-docker.sh --dry-run
sudo sh ./get-docker.sh
sudo groupadd docker
sudo usermod -aG docker $USER
