#!/bin/bash

set -e

echo "Installing Core Tools..."

OS="$(uname)"

# 1. Platform-specific standard packages
if [ "$OS" == "Darwin" ]; then
    BREWFILE="$(dirname "$0")/../macos/Brewfile.core"
    if [ -f "$BREWFILE" ]; then
        echo "Installing core packages from Brewfile.core..."
        brew bundle --file="$BREWFILE" --verbose
    fi
elif [ "$OS" == "Linux" ]; then
    if command -v apt-get &> /dev/null; then
        LIST="$(dirname "$0")/../linux/apt-packages.txt"
        if [ -f "$LIST" ]; then
            grep -v '^#' "$LIST" | xargs sudo apt-get install -y
        fi
    fi
fi

# 2. External tools via URL (Data-driven & Platform-aware)
# List of files to process based on OS
LISTS=()
if [ "$OS" == "Darwin" ]; then
    LISTS+=("$(dirname "$0")/../macos/external-tools.txt")
elif [ "$OS" == "Linux" ]; then
    LISTS+=("$(dirname "$0")/../linux/external-tools.txt")
fi

for list_file in "${LISTS[@]}"; do
    if [ -f "$list_file" ]; then
        echo "Processing external tools from $(basename "$list_file")..."
        while IFS=':' read -r name check_cmd install_cmd || [ -n "$name" ]; do
            [[ "$name" =~ ^#.*$ || -z "$name" ]] && continue
            
            # Trim whitespace without using xargs (which mangles quotes)
            name="${name#"${name%%[![:space:]]*}"}"
            name="${name%"${name##*[![:space:]]}"}"
            check_cmd="${check_cmd#"${check_cmd%%[![:space:]]*}"}"
            check_cmd="${check_cmd%"${check_cmd##*[![:space:]]}"}"
            install_cmd="${install_cmd#"${install_cmd%%[![:space:]]*}"}"
            install_cmd="${install_cmd%"${install_cmd##*[![:space:]]}"}"

            if ! command -v "$check_cmd" &>/dev/null; then
                echo "Installing $name..."
                eval "$install_cmd"
            else
                echo "$name is already available. Skipping..."
            fi
        done < "$list_file"
    fi
done

echo "Core Tools installed."
