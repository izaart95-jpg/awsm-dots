-- themes/tokyonight.lua
-- ─────────────────────────────────────────────────────────────────────────────
-- Tokyo Night Storm variant — precise color tokens for every UI surface.
-- Aesthetic: deep indigo + electric cyan + cherry blossom pink accents.
-- ─────────────────────────────────────────────────────────────────────────────

local theme = {}

-- ─── Fonts ────────────────────────────────────────────────────────────────────
theme.font         = "JetBrainsMono Nerd Font 10"
theme.taglist_font = "JetBrainsMono Nerd Font Bold 10"
theme.title_font   = "JetBrainsMono Nerd Font 9"

-- ─── Palette (Tokyo Night Storm) ─────────────────────────────────────────────
local c = {
    -- Backgrounds (darkest → lightest)
    bg_dark    = "#16161e",
    bg         = "#1a1b26",
    bg_highlight = "#292e42",
    bg_popup   = "#1f2335",
    bg_visual  = "#2d3f76",

    -- UI chrome
    fg_dark    = "#737aa2",
    fg_gutter  = "#3b4261",
    dark3      = "#545c7e",
    dark5      = "#737aa2",
    comment    = "#565f89",

    -- Main text
    fg         = "#c0caf5",
    fg_sidebar = "#a9b1d6",

    -- Accents
    blue       = "#7aa2f7",    -- primary
    blue0      = "#3d59a1",
    blue1      = "#2ac3de",    -- electric cyan
    blue2      = "#0db9d7",
    blue5      = "#89ddff",
    blue6      = "#b4f9f8",
    blue7      = "#394b70",
    cyan       = "#7dcfff",
    magenta    = "#bb9af7",    -- purple accent
    magenta2   = "#ff007c",
    purple     = "#9d7cd8",
    orange     = "#ff9e64",
    yellow     = "#e0af68",
    green      = "#9ece6a",
    green1     = "#73daca",    -- teal-green
    green2     = "#41a6b5",
    teal       = "#1abc9c",
    red        = "#f7768e",    -- cherry blossom
    red1       = "#db4b4b",
}
theme.palette = c

-- ─── Core colors ──────────────────────────────────────────────────────────────
theme.bg_normal   = c.bg
theme.bg_focus    = c.bg_highlight
theme.bg_urgent   = c.red
theme.bg_minimize = c.fg_gutter
theme.bg_systray  = c.bg

theme.fg_normal   = c.fg
theme.fg_focus    = c.blue1   -- electric cyan on focus
theme.fg_urgent   = c.bg_dark
theme.fg_minimize = c.dark5

-- ─── Widget / bar colors ──────────────────────────────────────────────────────
theme.bg_hover    = "#292e42e8"
theme.widget_bg   = "#00000000"
theme.bar_bg      = c.bg_popup .. "f0"

-- ─── Borders ──────────────────────────────────────────────────────────────────
theme.border_width  = 2
theme.border_normal = c.fg_gutter
theme.border_focus  = c.blue      -- electric blue focus ring
theme.border_marked = c.yellow

-- ─── Titlebar ─────────────────────────────────────────────────────────────────
theme.titlebar_bg_normal  = c.bg_dark
theme.titlebar_bg_focus   = c.bg_popup
theme.titlebar_fg_normal  = c.dark5
theme.titlebar_fg_focus   = c.fg
theme.titlebar_size       = 28

-- Traffic-light button colors (Tokyo Night flavor)
theme.tb_close_bg    = c.red
theme.tb_close_hover = c.magenta2
theme.tb_max_bg      = c.yellow
theme.tb_max_hover   = c.orange
theme.tb_min_bg      = c.green1
theme.tb_min_hover   = c.teal

-- ─── Bar styling tokens ───────────────────────────────────────────────────────
theme.bar_height       = 36
theme.bar_radius       = 18
theme.bar_margin_top   = 8
theme.bar_margin_side  = 12
theme.bar_opacity      = 0.93
theme.bar_border_width = 1
theme.bar_border_color = c.fg_gutter

theme.island_radius    = 10

-- ─── Notification tokens ─────────────────────────────────────────────────────
theme.notification_bg           = c.bg_popup
theme.notification_fg           = c.fg
theme.notification_border_color = c.blue
theme.notification_border_width = 1
theme.notification_shape_radius = 10
theme.notification_font         = "JetBrainsMono Nerd Font 10"
theme.notification_icon_size    = 32
theme.notification_margin       = 14

-- ─── Menu ─────────────────────────────────────────────────────────────────────
theme.menu_bg_normal    = c.bg_popup
theme.menu_bg_focus     = c.bg_highlight
theme.menu_fg_normal    = c.fg
theme.menu_fg_focus     = c.cyan
theme.menu_border_width = 1
theme.menu_border_color = c.fg_gutter
theme.menu_height       = 24
theme.menu_width        = 200

-- ─── Taglist ──────────────────────────────────────────────────────────────────
theme.taglist_bg_focus    = c.blue
theme.taglist_fg_focus    = c.bg_dark
theme.taglist_bg_occupied = c.bg_highlight
theme.taglist_fg_occupied = c.fg
theme.taglist_bg_empty    = "#00000000"
theme.taglist_fg_empty    = c.comment

-- ─── Wallpaper ────────────────────────────────────────────────────────────────
theme.wallpaper = os.getenv("HOME") .. "/Pictures/wallpaper.jpg"

return theme
