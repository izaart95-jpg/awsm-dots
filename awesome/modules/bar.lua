-- modules/bar.lua
-- ─────────────────────────────────────────────────────────────────────────────
-- Two bar modes:
--   ISLAND  (default) — three separated floating islands centered on screen
--                        like a macOS-inspired notch dock
--   FULL    — classic full-width wibar attached to the screen edge
--
-- Dynamic wibar styling system:
--   M.style.radius      — island corner radius
--   M.style.margin_top  — gap from screen top
--   M.style.margin_side — gap from screen sides
--   M.style.opacity     — background opacity (0–1)
--   M.style.spacing     — gap between islands
--
-- Theme switching:
--   Subscribes to awesome "theme::changed" signal and fully rebuilds.
-- ─────────────────────────────────────────────────────────────────────────────

local awful    = require("awful")
local wibox    = require("wibox")
local gears    = require("gears")
local beautiful = require("beautiful")
local W        = require("modules.widgets")
local notify   = require("modules.notify")

-- ─── Public config ────────────────────────────────────────────────────────────
local M = {
    show_cpu      = true,
    show_ram      = true,
    show_vol      = true,
    show_bat      = true,
    show_wifi     = true,
    position      = "top",
    floating_mode = false,   -- ← island bar by default

    -- Dynamic styling table — override before calling M.init()
    -- Values here are read at bar-build time; changing them and calling
    -- M.rebuild() will apply immediately.
    style = {
        height       = nil,   -- nil = read from beautiful.bar_height (36)
        radius       = nil,   -- nil = beautiful.bar_radius (pill) or island_radius
        margin_top   = nil,   -- nil = beautiful.bar_margin_top
        margin_side  = nil,   -- nil = beautiful.bar_margin_side
        opacity      = nil,   -- nil = beautiful.bar_opacity
        spacing      = 6,     -- gap between the three islands (px)
        border_width = nil,   -- nil = beautiful.bar_border_width
        border_color = nil,   -- nil = beautiful.bar_border_color
    },

    gap = 4,
}

-- ─── Internal state ───────────────────────────────────────────────────────────
local _screens = {}   -- { [screen] = { wibar=…, islands={…} } }

-- ─── Style helpers ────────────────────────────────────────────────────────────
local function sval(key, theme_key, default)
    return M.style[key] or (beautiful[theme_key]) or default
end

local function get_height()       return sval("height",       "bar_height",       36)      end
local function get_margin_top()   return sval("margin_top",   "bar_margin_top",   8)       end
local function get_margin_side()  return sval("margin_side",  "bar_margin_side",  12)      end
local function get_opacity()      return sval("opacity",      "bar_opacity",      0.92)    end
local function get_border_w()     return sval("border_width", "bar_border_width", 1)       end
local function get_border_c()     return sval("border_color", "bar_border_color", "#45475a") end
local function get_spacing()      return M.style.spacing or 6                               end

local function get_radius_island()
    return sval("radius", "island_radius", 10)
end

-- Encode opacity into the hex bg color (append alpha byte)
local function bg_with_opacity(base_hex, opacity)
    -- base_hex may already carry alpha — strip it to 6 chars
    local hex = (base_hex or "#1e1e2e"):gsub("#", ""):sub(1, 6)
    local alpha = math.floor(math.max(0, math.min(1, opacity)) * 255 + 0.5)
    return "#" .. hex .. string.format("%02x", alpha)
end

-- ─── Gap management ───────────────────────────────────────────────────────────
local function update_gaps()
    local layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
    if layout and (layout:find("floating") or layout:find("max")) then
        beautiful.useless_gap = 0
    else
        beautiful.useless_gap = M.gap
    end
end
screen.connect_signal("layout::change",  update_gaps)
tag.connect_signal("property::layout",   update_gaps)

-- ─── Cleanup helpers ─────────────────────────────────────────────────────────
local function teardown_screen(s)
    local state = _screens[s]
    if not state then return end

    if state.wibar then
        state.wibar.visible = false
        state.wibar = nil
    end
    if state.islands then
        for _, island in ipairs(state.islands) do
            island.visible = false
        end
        state.islands = {}
    end
    _screens[s] = nil
