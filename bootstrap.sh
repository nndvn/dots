#!/bin/bash

# -e: exit on error
# -u: exit on unset variables
set -eu

case "$(uname -s)" in
Darwin)
    echo "darwin platform"
    echo "looking for homebrew"
    if [ $(command -v brew) ]; then
        echo "homebrew already installed: $(brew --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
    else
    	echo "homebrew not found, installing homebrew"
    	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        echo >> $HOME/.zprofile
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    	echo "homebrew successfully installed: $(brew --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
    fi
    echo "installing requirements"
    brew install zsh git gnupg pinentry-mac pass chezmoi
    ;;
Linux)
    echo "linux platform"
    sudo apt autoremove && sudo apt update && sudo apt full-upgrade -y
    sudo apt install zsh git gpg ufw
    snap install chezmoi --classic
    ;;
*)
    echo "unsupported platform"
    exit 1
    ;;
esac

chezmoi init nndvn/dots
chezmoi apply
