# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# --- Path Settings ---

# Homebrew
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Local bin
export PATH="$HOME/.local/bin:$PATH"

# Android SDK
if [[ "$OSTYPE" == "darwin"* ]]; then
    export ANDROID_HOME="$HOME/Library/Android/sdk"
else
    export ANDROID_HOME="$HOME/Android/Sdk"
fi
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH"

# Flutter
export CHROME_EXECUTABLE="/Applications/Dia.app/Contents/MacOS/Dia" # macOS Web Debug

# Set name of the theme to load
ZSH_THEME="cloud"

# Which plugins would you like to load?
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# --- Advanced Zsh Settings ---

# 1. Completion Settings
zstyle ':completion:*' menu select # タブ補完でメニュー選択を有効化
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' # 大文字小文字を区別せずに補完
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS} # 補完候補に色を付ける

# 2. History Settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt hist_ignore_dups     # 直前と同じコマンドは履歴に残さない
setopt hist_ignore_space    # スペースから始まるコマンドは履歴に残さない
setopt share_history        # 別のターミナル間で履歴を共有する
setopt hist_reduce_blanks   # 余分な空白を削除して記録

# 3. Directory Navigation
setopt auto_cd              # ディレクトリ名だけで移動
setopt auto_pushd           # cd時に自動でスタックに積む（popdで戻れる）
setopt pushd_ignore_dups    # 重複したスタックを避ける

# 4. Miscellaneous
setopt correct              # コマンドのスペルミスを自動修正
setopt interactive_comments # ターミナル上で # 以降をコメントとして許容

# --- Tools Initialization ---

# mise (Language Runtime Manager)
if [ -f "$HOME/.local/bin/mise" ]; then
    export PATH="$HOME/.local/bin:$PATH"
    eval "$(mise activate zsh)"
fi

# Source common aliases
if [ -f ~/.aliases ]; then
    . ~/.aliases
fi

# Source common functions
if [ -f ~/.functions ]; then
    . ~/.functions
fi

# Starship Prompt
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# fzf initialization
if command -v fzf &> /dev/null; then
    source <(fzf --zsh)
fi

# Platform specific zshrc
if [ -f ~/.zshrc_local ]; then
    . ~/.zshrc_local
fi
