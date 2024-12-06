#!/bin/sh

set -eufo pipefail
echo "run_once_before_02-install-requirements.sh"

echo "installing requirements"
# brew cleanup && brew update && brew upgrade
# brew install zsh git gnupg pinentry-mac pass ykman
# brew install --cask yubico-yubikey-manager yubico-authenticator logi-options+
zsh --version
git --version
gpg --version
pass --version
