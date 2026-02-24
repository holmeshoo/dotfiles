#!/bin/bash

set -e

echo "Installing Heavy Applications..."

OS="$(uname)"

if [ "$OS" == "Darwin" ]; then
    # macOS のアプリは setup-tools.sh で実行される brew bundle (Brewfile) に集約されました。
    echo "macOS apps are managed via Brewfile in the tools step."
elif [ "$OS" == "Linux" ]; then
    # Linux: Docker Engine (Official Script)
    if ! command -v docker &> /dev/null; then
        echo "Installing Docker Engine..."
        curl -fsSL https://get.docker.com | sh
        sudo usermod -aG docker $USER
    fi

    # VSCode for Linux (using apt)
    if ! command -v code &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            echo "Installing VS Code..."
            wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/vscode.gpg > /dev/null
            echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/vscode.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
            sudo apt-get update && sudo apt-get install -y code
        fi
    fi

    # Vivaldi for Linux
    if ! command -v vivaldi &> /dev/null; then
        echo "Installing Vivaldi browser..."
        if command -v apt-get &> /dev/null; then
            wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/vivaldi-browser.gpg
            echo "deb [signed-by=/usr/share/keyrings/vivaldi-browser.gpg arch=$(dpkg --print-architecture)] https://repo.vivaldi.com/archive/deb/ stable main" | sudo tee /etc/apt/sources.list.d/vivaldi.list
            sudo apt-get update && sudo apt-get install -y vivaldi-stable
        fi
    fi
fi

echo "Applications installed."
