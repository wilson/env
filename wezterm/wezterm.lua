local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.font = wezterm.font('IBM Plex Mono', {weight = 'Regular'})
config.font_size = 14.0

config.initial_cols = 200
config.initial_rows = 55

config.color_scheme = 'Moonfly (Gogh)'

config.window_background_opacity = 1.0
config.macos_window_background_blur = 0

config.keys = {}

-- If we are in vim or nvim, map Cmd-w to close the current buffer
-- In other contexts, it behaves as normal, and closes the current WezTerm tab
local act = wezterm.action
table.insert(config.keys, {
  key = 'w',
  mods = 'SUPER',
  action = wezterm.action_callback(function(window, pane)
    local process = pane:get_foreground_process_name()
    if process and process:find('n?vim') ~= nil then
      -- Just :bd, so we can't close unmodified buffers by accident
      pane:send_text('\x1b:bd\r')
    else
      -- Fallback to standard terminal behavior
      window:perform_action(act.CloseCurrentTab { confirm = true }, pane)
    end
  end),
})

return config
