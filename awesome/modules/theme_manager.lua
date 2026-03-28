-- modules/theme_manager.lua
-- ─────────────────────────────────────────────────────────────────────────────
-- Live theme switching without requiring awesome.restart.
-- Strategy:
--   1. Re-init beautiful with the new theme file.
--   2. Emit "theme::changed" so every module that subscribed can redraw.
--   3. Rebuild wibars (they hold hard-coded color references).
--   4. Update all client borders & titlebars.
-- Limitations:
--   • Compositor-side blur/transparency requires picom — we just toggle bg
--     opacity tokens; picom itself is not restarted.
--   • Wallpaper is re-applied via feh if the theme defines one.
-- ─────────────────────────────────────────────────────────────────────────────

local awful   = require("awful")
local gears   = require("gears")
local beautiful = require("beautiful")

local M = {
    current = "catppuccin",
    debug   = true,   -- set false to silence logs
    _themes = {},     -- registry of loaded theme names
}

-- Available theme registry (name → relative path under themes/)
local THEMES = {
    catppuccin = "catppuccin",
    tokyonight = "tokyonight",
}

-- ─── Logging ──────────────────────────────────────────────────────────────────
local function log(msg)
    if M.debug then
        print("[theme_manager] " .. tostring(msg))
    end
end

-- ─── Apply a theme by name ────────────────────────────────────────────────────
function M.apply(name)
    if not THEMES[name] then
        log("Unknown theme: " .. tostring(name) .. " — skipping")
        return false
    end

    local path = os.getenv("HOME") .. "/.config/awesome/themes/" .. THEMES[name] .. ".lua"
    log("Switching to " .. name .. " → " .. path)

    -- 1. Reinitialize beautiful
    local ok, err = pcall(beautiful.init, path)
    if not ok then
        log("beautiful.init failed: " .. tostring(err))
        return false
    end

    M.current = name

    -- 2. Update all client borders & shapes immediately
    for _, c in ipairs(client.get()) do
        if c and c.valid then
            c.border_color = (client.focus == c)
                and (beautiful.border_focus  or "#cba6f7")
                or  (beautiful.border_normal or "#313244")
        end
    end

    -- 3. Update wallpaper on all screens
    if beautiful.wallpaper then
        for s in screen do
            gears.wallpaper.maximized(beautiful.wallpaper, s, false)
        end
    end

    -- 4. Emit custom signal — bar.lua and titlebars.lua subscribe to this
    awesome.emit_signal("theme::changed", name)

    -- 5. Rebuild wibars (they bake colors into widget markup)
    --    We rely on bar.lua having registered its rebuild fn via M.on_changed()
    for _, fn in ipairs(M._change_listeners) do
        local ok2, err2 = pcall(fn, name)
        if not ok2 then log("listener error: " .. tostring(err2)) end
    end

    log("Theme applied: " .. name)
    return true
end

-- ─── Toggle between catppuccin ↔ tokyonight ──────────────────────────────────
function M.toggle()
    local next_theme = (M.current == "catppuccin") and "tokyonight" or "catppuccin"
    return M.apply(next_theme)
end

-- ─── Listener registry ────────────────────────────────────────────────────────
M._change_listeners = {}

function M.on_changed(fn)
    table.insert(M._change_listeners, fn)
end

-- ─── Init: set current from whatever beautiful already loaded ─────────────────
function M.init(current_name)
    M.current = current_name or "catppuccin"
    log("Initialized with theme: " .. M.current)
end

return M
