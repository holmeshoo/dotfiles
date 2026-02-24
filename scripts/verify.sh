#!/bin/bash

# --- Path Settings for Verification ---
OS="$(uname)"

# Load Homebrew only on macOS
if [ "$OS" == "Darwin" ]; then
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

# Load mise and local bin
export PATH="$HOME/.local/bin:$PATH"
if command -v mise &> /dev/null; then
    eval "$(mise activate bash)"
fi

# --- Configuration ---
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "--- Verifying Dotfiles Installation ($OS) ---"

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
        echo -e "${GREEN}✓${NC} Command available: $1 ($(which $1))"
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
# brew is only required on macOS
[ "$OS" == "Darwin" ] && check_cmd "brew"
check_cmd "git"
check_cmd "micro"
check_cmd "btop"
check_cmd "mise"

echo -e "
--- Verification Successful ---"
