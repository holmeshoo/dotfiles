#!/usr/bin/env bash

# Master update script for dotfiles and system tools

GREEN='\033[0;32m'
NC='\033[0m'
OS="$(uname)"
DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo -e "${GREEN}--- Updating System and Tools ---${NC}"

# Update Dotfiles Repository
echo -e "
[1/5] Updating dotfiles repository..."
cd "$DOTFILES_DIR"

# Temporarily stash local changes
HAS_CHANGES=$(git status --porcelain)
if [ -n "$HAS_CHANGES" ]; then
    echo "  -> Stashing local changes..."
    git stash push -m "Automatic stash by update.sh" &>/dev/null
fi

if git pull; then
    # Re-apply stashed changes
    if [ -n "$HAS_CHANGES" ]; then
        echo "  -> Re-applying local changes..."
        git stash pop &>/dev/null || echo -e "${YELLOW}Notice: Conflicts occurred while re-applying local changes. Please resolve manually.${NC}"
    fi
else
    echo -e "${RED}Error: Failed to pull updates from repository.${NC}"
    echo "Please resolve any conflicts in $DOTFILES_DIR manually."
    exit 1
fi

# Update Package Managers
echo -e "
[2/5] Updating package manager..."
if [ "$OS" == "Darwin" ]; then
    brew update && brew upgrade
elif [ "$OS" == "Linux" ]; then
    sudo apt-get update && sudo apt-get upgrade -y
fi

# Update mise runtimes
echo -e "
[3/5] Updating mise (languages)..."
if command -v mise &>/dev/null; then
    if [ "$OS" != "Darwin" ]; then
        mise self-update -y 2>/dev/null || echo "  -> mise is managed by package manager, skipping self-update."
    fi
    mise upgrade --yes
fi

# Update NPM Global Packages
echo -e "
[4/5] Updating global NPM packages..."
if command -v mise &>/dev/null; then
    mise exec node@lts -- npm update -g
fi

# Update Cargo Global Packages
echo -e "
[5/5] Updating global Cargo packages..."
if command -v mise &>/dev/null; then
    CARGO_LIST="$DOTFILES_DIR/common/cargo-packages.txt"
    if [ -f "$CARGO_LIST" ]; then
        while read -r pkg || [ -n "$pkg" ]; do
            [[ "$pkg" =~ ^#.*$ || -z "$pkg" ]] && continue
            pkg=$(echo "$pkg" | xargs)
            echo "  -> Updating $pkg"
            mise exec rust@latest -- cargo install "$pkg"
        done < "$CARGO_LIST"
    fi
fi

echo -e "
${GREEN}--- All updates completed! ---${NC}"
