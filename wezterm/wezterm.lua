local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.font = wezterm.font('IBM Plex Mono', {weight = 'Regular'})
config.font_size = 14.0

config.initial_cols = 200
config.initial_rows = 55

config.color_scheme = 'Moonfly (Gogh)'

config.audible_bell = 'Disabled'

-- Lua core lacks a "merge properties with object and return the new object" function.
local function merge(t1, t2)
  local newobj = {}
  for k, v in pairs(t1) do newobj[k] = v end
  for k, v in pairs(t2) do newobj[k] = v end
  return newobj
end

-- Always open new tabs in ${HOME}, vs. using OSC 7 to inherit the CWD.
local spawn_new_tab = {
  key = 't',
  action = wezterm.action.SpawnCommandInNewTab {
    cwd = wezterm.home_dir,
    domain = 'CurrentPaneDomain',
  },
}

local close_tab = {
  -- If we are in vim or nvim, map Cmd-w and Ctrl-Shift-w to close the current buffer
  -- In other contexts, it behaves as normal, and closes the current WezTerm tab
  key = 'w',
  action = wezterm.action_callback(function(window, pane)
    local process = pane:get_foreground_process_name()
    local basename = process and process:match('([^/\\]+)$')

    -- This explicitly does not detect nvimdiff / nvimdiff2 at the moment
    if basename == 'vim' or basename == 'nvim' then
      -- Just :bd, so we can't close unmodified buffers by accident
      pane:send_text('\x1b:bd\r')
    else
      -- Fallback to standard terminal behavior
      window:perform_action(wezterm.action.CloseCurrentTab { confirm = true }, pane)
    end
  end),
}

config.keys = {
  merge({ mods = 'SUPER' }, spawn_new_tab),
  merge({ mods = 'CTRL|SHIFT' }, spawn_new_tab),
  merge({ mods = 'SUPER' }, close_tab),
  merge({ mods = 'CTRL|SHIFT' }, close_tab),
}

return config
