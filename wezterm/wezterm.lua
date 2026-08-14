local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.font = wezterm.font('IBM Plex Mono', {weight = 'Regular'})
config.font_size = 14.0

config.initial_cols = 200
config.initial_rows = 55

config.color_scheme = 'Moonfly (Gogh)'

config.window_background_opacity = 1.0
config.macos_window_background_blur = 0

return config
