#!/bin/sh

set -eufo pipefail
echo "run_once_before_04-folders.sh"

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
        exit 0
    fi
fi

echo "creating personal folders"
folders=("Developer" "Projects" "Test")
for folder in "${folders[@]}"; do
    mkdir -p $HOME/$folder
done
