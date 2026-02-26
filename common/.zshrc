# --- Zsh Configuration / Zsh 設定 ---

# Path to your oh-my-zsh installation / Oh My Zsh のインストールパス
export ZSH="$HOME/.oh-my-zsh"

# --- Path Settings / パス設定 ---

# Homebrew initialization / Homebrew の初期化
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Local bin path / ローカル実行ファイルのパス
export PATH="$HOME/.local/bin:$PATH"

# Android SDK settings / Android SDK の設定
if [[ "$OSTYPE" == "darwin"* ]]; then
    export ANDROID_HOME="$HOME/Library/Android/sdk"
else
    export ANDROID_HOME="$HOME/Android/Sdk"
fi
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH"

# Flutter Web Debug browser / Flutter Web デバッグ用ブラウザ
export CHROME_EXECUTABLE="/Applications/Dia.app/Contents/MacOS/Dia" # macOS

# --- Oh My Zsh Settings / Oh My Zsh の設定 ---

# Theme / テーマ設定
ZSH_THEME="cloud"

# Plugins / 使用するプラグイン
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

# Load Oh My Zsh / Oh My Zsh の読み込み
source $ZSH/oh-my-zsh.sh

# --- Advanced Settings / 詳細設定 ---

# Completion / 補完設定
zstyle ':completion:*' menu select # Enable menu selection / 補完候補をメニュー選択可能に
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' # Case-insensitive / 大文字小文字を区別しない

# History / 履歴設定
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt hist_ignore_dups     # Ignore consecutive duplicates / 直前と同じコマンドは記録しない
setopt share_history        # Share history across terminals / ターミナル間で履歴を共有

# --- Tools Initialization / ツール初期化 ---

# mise (Tool manager) / mise の有効化
if [ -f "$HOME/.local/bin/mise" ]; then
    eval "$(mise activate zsh)"
fi

# Source common files / 共通設定の読み込み
[ -f ~/.aliases ] && . ~/.aliases
[ -f ~/.functions ] && . ~/.functions

# Starship Prompt / Starship プロンプトの起動
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# fzf integration / fzf の統合
if command -v fzf &> /dev/null; then
    source <(fzf --zsh)
fi

# Platform specific local settings / プラットフォーム固有のローカル設定
[ -f ~/.zshrc_local ] && . ~/.zshrc_local
