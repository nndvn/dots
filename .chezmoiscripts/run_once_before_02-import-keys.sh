#!/usr/bin/env bash

set -eufo pipefail

# script variables
readonly SCRIPT_NAME=$(basename "$0")
readonly REQUIRED_VARS=("BACKUP_MEDIA" "KEY_ID")
readonly GPG_HOME="${HOME}/.gnupg"

ensure_gpg() {
    # command -v gpg &>/dev/null || gum log --structured --time rfc3339 --level error "GPG is not installed"

    # Create GPG home directory if it doesn't exist
    # [ ! -d "$GPG_HOME" ] && gpg -k
    gpg -k
}

main() {
    gum log --structured --time rfc3339 --level debug "Starting $SCRIPT_NAME"

    ensure_gpg

    gum log --structured --time rfc3339 --level info "Script completed successfully"
    exit 0
}

main "$@"
