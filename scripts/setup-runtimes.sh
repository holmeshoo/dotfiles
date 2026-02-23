#!/bin/bash

set -e

echo "Setting up Language Runtimes with mise..."

# Fix potential permission issues if previous run used sudo incorrectly
if [ -d "$HOME/.local/share/mise" ]; then
    echo "Ensuring correct permissions for mise..."
    sudo chown -R $(whoami) "$HOME/.local/share/mise" "$HOME/.local/bin" 2>/dev/null || true
fi

# 1. Install mise (Universal tool manager)
if ! command -v mise &> /dev/null; then
    echo "Installing mise..."
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
