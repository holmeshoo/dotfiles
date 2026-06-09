#!/bin/bash

set -e

echo "Installing Heavy Applications..."

OS="$(uname)"

# macOS: Heavy Apps via Brewfile.apps
if [ "$OS" == "Darwin" ]; then
    BREWFILE="$(dirname "$0")/../macos/Brewfile.apps"
    if [ -f "$BREWFILE" ]; then
        echo "Installing apps from Brewfile.apps..."
        brew bundle --file="$BREWFILE" --verbose
    fi
fi

# Linux: External apps via URL/Repo (Data-driven)
if [ "$OS" == "Linux" ]; then
    LIST="$(dirname "$0")/../linux/external-apps.txt"
    if [ -f "$LIST" ]; then
        while read -r line || [ -n "$line" ]; do
            [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
            
            # Safely split by the first two colons only
            name=$(echo "$line" | cut -d: -f1 | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
            check_cmd=$(echo "$line" | cut -d: -f2 | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
            install_cmd=$(echo "$line" | cut -d: -f3- | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')

            if ! command -v "$check_cmd" &>/dev/null; then
                echo "Installing $name..."
                eval "$install_cmd"
            else
                echo "$name is already installed. Skipping..."
            fi
        done < "$LIST"
    fi
fi

# VSCode Extensions (Cross-platform)
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
