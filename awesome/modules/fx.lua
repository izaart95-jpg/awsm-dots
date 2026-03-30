-- modules/fx.lua
-- ─────────────────────────────────────────────────────────────────────────────
-- Unified FX system: hover highlights, press feedback, easing, and a global
-- toggle.  All timers use gears.timer so they're garbage-collected properly.
-- No external dependencies — works without rubato.
-- ─────────────────────────────────────────────────────────────────────────────

local gears     = require("gears")
local beautiful = require("beautiful")

-- ─── Module state ─────────────────────────────────────────────────────────────
local M = {
    enabled        = true,   -- global kill-switch
    hover_duration = 0.14,   -- seconds for hover fade
    press_duration = 0.10,   -- seconds for press flash
    step_interval  = 0.016,  -- ~60 fps tick (~16 ms)
}

-- ─── Easing library ───────────────────────────────────────────────────────────
M.easing = {}

function M.easing.linear(t)      return t end
function M.easing.quad_in(t)     return t * t end
function M.easing.quad_out(t)    return t * (2 - t) end
function M.easing.quad_inout(t)
    if t < 0.5 then return 2 * t * t
    else return -1 + (4 - 2 * t) * t end
end
function M.easing.cubic_out(t)   local u = 1 - t; return 1 - u*u*u end
function M.easing.sine_out(t)    return math.sin(t * math.pi / 2) end
function M.easing.expo_out(t)
    if t == 1 then return 1 end
    return 1 - math.pow(2, -10 * t)
end
function M.easing.back_out(t)
    local c1 = 1.70158; local c3 = c1 + 1
    return 1 + c3 * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2)
end

-- ─── Low-level: tween a value from → to over duration, call setter(v) ────────
-- Returns a handle with :stop() to cancel early.
function M.tween(from, to, duration, setter, easing_fn, on_done)
    easing_fn = easing_fn or M.easing.quad_out

    local elapsed = 0
    local handle  = {}
    local started = false   -- guard: don't stop before started
    local timer   = gears.timer { timeout = M.step_interval }

    timer:connect_signal("timeout", function()
        if not M.enabled then
            timer:stop()
            setter(to)
            if on_done then on_done() end
            return
        end

        elapsed = elapsed + M.step_interval
        local t = math.min(elapsed / duration, 1)
        setter(easing_fn(t) * (to - from) + from)

        if t >= 1 then
            timer:stop()
            started = false
            if on_done then on_done() end
        end
    end)

    timer:start()
    started = true

    handle.stop = function()
        if started then
            timer:stop()
            started = false
        end
    end
    return handle
end

-- ─── Hex color utilities ──────────────────────────────────────────────────────
local function hex_to_rgb(hex)
    hex = hex:gsub("#", "")
    if #hex == 8 then
        return tonumber(hex:sub(1,2),16)/255,
               tonumber(hex:sub(3,4),16)/255,
               tonumber(hex:sub(5,6),16)/255,
               tonumber(hex:sub(7,8),16)/255
    else
        return tonumber(hex:sub(1,2),16)/255,
               tonumber(hex:sub(3,4),16)/255,
               tonumber(hex:sub(5,6),16)/255,
               1.0
    end
end

local function rgb_to_hex(r, g, b, a)
    a = a or 1.0
    return string.format("#%02x%02x%02x%02x",
        math.floor(r*255+0.5),
        math.floor(g*255+0.5),
        math.floor(b*255+0.5),
        math.floor(a*255+0.5))
end

local function lerp_color(hex_a, hex_b, t)
    local r1,g1,b1,a1 = hex_to_rgb(hex_a)
    local r2,g2,b2,a2 = hex_to_rgb(hex_b)
    return rgb_to_hex(
        r1 + (r2-r1)*t,
        g1 + (g2-g1)*t,
        b1 + (b2-b1)*t,
        a1 + (a2-a1)*t)
end

-- ─── High-level: hover color fade ─────────────────────────────────────────────
function M.hover(widget, color_normal, color_hover, duration)
    duration    = duration    or M.hover_duration
    color_normal = color_normal or (beautiful.widget_bg or "#00000000")
    color_hover  = color_hover  or (beautiful.bg_focus  or "#313244")

    local current_t    = 0
    local active_tween = nil

    local function animate_to(target_t)
        if active_tween then
            active_tween.stop()
            active_tween = nil
        end
        local start_t = current_t
        active_tween = M.tween(0, 1, duration, function(p)
            current_t = start_t + (target_t - start_t) * p
            widget.bg = lerp_color(color_normal, color_hover, current_t)
        end, M.easing.quad_out)
    end

    widget:connect_signal("mouse::enter",  function() animate_to(1) end)
    widget:connect_signal("mouse::leave",  function() animate_to(0) end)
end

-- ─── High-level: press flash ──────────────────────────────────────────────────
function M.press_flash(widget, color_normal, color_press, duration)
    duration    = duration    or M.press_duration
    color_normal = color_normal or (beautiful.bg_focus   or "#313244")
    color_press  = color_press  or (beautiful.bg_minimize or "#45475a")

    widget:connect_signal("button::press", function()
        if not M.enabled then return end
        widget.bg = color_press
        local t = gears.timer { timeout = duration }
        t:connect_signal("timeout", function()
            t:stop()
            widget.bg = color_normal
        end)
        t:start()
    end)
end

-- ─── High-level: opacity pulse on click ───────────────────────────────────────
function M.opacity_pulse(widget, duration)
    duration = duration or 0.18
    widget:connect_signal("button::press", function()
        if not M.enabled then return end
        local orig = widget.opacity or 1
        M.tween(1, 0.55, duration * 0.4, function(v)
            widget.opacity = v
        end, M.easing.quad_out, function()
            M.tween(0.55, orig, duration * 0.6, function(v)
                widget.opacity = v
            end, M.easing.quad_out)
        end)
    end)
end

-- ─── attach(): the all-in-one call used by widgets.lua / make_pill ────────────
function M.attach(widget, opts)
    opts = opts or {}
    local cn = opts.color_normal or beautiful.widget_bg    or "#00000000"
    local ch = opts.color_hover  or beautiful.bg_hover     or "#2a2c3a"
    local cp = opts.color_press  or beautiful.bg_focus     or "#313244"
    local dh = opts.hover_dur    or M.hover_duration
    local dp = opts.press_dur    or M.press_duration

    M.hover(widget,       cn, ch, dh)
    M.press_flash(widget, ch, cp, dp)
end

-- ─── toggle ───────────────────────────────────────────────────────────────────
function M.toggle()
    M.enabled = not M.enabled
    return M.enabled
end

return M
