-- Catppuccin Mocha Theme for Awesome WM
local beautiful = require("beautiful")
local gears = require("gears")

local theme = {}

-- Fonts
theme.font          = "JetBrainsMono Nerd Font 10"
theme.taglist_font  = "JetBrainsMono Nerd Font Bold 10"
theme.title_font    = "JetBrainsMono Nerd Font 9"

-- Colors (Catppuccin Mocha)
theme.bg_normal     = "#1e1e2e"
theme.bg_focus      = "#313244"
theme.bg_urgent     = "#f38ba8"
theme.bg_minimize   = "#45475a"
theme.bg_systray    = "#1e1e2e"

theme.fg_normal     = "#cdd6f4"
theme.fg_focus      = "#f5c2e7"
theme.fg_urgent     = "#11111b"
theme.fg_minimize   = "#6c7086"

-- Borders
theme.border_width  = 2
theme.border_normal = "#313244"
theme.border_focus  = "#cba6f7"
theme.border_marked = "#f9e2af"

-- Titlebar
theme.titlebar_bg_normal = "#1e1e2e"
theme.titlebar_bg_focus  = "#313244"
theme.titlebar_size      = 28

-- Wallpaper
theme.wallpaper = os.getenv("HOME") .. "/.config/awesome/wallpaper.jpg"

-- Menu
theme.menu_bg_normal = "#1e1e2e"
theme.menu_bg_focus = "#313244"
theme.menu_fg_normal = "#cdd6f4"
theme.menu_fg_focus = "#cba6f7"
theme.menu_border_width = 1
theme.menu_border_color = "#313244"
theme.menu_height = 24
theme.menu_width = 200
theme.menu_submenu_icon = nil

-- Define palette for titlebar buttons
theme.palette = {
    red    = "#f38ba8",
    green  = "#a6e3a1",
    yellow = "#f9e2af",
    blue   = "#89b4fa",
    mauve  = "#cba6f7",
    peach  = "#fab387"
}

return theme
