#!/bin/bash

set -e

echo "Installing Heavy Applications..."

OS="$(uname)"

# 1. macOS: Heavy Apps via Brewfile.apps
if [ "$OS" == "Darwin" ]; then
    BREWFILE="$(dirname "$0")/../macos/Brewfile.apps"
    if [ -f "$BREWFILE" ]; then
        echo "Installing apps from Brewfile.apps..."
        brew bundle --file="$BREWFILE" --verbose
    fi
fi

# 2. Linux: External apps via URL/Repo (Data-driven)
if [ "$OS" == "Linux" ]; then
    LIST="$(dirname "$0")/../linux/external-apps.txt"
    if [ -f "$LIST" ]; then
        # Use sed to pre-clean whitespace around ':' and line ends
        while IFS=':' read -r name check_cmd install_cmd || [ -n "$name" ]; do
            [[ "$name" =~ ^#.*$ || -z "$name" ]] && continue
            
            if ! command -v "$check_cmd" &>/dev/null; then
                echo "Installing $name..."
                eval "$install_cmd"
            else
                echo "$name is already installed. Skipping..."
            fi
        done < <(sed 's/[[:space:]]*:[[:space:]]*/:/g; s/^[[:space:]]*//; s/[[:space:]]*$//' "$LIST")
    fi
fi

# 3. VSCode Extensions (Cross-platform)
if command -v code &>/dev/null; then
    EXT_LIST="$(dirname "$0")/../common/vscode-extensions.txt"
    if [ -f "$EXT_LIST" ]; then
        echo "Installing VSCode extensions..."
        while read -r ext || [ -n "$ext" ]; do
            [[ "$ext" =~ ^#.*$ || -z "$ext" ]] && continue
            echo "  -> $ext"
            code --install-extension "$ext" --force
        done < "$EXT_LIST"
    fi
fi

echo "Applications installed."
