# --- Path Settings ---

# Homebrew
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Local bin
export PATH="$HOME/.local/bin:$PATH"

# Source common aliases
if [ -f ~/.aliases ]; then
    . ~/.aliases
fi

# Source common functions
if [ -f ~/.functions ]; then
    . ~/.functions
fi

# mise (Tool manager)
if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi
if command -v mise &> /dev/null; then
    eval "$(mise activate bash)"
fi

# Platform specific bashrc
if [ -f ~/.bashrc_local ]; then
    . ~/.bashrc_local
fi
