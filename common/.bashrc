# Source common aliases
if [ -f ~/.aliases ]; then
    . ~/.aliases
fi

# Platform specific bashrc
if [ -f ~/.bashrc_local ]; then
    . ~/.bashrc_local
fi
