-- modules/bar.lua
-- ─────────────────────────────────────────────────────────────────────────────
-- Two bar modes:
--   ISLAND  (default) — three floating islands, properly spaced
--   FULL    — classic full-width wibar
--
-- pywal integration: auto-detects themes/pywal.lua and rebuilds on wal change.
-- ─────────────────────────────────────────────────────────────────────────────

local awful     = require("awful")
local wibox     = require("wibox")
local gears     = require("gears")
local beautiful = require("beautiful")
local W         = require("modules.widgets")
local notify    = require("modules.notify")

-- ─── Public config ────────────────────────────────────────────────────────────
local M = {
    show_cpu      = true,
    show_ram      = true,
    show_vol      = true,
    show_bat      = true,
    show_wifi     = true,
    position      = "top",
    floating_mode = true,

    style = {
        height       = nil,
        radius       = nil,
        margin_top   = nil,
        margin_side  = nil,
        opacity      = nil,
        spacing      = 8,
        border_width = nil,
        border_color = nil,
    },

    gap = 4,
}

-- ─── Internal state ───────────────────────────────────────────────────────────
local _screens = {}

-- ─── Style helpers ────────────────────────────────────────────────────────────
local function sval(key, theme_key, default)
    return M.style[key] or beautiful[theme_key] or default
end

local function get_height()      return sval("height",       "bar_height",       36)    end
local function get_margin_top()  return sval("margin_top",   "bar_margin_top",   8)     end
local function get_margin_side() return sval("margin_side",  "bar_margin_side",  12)    end
local function get_opacity()     return sval("opacity",      "bar_opacity",      0.92)  end
local function get_border_w()    return sval("border_width", "bar_border_width", 1)     end
local function get_border_c()    return sval("border_color", "bar_border_color", "#45475a") end
local function get_spacing()     return M.style.spacing or 8                             end
local function get_radius()      return sval("radius",       "island_radius",    10)    end

local function bg_with_opacity(hex, opacity)
    local h = (hex or "#1e1e2e"):gsub("#", ""):sub(1, 6)
    local a = math.floor(math.max(0, math.min(1, opacity)) * 255 + 0.5)
    return "#" .. h .. string.format("%02x", a)
end

-- ─── Gap management ───────────────────────────────────────────────────────────
local function update_gaps()
    local layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
    beautiful.useless_gap = (layout and (layout:find("floating") or layout:find("max"))) and 0 or M.gap
end
screen.connect_signal("layout::change", update_gaps)
tag.connect_signal("property::layout",  update_gaps)

-- ─── Cleanup ──────────────────────────────────────────────────────────────────
local function teardown_screen(s)
    local state = _screens[s]
    if not state then return end
    if state.wibar   then state.wibar.visible = false; state.wibar = nil end
    if state.islands then
        for _, island in ipairs(state.islands) do island.visible = false end
        state.islands = {}
    end
    _screens[s] = nil
end

-- ─── Separator widget ─────────────────────────────────────────────────────────
local function make_sep()
    local c = (beautiful.palette and beautiful.palette.surface1)
           or (beautiful.palette and beautiful.palette.fg_gutter)
           or "#45475a"
    return wibox.widget {
        markup        = string.format('<span foreground="%s">│</span>', c),
        widget        = wibox.widget.textbox,
        forced_width  = 8,
        align         = "center",
        valign        = "center",
    }
end

