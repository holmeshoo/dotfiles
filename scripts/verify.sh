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
check_link ".zshrc_local"
check_link ".bashrc_local"
check_link ".gitconfig.local"

# Check config files in .config
CONFIG_FILES=(".config/mise/config.toml" ".config/starship.toml")
for f in "${CONFIG_FILES[@]}"; do
    if [ -L "$HOME/$f" ]; then
        echo -e "${GREEN}✓${NC} Symlink created: $f"
    else
        echo -e "${RED}✗${NC} Symlink missing: $f"
        exit 1
    fi
done

echo -e "
[2. Tools & Apps]"
# Standard tools
[ "$OS" == "Darwin" ] && check_cmd "brew"
check_cmd "git"
check_cmd "micro"
check_cmd "btop"

# Data-driven check for OS-specific external tools & apps
LISTS=()
if [ "$OS" == "Darwin" ]; then
    LISTS+=("$(dirname "$0")/../macos/external-tools.txt")
elif [ "$OS" == "Linux" ]; then
    LISTS+=("$(dirname "$0")/../linux/external-tools.txt")
    LISTS+=("$(dirname "$0")/../linux/external-apps.txt")
fi

for list_file in "${LISTS[@]}"; do
    if [ -f "$list_file" ]; then
        while IFS=':' read -r name check_cmd install_cmd || [ -n "$name" ]; do
            [[ "$name" =~ ^#.*$ || -z "$name" ]] && continue
            check_cmd=$(echo $check_cmd | xargs)
            check_cmd "$check_cmd"
        done < "$list_file"
    fi
done

echo -e "
--- Verification Successful ---"
