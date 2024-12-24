#!/bin/sh

# -e: exit on error
# -u: exit on unset variables
set -eu

case "$(uname -s)" in
Darwin)
    echo "darwin platform"
    sudo softwareupdate --install --all
    sudo softwareupdate --install-rosetta --agree-to-license
    xcode-select --install
    echo "looking for homebrew"
    if [ $(command -v brew) ]; then
        echo "homebrew already installed: $(brew --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
    else
    	echo "homebrew not found, installing homebrew"
    	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    	echo "homebrew successfully installed: $(brew --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
    fi
    ;;
Linux)
    echo "linux platform"
    sudo apt autoremove && sudo apt update && sudo apt upgrade -y
    exit 1
    ;;
*)
    echo "unsupported platform"
    exit 1
    ;;
esac
