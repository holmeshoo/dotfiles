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
    echo "Installing core tools via package manager..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        
        # List of packages to install
        tools=(micro git tree curl build-essential cmake gdb clang btop htop zsh translate-shell)
        
        for tool in "${tools[@]}"; do
            # Note: For some meta-packages like build-essential, we check a key command
            check_cmd="$tool"
            [ "$tool" == "build-essential" ] && check_cmd="make"
            [ "$tool" == "translate-shell" ] && check_cmd="trans"
            
            if command -v "$check_cmd" &> /dev/null; then
                echo "$tool is already installed. Skipping..."
            else
                echo "Installing $tool..."
                sudo apt-get install -y "$tool"
            fi
        done
    fi
fi

echo "Core Tools installed."
