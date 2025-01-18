#!/bin/bash
# todo: install requirements

set -eufo pipefail

error_exit() {
    echo "error: $1" >&2
    exit 1
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

version_number() {
    "$1" --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+'
}

keep_sudo() {
    echo "administrator password is required for \`sudo\` operations in this script"
    echo "prompting for sudo password"
    if sudo -v; then
    	echo "sudo credentials updated"
    	# keep-alive: update existing `sudo` time stamp until `install.sh` has finished
        while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
    else
    	error_exit "failed to obtain sudo credentials"
    fi
}

detect_os() {
    if [[ "$OSTYPE" == 'darwin'* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == 'linux'* ]]; then
        # todo: support for more distros
        if command_exists apt || [[ -f /etc/debian_version ]]; then
            echo "debian"
        else
            echo "unsupported"
        fi
    else
        echo "unsupported"
    fi
}

install_homebrew() {
    echo "looking for homebrew..."

    if ! command_exists brew; then
        echo "homebrew not found, installing homebrew..."

       	NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || error_exit "failed to install homebrew"

        # add homebrew to path
        # todo: only on macos arm
        if [ -f /usr/local/bin/brew ]; then
            eval "$(/usr/local/bin/brew shellenv)"
        elif [ -f /opt/homebrew/bin/brew ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            error_exit "homebrew installation not found"
        fi

        echo "homebrew successfully installed: $(version_number brew)"
    else
        echo "homebrew already installed: $(version_number brew)"
    fi
}

install_requirements() {}{
    echo "looking for requirements..."

    case "$os" in
        macos)
            export HOMEBREW_NO_ANALYTICS=1
            export HOMEBREW_NO_ENV_HINTS=1
            export HOMEBREW_NO_INSTALL_CLEANUP=1

            echo "installing macos requirements with homebrew..."
            brew install --quiet curl git gnupg || error_exit "failed to install requirements"
            ;;
        debian)
            echo "installing debian requirements with apt..."
            export DEBIAN_FRONTEND=noninteractive
            sudo apt update || error_exit "failed to update apt"
            sudo apt install -y curl git gnupg || error_exit "failed to install requirements"
            ;;
        *)
            error_exit "unsupported operating system"
            ;;
    esac

    echo "requirements successfully installed"
}

install_chezmoi() {
    echo "looking for chezmoi..."

    if ! command_exists chezmoi; then
        echo "chezmoi not found, installing chezmoi..."

        if command_exists brew; then
            export HOMEBREW_NO_ANALYTICS=1
            export HOMEBREW_NO_ENV_HINTS=1
            export HOMEBREW_NO_INSTALL_CLEANUP=1
            brew install --quiet chezmoi
        elif command_exists snap; then
            sudo snap install chezmoi --classic
        else
            sh -c "$(curl -fsLS get.chezmoi.io)" || error_exit "failed to install chezmoi"
            export PATH="$HOME/bin:$PATH"
        fi

        echo "chezmoi successfully installed: $(version_number chezmoi)"
    else
        echo "chezmoi already installed: $(version_number chezmoi)"
    fi
}

init_chezmoi() {
    echo "initializing chezmoi..."

    if ! command_exists chezmoi; then
        error_exit "chezmoi installation not found"
    else
        chezmoi init --apply "$CHEZMOI_GIT_REPO"
    fi
}

main() {
    keep_sudo

    echo "detecting operating system..."
    os=$(detect_os)

    case "$os" in
        macos)
            echo "running on macos"
            # todo: system update
            # echo "updating system..." && sudo softwareupdate --install --all
            install_homebrew
            install_chezmoi
            ;;
        debian)
            echo "running on debian"
            # export DEBIAN_FRONTEND=noninteractive
            # sudo apt update
            # sudo apt install -y curl git gnupg
            install_chezmoi
            ;;
        *)
            error_exit "unsupported operating system (macos & debian-based only)"
            ;;
    esac

    init_chezmoi
}

main