end

-- ─────────────────────────────────────────────────────────────────────────────
-- ISLAND BAR (default)
-- Three separated wiboxes that float above windows:
--   LEFT island  : launcher + taglist
--   CENTER island: clock
--   RIGHT island : system widgets + layout icon
-- ─────────────────────────────────────────────────────────────────────────────
local function create_island_bar(s)
    teardown_screen(s)

    local geo         = s.geometry
    local h           = get_height()
    local mt          = get_margin_top()
    local ms          = get_margin_side()
    local spacing     = get_spacing()
    local radius      = get_radius_island()
    local bw          = get_border_w()
    local bc          = get_border_c()
    local opacity     = get_opacity()
    local bar_bg_base = (beautiful.bg_normal or "#1e1e2e"):sub(1,7)
    local bar_bg      = bg_with_opacity(bar_bg_base, opacity)

    -- Measure pieces so we can centre the clock island
    local left_w  = 200
    local right_w = 220
    local clock_w = 160
    local y       = geo.y + mt

    -- ── Shared island shape ──────────────────────────────────────────────────
    local function island_shape(cr, w2, hh)
        gears.shape.rounded_rect(cr, w2, hh, radius)
    end

    -- ── LEFT island: launcher + taglist ─────────────────────────────────────
    local taglist  = W.create_taglist(s)
    local launcher = W.create_launcher()

    local left_bar = wibox {
        screen       = s,
        x            = geo.x + ms,
        y            = y,
        width        = left_w,
        height       = h,
        bg           = bar_bg,
        visible      = true,
        ontop        = true,
        type         = "dock",
        border_width = bw,
        border_color = bc,
        shape        = island_shape,
    }
    left_bar:setup {
        {
            layout  = wibox.layout.fixed.horizontal,
            spacing = 4,
            {
                launcher,
                left   = 6,
                right  = 2,
                widget = wibox.container.margin,
            },
            {
                taglist,
                left   = 2,
                right  = 6,
                top    = 2,
                bottom = 2,
                widget = wibox.container.margin,
            },
        },
        widget = wibox.container.place,
        halign = "left",
        valign = "center",
    }

    -- ── CENTER island: clock ─────────────────────────────────────────────────
    local clock_x = geo.x + math.floor((geo.width - clock_w) / 2)

    local center_bar = wibox {
        screen       = s,
        x            = clock_x,
        y            = y,
        width        = clock_w,
        height       = h,
        bg           = bar_bg,
        visible      = true,
        ontop        = true,
        type         = "dock",
        border_width = bw,
        border_color = bc,
        shape        = island_shape,
    }
    center_bar:setup {
        W.create_clock(),
        widget = wibox.container.place,
        halign = "center",
        valign = "center",
    }

    -- ── RIGHT island: system widgets + layout ────────────────────────────────
    local right_widgets = wibox.widget {
        layout  = wibox.layout.fixed.horizontal,
        spacing = 0,
    }
    if M.show_cpu  then right_widgets:add(W.create_cpu())     end
    if M.show_ram  then right_widgets:add(W.create_ram())     end
    if M.show_vol  then right_widgets:add(W.create_volume())  end
    if M.show_bat  then right_widgets:add(W.create_battery()) end
    if M.show_wifi then right_widgets:add(W.create_wifi())    end
    right_widgets:add(
        wibox.container.margin(wibox.widget.systray(), 4, 4, 4, 4))
    right_widgets:add(W.create_layout_icon(s, 15, function(icon, name)
        notify.layout(icon, name)
    end))

    local right_bar = wibox {
        screen       = s,
        x            = geo.x + geo.width - ms - right_w,
        y            = y,
        width        = right_w,
        height       = h,
        bg           = bar_bg,
        visible      = true,
        ontop        = true,
        type         = "dock",
        border_width = bw,
        border_color = bc,
        shape        = island_shape,
    }
    right_bar:setup {
        {
            right_widgets,
            left   = 4,
            right  = 8,
            widget = wibox.container.margin,
        },
        widget = wibox.container.place,
        halign = "right",
        valign = "center",
    }

    -- ── Invisible wibar to reserve screen space ──────────────────────────────
    s.mypromptbox = s.mypromptbox or awful.widget.prompt()
    local spacer = awful.wibar {
        position     = M.position,
        screen       = s,
        height       = mt + h + M.gap,
        bg           = "#00000000",
        border_width = 0,
        opacity      = 0,
    }

    _screens[s] = {
        wibar   = spacer,
        islands = { left_bar, center_bar, right_bar },
    }
