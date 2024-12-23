#!/bin/bash

set -eufo pipefail
echo "run_once_after_install-bun.sh"

echo "looking for bun"
if [ $(command -v bun) ]; then
	echo "bun already installed: $(bun --version)"
else
	echo "bun not found, installing homebrew"
	curl -fsSL https://bun.sh/install | bash
	echo "bun successfully installed: $(bun --version)"
fi
