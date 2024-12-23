#!/bin/sh

set -eufo pipefail
echo "run_once_before_01-homebrew.sh"

# sudo softwareupdate -i -a
xcode-select --install || echo "xcode cli already installed"

# echo "looking for xcode cli"
# xcode-select -p &>/dev/null
# if [ $? -ne 0 ]; then
#     echo "xcode cli not found, installing xcode cli"
#     xcode-select --install

#     if [ $? -eq 0 ]; then
#         echo "xcode cli successfully installed: $(xcode-select --version | grep -oE '[0-9]*\.?[0-9]+')"
#     else
#         echo "xcode cli error"
#     fi
# else
#     echo "xcode cli already installed: $(xcode-select --version | grep -oE '[0-9]*\.?[0-9]+')"
# fi

echo "looking for homebrew"
if [ $(command -v brew) ]; then
	echo "homebrew already installed: $(brew --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
else
	echo "homebrew not found, installing homebrew"
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	echo "homebrew successfully installed: $(brew --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
fi