end

-- ─────────────────────────────────────────────────────────────────────────────
-- FULL BAR
-- Classic full-width attached wibar, no islands.
-- ─────────────────────────────────────────────────────────────────────────────
local function create_full_bar(s)
    teardown_screen(s)

    s.mypromptbox = s.mypromptbox or awful.widget.prompt()

    local h      = get_height()
    local opacity = get_opacity()
    local bar_bg_base = (beautiful.bg_normal or "#1e1e2e"):sub(1,7)
    local bar_bg      = bg_with_opacity(bar_bg_base, opacity)
    local surface1    = (beautiful.palette and beautiful.palette.surface1)
                     or (beautiful.palette and beautiful.palette.fg_gutter)
                     or "#45475a"

    local taglist = W.create_taglist(s)

    local right = wibox.layout.fixed.horizontal()
    right.spacing = 0
    if M.show_cpu  then right:add(W.create_cpu())     end
    if M.show_ram  then right:add(W.create_ram())     end
    if M.show_vol  then right:add(W.create_volume())  end
    if M.show_bat  then right:add(W.create_battery()) end
    if M.show_wifi then right:add(W.create_wifi())    end
    right:add(wibox.container.margin(wibox.widget.systray(), 4, 4, 4, 4))
    right:add(W.create_layout_icon(s, 15, function(icon, name)
        notify.layout(icon, name)
    end))

    local bar = awful.wibar {
        position     = M.position,
        screen       = s,
        height       = h,
        bg           = bar_bg,
        border_width = 0,
    }

    bar:setup {
        layout = wibox.layout.align.horizontal,
        expand = "none",
        {
            layout  = wibox.layout.fixed.horizontal,
            spacing = 4,
            W.create_launcher(),
            wibox.widget {
                markup = '<span font="JetBrainsMono Nerd Font 11" foreground="'..surface1..'">󰁍</span>',
                widget = wibox.widget.textbox,
            },
            wibox.container.margin(taglist, 0, 0, 2, 2),
            s.mypromptbox,
        },
        wibox.container.margin(W.create_clock(), 0, 0, 0, 0),
        right,
    }

    bar.visible = true
    _screens[s] = { wibar = bar, islands = {} }
end

-- ─── Toggle floating ↔ full ───────────────────────────────────────────────────
function M.toggle_floating(s)
    s = s or awful.screen.focused()
    M.floating_mode = not M.floating_mode

    if M.floating_mode then
        create_island_bar(s)
    else
        create_full_bar(s)
    end

    notify.bar_mode(M.floating_mode)
end

-- ─── Rebuild all screens (called on theme change) ─────────────────────────────
function M.rebuild()
    for s in screen do
        if M.floating_mode then
            create_island_bar(s)
        else
            create_full_bar(s)
        end
    end
end

-- ─── Init ─────────────────────────────────────────────────────────────────────
function M.init()
    awful.screen.connect_for_each_screen(function(s)
        awful.tag({ "1","2","3","4","5" }, s, awful.layout.layouts[1])
        s.mypromptbox = awful.widget.prompt()

        if M.floating_mode then
            create_island_bar(s)
        else
            create_full_bar(s)
        end
    end)

    -- Rebuild on theme switch
    awesome.connect_signal("theme::changed", function()
        M.rebuild()
    end)
end

return M
