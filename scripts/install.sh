#!/bin/bash

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Setting up dotfiles from $DOTFILES_DIR"

# List of files to symlink in home directory
FILES=(
    "common/.gitconfig"
    "common/.vimrc"
    "common/.editorconfig"
    "common/.aliases"
    "common/.bashrc"
    "common/.zshrc"
)

# Detect OS
OS="$(uname)"
if [ "$OS" == "Darwin" ]; then
    echo "Detected macOS"
    # macOS specific setup
elif [ "$OS" == "Linux" ]; then
    echo "Detected Linux"
    FILES+=("linux/.bashrc_local")
fi

for file in "${FILES[@]}"; do
    target="$HOME/$(basename "$file")"
    source="$DOTFILES_DIR/$file"
    
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo "Warning: $target already exists and is not a symlink. Skipping."
    else
        echo "Linking $source to $target"
        ln -sf "$source" "$target"
    fi
done

echo "Done!"
