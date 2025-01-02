#!/bin/bash

set -eufo pipefail
echo "configure-docker.sh"

sudo usermod -aG docker $USER

# done
echo "done. note that some of these changes require a logout/restart to take effect"
