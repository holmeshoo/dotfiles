#!/bin/bash

set -e

echo "Installing Core Tools..."

OS="$(uname)"

if [ "$OS" == "Darwin" ]; then
    echo "Installing core tools via Homebrew..."
    
    # List of "package:command" pairs
    tools=(
        "micro:micro"
        "git:git"
        "tree:tree"
        "curl:curl"
        "cmake:cmake"
        "llvm:clang"
        "btop:btop"
        "htop:htop"
        "translate-shell:trans"
    )

    for item in "${tools[@]}"; do
        tool="${item%%:*}"
        cmd="${item##*:}"
        
        if brew list "$tool" &>/dev/null || command -v "$cmd" &>/dev/null; then
            echo "$tool is already available. Skipping..."
        else
            echo "Installing $tool..."
            brew install "$tool"
        fi
    done
elif [ "$OS" == "Linux" ]; then
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y micro git curl tree build-essential cmake gdb clang btop htop zsh translate-shell
    fi
fi

echo "Core Tools installed."
