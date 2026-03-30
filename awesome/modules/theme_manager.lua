-- modules/theme_manager.lua
-- ─────────────────────────────────────────────────────────────────────────────
-- Live theme switching + pywal integration.
-- ─────────────────────────────────────────────────────────────────────────────

local awful     = require("awful")
local gears     = require("gears")
local beautiful = require("beautiful")

local M = {
    current = "catppuccin",
    debug   = true,
    _change_listeners = {},
}

local THEMES = {
    catppuccin = "catppuccin",
    tokyonight = "tokyonight",
    pywal      = "pywal",
}

local function log(msg)
    if M.debug then print("[theme_manager] " .. tostring(msg)) end
end

-- ─── Safe wallpaper setter ────────────────────────────────────────────────────
local function set_wallpaper()
    if not beautiful.wallpaper then return end

    -- Resolve symlinks / verify the file actually exists before handing to Cairo
    local path = beautiful.wallpaper
    local f = io.open(path, "rb")
    if not f then
        log("Wallpaper file not found, skipping: " .. tostring(path))
        return
    end
    f:close()

    for s in screen do
        local ok, err = pcall(gears.wallpaper.maximized, path, s, false)
        if not ok then
            log("gears.wallpaper.maximized failed: " .. tostring(err))
        end
    end
end

-- ─── Apply ────────────────────────────────────────────────────────────────────
function M.apply(name)
    if not THEMES[name] then
        log("Unknown theme: " .. tostring(name))
        return false
    end

    local path = os.getenv("HOME") .. "/.config/awesome/themes/" .. THEMES[name] .. ".lua"

    if name == "pywal" then
        local f = io.open(path, "r")
        if not f then
            log("pywal theme not found. Run: scripts/wal-reload.sh")
            return false
        end
        f:close()
    end

    log("Switching to " .. name .. " → " .. path)

    local ok, err = pcall(beautiful.init, path)
    if not ok then
        log("beautiful.init failed: " .. tostring(err))
        return false
    end

    M.current = name

    -- Update client borders
    for _, c in ipairs(client.get()) do
        if c and c.valid then
            c.border_color = (client.focus == c)
                and (beautiful.border_focus  or "#cba6f7")
                or  (beautiful.border_normal or "#313244")
        end
    end

    -- Update wallpaper safely
    set_wallpaper()

    awesome.emit_signal("theme::changed", name)

    for _, fn in ipairs(M._change_listeners) do
        local ok2, err2 = pcall(fn, name)
        if not ok2 then log("listener error: " .. tostring(err2)) end
    end

    log("Theme applied: " .. name)
    return true
end

-- ─── Toggle catppuccin ↔ tokyonight ↔ pywal ──────────────────────────────────
function M.toggle()
    local order = { "catppuccin", "tokyonight", "pywal" }
    local idx = 1
    for i, n in ipairs(order) do
        if n == M.current then idx = i; break end
    end
    local next_theme = order[(idx % #order) + 1]
    if next_theme == "pywal" then
        local path = os.getenv("HOME") .. "/.config/awesome/themes/pywal.lua"
        local f = io.open(path, "r")
        if not f then
            log("pywal not available, skipping to catppuccin")
            next_theme = "catppuccin"
        else
            f:close()
        end
    end
    return M.apply(next_theme)
end

-- ─── Listener registry ────────────────────────────────────────────────────────
function M.on_changed(fn)
    table.insert(M._change_listeners, fn)
end

-- ─── Watch pywal cache for changes ───────────────────────────────────────────
local _wal_mtime = nil
local function check_wal_update()
    local wal_file = os.getenv("HOME") .. "/.cache/wal/colors.sh"
    local f = io.popen("stat -c %Y " .. wal_file .. " 2>/dev/null")
    if not f then return end
    local mtime_str = f:read("*l")
    f:close()
    local mtime = tonumber(mtime_str)
    if not mtime then return end

    if _wal_mtime and mtime ~= _wal_mtime then
        log("pywal cache changed — triggering wal-reload.sh")
        awful.spawn.easy_async(
            os.getenv("HOME") .. "/.config/awesome/scripts/wal-reload.sh",
            function(stdout, stderr, reason, code)
                log("wal-reload.sh exited: " .. tostring(code))
                if M.current == "pywal" then
                    M.apply("pywal")
                end
            end)
    end
    _wal_mtime = mtime
end

-- ─── Init ─────────────────────────────────────────────────────────────────────
function M.init(current_name)
    M.current = current_name or "catppuccin"
    log("Initialized with theme: " .. M.current)

    local wal_timer = gears.timer { timeout = 5 }
    wal_timer:connect_signal("timeout", check_wal_update)
    wal_timer:start()
    check_wal_update()
end

return M
