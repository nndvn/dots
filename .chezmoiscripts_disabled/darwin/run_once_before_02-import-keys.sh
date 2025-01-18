#!/usr/bin/env bash

# Strict error handling
set -eufo pipefail
IFS=$'\n\t'

# Script variables
readonly SCRIPT_NAME=$(basename "$0")
readonly REQUIRED_VARS=("BACKUP_MEDIA" "KEY_ID")
readonly GPG_HOME="${HOME}/.gnupg"

# Logging function
log() {
    local level=$1
    shift
    if command -v gum >/dev/null 2>&1; then
        gum log --structured --time rfc3339 --level "$level" "$@"
    else
        echo "[$level] $*" >&2
    fi
}

# Function to cleanup on exit
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log error "Script failed with exit code $exit_code"
    fi
    return $exit_code
}

trap cleanup EXIT

# Function to validate required variables
validate_variables() {
    local missing_vars=()
    for var in "${REQUIRED_VARS[@]}"; do
        if [[ -z "${!var:-}" ]]; then
            missing_vars+=("$var")
        fi
    done

    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        log error "Missing required variables: ${missing_vars[*]}"
        return 1
    fi
}

# Function to check GPG configuration
check_gpg_config() {
    if [ ! -d "$GPG_HOME" ]; then
        log info "Creating .gnupg directory"
        mkdir -p "$GPG_HOME"
        chmod 700 "$GPG_HOME"
    fi

    # Set proper permissions for GPG directory
    find "$GPG_HOME" -type f -exec chmod 600 {} \;
    find "$GPG_HOME" -type d -exec chmod 700 {} \;
}

# Function to check YubiKey
check_yubikey() {
    local retries=3
    local wait_time=2

    log info "Checking for YubiKey presence"

    while ((retries > 0)); do
        if gpg --card-status >/dev/null 2>&1; then
            log info "YubiKey detected"
            return 0
        fi
        ((retries--))
        if ((retries > 0)); then
            log warn "YubiKey not detected, waiting ${wait_time}s before retry ($retries left)"
            sleep "$wait_time"
        fi
    done

    log warn "No YubiKey detected after all retries"
    return 1
}

# Function to extract and import public key from YubiKey
import_yubikey_public_key() {
    local public_key_url
    public_key_url=$(gpg --card-status 2>/dev/null | grep 'URL of public key' | sed 's/URL of public key : //g')

    if [[ -z "$public_key_url" ]]; then
        log warn "No public key URL found on YubiKey"
        return 1
    fi

    log info "Importing public key from: $public_key_url"
    if ! curl -sSfL "$public_key_url" | gpg --import; then
        log error "Failed to import public key from URL"
        return 1
    fi

    log info "Successfully imported public key from YubiKey"
    return 0
}

# Function to list YubiKey GPG keys
list_yubikey_keys() {
    local keys
    keys=$(gpg --card-status 2>/dev/null | grep -E 'Signature key|Encryption key|Authentication key')

    if [[ -n "$keys" ]]; then
        log info "GPG keys found on YubiKey:"
        echo "$keys" | while IFS= read -r key; do
            log info "  $key"
        done
        return 0
    else
        log info "No GPG keys found on YubiKey"
        return 1
    fi
}

# Main YubiKey processing logic
process_yubikey() {
    log info "YubiKey detected, processing..."

    if ! import_yubikey_public_key; then
        log warn "Failed to import public key from YubiKey"
    fi

    if ! list_yubikey_keys; then
        log warn "Failed to list YubiKey keys"
    fi

    return 0
}

# Function to import GPG keys from backup
import_gpg_keys() {
    log info "No YubiKey detected, attempting to import keys from backup..."

    local gpg_dir="$BACKUP_MEDIA/keys/test"
    local key_file="$gpg_dir/$KEY_ID.asc"
    local ssb_file="$gpg_dir/$KEY_ID.ssb.asc"
    local trust_file="$gpg_dir/ownertrust.txt"

    # Verify backup directory exists
    if [[ ! -d "$gpg_dir" ]]; then
        log error "GPG backup directory not found: $gpg_dir"
        return 1
    fi

    # Check if key is already imported
    if gpg --list-secret-keys 2>/dev/null | grep -q "$KEY_ID"; then
        log info "Secret key $KEY_ID already imported"
        return 0
    fi

    # Verify all required files exist and are readable
    local required_files=("$key_file" "$ssb_file" "$trust_file")
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            log error "Required file not found: $file"
            return 1
        fi
        if [[ ! -r "$file" ]]; then
            log error "Required file not readable: $file"
            return 1
        fi
    done

    log info "Importing GPG keys from backup"

    # Import keys and trust with proper error handling
    if ! gpg --import "$key_file" 2>/dev/null; then
        log error "Failed to import main key"
        return 1
    fi

    if ! gpg --import-ownertrust "$trust_file" 2>/dev/null; then
        log error "Failed to import trust"
        return 1
    fi

    if ! gpg --import "$ssb_file" 2>/dev/null; then
        log error "Failed to import subkey"
        return 1
    fi

    log info "Successfully imported GPG keys"
    return 0
}

# Main execution
main() {
    log debug "Starting $SCRIPT_NAME"

    # Check if GPG is installed
    if ! command -v gpg >/dev/null 2>&1; then
        log error "GPG is not installed"
        return 1
    fi

    # Validate required variables
    validate_variables || return 1

    # Ensure GPG configuration exists
    check_gpg_config

    # Try to detect YubiKey
    if check_yubikey; then
        if ! process_yubikey; then
            log error "Failed to process YubiKey"
            return 1
        fi
    else
        if ! import_gpg_keys; then
            log error "Failed to import GPG keys"
            return 1
        fi
    fi

    log info "Script completed successfully"
    return 0
}

# Execute main function
main "$@"
