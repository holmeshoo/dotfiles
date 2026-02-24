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
MISE_CONFIG="$(dirname "$0")/../common/.mise.toml"
if [ -f "$MISE_CONFIG" ]; then
    echo "Installing runtimes from $MISE_CONFIG..."
    # mise install は設定ファイルに書かれたものを一括で入れる
    mise install --yes --config "$MISE_CONFIG"
fi

echo "Runtimes setup complete!"
