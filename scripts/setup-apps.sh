#!/bin/bash

set -e

echo "Installing Heavy Applications..."

OS="$(uname)"

if [ "$OS" == "Darwin" ]; then
    # macOS: Docker Desktop, VSCode, Browsers, etc.
    echo "Installing applications via Homebrew Cask..."
    
    apps=(docker visual-studio-code slack discord arc vivaldi)
    for app in "${apps[@]}"; do
        if ! brew list --cask "$app" &>/dev/null; then
            echo "Installing $app..."
            brew install --cask "$app"
        else
            echo "$app is already installed. Skipping..."
        fi
    done
elif [ "$OS" == "Linux" ]; then
    # Linux: Docker Engine (Official Script)
    if ! command -v docker &> /dev/null; then
        echo "Installing Docker Engine..."
        curl -fsSL https://get.docker.com | sh
        sudo usermod -aG docker $USER
    fi

    # VSCode for Linux (using apt)
    if command -v apt-get &> /dev/null; then
        echo "Installing VS Code..."
        sudo apt-get install -y wget gpg
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
        sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
        rm -f packages.microsoft.gpg
        sudo apt-get update
        sudo apt-get install -y code
    fi
fi

echo "Applications installed."
