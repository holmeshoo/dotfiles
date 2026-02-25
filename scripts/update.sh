#!/bin/bash

# Master update script for dotfiles and system tools

GREEN='\033[0;32m'
NC='\033[0m'
OS="$(uname)"

echo -e "${GREEN}--- Updating System and Tools ---${NC}"

# 1. Update Dotfiles Repository
echo -e "
[1/4] Updating dotfiles repository..."
cd "$(dirname "$0")/.." && git pull

# 2. Update Package Managers
echo -e "
[2/4] Updating package manager..."
if [ "$OS" == "Darwin" ]; then
    brew update && brew upgrade
elif [ "$OS" == "Linux" ]; then
    sudo apt-get update && sudo apt-get upgrade -y
fi

# 3. Update mise runtimes
echo -e "
[3/4] Updating mise (languages)..."
if command -v mise &>/dev/null; then
    mise self-update -y
    mise upgrade --yes
fi

# 4. Update Starship
echo -e "
[4/4] Updating Starship..."
if command -v starship &>/dev/null; then
    if [ "$OS" == "Linux" ]; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi
    # On macOS, brew upgrade handled it.
fi

echo -e "
${GREEN}--- All updates completed! ---${NC}"
