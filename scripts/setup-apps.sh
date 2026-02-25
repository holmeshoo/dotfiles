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
        while IFS=':' read -r name check_cmd install_cmd || [ -n "$name" ]; do
            [[ "$name" =~ ^#.*$ || -z "$name" ]] && continue
            
            name=$(echo $name | xargs)
            check_cmd=$(echo $check_cmd | xargs)
            install_cmd=$(echo $install_cmd | xargs)

            if ! command -v "$check_cmd" &>/dev/null; then
                echo "Installing $name..."
                eval "$install_cmd"
            else
                echo "$name is already installed. Skipping..."
            fi
        done < "$LIST"
    fi
fi

echo "Applications installed."
