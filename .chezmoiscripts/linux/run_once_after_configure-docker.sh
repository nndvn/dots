#!/bin/bash

set -eufo pipefail
echo "configure-docker.sh"

if groups | grep -q docker; then
  echo "current user is in the 'docker' group"
else
  echo "current user is not in the 'docker' group"
  sudo usermod -aG docker $USER
fi

# done
echo "done. note that some of these changes require a logout/restart to take effect"
