#!/usr/bin/env bash

echo "Starting Linux setup..."

# Basic system update
if command -v apt-get &> /dev/null; then
    echo "Detected Debian/Ubuntu-based system. Updating packages..."
    sudo apt-get update
fi

echo "Linux setup complete."
