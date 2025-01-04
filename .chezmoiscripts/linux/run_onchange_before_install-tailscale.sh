#!/bin/bash

set -eufo pipefail
gum log -sl debug "$(basename "$0")"

gum log -sl info "looking for tailscale"
if [ $(command -v tailscale) ]; then
    gum log -sl info "tailscale already installed: $(tailscale --version)"
else
    gum log -sl info "tailscale not found, installing tailscale"
    curl -fsSL https://tailscale.com/install.sh | sh
    gum log -sl info "tailscale successfully installed: $(tailscale --version)"
fi
