set -e

# Root Check 
if [ "$EUID" -eq 0 ]; then
    echo "Error: Please do not run this script as root or with sudo."
    exit 1
fi

# Selection function
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --all       Install everything (Core, Runtime, Apps, and Fonts)"
    echo "  --core      Install Core CLI tools"
    echo "  --runtime   Install Language runtimes"
    echo "  --apps      Install Heavy applications"
    echo "  --fonts     Install Fonts"
    echo "  --help      Show this help"
    exit 0
}

# Mode flags
DO_CORE=false
DO_RUNTIME=false
DO_APPS=false
DO_FONTS=false

# selection logic
if [[ "$#" -gt 0 ]]; then
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --all) DO_CORE=true; DO_RUNTIME=true; DO_APPS=true; DO_FONTS=true ;;
            --core) DO_CORE=true ;;
            --runtime) DO_RUNTIME=true ;;
            --apps) DO_APPS=true ;;
            --fonts) DO_FONTS=true ;;
            --help) usage ;;
            *) echo "Unknown parameter: $1"; usage ;;
        esac
        shift
    done
else
    if command -v whiptail &>/dev/null; then
        CHOICES=$(whiptail --title "Dotfiles Setup" --checklist \
        "Space to select/deselect, Enter to confirm:" 15 60 4 \
        "Core" "CLI Tools (micro, git, etc.)" ON \
        "Runtime" "Language runtimes (Node, Python)" ON \
        "Apps" "Heavy applications (Docker, VSCode)" OFF \
        "Fonts" "Nerd Fonts and Japanese fonts" OFF 3>&1 1>&2 2>&3) || exit 1

        [[ $CHOICES == *"Core"* ]] && DO_CORE=true
        [[ $CHOICES == *"Runtime"* ]] && DO_RUNTIME=true
        [[ $CHOICES == *"Apps"* ]] && DO_APPS=true
        [[ $CHOICES == *"Fonts"* ]] && DO_FONTS=true
    else
        # Fallback to simple confirm if whiptail is missing
        confirm() { read -p "$1 [y/N]: " response; [[ "$response" =~ ^[yY] ]] && return 0 || return 1; }
        confirm "Install Core CLI Tools?" && DO_CORE=true
        confirm "Install Language Runtimes?" && DO_RUNTIME=true
        confirm "Install Heavy Applications?" && DO_APPS=true
        confirm "Install Fonts?" && DO_FONTS=true
    fi
fi

# Sudo Keep-alive
echo "Some steps require sudo. Please enter your password:"
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

REPO_URL="https://github.com/holmeshoo/dotfiles.git"

# Determine dotfiles directory
if [ -f "$(dirname "$0")/../common/.zshrc" ]; then
    DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
else
    DOTFILES_DIR="$HOME/dotfiles"
fi

echo "Setting up dotfiles from $DOTFILES_DIR"

# OS Specific requirements
OS="$(uname)"
if [ "$OS" == "Darwin" ]; then
    # Check if Xcode Command Line Tools are installed
    if ! xcode-select -p &>/dev/null; then
        echo "Xcode Command Line Tools not found. Installing..."
        # This will trigger the interactive installation dialog on macOS
        xcode-select --install
        echo "Please complete the installation dialog and run this script again."
        exit 0
    fi

    if command -v xcodebuild &> /dev/null && xcode-select -p 2>/dev/null | grep -q "Xcode.app"; then
        sudo xcodebuild -license accept || echo "Skipping Xcode license."
    fi
elif [ "$OS" == "Linux" ]; then
    if command -v apt-get &> /dev/null; then
        echo "Updating package list..."
        sudo apt-get update
        if ! command -v git &> /dev/null; then
            sudo apt-get install -y git
        fi
    fi
fi

# Get the repository
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Cloning repository to $DOTFILES_DIR..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
fi

cd "$DOTFILES_DIR"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"

# Link dotfiles (Early Step)
echo "Creating symlinks..."

# Ensure local override files exist
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

# Read and apply links
LINKS_FILES=("$DOTFILES_DIR/common/links.txt")
if [ "$OS" == "Darwin" ]; then
    LINKS_FILES+=("$DOTFILES_DIR/macos/links.txt")
elif [ "$OS" == "Linux" ]; then
    LINKS_FILES+=("$DOTFILES_DIR/linux/links.txt")
fi

for links_file in "${LINKS_FILES[@]}"; do
    if [ -f "$links_file" ]; then
        echo "Processing links from $(basename "$links_file")..."
        while read -r line || [ -n "$line" ]; do
            [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
            
            src_name=$(echo "$line" | cut -d: -f1 | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
            dst_rel=$(echo "$line" | cut -d: -f2 | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
            
            source="$DOTFILES_DIR/common/$src_name"
            target="$HOME/$dst_rel"
            
            if [ ! -f "$source" ]; then
                echo "Warning: Source file $source not found. Skipping."
                continue
            fi
            
            mkdir -p "$(dirname "$target")"
            
            if [[ "$dst_rel" == ".ssh/"* ]]; then
                chmod 700 "$HOME/.ssh" 2>/dev/null || true
            fi

            if [ -e "$target" ] && [ ! -L "$target" ]; then
                echo "Backing up $target"
                mv "$target" "/tmp/$(basename "$target").bak"
            fi
            
            if [ -L "$target" ] || [ -e "$target" ]; then
                rm -rf "$target"
            fi
            
            echo "Linking $dst_rel"
            ln -s "$source" "$target"
        done < "$links_file"
    fi
done

# init OS-specific settings
if [ "$OS" == "Darwin" ]; then
    bash "$DOTFILES_DIR/macos/init.sh"
    [ -f /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
    [ -f /usr/local/bin/brew ] && eval "$(/usr/local/bin/brew shellenv)"
elif [ "$OS" == "Linux" ]; then
    bash "$DOTFILES_DIR/linux/init.sh"
fi

bash "$SCRIPTS_DIR/setup-shell.sh"

# Run selected setup steps
[ "$DO_CORE" = true ] && bash "$SCRIPTS_DIR/setup-tools.sh"
[ "$DO_RUNTIME" = true ] && bash "$SCRIPTS_DIR/setup-runtimes.sh"
[ "$DO_APPS" = true ] && bash "$SCRIPTS_DIR/setup-apps.sh"
[ "$DO_FONTS" = true ] && bash "$SCRIPTS_DIR/setup-fonts.sh"

# 4. Finalize: Change Default Shell
ZSH_PATH="$(which zsh)"
if [ "$SHELL" != "$ZSH_PATH" ]; then
    echo "Changing your default shell to zsh..."
    sudo chsh -s "$ZSH_PATH" "$(whoami)"
fi

echo "Successfully installed dotfiles!"
