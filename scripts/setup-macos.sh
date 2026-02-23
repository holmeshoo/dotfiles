#!/bin/bash

echo "Starting macOS setup..."

# Install Homebrew if not found
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add brew to PATH for the current session
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

# Install packages from Brewfile
BREWFILE="$(dirname "$0")/../macos/Brewfile"
if [ -f "$BREWFILE" ]; then
    echo "Installing packages from Brewfile..."
    brew bundle --file="$BREWFILE"
fi

echo "macOS setup complete."
