-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- Use config_builder for better error handling
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- OS-specific configurations
if wezterm.target_triple:match("windows") then
  config.wsl_domains = {
    {
      name = 'WSL:Ubuntu',
      distribution = 'Ubuntu',
      default_cwd = "~",
    },
  }
  config.window_decorations = "TITLE | RESIZE"
  config.default_domain = 'WSL:Ubuntu'
  -- no padding on windows
  config.window_padding = {
    left = 2,
    right = 2,
    top = 0,
    bottom = 0,
  }
elseif wezterm.target_triple:match("darwin") then
  config.macos_window_background_blur = 40
  config.window_decorations = "RESIZE"
  config.window_padding = {
    left = 2,
    right = 2,
    top = 2,
    bottom = 2,
  }
end

-- Common configuration options
-- theme-set renders the active theme here. WezTerm reloads when it changes.
local theme_colors = wezterm.home_dir .. "/.config/theme/current/wezterm.lua"
wezterm.add_to_config_reload_watch_list(theme_colors)
local ok, colors = pcall(dofile, theme_colors)

config.font = wezterm.font("Hack Nerd Font Mono")
config.font_size = 10
config.enable_tab_bar = false
if ok then
  config.colors = colors
end
config.window_background_opacity = 1
-- Omarchy/Mako keeps critical notifications persistent, and WezTerm sends
-- OSC toast notifications as critical with no timeout on Linux.
config.notification_handling = "SuppressFromFocusedPane"

-- Label visible URLs, then open the selected one in the default browser.
config.keys = {
  {
    key = 'Space',
    mods = 'CTRL',
    action = wezterm.action.QuickSelectArgs {
      label = 'open URL',
      patterns = {
        'https?://\\S*[A-Za-z0-9/_#?=&%+~-]',
      },
      skip_action_on_paste = true,
      action = wezterm.action_callback(function(window, pane)
        local url = window:get_selection_text_for_pane(pane)
        wezterm.open_with(url)
      end),
    },
  },
}

-- allow for left option to be used as a compose key
config.use_dead_keys = false
config.send_composed_key_when_left_alt_is_pressed = true

-- Never prompt window close confirmation
config.window_close_confirmation = 'NeverPrompt'

-- Try to remove margin
config.adjust_window_size_when_changing_font_size = false
config.enable_scroll_bar = false
config.use_fancy_tab_bar = false

-- Return the configuration to wezterm
return config
