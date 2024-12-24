#!/bin/sh

set -eufo pipefail
echo "run_once_before_01-homebrew.sh"

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
brew cleanup && brew update && brew upgrade
brew install zsh git gnupg pinentry-mac pass
# ykman
# brew install --cask yubico-yubikey-manager yubico-authenticator logi-options+
zsh --version
git --version
gpg --version
pass --version
#ykman --version
