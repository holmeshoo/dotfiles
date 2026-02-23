#!/bin/bash

set -e

# --- Configuration ---
REPO_URL="https://github.com/holmeshoo/dotfiles.git"
TARBALL_URL="https://github.com/holmeshoo/dotfiles/archive/refs/heads/main.tar.gz"
DOTFILES_DIR="$HOME/dotfiles"

echo "Starting dotfiles installation..."

# 0. OS Specific: Ensure basic requirements
OS="$(uname)"
if [ "$OS" == "Darwin" ]; then
    if command -v xcodebuild &> /dev/null; then
        echo "Attempting to accept Xcode license..."
        sudo xcodebuild -license accept || echo "Skipping Xcode license."
    fi
elif [ "$OS" == "Linux" ]; then
    if ! command -v git &> /dev/null; then
        echo "git not found. Installing git..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y git
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y git
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm git
        fi
    fi
fi

# 1. Get the repository (Clone or Download Tarball)
if [ ! -d "$DOTFILES_DIR" ]; then
    if command -v git &> /dev/null; then
        echo "Cloning repository to $DOTFILES_DIR..."
        git clone "$REPO_URL" "$DOTFILES_DIR"
    else
        echo "git not found. Downloading repository as a tarball..."
        mkdir -p "$DOTFILES_DIR"
        curl -L "$TARBALL_URL" | tar -xz -C "$DOTFILES_DIR" --strip-components=1
    fi
else
    echo "Dotfiles directory already exists. Updating..."
    if [ -d "$DOTFILES_DIR/.git" ]; then
        cd "$DOTFILES_DIR" && git pull
    else
        echo "Non-git directory found. Re-downloading..."
        curl -L "$TARBALL_URL" | tar -xz -C "$DOTFILES_DIR" --strip-components=1
    fi
fi

cd "$DOTFILES_DIR"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"

# 2. Link dotfiles FIRST
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
if [ "$OS" == "Linux" ]; then
    FILES+=("linux/.bashrc_local")
fi

for file in "${FILES[@]}"; do
    target="$HOME/$(basename "$file")"
    source="$DOTFILES_DIR/$file"
    
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo "Warning: $target already exists and is not a symlink. Skipping."
    else
        echo "Linking $source to $target"
        ln -sf "$source" "$target"
    fi
done

# 3. Base OS Setup (Homebrew, apt-update, etc.)
if [ "$OS" == "Darwin" ]; then
    bash "$SCRIPTS_DIR/setup-macos.sh"
    # Ensure brew is available in the current session for subsequent scripts
    if [ -f /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -f /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
elif [ "$OS" == "Linux" ]; then
    bash "$SCRIPTS_DIR/setup-linux.sh"
fi

# 3.5 Shell Setup (Oh My Zsh)
bash "$SCRIPTS_DIR/setup-shell.sh"

# 4. Optional Setup
confirm() {
    read -p "$1 [y/N]: " response
    case "$response" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}

echo ""
echo "--- Select Setup Levels ---"
if confirm "Install EVERYTHING (Core, Language, and Heavy)?"; then
    bash "$SCRIPTS_DIR/setup-tools.sh"
    bash "$SCRIPTS_DIR/setup-runtimes.sh"
    bash "$SCRIPTS_DIR/setup-apps.sh"
else
    confirm "1. [Core] CLI Tools (micro, tree, etc.)" && bash "$SCRIPTS_DIR/setup-tools.sh"
    confirm "2. [Language] Runtimes (Node.js, Python, mise)" && bash "$SCRIPTS_DIR/setup-runtimes.sh"
    confirm "3. [Heavy] Applications (Docker, VSCode)" && bash "$SCRIPTS_DIR/setup-apps.sh"
fi

echo ""
echo "Successfully installed dotfiles!"
