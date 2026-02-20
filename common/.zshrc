# Source common aliases
if [ -f ~/.aliases ]; then
    . ~/.aliases
fi

# Platform specific zshrc
if [ -f ~/.zshrc_local ]; then
    . ~/.zshrc_local
fi
