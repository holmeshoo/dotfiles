#!/bin/bash

set -e

echo "Setting up Language Runtimes with mise..."

# 0. Clean up potential root-owned or broken installations
if [ "$1" == "--clean" ]; then
    echo "Cleaning up existing mise installation..."
    sudo rm -rf "$HOME/.local/bin/mise" "$HOME/.local/share/mise" "$HOME/.cache/mise" "$HOME/.config/mise" 2>/dev/null || true
fi

# 1. Install mise (Universal tool manager)
if ! command -v mise &> /dev/null; then
    echo "Installing mise..."
    mkdir -p "$HOME/.local/bin"
    curl https://mise.jdx.dev/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

# Initialize mise
eval "$(mise activate bash)"

# 2. Install all tools defined in .mise.toml
# .mise.toml は install.sh によって ~/.config/mise/config.toml にリンク済み
echo "Installing runtimes via mise..."
mise install --yes

echo "Runtimes setup complete!"
