-- modules/titlebars.lua
-- ─────────────────────────────────────────────────────────────────────────────
-- macOS-style titlebars:
--   • Colored traffic-light buttons (close / minimize / maximize) on the left
--   • Title centered
--   • Buttons show icons on hover, are plain circles at rest
--   • Rounded window corners
--   • Borders update on focus/unfocus
-- ─────────────────────────────────────────────────────────────────────────────

local awful    = require("awful")
local wibox    = require("wibox")
local gears    = require("gears")
local beautiful = require("beautiful")
local FX       = require("modules.fx")

local M = {}

-- ─── Traffic-light button factory ────────────────────────────────────────────
-- size     : diameter in pixels
-- bg_color : resting color (hex)
-- hover_color : color on hover
-- icon     : Nerd Font glyph shown on hover
-- on_press : callback
local function make_traffic_btn(size, bg_color, hover_color, icon, on_press)
    local FONT  = "JetBrainsMono Nerd Font"
    local icon_w = wibox.widget {
        markup  = "",   -- hidden at rest
        widget  = wibox.widget.textbox,
        align   = "center",
        valign  = "center",
        forced_width  = size,
        forced_height = size,
    }

    local btn = wibox.widget {
        {
            icon_w,
            widget = wibox.container.place,
            halign = "center",
            valign = "center",
        },
        bg            = bg_color,
        forced_width  = size,
        forced_height = size,
        shape         = gears.shape.circle,
        widget        = wibox.container.background,
    }

    -- Hover: show icon + brighten to hover_color via FX.hover
    -- FX.hover manages enter/leave signals internally; we add icon visibility on top.
    FX.hover(btn, bg_color, hover_color, 0.10)

    btn:connect_signal("mouse::enter", function()
        icon_w.markup = string.format(
            '<span font="%s %d" foreground="#00000077">%s</span>',
            FONT, math.floor(size * 0.55), icon)
    end)
    btn:connect_signal("mouse::leave", function()
        icon_w.markup = ""
    end)

    btn:connect_signal("button::press", function(_, _, _, b)
        if b == 1 and on_press then on_press() end
    end)

    return btn
end

-- ─── Build titlebar for a client ─────────────────────────────────────────────
local function build_titlebar(c)
    local size     = beautiful.titlebar_size or 28
    local btn_size = 13
    local btn_gap  = 7

    -- Colors — fall back gracefully if theme doesn't define them
    local close_bg    = beautiful.tb_close_bg    or "#f38ba8"
    local close_hover = beautiful.tb_close_hover or "#eba0ac"
    local max_bg      = beautiful.tb_max_bg      or "#f9e2af"
    local max_hover   = beautiful.tb_max_hover   or "#fab387"
    local min_bg      = beautiful.tb_min_bg      or "#a6e3a1"
    local min_hover   = beautiful.tb_min_hover   or "#94e2d5"

    -- Traffic lights
    local btn_close = make_traffic_btn(btn_size, close_bg, close_hover, "×", function()
        c:kill()
    end)
    local btn_min = make_traffic_btn(btn_size, min_bg, min_hover, "−", function()
        c.minimized = true
    end)
    local btn_max = make_traffic_btn(btn_size, max_bg, max_hover, "+", function()
        c.maximized = not c.maximized
        c:raise()
    end)

    -- Drag region (title)
    local title_w = awful.titlebar.widget.titlewidget(c)
    title_w:set_align("center")

    local drag_buttons = gears.table.join(
        awful.button({}, 1, function()
            c:emit_signal("request::activate", "mouse_click", { raise = true })
            awful.mouse.client.move(c)
        end),
        awful.button({}, 3, function()
            c:emit_signal("request::activate", "mouse_click", { raise = true })
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c, {
        size     = size,
        bg       = beautiful.titlebar_bg_normal or beautiful.bg_normal,
        position = "top",
    }):setup {
        -- Left: traffic lights
        {
            {
                btn_close, btn_min, btn_max,
                spacing = btn_gap,
                layout  = wibox.layout.fixed.horizontal,
            },
            left   = 10,
            right  = 6,
            top    = (size - btn_size) / 2,
            bottom = (size - btn_size) / 2,
            widget = wibox.container.margin,
        },
        -- Center: title
        {
            {
                title_w,
                buttons = drag_buttons,
                layout  = wibox.layout.flex.horizontal,
            },
            widget = wibox.container.place,
            halign = "center",
            valign = "center",
        },
        -- Right: mirror padding to keep title truly centered
        {
            forced_width = 10 + btn_size * 3 + btn_gap * 2 + 6,
            widget       = wibox.widget.base.empty_widget(),
        },
        layout = wibox.layout.align.horizontal,
    }
end

-- ─── Update titlebar bg when focus changes ───────────────────────────────────
local function refresh_titlebar(c, focused)
    local bg = focused
        and (beautiful.titlebar_bg_focus  or beautiful.bg_focus  or "#313244")
        or  (beautiful.titlebar_bg_normal or beautiful.bg_normal or "#1e1e2e")
    local tb = awful.titlebar(c)
    if tb then tb.bg = bg end
end

-- ─── init ─────────────────────────────────────────────────────────────────────
function M.init()
    client.connect_signal("request::titlebars", function(c)
        build_titlebar(c)
    end)

    -- Borders + titlebar bg on focus change
    client.connect_signal("focus", function(c)
        c.border_color = beautiful.border_focus or "#cba6f7"
        refresh_titlebar(c, true)
    end)
    client.connect_signal("unfocus", function(c)
        c.border_color = beautiful.border_normal or "#313244"
        refresh_titlebar(c, false)
    end)

    -- Rounded corners on all clients
    client.connect_signal("manage", function(c)
        c.shape = function(cr, w, h)
            gears.shape.rounded_rect(cr, w, h, 8)
        end
        if awesome.startup
            and not c.size_hints.user_position
            and not c.size_hints.program_position
        then
            awful.placement.no_offscreen(c)
        end
    end)

    -- Rebuild titlebars when theme changes
    awesome.connect_signal("theme::changed", function()
        for _, c in ipairs(client.get()) do
            if c and c.valid then
                awful.titlebar.hide(c)
                awful.titlebar.show(c)
            end
        end
    end)
end

return M
