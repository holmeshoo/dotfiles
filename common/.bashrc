# --- Bash Configuration / Bash 設定 ---

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

# --- Tools Initialization / ツール初期化 ---

# Source common files / 共通設定の読み込み
[ -f ~/.aliases ] && . ~/.aliases
[ -f ~/.functions ] && . ~/.functions

# mise (Tool manager) / mise の有効化
if command -v mise &> /dev/null; then
    eval "$(mise activate bash)"
fi

# Starship Prompt / Starship プロンプトの起動
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi

# Platform specific local settings / プラットフォーム固有のローカル設定
[ -f ~/.bashrc_local ] && . ~/.bashrc_local
