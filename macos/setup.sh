#!/bin/bash

set -e

echo "Starting macOS base setup (Homebrew)..."

# Install Homebrew if not found
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add brew to PATH for the current session
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

# Apply system settings (defaults write)
bash "$(dirname "$0")/defaults.sh"

# Link VSCode settings
VSCODE_SETTING_DIR="$HOME/Library/Application Support/Code/User"
mkdir -p "$VSCODE_SETTING_DIR"
ln -sf "$(dirname "$0")/../common/vscode/settings.json" "$VSCODE_SETTING_DIR/settings.json"

echo "macOS base setup complete."
