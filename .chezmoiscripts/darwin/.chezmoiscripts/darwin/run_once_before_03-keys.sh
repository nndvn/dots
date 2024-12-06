#!/bin/sh

set -eufo pipefail
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
    echo "no yubikey detected"
fi
