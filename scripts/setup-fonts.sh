#!/bin/bash

set -e

echo "Installing Fonts..."

OS="$(uname)"

if [ "$OS" == "Darwin" ]; then
    # macOS: Brewfile.fonts (新設) を使用
    BREWFILE="$(dirname "$0")/../macos/Brewfile.fonts"
    if [ -f "$BREWFILE" ]; then
        echo "Installing fonts via Homebrew..."
        brew bundle --file="$BREWFILE" --verbose
    fi
elif [ "$OS" == "Linux" ]; then
    # Linux: linux/external-fonts.txt (新設) を使用
    LIST="$(dirname "$0")/../linux/external-fonts.txt"
    if [ -f "$LIST" ]; then
        while IFS=':' read -r name check_cmd install_cmd || [ -n "$name" ]; do
            [[ "$name" =~ ^#.*$ || -z "$name" ]] && continue
            
            # Trim whitespace
            name="${name#"${name%%[![:space:]]*}"}"
            name="${name%"${name##*[![:space:]]}"}"
            check_cmd="${check_cmd#"${check_cmd%%[![:space:]]*}"}"
            check_cmd="${check_cmd%"${check_cmd##*[![:space:]]}"}"
            install_cmd="${install_cmd#"${install_cmd%%[![:space:]]*}"}"
            install_cmd="${install_cmd%"${install_cmd##*[![:space:]]}"}"

            if ! eval "$check_cmd" &>/dev/null; then
                echo "Installing $name..."
                eval "$install_cmd"
            else
                echo "$name is already installed."
            fi
        done < "$LIST"
    fi
fi

echo "Fonts installation complete."
