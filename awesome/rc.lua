-- rc.lua — Awesome WM entry point
-- ═══════════════════════════════════════════════════════════════════════════════
-- Load order:
--   1. Error handling
--   2. Libraries
--   3. Theme (beautiful.init)
--   4. Theme manager (live switching)
--   5. Layouts
--   6. FX system (widget animations)
--   7. Window animations
--   8. Bar & Widgets (island bar by default)
--   9. Keybindings
--  10. Rules
--  11. Titlebars & client signals
--  12. Startup applications
-- ═══════════════════════════════════════════════════════════════════════════════

-- ─── 1. Error handling ────────────────────────────────────────────────────────
local naughty = require("naughty")

if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title  = "Startup Error",
        text   = awesome.startup_errors,
    })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        if in_error then return end
        in_error = true
        naughty.notify({
            preset = naughty.config.presets.critical,
            title  = "Error",
            text   = tostring(err),
        })
        in_error = false
    end)
end

-- ─── 2. Libraries ─────────────────────────────────────────────────────────────
local gears    = require("gears")
local awful    = require("awful")
require("awful.autofocus")
local beautiful = require("beautiful")

-- Extend Lua path for any system-installed modules
package.path  = package.path  .. ";/usr/share/lua/5.4/?.lua;/usr/share/lua/5.4/?/init.lua"
package.cpath = package.cpath .. ";/usr/lib/lua/5.4/?.so"

-- ─── 3. Theme ─────────────────────────────────────────────────────────────────
-- Options: "catppuccin"  |  "tokyonight"
-- Live switching is handled by modules/theme_manager.lua — no restart needed.
local THEME = "catppuccin"

local theme_path = os.getenv("HOME") .. "/.config/awesome/themes/" .. THEME .. ".lua"
beautiful.init(theme_path)

-- ─── 4. Theme manager ─────────────────────────────────────────────────────────
local theme_manager = require("modules.theme_manager")
theme_manager.init(THEME)
-- Debug mode: set false to silence "[theme_manager]" log lines
theme_manager.debug = true

-- ─── 5. Config ────────────────────────────────────────────────────────────────
local terminal = "kitty"
local modkey   = "Mod4"
beautiful.useless_gap = 4

-- ─── 6. Layouts ───────────────────────────────────────────────────────────────
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.floating,
    awful.layout.suit.max,
}

-- ─── 7. FX system (widget hover/press animations) ─────────────────────────────
local fx = require("modules.fx")
-- Tune global defaults here if desired:
-- fx.hover_duration = 0.12
-- fx.press_duration = 0.08

-- ─── 8. Window animations ─────────────────────────────────────────────────────
local animations = require("modules.animations")
animations.init()
-- animations.enabled  = true
-- animations.duration = 0.18

-- ─── 9. Notification helper ───────────────────────────────────────────────────
local notify = require("modules.notify")

-- ─── 10. Bar & Widgets ────────────────────────────────────────────────────────
local bar = require("modules.bar")
bar.show_cpu      = false
bar.show_ram      = true
bar.show_vol      = true
bar.show_bat      = false
bar.show_wifi     = true
bar.position      = "top"
bar.floating_mode = true    -- ← island bar by default

-- Optional: fine-tune island bar appearance here
-- bar.style.margin_top  = 8
-- bar.style.margin_side = 12
-- bar.style.spacing     = 6
-- bar.style.opacity     = 0.92

bar.init()

-- ─── 11. Keybindings ──────────────────────────────────────────────────────────
local keybindings = require("modules.keybindings")
local clientkeys, clientbuttons = keybindings.init({
    terminal      = terminal,
    modkey        = modkey,
    animations    = animations,
    bar           = bar,
    theme_manager = theme_manager,
    fx            = fx,
    notify        = notify,
})

-- ─── 12. Rules ────────────────────────────────────────────────────────────────
local rules = require("modules.rules")
rules.init(clientkeys, clientbuttons)

-- ─── 13. Titlebars & client signals ───────────────────────────────────────────
local titlebars = require("modules.titlebars")
titlebars.init()

-- ─── 14. Startup applications ─────────────────────────────────────────────────
awful.spawn.with_shell("pkill -9 picom 2>/dev/null; pkill -9 dunst 2>/dev/null; true")
awful.spawn.with_shell("sleep 0.2 && dunst &")
awful.spawn.with_shell("sleep 0.2 && picom -b &")
awful.spawn.with_shell(
    "feh --bg-fill " .. os.getenv("HOME") .. "/Pictures/wallpaper.jpg 2>/dev/null || true")
