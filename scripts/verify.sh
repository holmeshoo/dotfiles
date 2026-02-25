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
TEST_FONTS=false

if [[ "$#" -eq 0 ]]; then
    TEST_CORE=true
    TEST_RUNTIME=true
    TEST_APPS=true
    TEST_FONTS=true
else
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --all) TEST_CORE=true; TEST_RUNTIME=true; TEST_APPS=true; TEST_FONTS=true ;;
            --core) TEST_CORE=true ;;
            --runtime) TEST_RUNTIME=true ;;
            --apps) TEST_APPS=true ;;
            --fonts) TEST_FONTS=true ;;
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

# New smarter check function
check_status() {
    local name="$1"
    local check_expr="$2"
    if eval "$check_expr" &>/dev/null; then
        echo -e "${GREEN}✓${NC} $name available"
    else
        echo -e "${RED}✗${NC} $name missing (Checked via: $check_expr)"
        exit 1
    fi
}

# --- 1. Symlinks ---
echo -e "\n[1. Symlinks]"
LINKS_FILE="$(dirname "$0")/../common/links.txt"
if [ -f "$LINKS_FILE" ]; then
    while IFS=':' read -r src dst || [ -n "$src" ]; do
        [[ "$src" =~ ^#.*$ || -z "$src" ]] && continue
        check_link "$(echo $dst | xargs)"
    done < "$LINKS_FILE"
fi

# --- 2. Core Tools ---
if [ "$TEST_CORE" = true ]; then
    echo -e "\n[2. Core Tools]"
    if [ "$OS" == "Darwin" ]; then
        check_status "Homebrew" "command -v brew"
        BREWFILE="$(dirname "$0")/../macos/Brewfile.core"
        if [ -f "$BREWFILE" ]; then
            grep '^brew "' "$BREWFILE" | sed 's/brew "\(.*\)"/\1/' | while read -r pkg; do
                case $pkg in
                    llvm) check_status "llvm" "command -v clang" ;;
                    translate-shell) check_status "trans" "command -v trans" ;;
                    cocoapods) check_status "cocoapods" "command -v pod" ;;
                    git-delta) check_status "delta" "command -v delta" ;;
                    *) check_status "$pkg" "command -v $pkg" ;;
                esac
            done
        fi
    elif [ "$OS" == "Linux" ]; then
        LIST="$(dirname "$0")/../linux/apt-packages.txt"
        if [ -f "$LIST" ]; then
            grep -v '^#' "$LIST" | while read -r pkg; do
                case $pkg in
                    build-essential) check_status "make" "command -v make" ;;
                    translate-shell) check_status "trans" "command -v trans" ;;
                    *) check_status "$pkg" "command -v $pkg" ;;
                esac
            done
        fi
    fi
    
    # OS-specific external tools
    EXT_TOOLS=""
    [ "$OS" == "Darwin" ] && EXT_TOOLS="$(dirname "$0")/../macos/external-tools.txt"
    [ "$OS" == "Linux" ] && EXT_TOOLS="$(dirname "$0")/../linux/external-tools.txt"
    if [ -f "$EXT_TOOLS" ]; then
        while IFS=':' read -r name check_expr inst || [ -n "$name" ]; do
            [[ "$name" =~ ^#.*$ || -z "$name" ]] && continue
            check_status "$(echo $name | xargs)" "$(echo $check_expr | xargs)"
        done < "$EXT_TOOLS"
    fi
fi

# --- 3. Runtimes ---
if [ "$TEST_RUNTIME" = true ]; then
    echo -e "\n[3. Runtimes]"
    check_status "mise" "command -v mise"
fi

# --- 4. Apps ---
if [ "$TEST_APPS" = true ]; then
    echo -e "\n[4. Heavy Applications]"
    if [ "$OS" == "Darwin" ]; then
        BREWFILE="$(dirname "$0")/../macos/Brewfile.apps"
        if [ -f "$BREWFILE" ]; then
            grep '^cask "' "$BREWFILE" | sed 's/cask "\(.*\)"/\1/' | while read -r pkg; do
                case $pkg in
                    visual-studio-code) check_status "vscode" "command -v code" ;;
                    thebrowsercompany-dia) check_status "dia" "command -v dia" ;;
                    vivaldi) check_status "vivaldi" "command -v vivaldi" ;;
                    android-studio) check_status "android-studio" "command -v studio" ;;
                esac
            done
            grep '^brew "' "$BREWFILE" | sed 's/brew "\(.*\)"/\1/' | while read -r pkg; do
                check_status "$pkg" "command -v $pkg"
            done
        fi
    elif [ "$OS" == "Linux" ]; then
        LIST="$(dirname "$0")/../linux/external-apps.txt"
        if [ -f "$LIST" ]; then
            while IFS=':' read -r name check_expr inst || [ -n "$name" ]; do
                [[ "$name" =~ ^#.*$ || -z "$name" ]] && continue
                check_status "$(echo $name | xargs)" "$(echo $check_expr | xargs)"
            done < "$LIST"
        fi
    fi
fi

echo -e "\n--- Verification Successful ---"
