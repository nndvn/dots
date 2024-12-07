#!/bin/bash

set -eufo pipefail
echo "run_once_before_01-system.sh"

sudo apt autoremove && sudo apt update && sudo apt full-upgrade -y
