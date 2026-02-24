#!/bin/bash

# Configuration
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "--- Verifying Dotfiles Installation ---"

check_link() {
    if [ -L "$HOME/$1" ]; then
        echo -e "${GREEN}✓${NC} Symlink created: $1"
    else
        echo -e "${RED}✗${NC} Symlink missing: $1"
        exit 1
    fi
}

check_cmd() {
    if command -v "$1" &> /dev/null; then
        echo -e "${GREEN}✓${NC} Command available: $1"
    else
        echo -e "${RED}✗${NC} Command missing: $1"
        exit 1
    fi
}

echo -e "
[1. Symlinks]"
check_link ".zshrc"
check_link ".gitconfig"
check_link ".vimrc"
check_link ".functions"
check_link ".aliases"

echo -e "
[2. Tools]"
check_cmd "brew"
check_cmd "git"
check_cmd "micro"
check_cmd "btop"
check_cmd "mise"

echo -e "
--- Verification Successful ---"
