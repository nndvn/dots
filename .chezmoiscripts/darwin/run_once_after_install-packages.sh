#!/bin/bash

set -eufo pipefail
echo "run_once_after_install-packages.sh"

echo "installing packages"
# brew bundle install --no-lock > /dev/null
brew bundle install --no-lock
