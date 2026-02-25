#!/bin/bash

set -e

echo "Installing Core Tools..."

OS="$(uname)"

if [ "$OS" == "Darwin" ]; then
    # macOS: すべて Brewfile に任せる (tools & apps)
    BREWFILE="$(dirname "$0")/../macos/Brewfile"
    if [ -f "$BREWFILE" ]; then
        echo "Installing packages from Brewfile..."
        brew bundle --file="$BREWFILE" --verbose
    fi
elif [ "$OS" == "Linux" ]; then
    echo "Installing core tools via package manager..."
    if command -v apt-get &> /dev/null; then
        LIST="$(dirname "$0")/../linux/apt-packages.txt"
        if [ -f "$LIST" ]; then
            # ファイルからパッケージを読み込んで一括インストール
            grep -v '^#' "$LIST" | xargs sudo apt-get install -y
        fi
    fi
fi

echo "Core Tools installed."
