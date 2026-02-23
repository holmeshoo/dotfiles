#!/bin/bash

set -e

echo "Installing Core Tools..."

OS="$(uname)"

if [ "$OS" == "Darwin" ]; then
    # macOS: Brewfileのcoreセクション（後述）を使用
    echo "Installing core tools via Homebrew..."
    brew install micro git tree curl cmake llvm btop htop zsh translate-shell
elif [ "$OS" == "Linux" ]; then
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y micro git curl tree build-essential cmake gdb clang btop htop zsh translate-shell
    fi
fi

echo "Core Tools installed."
