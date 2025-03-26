local wezterm = require 'wezterm'
local config = {}

-- Detect system appearance and choose the theme accordingly
if wezterm.gui then
    local appearance = wezterm.gui.get_appearance()
    if appearance:find("Dark") then
      config.color_scheme = "Catppuccin Mocha" -- replace with your preferred dark theme
    else
      config.color_scheme = "Catppuccin Latte" -- replace with your preferred light theme
    end
  end

-- Set window background opacity to 50%
config.window_background_opacity = 0.5

-- Remove window decorations (title bar)
config.window_decorations = "NONE"


config.window_frame = {
    -- The font used in the tab bar.
    -- Roboto Bold is the default; this font is bundled
    -- with wezterm.
    -- Whatever font is selected here, it will have the
    -- main font setting appended to it to pick up any
    -- fallback fonts you may have used there.
    font = wezterm.font { family = 'Comicshanns Nerd Font Mono', weight = 'Bold' },

    -- The size of the font in the tab bar.
    -- Default to 10.0 on Windows but 12.0 on other systems
    font_size = 12.0,

    -- The overall background color of the tab bar when
    -- the window is focused
    -- active_titlebar_bg = '#333333',

    -- The overall background color of the tab bar when
    -- the window is not focused
    -- inactive_titlebar_bg = '#333333',
}

config.colors = {
    tab_bar = {
        -- The color of the inactive tab bar edge/divider
        inactive_tab_edge = '#575757',
    },
}

return config
