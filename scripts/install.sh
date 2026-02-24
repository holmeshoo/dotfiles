#!/bin/bash

set -e

# --- Root Check ---
if [ "$EUID" -eq 0 ]; then
    echo "Error: Please do not run this script as root or with sudo."
    exit 1
fi

# --- Usage ---
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --all       Install everything (Core, Runtime, and Apps)"
    echo "  --core      Install Core CLI tools"
    echo "  --runtime   Install Language runtimes"
    echo "  --apps      Install Heavy applications"
    echo "  --help      Show this help"
    exit 0
}

# --- Initial Selection ---
DO_CORE=false
DO_RUNTIME=false
DO_APPS=false

# Parse arguments if provided
if [[ "$#" -gt 0 ]]; then
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --all) DO_CORE=true; DO_RUNTIME=true; DO_APPS=true ;;
            --core) DO_CORE=true ;;
            --runtime) DO_RUNTIME=true ;;
            --apps) DO_APPS=true ;;
            --help) usage ;;
            *) echo "Unknown parameter: $1"; usage ;;
        esac
        shift
    done
else
    # Graphical Selection (Whiptail) only if no arguments
    if command -v whiptail &>/dev/null; then
        CHOICES=$(whiptail --title "Dotfiles Setup" --checklist \
        "Space to select/deselect, Enter to confirm:" 15 60 3 \
        "Core" "CLI Tools (micro, git, etc.)" ON \
        "Runtime" "Language runtimes (Node, Python)" ON \
        "Apps" "Heavy applications (Docker, VSCode)" OFF 3>&1 1>&2 2>&3) || exit 1

        [[ $CHOICES == *"Core"* ]] && DO_CORE=true
        [[ $CHOICES == *"Runtime"* ]] && DO_RUNTIME=true
        [[ $CHOICES == *"Apps"* ]] && DO_APPS=true
    else
        # Fallback to simple confirm if whiptail is missing
        confirm() { read -p "$1 [y/N]: " response; [[ "$response" =~ ^[yY] ]] && return 0 || return 1; }
        confirm "Install Core CLI Tools?" && DO_CORE=true
        confirm "Install Language Runtimes?" && DO_RUNTIME=true
        confirm "Install Heavy Applications?" && DO_APPS=true
    fi
fi

# --- Sudo Keep-alive ---
echo "Some steps require sudo. Please enter your password:"
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# --- Configuration ---
REPO_URL="https://github.com/holmeshoo/dotfiles.git"
TARBALL_URL="https://github.com/holmeshoo/dotfiles/archive/refs/heads/main.tar.gz"

# Determine dotfiles directory
if [ -f "$(dirname "$0")/../common/.zshrc" ]; then
    DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
else
    DOTFILES_DIR="$HOME/dotfiles"
fi

echo "Setting up dotfiles from $DOTFILES_DIR"

# 0. OS Specific requirements
OS="$(uname)"
if [ "$OS" == "Darwin" ]; then
    if command -v xcodebuild &> /dev/null && xcode-select -p | grep -q "Xcode.app"; then
        sudo xcodebuild -license accept || echo "Skipping Xcode license."
    fi
elif [ "$OS" == "Linux" ]; then
    if ! command -v git &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y git
        fi
    fi
fi

# 1. Get the repository
if [ ! -d "$DOTFILES_DIR" ]; then
    if command -v git &> /dev/null; then
        git clone "$REPO_URL" "$DOTFILES_DIR"
    else
        mkdir -p "$DOTFILES_DIR"
        curl -L "$TARBALL_URL" | tar -xz -C "$DOTFILES_DIR" --strip-components=1
    fi
fi

cd "$DOTFILES_DIR"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"

# 3. Execution (Install Tools & Apps)
if [ "$OS" == "Darwin" ]; then
    bash "$SCRIPTS_DIR/setup-macos.sh"
    if [ -f /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi
    if [ -f /usr/local/bin/brew ]; then eval "$(/usr/local/bin/brew shellenv)"; fi
elif [ "$OS" == "Linux" ]; then
    bash "$SCRIPTS_DIR/setup-linux.sh"
fi

bash "$SCRIPTS_DIR/setup-shell.sh"

# Run selected setup steps
[ "$DO_CORE" = true ] && bash "$SCRIPTS_DIR/setup-tools.sh"
[ "$DO_RUNTIME" = true ] && bash "$SCRIPTS_DIR/setup-runtimes.sh"
[ "$DO_APPS" = true ] && bash "$SCRIPTS_DIR/setup-apps.sh"

# 4. Link dotfiles (Final Step)
# We do this at the end to ensure tools like Oh My Zsh don't overwrite our files
echo "Creating symlinks (Finalizing)..."
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
    
    # If it's a symlink or already backed up, just remove it to create a fresh one
    if [ -L "$target" ] || [ -e "$target" ]; then
        rm -rf "$target"
    fi
    
    echo "Linking $source to $target"
    ln -s "$source" "$target"
done

# 5. Finalize: Change Default Shell
# We do this at the very end as it might prompt for a password
if [ "$OS" == "Darwin" ] || [ "$OS" == "Linux" ]; then
    ZSH_PATH="$(which zsh)"
    if [ "$SHELL" != "$ZSH_PATH" ]; then
        echo "Changing your default shell to zsh..."
        sudo chsh -s "$ZSH_PATH" "$(whoami)"
    fi
fi

echo "Successfully installed dotfiles!"
