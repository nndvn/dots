#!/usr/bin/env bash

# script configuration
set -eufo pipefail

# color definitions
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # no color

# logging functions
log_info() { echo -e "${GREEN}[INFO]${NC} $*" >&2; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*" >&2; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# error handling
error_exit() {
    log_error "$1"
    exit 1
}

# trap errors
trap 'error_exit "An unexpected error occurred on line $LINENO"' ERR

# utility functions
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

version_number() {
    "$1" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1
}

keep_sudo() {
    log_info "Administrator privileges are required for some operations"
    if ! sudo -v; then
        error_exit "Failed to obtain sudo credentials"
    fi

    # keep sudo alive
    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" || exit
    done 2>/dev/null &
}

detect_os() {
    case "$OSTYPE" in
        darwin*)
            echo "macos"
            ;;
        linux*)
            if [ -f /etc/debian_version ]; then
                echo "debian"
            elif [ -f /etc/fedora-release ]; then
                echo "fedora"
            elif [ -f /etc/redhat-release ]; then
                echo "redhat"
            elif [ -f /etc/arch-release ]; then
                echo "arch"
            else
                echo "unsupported"
            fi
            ;;
        *)
            echo "unsupported"
            ;;
    esac
}

install_homebrew() {
    log_info "Checking for Homebrew..."
    if ! command_exists brew; then
        log_info "Installing Homebrew..."
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" ||
            error_exit "Failed to install Homebrew"

        # configure homebrew path
        if [ -f /usr/local/bin/brew ]; then
            eval "$(/usr/local/bin/brew shellenv)"
        elif [ -f /opt/homebrew/bin/brew ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            error_exit "Homebrew installation not found"
        fi

        log_info "Homebrew $(version_number brew) installed successfully"
    else
        log_info "Homebrew $(version_number brew) already installed"
    fi
}

install_packages() {
    log_info "Installing required packages..."
    case "$1" in
        macos)
            # set homebrew environment variables
            export HOMEBREW_NO_ENV_HINTS=1
            export HOMEBREW_NO_ANALYTICS=1
            export HOMEBREW_NO_AUTO_UPDATE=1
            export HOMEBREW_NO_INSTALL_CLEANUP=1

            # install all packages including chezmoi via homebrew
            brew install --quite zsh git gnupg gum chezmoi
            ;;

        debian)
            # set debian environment variables
            export DEBIAN_FRONTEND=noninteractive

            sudo apt-get update
            sudo apt-get install -y zsh git gnupg curl

            # install gum from charm.sh
            sudo mkdir -p /etc/apt/keyrings
            curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
            echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
            sudo apt-get update
            sudo apt-get install -y gum

            # install chezmoi
            if command_exists snap; then
                sudo snap install chezmoi --classic
            else
                sh -c "$(curl -fsLS get.chezmoi.io)"
                export PATH="$HOME/bin:$PATH"
            fi
            ;;

        *)
            log_warn "Package installation not implemented for this OS"
            ;;
    esac

    # verify installations
    for pkg in zsh git gpg gum chezmoi; do
        if ! command_exists "$pkg"; then
            error_exit "Failed to install $pkg"
        fi
        log_info "$pkg $(version_number "$pkg" 2>/dev/null || echo 'unknown version') installed"
    done
}

init_chezmoi() {
    log_info "Initializing chezmoi..."
    if ! command_exists chezmoi; then
        error_exit "chezmoi installation not found"
    fi

    if [ -z "${CHEZMOI_REPO:-}" ]; then
        error_exit "CHEZMOI_REPO environment variable not set"
    fi

    # chezmoi init --apply "$CHEZMOI_REPO"
    if [ -d "$HOME/.config/chezmoi" ]; then
        log_warn "chezmoi already initialized at $HOME/.config/chezmoi"
        log_info "Re-initializing chezmoi..."
        # chezmoi init --force --apply "$CHEZMOI_REPO"
    else
        log_info "First time initializing chezmoi..."
        chezmoi init --apply "$CHEZMOI_REPO"
    fi
}

main() {
    log_info "Starting installation..."
    keep_sudo

    log_info "Detecting operating system..."
    os=$(detect_os)

    case "$os" in
        macos)
            log_info "Running on macOS"
            # uncomment to enable system updates
            # log_info "Updating system..."
            # sudo softwareupdate --install --all
            install_homebrew
            install_packages "$os"
            ;;
        debian)
            log_info "Running on Debian"
            install_packages "$os"
            ;;
        *)
            error_exit "Unsupported operating system: $os"
            ;;
    esac

    init_chezmoi
    log_info "Installation completed successfully"
    fastfetch
}

# only execute if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
