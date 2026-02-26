# --- Vim Configuration / Vim 設定 ---

# --- General Settings / 基本設定 ---

# Disable compatibility with old vi / 古い vi との互換性を無効化
set nocompatible

# Show line numbers / 行番号を表示
set number

# Show relative line numbers / 相対行番号を表示
set relativenumber

# Use spaces instead of tabs / タブの代わりにスペースを使用
set expandtab

# Tab width settings / タブ幅の設定
set shiftwidth=4
set tabstop=4

# Smart indenting / スマートインデント
set smartindent

# --- Search Settings / 検索設定 ---

# Highlight search results / 検索結果を強調表示
set hlsearch

# Show search results while typing / 入力中から検索を開始
set incsearch

# Ignore case when searching / 検索時に大文字小文字を区別しない
set ignorecase

# ...unless search contains capitals / 検索語に大文字が含まれる場合は区別する
set smartcase

# --- Miscellaneous / その他 ---

# Allow backspacing over everything / バックスペースの挙動を改善
set backspace=indent,eol,start

# Enable syntax highlighting / シンタックスハイライトを有効化
syntax on

# Enable filetype detection / ファイル形式の自動検出
filetype plugin indent on
