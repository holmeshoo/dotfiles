#!/usr/bin/env bash

set -e

echo "Installing Fonts..."

OS="$(uname)"

# Function to install from external-fonts.txt
install_from_list() {
    local list_file="$1"
    if [ -f "$list_file" ]; then
        echo "Processing external fonts from $(basename "$list_file")..."
        while IFS=':' read -r name check_cmd install_cmd || [ -n "$name" ]; do
            [[ "$name" =~ ^#.*$ || -z "$name" ]] && continue
            
            if ! eval "$check_cmd" &>/dev/null; then
                echo "Installing $name..."
                eval "$install_cmd"
            else
                echo "$name is already installed."
            fi
        done < <(sed 's/[[:space:]]*:[[:space:]]*/:/g; s/^[[:space:]]*//; s/[[:space:]]*$//' "$list_file")
    fi
}

# macOS specific: Brewfile.fonts
if [ "$OS" == "Darwin" ]; then
    BREWFILE="$(dirname "$0")/../macos/Brewfile.fonts"
    if [ -f "$BREWFILE" ]; then
        echo "Installing fonts via Homebrew..."
        brew bundle --file="$BREWFILE" --verbose
    fi
fi

# From external external-fonts.txt
if [ "$OS" == "Darwin" ]; then
    install_from_list "$(dirname "$0")/../macos/external-fonts.txt"
elif [ "$OS" == "Linux" ]; then
    install_from_list "$(dirname "$0")/../linux/external-fonts.txt"
fi

echo "Fonts installation complete."
