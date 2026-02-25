#!/bin/bash

# Master dump script to save current system state to dotfiles repository

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'
OS="$(uname)"
DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo -e "${GREEN}--- Exporting System State to Dotfiles ---${NC}"

# 1. VSCode Extensions
if command -v code &>/dev/null; then
    echo -e "
[1/3] Dumping VSCode extensions..."
    code --list-extensions > "$DOTFILES_DIR/common/vscode-extensions.txt"
    echo "  -> Saved to common/vscode-extensions.txt"
fi

# 2. Homebrew (macOS only)
if [ "$OS" == "Darwin" ] && command -v brew &>/dev/null; then
    echo -e "
[2/3] Dumping Homebrew packages..."
    # Create a temporary Brewfile
    brew bundle dump --force --file="/tmp/Brewfile"
    
    # In a perfect world, we'd split this into .core and .apps, 
    # but for simplicity in a dump script, we'll notify the user.
    echo -e "${YELLOW}Note: Current Homebrew state dumped to /tmp/Brewfile.${NC}"
    echo "Please manually update macos/Brewfile.core and Brewfile.apps if needed."
fi

# 3. mise (Language Runtimes)
if command -v mise &>/dev/null; then
    echo -e "
[3/3] Dumping mise configuration..."
    # Global config is usually at ~/.config/mise/config.toml
    # Since it's symlinked to common/.mise.toml, it might already be up-to-date,
    # but we can ensure the current tools are listed.
    # (mise doesn't have a direct 'dump' but the config.toml is the source of truth)
    echo "  -> common/.mise.toml is linked, check it for changes."
fi

echo -e "
${GREEN}--- Dump completed! ---${NC}"
echo "Don't forget to git commit and push your changes."
