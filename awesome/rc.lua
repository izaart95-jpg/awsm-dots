-- rc.lua — Awesome WM entry point
-- ═══════════════════════════════════════════════════════════════════════════════
-- Load order:
--   1.  Error handling
--   2.  Libraries
--   3.  Theme (beautiful.init) — prefers pywal if available
--   4.  Theme manager (live switching + pywal watcher)
--   5.  Layouts
--   6.  FX system
--   7.  Window animations (smoke/dissolve)
--   8.  Bar & Widgets
--   9.  Keybindings
--  10.  Rules
--  11.  Titlebars & client signals
--  12.  Startup applications
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
        naughty.notify({ preset = naughty.config.presets.critical,
                         title  = "Error", text = tostring(err) })
        in_error = false
    end)
end

-- ─── 2. Libraries ─────────────────────────────────────────────────────────────
local gears    = require("gears")
local awful    = require("awful")
require("awful.autofocus")
local beautiful = require("beautiful")
package.path  = package.path  .. ";/usr/share/lua/5.4/?.lua;/usr/share/lua/5.4/?/init.lua"
package.cpath = package.cpath .. ";/usr/lib/lua/5.4/?.so"

-- ─── 3. Theme — prefer pywal, fall back to catppuccin ─────────────────────────
local function pick_theme()
    -- If user set WAL_THEME env var, use that
    local env_theme = os.getenv("AWESOME_THEME")
    if env_theme then return env_theme end

    -- If pywal theme file exists and wal cache exists, use pywal
    local home = os.getenv("HOME")
    local pywal_theme = home .. "/.config/awesome/themes/pywal.lua"
    local wal_cache   = home .. "/.cache/wal/colors.sh"
    local f1 = io.open(pywal_theme, "r")
    local f2 = io.open(wal_cache,   "r")
    if f1 and f2 then
        f1:close(); f2:close()
        return "pywal"
    end
    if f1 then f1:close() end
    if f2 then f2:close() end

    return "catppuccin"
end

local THEME = pick_theme()
local theme_path = os.getenv("HOME") .. "/.config/awesome/themes/" .. THEME .. ".lua"
beautiful.init(theme_path)

-- ─── 4. Theme manager ─────────────────────────────────────────────────────────
local theme_manager = require("modules.theme_manager")
theme_manager.init(THEME)
theme_manager.debug = false   -- set true to see [theme_manager] logs

-- ─── 5. Config ────────────────────────────────────────────────────────────────
local terminal = os.getenv("TERMINAL") or "kitty"
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

-- ─── 7. FX system ─────────────────────────────────────────────────────────────
local fx = require("modules.fx")

-- ─── 8. Window animations (smoke/dissolve) ────────────────────────────────────
local animations = require("modules.animations")
animations.init()
-- Tune smoke feel here:
-- animations.duration     = 0.50   -- seconds (open)
-- animations.close_factor = 0.60   -- multiplier for close

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
bar.floating_mode = true

-- Appearance tweaks (optional):
-- bar.style.margin_top  = 8
-- bar.style.margin_side = 12
-- bar.style.opacity     = 0.92
-- bar.style.spacing     = 8

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

-- Apply wallpaper: use pywal's stored wallpaper if available
awful.spawn.with_shell([[
    WAL="$HOME/.cache/wal/wal"
    if [[ -f "$WAL" ]]; then
        feh --bg-fill "$WAL"
    else
        feh --bg-fill "$HOME/Pictures/wallpaper.jpg" 2>/dev/null || true
    fi
]])

-- Auto-generate pywal theme if wal cache exists but theme lua doesn't
awful.spawn.with_shell([[
    THEME="$HOME/.config/awesome/themes/pywal.lua"
    CACHE="$HOME/.cache/wal/colors.sh"
    SCRIPT="$HOME/.config/awesome/scripts/wal-reload.sh"
    if [[ -f "$CACHE" && ! -f "$THEME" && -x "$SCRIPT" ]]; then
        "$SCRIPT" &
    fi
]])
