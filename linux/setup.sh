#!/bin/bash

echo "Starting Linux setup..."

# Example: Install basic tools if using apt
if command -v apt-get &> /dev/null; then
    echo "Detected Debian/Ubuntu-based system. Updating packages..."
    sudo apt-get update
fi

# Link VSCode settings
VSCODE_SETTING_DIR="$HOME/.config/Code/User"
mkdir -p "$VSCODE_SETTING_DIR"
ln -sf "$(cd "$(dirname "$0")" && pwd)/../common/vscode/settings.json" "$VSCODE_SETTING_DIR/settings.json"

echo "Linux setup complete."
