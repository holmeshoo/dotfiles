#!/usr/bin/env bash

set -e

echo "Starting macOS base setup (Homebrew)..."

# Install Homebrew if not found
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Apply system settings
bash "$(dirname "$0")/defaults.sh"

# Export Homebrew environment for this script and subsequent ones
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

echo "macOS base setup complete."
