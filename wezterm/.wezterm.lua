-- This is needed for Wezterm API 
local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.default_domain = 'WSL:Ubuntu-22.04'
config.color_scheme = 'Kanagawa (Gogh)'

config.font_size = 11
config.window_decorations = "RESIZE"

-- optional
config.window_background_opacity = 1
config.macos_window_background_blur = 10

-- Keybindings
config.keys = {
  -- Vertical split with CTRL+SHIFT+ALT+' (single quote key)
  {
    key = '"',
    mods = 'CTRL|SHIFT|ALT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },

  -- Horizontal split with CTRL+SHIFT+ALT+'-' (dash key)
  {
    key = '|',
    mods = 'CTRL|SHIFT|ALT',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
}

return config
