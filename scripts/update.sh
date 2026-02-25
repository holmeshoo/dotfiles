#!/usr/bin/env bash

# Master update script for dotfiles and system tools

GREEN='\033[0;32m'
NC='\033[0m'
OS="$(uname)"
DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo -e "${GREEN}--- Updating System and Tools ---${NC}"

# Update Dotfiles Repository
echo -e "
[1/5] Updating dotfiles repository..."
cd "$DOTFILES_DIR" && git pull

# Update Package Managers
echo -e "
[2/5] Updating package manager..."
if [ "$OS" == "Darwin" ]; then
    brew update && brew upgrade
elif [ "$OS" == "Linux" ]; then
    sudo apt-get update && sudo apt-get upgrade -y
fi

# Update mise runtimes
echo -e "
[3/5] Updating mise (languages)..."
if command -v mise &>/dev/null; then
    mise self-update -y
    mise upgrade --yes
fi

# Update NPM Global Packages
echo -e "
[4/5] Updating global NPM packages..."
if command -v npm &>/dev/null; then
    npm update -g
fi

# Update Cargo Global Packages
echo -e "
[5/5] Updating global Cargo packages..."
if command -v cargo &>/dev/null; then
    # Re-run install for each package in our list to ensure latest version
    CARGO_LIST="$DOTFILES_DIR/common/cargo-packages.txt"
    if [ -f "$CARGO_LIST" ]; then
        while read -r pkg || [ -n "$pkg" ]; do
            [[ "$pkg" =~ ^#.*$ || -z "$pkg" ]] && continue
            pkg=$(echo "$pkg" | xargs)
            echo "  -> Updating $pkg"
            cargo install "$pkg"
        done < "$CARGO_LIST"
    fi
fi

echo -e "
${GREEN}--- All updates completed! ---${NC}"
