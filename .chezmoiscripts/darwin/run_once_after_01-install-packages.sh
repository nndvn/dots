#!/bin/bash

set -eufo pipefail
echo "run_once_after_01-install-packages.sh"

echo "installing packages"
# check if .brewfile exists
if [ -f .brewfile ]; then
    # install packages using brew bundle
    # brew bundle install
    # brew bundle install --no-lock > /dev/null
    brew bundle install --no-lock --file=~/.brewfile
else
    echo "no .brewfile found"
fi
