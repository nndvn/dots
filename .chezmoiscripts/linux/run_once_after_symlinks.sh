#!/bin/bash

set -eufo pipefail
echo "run_once_after_symlinks.sh"

sudo ln -s ~/.ssh/sshd_config /etc/ssh/sshd_config
