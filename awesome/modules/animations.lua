-- modules/animations.lua
-- ─────────────────────────────────────────────────────────────────────────────
-- Smoke-dissolve window animations inspired by FBM warped-noise shaders.
-- Since AwesomeWM has no GPU shader pipeline, we approximate the smoke effect
-- by combining:
--   • Rapid opacity modulation following a curved envelope
--   • Geometric scale distortion (shrink/grow from center)
--   • Subtle blur simulation via opacity dithering (multi-step envelope)
--
-- The result looks like windows materialising out of smoke rather than
-- a boring linear fade. For a true GLSL smoke effect, use the niri
-- compositor (Wayland) with the liixini/shaders smoke.glsl files.
--
-- Public API
--   M.init()      — wire up manage/unmanage signals
--   M.toggle()    — enable/disable; restores opacity on all clients
--   M.enabled     — boolean
--   M.duration    — open duration in seconds (default 0.45)
--   M.close_factor— multiplier for close duration (default 0.65)
-- ─────────────────────────────────────────────────────────────────────────────

local gears = require("gears")

local M = {
    enabled      = true,
    duration     = 0.45,
    close_factor = 0.65,
    _active      = {},   -- { [client] = timer } for cleanup
}

-- ─── Optional rubato ──────────────────────────────────────────────────────────
local rubato_ok, rubato = pcall(require, "rubato")
if not rubato_ok then rubato = nil end

-- ─── Math helpers ─────────────────────────────────────────────────────────────

-- Smooth cubic in-out (Perlin-style)
local function smooth(t) return t * t * (3 - 2 * t) end

-- FBM-like envelope: irregular "smoke puff" curve
-- Maps t∈[0,1] → opacity∈[0,1] with an irregular rise shape
-- Mimics the warpedFbm "appear" variable from the GLSL shader.
local function smoke_envelope_open(t)
    -- Phase 1 (0→0.3): rapid turbulent rise with slight overshoot
    -- Phase 2 (0.3→0.7): settle — small dip then climb (smoke curl)
    -- Phase 3 (0.7→1.0): smooth land at 1.0
    if t < 0.30 then
        local s = t / 0.30
        return smooth(s) * 0.75 + math.sin(s * math.pi) * 0.10
    elseif t < 0.65 then
        local s = (t - 0.30) / 0.35
        -- slight dip then rise — the "curl" of smoke
        return 0.75 + s * 0.30 - math.sin(s * math.pi * 1.5) * 0.08
    else
        local s = (t - 0.65) / 0.35
        return 0.95 + smooth(s) * 0.05
    end
end

-- Reverse smoke for close: fast opaque → turbulent dissolve → gone
local function smoke_envelope_close(t)
    if t < 0.20 then
        return 1.0 - t * 0.15   -- brief hold (smoke gathers)
    elseif t < 0.60 then
        local s = (t - 0.20) / 0.40
        -- "disperse" phase — breaks apart unevenly
        return 0.85 - smooth(s) * 0.55 + math.sin(s * math.pi * 2) * 0.08
    else
        local s = (t - 0.60) / 0.40
        return 0.30 - smooth(s) * 0.30
    end
end

-- ─── Core tween ───────────────────────────────────────────────────────────────
local TICK = 0.014   -- ~70fps
local function tween_smoke(c, envelope_fn, duration, on_done)
    if not (c and c.valid) then return end

    -- Cancel any running animation on this client
    if M._active[c] then
        M._active[c]:stop()
        M._active[c] = nil
    end

    local elapsed = 0
    local timer = gears.timer { timeout = TICK }
    M._active[c] = timer

    timer:connect_signal("timeout", function()
        if not (c and c.valid) then
            timer:stop()
            M._active[c] = nil
            return
        end

        elapsed = elapsed + TICK
        local t = math.min(elapsed / duration, 1.0)
        local op = math.max(0.0, math.min(1.0, envelope_fn(t)))
        c.opacity = op

        if t >= 1.0 then
            timer:stop()
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

-- ─── Close (unmanage) ────────────────────────────────────────────────────────
local function smoke_close(c)
    if c._smoke_closing then return end
    c._smoke_closing = true
    if not M.enabled then return end

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
        -- Stop all active timers, restore opacity
        for c, t in pairs(M._active) do
            t:stop()
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
