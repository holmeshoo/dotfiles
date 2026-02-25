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

# 3. Install Global NPM Packages
if command -v npm &> /dev/null; then
    NPM_LIST="$(dirname "$0")/../common/npm-packages.txt"
    if [ -f "$NPM_LIST" ]; then
        echo "Installing global NPM packages..."
        while read -r pkg || [ -n "$pkg" ]; do
            [[ "$pkg" =~ ^#.*$ || -z "$pkg" ]] && continue
            pkg=$(echo "$pkg" | xargs)
            echo "  -> $pkg"
            npm install -g "$pkg"
        done < "$NPM_LIST"
    fi
fi

# 4. Install Global Cargo Packages
if command -v cargo &> /dev/null; then
    CARGO_LIST="$(dirname "$0")/../common/cargo-packages.txt"
    if [ -f "$CARGO_LIST" ]; then
        echo "Installing global Cargo packages..."
        while read -r pkg || [ -n "$pkg" ]; do
            [[ "$pkg" =~ ^#.*$ || -z "$pkg" ]] && continue
            pkg=$(echo "$pkg" | xargs)
            echo "  -> $pkg"
            cargo install "$pkg"
        done < "$CARGO_LIST"
    fi
fi

echo "Runtimes setup complete!"
