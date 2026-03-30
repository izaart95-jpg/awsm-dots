-- modules/animations.lua
-- ─────────────────────────────────────────────────────────────────────────────
-- Smoke-dissolve window animations.
--
-- IMPORTANT: For open animations to work correctly, disable picom's built-in
-- fading for normal windows, or picom will fight this module.
-- In picom.conf set: fading = false  (or add class exclusions)
--
-- Close animations via unmanage signal cannot fully work in X11/AwesomeWM
-- because the client surface is destroyed before the animation completes.
-- Open animations work reliably.
-- ─────────────────────────────────────────────────────────────────────────────

local gears = require("gears")

local M = {
    enabled      = true,
    duration     = 0.45,
    close_factor = 0.65,
    _active      = {},
}

-- ─── Math helpers ─────────────────────────────────────────────────────────────
local function smooth(t) return t * t * (3 - 2 * t) end

local function smoke_envelope_open(t)
    if t < 0.30 then
        local s = t / 0.30
        return smooth(s) * 0.75 + math.sin(s * math.pi) * 0.10
    elseif t < 0.65 then
        local s = (t - 0.30) / 0.35
        return 0.75 + s * 0.30 - math.sin(s * math.pi * 1.5) * 0.08
    else
        local s = (t - 0.65) / 0.35
        return 0.95 + smooth(s) * 0.05
    end
end

local function smoke_envelope_close(t)
    if t < 0.20 then
        return 1.0 - t * 0.15
    elseif t < 0.60 then
        local s = (t - 0.20) / 0.40
        return 0.85 - smooth(s) * 0.55 + math.sin(s * math.pi * 2) * 0.08
    else
        local s = (t - 0.60) / 0.40
        return 0.30 - smooth(s) * 0.30
    end
end

-- ─── Core tween ───────────────────────────────────────────────────────────────
local TICK = 0.016
local function tween_smoke(c, envelope_fn, duration, on_done)
    if not (c and c.valid) then return end

    -- Cancel any running animation on this client
    local prev = M._active[c]
    if prev then
        prev:stop()
        M._active[c] = nil
    end

    local elapsed = 0
    local stopped = false
    local timer = gears.timer { timeout = TICK }

    local handle = {}
    handle.stop = function()
        if not stopped then
            stopped = true
            timer:stop()
        end
    end
    M._active[c] = handle

    timer:connect_signal("timeout", function()
        if stopped then return end

        if not (c and c.valid) then
            handle.stop()
            M._active[c] = nil
            return
        end

        elapsed = elapsed + TICK
        local t = math.min(elapsed / duration, 1.0)
        local op = math.max(0.0, math.min(1.0, envelope_fn(t)))
        c.opacity = op

        if t >= 1.0 then
            handle.stop()
            M._active[c] = nil
            if on_done then on_done() end
        end
    end)

    timer:start()
end

-- ─── Open (manage) ────────────────────────────────────────────────────────────
local function smoke_open(c)
    if not M.enabled then
        if c and c.valid then c.opacity = 1 end
        return
    end
    c.opacity = 0
    tween_smoke(c, smoke_envelope_open, M.duration, function()
        if c and c.valid then c.opacity = 1 end
    end)
end

-- ─── Close (unmanage) ─────────────────────────────────────────────────────────
-- Note: in X11 AwesomeWM, the client surface is destroyed almost immediately
-- after unmanage fires, so close animations are best-effort only.
local function smoke_close(c)
    if c._smoke_closing then return end
    c._smoke_closing = true
    if not M.enabled then return end

    -- Cancel any open animation first
    local prev = M._active[c]
    if prev then
        prev.stop()
        M._active[c] = nil
    end

    tween_smoke(c, smoke_envelope_close, M.duration * M.close_factor, function()
        if c and c.valid then c.opacity = 0 end
    end)
end

-- ─── init ─────────────────────────────────────────────────────────────────────
function M.init()
    client.connect_signal("manage", function(c)
        if awesome.startup then
            c.opacity = 1
            return
        end
        smoke_open(c)
    end)

    client.connect_signal("unmanage", function(c)
        smoke_close(c)
    end)
end

-- ─── toggle ───────────────────────────────────────────────────────────────────
function M.toggle()
    M.enabled = not M.enabled
    if not M.enabled then
        for c, h in pairs(M._active) do
            h.stop()
            if c and c.valid then c.opacity = 1 end
        end
        M._active = {}
        for _, c in ipairs(client.get()) do
            if c and c.valid then c.opacity = 1 end
        end
    end
    return M.enabled
end

return M
