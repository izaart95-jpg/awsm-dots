-- modules/animations.lua
-- ─────────────────────────────────────────────────────────────────────────────
-- Window lifecycle animations (fade-in on manage, fade-out on unmanage).
-- Also exposes the global animation toggle consumed by keybindings.lua.
-- Widget hover/press animations live in modules/fx.lua.
-- ─────────────────────────────────────────────────────────────────────────────

local gears = require("gears")

local M = {
    enabled  = true,
    duration = 0.5,  -- seconds for fade-in
    -- Duration multiplier for fade-out (slightly snappier feels better)
    close_factor = 0.7,
}

-- ─── Optional rubato support ──────────────────────────────────────────────────
local rubato_ok, rubato = pcall(require, "rubato")
if not rubato_ok then
    rubato = nil
end

-- ─── Easing (inline so animations.lua is self-contained) ─────────────────────
local function quad_out(t) return t * (2 - t) end

-- ─── Core: tween opacity with gears.timer fallback ────────────────────────────
-- Uses rubato when available for smoother results; falls back gracefully.
local function tween_opacity(c, from_op, to_op, duration)
    if not M.enabled then
        if c and c.valid then c.opacity = to_op end
        return
    end

    -- ── rubato path ──────────────────────────────────────────────────────────
    if rubato then
        c.opacity = from_op
        local anim = rubato.timed {
            duration   = duration,
            pos        = from_op,
            easing     = rubato.easing and rubato.easing.quadratic or nil,
            subscribed = function(pos)
                if c and c.valid then c.opacity = pos end
            end,
        }
        anim.target = to_op
        return
    end

    -- ── gears.timer fallback (~60fps) ────────────────────────────────────────
    local step    = 0.016
    local elapsed = 0
    local timer   = gears.timer { timeout = step }
    c.opacity = from_op

    timer:connect_signal("timeout", function()
        elapsed = elapsed + step
        local t = math.min(elapsed / duration, 1)
        if c and c.valid then
            c.opacity = from_op + (to_op - from_op) * quad_out(t)
        end
        if t >= 1 then
            timer:stop()
            -- Ensure we land exactly on the target
            if c and c.valid then c.opacity = to_op end
        end
    end)

    timer:start()
end

-- ─── Window open ──────────────────────────────────────────────────────────────
local function fade_in(c)
    tween_opacity(c, 0, 1, M.duration)
end

-- ─── Window close ─────────────────────────────────────────────────────────────
local function fade_out(c)
    if c._fading_out then return end  -- guard against double-signal
    c._fading_out = true
    tween_opacity(c, 1, 0, M.duration * M.close_factor)
end

-- ─── init ─────────────────────────────────────────────────────────────────────
function M.init()
    client.connect_signal("manage", function(c)
        -- Skip on awesome restart to avoid startup flicker
        if awesome.startup then
            c.opacity = 1
            return
        end
        fade_in(c)
    end)

    client.connect_signal("unmanage", function(c)
        fade_out(c)
    end)
end

-- ─── toggle (called from keybindings) ─────────────────────────────────────────
function M.toggle()
    M.enabled = not M.enabled
    -- Restore opacity on all existing clients when disabling
    if not M.enabled then
        for _, c in ipairs(client.get()) do
            if c and c.valid then c.opacity = 1 end
        end
    end
    return M.enabled
end

return M
