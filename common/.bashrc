# Source common aliases
if [ -f ~/.aliases ]; then
    . ~/.aliases
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
