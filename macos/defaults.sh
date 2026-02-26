#!/usr/bin/env bash

# macOS System Configurations
# Original idea from: https://github.com/mathiasbynens/dotfiles/blob/master/.macos

echo "Configuring macOS system settings..."

# Close any open System Settings panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Settings" to quit'

###############################################################################
# Keyboard & Trackpad                                                         #
###############################################################################

# キーのリピート速度を爆速にする
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# トラックパッド: タップでクリックを有効にする
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true

###############################################################################
# Finder                                                                      #
###############################################################################

# 隠しファイルを表示する
defaults write com.apple.finder AppleShowAllFiles -bool true

# すべての拡張子のファイルを表示する
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# ステータスバーを表示する
defaults write com.apple.finder ShowStatusBar -bool true

# パスバーを表示する
defaults write com.apple.finder ShowPathbar -bool true

# ファイル拡張子変更時の警告を無効化する
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# 名前で並べ替えた時にフォルダを上にする
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# タイトルバーにフルパスを表示する
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# iCloudへのデフォルト保存を無効化する
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# ファイル保存ダイアログを常に詳細表示にする
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

###############################################################################
# Dock & Mission Control                                                      #
###############################################################################

# Dockを自動的に隠す
defaults write com.apple.dock autohide -bool true

# Dockに入っている固定アプリをすべて削除する (クリーンな状態にする)
defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock persistent-others -array

# Dockの位置を右側に設定
defaults write com.apple.dock orientation -string "right"

# Dockのベースアイコンサイズを設定 (36px)
defaults write com.apple.dock tilesize -int 36

# Dockのアイコン拡大を有効化し、拡大サイズを48pxに設定
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock largesize -int 48

# 最近使ったアプリケーションをDockに表示しない
defaults write com.apple.dock show-recents -bool false

# Mission Control: 最新の使用状況に基づいてスペースを自動的に並べ替えるのを無効化
defaults write com.apple.dock mru-spaces -bool false

# Mission Controlのアニメーション速度を上げる
defaults write com.apple.dock expose-animation-duration -float 0.1

###############################################################################
# Performance & Animations                                                    #
###############################################################################

# ウィンドウのリサイズ速度を上げる
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# ダイアログの表示・非表示のアニメーションを高速化する
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

# クイックルックの表示を高速化する
defaults write -g QLPanelAnimationDuration -float 0

# キーの長押しでアクセント記号メニューが出るのを無効化 (キーリピートを優先)
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

###############################################################################
# Screen Capture                                                              #
###############################################################################

# スクリーンショットの保存先を変更 (デスクトップを汚さない)
mkdir -p "${HOME}/Downloads/Screenshots"
defaults write com.apple.screencapture location -string "${HOME}/Downloads/Screenshots"

# スクリーンショットの影を無効化する
defaults write com.apple.screencapture disable-shadow -bool true

###############################################################################
# Kill affected applications                                                  #
###############################################################################

for app in "Dock" "Finder" "SystemUIServer"; do
    killall "$app" &> /dev/null || true
done

echo "macOS system settings updated. Note: Some changes may require a logout/restart to take effect."
