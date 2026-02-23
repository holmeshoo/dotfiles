#!/bin/bash

set -e

# --- Configuration ---
REPO_URL="https://github.com/holmeshoo/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

echo "Starting dotfiles installation..."

# 0. Ensure git is installed
if ! command -v git &> /dev/null; then
    echo "git not found. Installing git..."
    OS="$(uname)"
    if [ "$OS" == "Darwin" ]; then
        # macOS: Trigger Command Line Tools installation or use Homebrew
        # Note: Homebrew installer will also install git
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Add brew to PATH for this session to get git
        if [[ -f /opt/homebrew/bin/brew ]]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi
        if [[ -f /usr/local/bin/brew ]]; then eval "$(/usr/local/bin/brew shellenv)"; fi
    elif [ "$OS" == "Linux" ]; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y git
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y git
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm git
        else
            echo "Error: Package manager not supported. Please install git manually."
            exit 1
        fi
    fi
fi

# 1. Clone or Update dotfiles repository
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Cloning repository to $DOTFILES_DIR..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
else
    echo "Dotfiles directory already exists. Pulling latest changes..."
    cd "$DOTFILES_DIR" && git pull
fi

cd "$DOTFILES_DIR"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"

# 2. Link dotfiles FIRST
# Ensure settings are applied before other installations
echo "Creating symlinks..."
FILES=(
    "common/.gitconfig"
    "common/.vimrc"
    "common/.editorconfig"
    "common/.aliases"
    "common/.bashrc"
    "common/.zshrc"
)
OS="$(uname)"
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
elif [ "$OS" == "Linux" ]; then
    bash "$SCRIPTS_DIR/setup-linux.sh"
fi

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
