#!/bin/sh

set -eufo pipefail
echo "run_once_before_01-system.sh"

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

echo "run_once_before_03-import-keys.sh"

echo "checking for yubikey presence"
if [[ $(gpg --card-status) ]]; then
    echo "yubikey detected"

    echo "importing public key"
    PUBLIC_KEY_URL=$(gpg --card-status 2>/dev/null | grep 'URL of public key' | sed 's/URL of public key : //g')
    curl -s $PUBLIC_KEY_URL | gpg --import
    echo $PUBLIC_KEY_URL

    echo "list keys on the yubikey"
    keys=$(gpg --card-status 2>/dev/null | grep 'Signature key\|Encryption key\|Authentication key')
    if [ -n "$keys" ]; then
        echo "gpg keys found on yubikey:"
        echo "$keys"
    else
        echo "no gpg keys found on yubikey"
    fi
else
    echo "no yubikey detected, importing"
    if [ -d "$BACKUP_MEDIA/gpg" ]; then
        gpg --import "$BACKUP_MEDIA/gpg/$KEY_ID.asc"
        gpg --import-ownertrust $BACKUP_MEDIA/gpg/ownertrust.txt
        gpg --import "$BACKUP_MEDIA/gpg/$KEY_ID.ssb.asc"
    else
        echo "$BACKUP_MEDIA/gpg does not exist, exit"
        # exit 0
    fi
fi

echo "import pass repo $HOME/.password-store"
if [ -d "$HOME/.password-store" ]; then
    echo "folder exists, skipping"
else
    echo "folder does not exist, cloning"
    if [ -d "$BACKUP_MEDIA/repos/pwds" ]; then
        git clone $BACKUP_MEDIA/repos/pwds ~/.password-store
        pass
    else
        echo "$BACKUP_MEDIA/repos/pwds does not exist, exit"
        # exit 0
    fi
fi

echo "creating personal folders"
folders=("Developer" "Projects")
for folder in "${folders[@]}"; do
    mkdir -p $HOME/$folder
done
