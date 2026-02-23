#!/bin/bash

set -e

echo "Installing Heavy Applications..."

OS="$(uname)"

if [ "$OS" == "Darwin" ]; then
    # macOS: VSCode, Dia browser, and Lightweight Docker (Colima)
    echo "Installing applications..."
    
    # 1. Cask applications (GUI)
    apps=(
        "visual-studio-code:Visual Studio Code.app"
        "thebrowsercompany-dia:Dia.app"
    )

    for item in "${apps[@]}"; do
        app="${item%%:*}"
        app_name="${item##*:}"
        app_path="/Applications/$app_name"
        
        if brew list --cask "$app" &>/dev/null || [ -d "$app_path" ]; then
            echo "$app is already installed at $app_path. Skipping..."
        else
            echo "Installing $app..."
            brew install --cask "$app"
        fi
    done

    # 2. Lightweight Docker setup (Colima + Docker CLI)
    if ! command -v colima &> /dev/null; then
        echo "Installing Colima and Docker CLI..."
        brew install colima docker docker-compose
        echo "Note: Run 'colima start' to start the Docker daemon."
    else
        echo "Colima is already installed. Skipping..."
    fi
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