-- ─────────────────────────────────────────────────────────────────────────────
-- ISLAND BAR
-- ─────────────────────────────────────────────────────────────────────────────
local function create_island_bar(s)
    teardown_screen(s)

    local geo     = s.geometry
    local h       = get_height()
    local mt      = get_margin_top()
    local ms      = get_margin_side()
    local spacing = get_spacing()
    local radius  = get_radius()
    local bw      = get_border_w()
    local bc      = get_border_c()
    local opacity = get_opacity()
    local bg_base = (beautiful.bg_normal or "#1e1e2e"):sub(1,7)
    local bar_bg  = bg_with_opacity(bg_base, opacity)
    local y       = geo.y + mt

    local function island_shape(cr, w, hh)
        gears.shape.rounded_rect(cr, w, hh, radius)
    end

    -- Measure left island content dynamically
    local left_w  = 220
    local right_w = 260
    local clock_w = 170
    local clock_x = geo.x + math.floor((geo.width - clock_w) / 2)

    -- ── LEFT: launcher + separator + taglist ─────────────────────────────────
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
            spacing = 0,
            wibox.container.margin(W.create_launcher(), 6, 4, 4, 4),
            wibox.container.margin(make_sep(), 0, 4, 0, 0),
            wibox.container.margin(W.create_taglist(s), 2, 6, 2, 2),
        },
        widget = wibox.container.place,
        halign = "left",
        valign = "center",
    }

    -- ── CENTER: clock ─────────────────────────────────────────────────────────
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

    -- ── RIGHT: system widgets ─────────────────────────────────────────────────
    local right_inner = wibox.widget {
        layout  = wibox.layout.fixed.horizontal,
        spacing = 2,
    }

    if M.show_cpu  then right_inner:add(W.create_cpu())    end
    if M.show_ram  then right_inner:add(W.create_ram())    end
    if M.show_vol  then right_inner:add(W.create_volume()) end
    if M.show_bat  then right_inner:add(W.create_battery()) end
    if M.show_wifi then right_inner:add(W.create_wifi())   end

    right_inner:add(make_sep())
    right_inner:add(wibox.container.margin(wibox.widget.systray(), 2, 2, 4, 4))
    right_inner:add(W.create_layout_icon(s, 14, function(icon, name)
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
            right_inner,
            left   = 6,
            right  = 8,
            widget = wibox.container.margin,
        },
        widget = wibox.container.place,
        halign = "right",
        valign = "center",
    }

    -- ── Invisible spacer wibar ────────────────────────────────────────────────
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
-- ─────────────────────────────────────────────────────────────────────────────
local function create_full_bar(s)
    teardown_screen(s)

    s.mypromptbox = s.mypromptbox or awful.widget.prompt()

    local h       = get_height()
    local opacity = get_opacity()
    local bg_base = (beautiful.bg_normal or "#1e1e2e"):sub(1,7)
    local bar_bg  = bg_with_opacity(bg_base, opacity)
    local surface1 = (beautiful.palette and (beautiful.palette.surface1 or beautiful.palette.fg_gutter))
                  or "#45475a"

    local taglist = W.create_taglist(s)

    local right = wibox.layout.fixed.horizontal()
    right.spacing = 2
    if M.show_cpu  then right:add(W.create_cpu())    end
    if M.show_ram  then right:add(W.create_ram())    end
    if M.show_vol  then right:add(W.create_volume()) end
    if M.show_bat  then right:add(W.create_battery()) end
    if M.show_wifi then right:add(W.create_wifi())   end
    right:add(make_sep())
    right:add(wibox.container.margin(wibox.widget.systray(), 4, 4, 4, 4))
    right:add(W.create_layout_icon(s, 14, function(icon, name)
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
                markup = string.format('<span font="JetBrainsMono Nerd Font 11" foreground="%s">󰁍</span>', surface1),
                widget = wibox.widget.textbox,
            },
            wibox.container.margin(taglist, 0, 0, 2, 2),
            s.mypromptbox,
        },
        W.create_clock(),
        right,
    }
    bar.visible = true
    _screens[s] = { wibar = bar, islands = {} }
end

-- ─── Toggle ───────────────────────────────────────────────────────────────────
function M.toggle_floating(s)
    s = s or awful.screen.focused()
    M.floating_mode = not M.floating_mode
    if M.floating_mode then create_island_bar(s)
    else create_full_bar(s) end
    notify.bar_mode(M.floating_mode)
end

-- ─── Rebuild ──────────────────────────────────────────────────────────────────
function M.rebuild()
    for s in screen do
        if M.floating_mode then create_island_bar(s)
        else create_full_bar(s) end
    end
end

-- ─── Init ─────────────────────────────────────────────────────────────────────
function M.init()
    awful.screen.connect_for_each_screen(function(s)
        awful.tag({ "1","2","3","4","5" }, s, awful.layout.layouts[1])
        s.mypromptbox = awful.widget.prompt()
        if M.floating_mode then create_island_bar(s)
        else create_full_bar(s) end
    end)

    awesome.connect_signal("theme::changed", function()
        M.rebuild()
    end)
end

return M
