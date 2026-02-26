# Holmes Dotfiles

macOS, Linux, Windows（後述する通り作っただけ） に対応した dotfiles リポジトリです。CLI ツール、プログラミング言語のランタイム、GUI アプリ、フォント、システム設定の構築を自動化します。

## クイックスタート

### macOS / Linux
ターミナルで以下のコマンドを実行してください：
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/holmeshoo/dotfiles/main/scripts/install.sh)"
```
**注意 (macOS)**: Xcode Command Line Tools が未インストールの場合、Apple の規約により GUI での同意とインストールが必要です。ダイアログが表示されたら、インストールを完了させてから **もう一度上記のコマンドを実行してください。**

### Windows
PowerShell（管理者権限）で以下のコマンドを実行してください：
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/holmeshoo/dotfiles/main/windows/install.ps1'))
```

## 主な特徴

- マルチプラットフォーム対応: macOS (Homebrew), Linux (Apt/Snap), Windows (Winget) をサポート(windowsを除く)しています。
- モジュール化とデータ駆動: 設定はシンプルなテキストファイルに分離されています。新しいツールやフォントを追加する際、シェルスクリプトを直接編集する必要はありません。
- 言語環境の一元管理: [mise](common/.mise.toml) を使用し、Node, Python, Go, Rust, Java, Haskell, Flutter などの開発環境を一括管理します。
- 快適なターミナル環境: Zsh, Oh My Zsh, Starship プロンプト, fzf による履歴検索, tmux を統合したモダンな環境を提供します。
- VSCode の同期: 拡張機能の自動インストールと settings.json の同期機能を備えています。
- macOS 設定の自動化: キーリピート速度、Dock の位置、Finder の挙動などをスクリプトで自動設定します。

## ディレクトリ構造

```text
.
├── common/           # プラットフォーム共通設定 (.gitconfig, .zshrc, etc.)
│   ├── vscode/       # VSCode の settings.json
│   ├── links.txt     # シンボリックリンクの定義
│   └── local-files.txt # ローカル用設定ファイルのテンプレート
├── macos/            # macOS 専用スクリプトと Brewfile 群
├── linux/            # Linux 専用スクリプトとパッケージリスト
├── windows/          # Windows 専用 PowerShell スクリプトとリスト
└── scripts/          # 共通のセットアップ・保守ロジック (install, update, dump)
```

## セットアップ項目の分類について

本リポジトリでは、インストールする項目を以下の基準で分類しています。

### Core Tools (ツール)
OSそのものを便利にするための「インフラ的な道具」です。
- 特徴: 開発言語に関わらず常に使用するもの。OS標準のパッケージマネージャ、およびグローバルな `npm`/`cargo` パッケージとして管理されます。
- 自動化: 依存関係の解決のため、`mise` および主要なランタイム（Node.js, Rust）はこのステップで自動的にセットアップされます。
- 例: `git`, `micro`, `starship`, `tmux`, `fzf`, `rg` (ripgrep), `bat`, `gemini-cli` など。
- 管理ファイル: `macos/Brewfile.tools`, `linux/apt-packages.txt`, `windows/winget-packages.txt`, `common/npm-packages.txt`, `common/cargo-packages.txt`

### Language Runtimes (ランタイム)
コードを書いたり実行したりするための「言語環境」です。
- 特徴: プロジェクトごとにバージョンを切り替える必要があるもの。`mise` を介してユーザー領域にインストールされます。
- 例: `Node.js`, `Python`, `Rust`, `Go`, `Haskell`, `Flutter` など。
- 管理ファイル: `common/.mise.toml`

### Heavy Applications (アプリ)
GUIを持つ大型のソフトウェアです。
- 例: `VSCode`, `Vivaldi`, `Docker`, `Android Studio` など。
- 管理ファイル: `macos/Brewfile.apps`, `linux/external-apps.txt`, `windows/winget-apps.txt`

## メンテナンス用コマンド

環境を常に最新の状態に保つための便利なスクリプト群を用意しています：

- すべてを更新する:
  ```bash
  bash scripts/update.sh
  ```
  リポジトリ、OS パッケージ、mise ランタイム、Starship を一括更新します。

- 現在の状態を保存する:
  ```bash
  bash scripts/dump.sh
  ```
  現在インストールされている VSCode 拡張機能や Homebrew の状態をリポジトリへ書き戻します。

- インストール状況を検証する:
  ```bash
  bash scripts/verify.sh --all
  ```
  すべてのリンクやツールが正しくインストールされているかチェックします。

## 注意事項

### 動作環境と検証状況について
- **macOS**: 実機および CI にて動作検証済みです。
- **Linux**: CI 上での検証は行っていますが、**実機環境での完全な動作確認はまだ行えていません。**
- **Windows**: 作成者は Windows 上では **WSL (Windows Subsystem for Linux)** をメインで使用しているため、純粋な Windows 環境（PowerShell等）での動作検証は行っておらず、今後も対応の予定はありません。
- **対応ディストリビューション**: Linux 版は Debian/Ubuntu 系（`apt` パッケージマネージャを使用するもの）を前提としています。`pacman` を使う Arch Linux や `dnf` を使う Fedora 等には対応していません。

### 免責事項
- 本リポジトリは初学者が学習の過程で作成したものです。本スクリプトの実行によって生じたいかなる不利益や損害（データの損失、システムの不具合など）についても、作成者は一切の責任を負いません。内容を十分に理解した上で、自己責任でご利用ください。
- 本スクリプトを実行すると、既存の設定ファイルが上書きされる可能性があります（既存ファイルは `/tmp/` 内にバックアップが作成されますが、必ず事前に重要なデータのバックアップを取ってください）。
- 秘密鍵（SSH鍵など）や機密情報を含むファイルは絶対にリポジトリにコミットしないでください。ローカル専用の設定は `.local` ファイルを活用してください。
- インストールには管理者権限（sudo）が必要になる場合があります。

## カスタマイズ方法

### 自分専用の設定を追加する（推奨）
本リポジトリでは、Git の追跡対象外となっている `.local` ファイルを使用して、PC 個別のカスタマイズを安全に行うことができます。**これらのファイルに書いた設定は `scripts/update.sh` を実行しても上書き・削除されることはありません。**

- **Zsh**: `~/.zshrc_local` に記述
- **Bash**: `~/.bashrc_local` に記述
- **Git**: `~/.gitconfig.local` に記述（ユーザー名やメールアドレスなど）
- **SSH**: `~/.ssh/config.local` に記述

### 全体的なカスタマイズ
リポジトリ内のツールリストを編集することで、インストール対象を変更できます：
- CLI ツール: [macos/Brewfile.core](macos/Brewfile.core), [linux/apt-packages.txt](linux/apt-packages.txt), [windows/winget-packages.txt](windows/winget-packages.txt)
- GUI アプリ: [macos/Brewfile.apps](macos/Brewfile.apps), [linux/external-apps.txt](linux/external-apps.txt), [windows/winget-apps.txt](windows/winget-apps.txt)
- フォント: [macos/Brewfile.fonts](macos/Brewfile.fonts), [linux/external-fonts.txt](linux/external-fonts.txt), [windows/winget-fonts.txt](windows/winget-fonts.txt)
- ランタイム・言語別ツール: [common/.mise.toml](common/.mise.toml), [common/npm-packages.txt](common/npm-packages.txt), [common/cargo-packages.txt](common/cargo-packages.txt)
- VSCode: [common/vscode-extensions.txt](common/vscode-extensions.txt) および [common/vscode/settings.json](common/vscode/settings.json)
- リンク設定: [common/links.txt](common/links.txt)
