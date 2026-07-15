-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()
config.automatically_reload_config = true
config.font_size=12.0
-- IMEで日本語入力できるようにする
config.use_ime=true
-- ウィンドウの背景を半透明にする
config.window_background_opacity=0.7
-- MacOSでウィンドウの背景をぼかす
config.macos_window_background_blur = 20
-- ウィンドウの装飾を最小化する
-- config.window_decorations = "RESIZE"
-- タブが一つの時にタブバーを非表示にする
config.hide_tab_bar_if_only_one_tab = true
-- タブを透明化
config.window_frame = {
    inactive_titlebar_bg = "none",
    active_titlebar_bg = "none",
}
-- タブバーを背景色と同じに
config.window_background_gradient = {
    colors = { "#000000" },
}
-- タブの追加と消すボタンを消す
config.show_new_tab_button_in_tab_bar = false
config.show_close_tab_button_in_tabs = false
-- アクティブタブのタブの色をカスタマイズする
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local background = "#345956"
    local foreground = "#FFFFFF"
    if tab.is_active then
        background = "#ff7b00"
        foreground = "#ffffff"
    end
    local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "
    return {
        { Background = { Color = background } },
        { Foreground = { Color = foreground } },
        { Text = title },
    }
end)
-- キーバインドの設定を読み込む
config.keys = require("keybinds").keys
config.key_tables = require("keybinds").key_tables
return config
