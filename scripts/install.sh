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
    # Ensure apt is up to date before any sub-scripts run
    if command -v apt-get &> /dev/null; then
        echo "Updating package list..."
        sudo apt-get update
        if ! command -v git &> /dev/null; then
            sudo apt-get install -y git
        fi
    fi
fi

# 1. Get the repository
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Cloning repository to $DOTFILES_DIR..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
fi

cd "$DOTFILES_DIR"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"

# 3. Execution (Install Tools & Apps)
if [ "$OS" == "Darwin" ]; then
    bash "$DOTFILES_DIR/macos/setup.sh"
    # Ensure brew is available in this process for subsequent scripts
    [ -f /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
    [ -f /usr/local/bin/brew ] && eval "$(/usr/local/bin/brew shellenv)"
elif [ "$OS" == "Linux" ]; then
    bash "$DOTFILES_DIR/linux/setup.sh"
fi

bash "$SCRIPTS_DIR/setup-shell.sh"

# Run selected setup steps
[ "$DO_CORE" = true ] && bash "$SCRIPTS_DIR/setup-tools.sh"
[ "$DO_RUNTIME" = true ] && bash "$SCRIPTS_DIR/setup-runtimes.sh"
[ "$DO_APPS" = true ] && bash "$SCRIPTS_DIR/setup-apps.sh"

# 4. Link dotfiles (Final Step)
echo "Creating symlinks (Finalizing)..."

# Ensure local override files exist so they can be linked
LOCAL_FILES_LIST="$DOTFILES_DIR/common/local-files.txt"
if [ -f "$LOCAL_FILES_LIST" ]; then
    while read -r f || [ -n "$f" ]; do
        [[ "$f" =~ ^#.*$ || -z "$f" ]] && continue
        f=$(echo "$f" | xargs)
        if [ ! -f "$DOTFILES_DIR/common/$f" ]; then
            echo "Creating template for $f"
            echo "# Local overrides (Not committed to git)" > "$DOTFILES_DIR/common/$f"
        fi
    done < "$LOCAL_FILES_LIST"
fi

# Read mapping from external file: "SourceFileName : TargetLocation"
LINKS_FILE="$DOTFILES_DIR/common/links.txt"
if [ -f "$LINKS_FILE" ]; then
    while IFS=':' read -r src_name dst_rel || [ -n "$src_name" ]; do
        [[ "$src_name" =~ ^#.*$ || -z "$src_name" ]] && continue
        
        src_name=$(echo $src_name | xargs)
        dst_rel=$(echo $dst_rel | xargs)
        
        source="$DOTFILES_DIR/common/$src_name"
        target="$HOME/$dst_rel"
        
        if [ ! -f "$source" ]; then
            echo "Warning: Source file $source not found. Skipping."
            continue
        fi
        
            # Ensure target directory exists
            mkdir -p "$(dirname "$target")"
            
            # Special permissions for .ssh directory and config
            if [[ "$dst_rel" == ".ssh/"* ]]; then
                chmod 700 "$HOME/.ssh" 2>/dev/null || true
            fi
                # Backup existing file if it's not a link
        if [ -e "$target" ] && [ ! -L "$target" ]; then
            echo "Backing up $target"
            mv "$target" "/tmp/$(basename "$target").bak"
        fi
        
        # Remove existing link or file to ensure fresh link
        if [ -L "$target" ] || [ -e "$target" ]; then
            rm -rf "$target"
        fi
        
        echo "Linking $dst_rel"
        ln -s "$source" "$target"
    done < "$LINKS_FILE"
fi

# 5. Finalize: Change Default Shell
# We do this at the very end as it might prompt for a password
ZSH_PATH="$(which zsh)"
if [ "$SHELL" != "$ZSH_PATH" ]; then
    echo "Changing your default shell to zsh..."
    sudo chsh -s "$ZSH_PATH" "$(whoami)"
fi

echo "Successfully installed dotfiles!"
