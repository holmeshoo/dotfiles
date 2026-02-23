#!/bin/bash

echo "Starting Linux setup..."

# Example: Install basic tools if using apt
if command -v apt-get &> /dev/null; then
    echo "Detected Debian/Ubuntu-based system. Updating packages..."
    # sudo apt-get update && sudo apt-get install -y git vim
fi

echo "Linux setup complete."
