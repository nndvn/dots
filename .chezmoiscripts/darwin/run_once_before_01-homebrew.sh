#!/bin/sh

set -eufo pipefail
echo "run_once_before_01-homebrew.sh"

echo "looking for homebrew"
if [ $(command -v brew) ]; then
	echo "homebrew already installed: $(brew --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
else
	echo "homebrew not found, installing homebrew"
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	echo "homebrew successfully installed: $(brew --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
fi
