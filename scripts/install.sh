#!/bin/bash

set -e

# --- Root Check ---
if [ "$EUID" -eq 0 ]; then
    echo "Error: Please do not run this script as root or with sudo."
    exit 1
fi

# --- Sudo Keep-alive ---
if [ "$GITHUB_ACTIONS" != "true" ]; then
    echo "Some steps require sudo. Please enter your password:"
    sudo -v
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
fi

# --- Configuration ---
REPO_URL="https://github.com/holmeshoo/dotfiles.git"
TARBALL_URL="https://github.com/holmeshoo/dotfiles/archive/refs/heads/main.tar.gz"

# Determine dotfiles directory (Use current dir if it looks like the repo)
if [ -f "$(dirname "$0")/../common/.zshrc" ]; then
    DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
else
    DOTFILES_DIR="$HOME/dotfiles"
fi

echo "Setting up dotfiles from $DOTFILES_DIR"

# 0. OS Specific: Ensure basic requirements
OS="$(uname)"
if [ "$OS" == "Darwin" ]; then
    if command -v xcodebuild &> /dev/null && xcode-select -p | grep -q "Xcode.app"; then
        echo "Xcode detected. Attempting to accept license..."
        sudo xcodebuild -license accept || echo "Skipping Xcode license."
    fi
elif [ "$OS" == "Linux" ]; then
    if ! command -v git &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y git
        fi
    fi
fi

# 1. Get the repository if not already present
if [ ! -d "$DOTFILES_DIR" ]; then
    if command -v git &> /dev/null; then
        echo "Cloning repository to $DOTFILES_DIR..."
        git clone "$REPO_URL" "$DOTFILES_DIR"
    else
        echo "git not found. Downloading repository as a tarball..."
        mkdir -p "$DOTFILES_DIR"
        curl -L "$TARBALL_URL" | tar -xz -C "$DOTFILES_DIR" --strip-components=1
    fi
fi

cd "$DOTFILES_DIR"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"

# 2. Link dotfiles
echo "Creating symlinks..."
FILES=(
    "common/.gitconfig"
    "common/.vimrc"
    "common/.editorconfig"
    "common/.aliases"
    "common/.functions"
    "common/.bashrc"
    "common/.zshrc"
)
[ "$OS" == "Linux" ] && FILES+=("linux/.bashrc_local")

for file in "${FILES[@]}"; do
    target="$HOME/$(basename "$file")"
    source="$DOTFILES_DIR/$file"
    
    # Backup if file exists and is not a symlink
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo "Backing up existing $target to ${target}.bak"
        mv "$target" "${target}.bak"
    fi
    
    echo "Linking $source to $target"
    ln -sf "$source" "$target"
done

# 3. Base OS Setup
if [ "$OS" == "Darwin" ]; then
    bash "$SCRIPTS_DIR/setup-macos.sh"
    if [ -f /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi
    if [ -f /usr/local/bin/brew ]; then eval "$(/usr/local/bin/brew shellenv)"; fi
elif [ "$OS" == "Linux" ]; then
    bash "$SCRIPTS_DIR/setup-linux.sh"
fi

# 3.5 Shell Setup
bash "$SCRIPTS_DIR/setup-shell.sh"

# 4. Optional Setup
if [ "$GITHUB_ACTIONS" == "true" ]; then
    # CI環境では対話をスキップして Core と Language を自動実行
    echo "CI detected. Automatically installing Core and Language..."
    bash "$SCRIPTS_DIR/setup-tools.sh"
    bash "$SCRIPTS_DIR/setup-runtimes.sh"
else
    confirm() { read -p "$1 [y/N]: " response; [[ "$response" =~ ^[yY] ]] && return 0 || return 1; }
    echo -e "\n--- Select Setup Levels ---"
    if confirm "Install EVERYTHING (Core, Language, and Heavy)?"; then
        bash "$SCRIPTS_DIR/setup-tools.sh"
        bash "$SCRIPTS_DIR/setup-runtimes.sh"
        bash "$SCRIPTS_DIR/setup-apps.sh"
    else
        confirm "1. [Core] CLI Tools (micro, git, etc.)?" && bash "$SCRIPTS_DIR/setup-tools.sh"
        confirm "2. [Language] Runtimes (Node.js, Python, mise)?" && bash "$SCRIPTS_DIR/setup-runtimes.sh"
        confirm "3. [Heavy] Applications (Docker, VSCode)?" && bash "$SCRIPTS_DIR/setup-apps.sh"
    fi
fi

echo "Successfully installed dotfiles!"
