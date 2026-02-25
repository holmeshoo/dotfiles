#!/usr/bin/env bash

set -e

echo "Installing Core Tools..."

OS="$(uname)"
DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Platform-specific standard packages
if [ "$OS" == "Darwin" ]; then
    BREWFILE="$DOTFILES_DIR/macos/Brewfile.core"
    if [ -f "$BREWFILE" ]; then
        echo "Installing core packages from Brewfile.core..."
        brew bundle --file="$BREWFILE" --verbose
    fi
elif [ "$OS" == "Linux" ]; then
    if command -v apt-get &> /dev/null; then
        LIST="$DOTFILES_DIR/linux/apt-packages.txt"
        if [ -f "$LIST" ]; then
            grep -v '^#' "$LIST" | xargs sudo apt-get install -y
        fi
    fi
fi

# External tools via URL
LISTS=()
if [ "$OS" == "Darwin" ]; then
    LISTS+=("$DOTFILES_DIR/macos/external-tools.txt")
elif [ "$OS" == "Linux" ]; then
    LISTS+=("$DOTFILES_DIR/linux/external-tools.txt")
fi

for list_file in "${LISTS[@]}"; do
    if [ -f "$list_file" ]; then
        echo "Processing external tools from $(basename "$list_file")..."
        while IFS=':' read -r name check_cmd install_cmd || [ -n "$name" ]; do
            [[ "$name" =~ ^#.*$ || -z "$name" ]] && continue
            
            if ! eval "$check_cmd" &>/dev/null; then
                echo "Installing $name..."
                eval "$install_cmd"
            else
                echo "$name is already available. Skipping..."
            fi
        done < <(sed 's/[[:space:]]*:[[:space:]]*/:/g; s/^[[:space:]]*//; s/[[:space:]]*$//' "$list_file")
    fi
done

# Ensure mise and core runtimes are present for global packages
if ! command -v mise &> /dev/null; then
    echo "Forcing mise installation for global packages..."
    curl https://mise.jdx.dev/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

eval "$(mise activate bash)"

# Global NPM Packages 
NPM_LIST="$DOTFILES_DIR/common/npm-packages.txt"
if [ -f "$NPM_LIST" ]; then
    echo "Ensuring Node.js is available via mise..."
    mise use --global node@lts
    
    echo "Installing global NPM packages..."
    while read -r pkg || [ -n "$pkg" ]; do
        [[ "$pkg" =~ ^#.*$ || -z "$pkg" ]] && continue
        echo "  -> $pkg"
        npm install -g "$pkg"
    done < <(sed 's/^[[:space:]]*//; s/[[:space:]]*$//' "$NPM_LIST")
fi

# Global Cargo Packages 
CARGO_LIST="$DOTFILES_DIR/common/cargo-packages.txt"
if [ -f "$CARGO_LIST" ]; then
    echo "Ensuring Rust is available via mise..."
    mise use --global rust@latest
    
    echo "Installing global Cargo packages..."
    while read -r pkg || [ -n "$pkg" ]; do
        [[ "$pkg" =~ ^#.*$ || -z "$pkg" ]] && continue
        echo "  -> $pkg"
        cargo install "$pkg"
    done < <(sed 's/^[[:space:]]*//; s/[[:space:]]*$//' "$CARGO_LIST")
fi

echo "Core Tools installed."
