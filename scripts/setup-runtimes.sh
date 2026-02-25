#!/usr/bin/env bash

set -e

echo "Setting up Language Runtimes with mise..."

# Install mise 
if ! command -v mise &> /dev/null; then
    echo "Installing mise..."
    mkdir -p "$HOME/.local/bin"
    curl https://mise.jdx.dev/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

# Initialize mise
eval "$(mise activate bash)"

# Install all tools defined in .mise.toml
echo "Installing runtimes via mise..."
mise install --yes

echo "Runtimes setup complete!"
