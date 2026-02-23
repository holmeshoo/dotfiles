#!/bin/bash

set -e

echo "Installing Heavy Applications..."

OS="$(uname)"

if [ "$OS" == "Darwin" ]; then
    # macOS: Docker Desktop, VSCode, Browsers, etc.
    echo "Installing applications via Homebrew Cask..."
    
    # Map brew cask IDs to their actual .app folder names
    declare -A app_check
    app_check=(
        ["docker"]="Docker.app"
        ["visual-studio-code"]="Visual Studio Code.app"
        ["slack"]="Slack.app"
        ["discord"]="Discord.app"
        ["arc"]="Arc.app"
        ["vivaldi"]="Vivaldi.app"
    )

    for app in "${!app_check[@]}"; do
        app_path="/Applications/${app_check[$app]}"
        
        if brew list --cask "$app" &>/dev/null || [ -d "$app_path" ]; then
            echo "$app is already installed at $app_path. Skipping..."
        else
            echo "Installing $app..."
            brew install --cask "$app"
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
