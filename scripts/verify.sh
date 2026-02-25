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

# --- Arguments Parsing ---
TEST_CORE=false
TEST_RUNTIME=false
TEST_APPS=false

if [[ "$#" -eq 0 ]]; then
    # Default: Test everything if no arguments
    TEST_CORE=true
    TEST_RUNTIME=true
    TEST_APPS=true
else
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --all) TEST_CORE=true; TEST_RUNTIME=true; TEST_APPS=true ;;
            --core) TEST_CORE=true ;;
            --runtime) TEST_RUNTIME=true ;;
            --apps) TEST_APPS=true ;;
        esac
        shift
    done
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
LINKS_FILE="$(dirname "$0")/../common/links.txt"
if [ -f "$LINKS_FILE" ]; then
    while IFS=':' read -r src_rel dst_rel || [ -n "$src_rel" ]; do
        [[ "$src_rel" =~ ^#.*$ || -z "$src_rel" ]] && continue
        dst_rel=$(echo $dst_rel | xargs)
        check_link "$dst_rel"
    done < "$LINKS_FILE"
else
    echo -e "${RED}✗${NC} LINKS_FILE not found: $LINKS_FILE"
    exit 1
fi

echo -e "
[2. Tools & Apps]"

if [ "$TEST_CORE" = true ]; then
    echo "Verifying Core Tools..."
    [ "$OS" == "Darwin" ] && check_cmd "brew"
    check_cmd "git"
    check_cmd "micro"
    check_cmd "btop"
    check_cmd "starship"
fi

if [ "$TEST_RUNTIME" = true ]; then
    echo "Verifying Runtimes..."
    check_cmd "mise"
    # Note: Languages themselves (node, etc.) might need a shell restart to be in PATH
fi

if [ "$TEST_APPS" = true ]; then
    echo "Verifying Heavy Applications..."
    check_cmd "code"
    check_cmd "vivaldi"
    [ "$OS" == "Darwin" ] && check_cmd "colima"
fi

echo -e "
--- Verification Successful ---"
