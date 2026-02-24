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
    # Ensure bin directory exists
    mkdir -p "$HOME/.local/bin"
    curl https://mise.jdx.dev/install.sh | sh
    # Add to PATH for current session
    export PATH="$HOME/.local/bin:$PATH"
fi

# Initialize mise for current session
eval "$(mise activate bash)"

# 2. Install Node.js (Latest LTS)
echo "Installing Node.js..."
mise use -g node@lts

# 3. Install Python and uv
echo "Installing uv (Python package manager)..."
mise use -g uv@latest
echo "Setting up Python via uv..."
uv python install

# 4. Install Rust
echo "Installing Rust..."
mise use -g rust@latest

# 5. Install Java (OpenJDK 21 LTS)
echo "Installing Java..."
mise use -g java@openjdk-21

# 6. Install Go (Latest)
echo "Installing Go..."
mise use -g go@latest

echo "Runtimes setup complete!"
echo "Note: Restart your shell or run 'source ~/.bashrc' (or ~/.zshrc) to use these tools."
