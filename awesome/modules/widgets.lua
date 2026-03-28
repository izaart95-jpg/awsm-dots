-- modules/widgets.lua
-- ─────────────────────────────────────────────────────────────────────────────
-- All bar widget factories.
-- • make_pill()  — themed container; FX.attach() wires hover + press.
-- • All color reads go through beautiful so theme switches update them.
-- ─────────────────────────────────────────────────────────────────────────────

local awful     = require("awful")
local wibox     = require("wibox")
local gears     = require("gears")
local beautiful = require("beautiful")
local FX        = require("modules.fx")

local M = {}

-- ─── Nerd Font icon set ───────────────────────────────────────────────────────
M.icons = {
    launcher         = "󰣇",
    cpu              = "",
    memory           = "",
    battery_full     = "󰁹",
    battery_charging = "󰂄",
    battery_high     = "󰂀",
    battery_medium   = "󰁾",
    battery_low      = "󰁼",
    battery_critical = "󰁺",
    volume_high      = "󰕾",
    volume_medium    = "󰖀",
    volume_low       = "󰕿",
    volume_muted     = "󰖁",
    wifi             = "󰤨",
    wifi_off         = "󰤮",
    clock            = "󰅐",
    layout_tile      = "󰍹",
    layout_left      = "󰍺",
    layout_bottom    = "󰍸",
    layout_floating  = "󰍶",
    layout_max       = "󰍷",
    separator        = "󰅂",
    floating         = "󰖬",
    ontop            = "󰖳",
    theme            = "󰸌",
}

M.layout_names = {
    tile       = { icon = "󰍹", name = "Tile" },
    tileleft   = { icon = "󰍺", name = "Tile Left" },
    tilebottom = { icon = "󰍸", name = "Tile Bottom" },
    floating   = { icon = "󰍶", name = "Floating" },
    max        = { icon = "󰍷", name = "Max" },
}

-- ─── Low-level helpers ────────────────────────────────────────────────────────
local FONT = "JetBrainsMono Nerd Font"

local function span(text, color, size)
    return string.format('<span font="%s %s" foreground="%s">%s</span>',
        FONT, tostring(size), color, text)
end
M.span = span

local function mktext(text, color, size)
    return wibox.widget {
        markup = span(text, color, size),
        widget = wibox.widget.textbox,
        align  = "center",
        valign = "center",
    }
end

local function mkicon(icon, size, color)
    size  = size  or 14
    color = color or beautiful.fg_normal or "#cdd6f4"
    local w = mktext(icon, color, size)
    w.forced_width = size + 8
    return w
end

local function pal(key, fallback)
    return (beautiful.palette and beautiful.palette[key]) or fallback
end

-- ─── make_pill: themed pill container ─────────────────────────────────────────
-- Returns a wibox.container.background with hover+press wired via FX.
local function make_pill(opts)
    local pad    = opts.pad    or { left=8, right=8, top=4, bottom=4 }
    local radius = opts.radius or (beautiful.island_radius or 8)

    local inner = opts.content
    if opts.forced_width then
        inner = wibox.widget {
            opts.content,
            forced_width = opts.forced_width,
            widget       = wibox.container.constraint,
        }
    end

    local pill = wibox.widget {
        {
            inner,
            left   = pad.left,
            right  = pad.right,
            top    = pad.top,
            bottom = pad.bottom,
            widget = wibox.container.margin,
        },
        bg     = beautiful.widget_bg or "#00000000",
        shape  = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, radius) end,
        widget = wibox.container.background,
    }

    FX.attach(pill)
    return pill
end

-- ─── Helper: format RAM ───────────────────────────────────────────────────────
function M.format_ram(mb)
    if mb >= 1024 then return string.format("%.1fG", mb / 1024) end
    return mb .. "M"
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- CPU widget
-- ═══════════════════════════════════════════════════════════════════════════════
function M.create_cpu(color)
    color = color or pal("peach", "#fab387")
    local icon_w  = mkicon(M.icons.cpu, 11, color)
    local value_w = mktext("–", color, 9)

    local pill = make_pill {
        forced_width = 68,
        content = wibox.widget {
            layout  = wibox.layout.fixed.horizontal,
            spacing = 4,
            icon_w, value_w,
        },
        pad = { left=8, right=8, top=4, bottom=4 },
    }

    local prev = nil
    awful.widget.watch("grep '^cpu ' /proc/stat", 2, function(_, out)
        local u,n,s,i,w2,ir,si,st =
            out:match("cpu%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
        if not u then return end
        local cur = {
            user=tonumber(u), nice=tonumber(n), system=tonumber(s),
            idle=tonumber(i), iowait=tonumber(w2), irq=tonumber(ir),
            softirq=tonumber(si), steal=tonumber(st),
        }
        cur.total      = cur.user+cur.nice+cur.system+cur.idle+cur.iowait+cur.irq+cur.softirq+cur.steal
        cur.idle_total = cur.idle + cur.iowait
        if prev then
            local dt = cur.total - prev.total
            local di = cur.idle_total - prev.idle_total
            if dt > 0 then
                local pct = math.max(0, math.min(100, (1 - di/dt) * 100))
                value_w.markup = span(string.format("%.0f%%", pct), color, 9)
            end
        end
        prev = cur
    end)
    return pill
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- RAM widget
-- ═══════════════════════════════════════════════════════════════════════════════
function M.create_ram(color)
    color = color or pal("blue", "#89b4fa")
    local icon_w  = mkicon(M.icons.memory, 11, color)
    local value_w = mktext("–", color, 9)

    local pill = make_pill {
        forced_width = 68,
        content = wibox.widget {
            layout  = wibox.layout.fixed.horizontal,
            spacing = 4,
            icon_w, value_w,
        },
        pad = { left=6, right=6, top=4, bottom=4 },
    }

    awful.widget.watch(
        "bash -c \"free -m | awk 'NR==2{printf \\\"%d\\\", $3}'\"",
        3, function(_, out)
            local v = tonumber(out:match("(%d+)") or "0") or 0
            value_w.markup = span(M.format_ram(v), color, 9)
        end)
    return pill
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- Volume widget
-- ═══════════════════════════════════════════════════════════════════════════════
function M.create_volume(color)
    color = color or pal("subtext1", "#bac2de")
    local icon_w  = mkicon(M.icons.volume_high, 11, color)
    local value_w = mktext("–", color, 9)

    local pill = make_pill {
        forced_width = 54,
        content = wibox.widget {
            layout  = wibox.layout.fixed.horizontal,
            spacing = 4,
            icon_w, value_w,
        },
    }

    pill:buttons(gears.table.join(
        awful.button({}, 1, function() awful.spawn("pamixer -t")   end),
        awful.button({}, 4, function() awful.spawn("pamixer -i 5") end),
        awful.button({}, 5, function() awful.spawn("pamixer -d 5") end)
    ))

    awful.widget.watch(
        "bash -c 'v=$(pamixer --get-volume 2>/dev/null||echo 0); "..
        "m=$(pamixer --get-mute 2>/dev/null||echo false); echo $v $m'",
        1, function(_, out)
            local v, muted = out:match("(%d+)%s+(%S+)")
            v = tonumber(v) or 0
            local ico = (muted == "true" or v == 0) and M.icons.volume_muted
                     or v < 33  and M.icons.volume_low
                     or v < 66  and M.icons.volume_medium
                     or             M.icons.volume_high
            icon_w.markup  = span(ico, color, 11)
            value_w.markup = span(v .. "%", color, 9)
        end)
    return pill
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- Battery widget
-- ═══════════════════════════════════════════════════════════════════════════════
function M.create_battery(color)
    color = color or pal("yellow", "#f9e2af")
    local icon_w  = mkicon(M.icons.battery_full, 11, color)
    local value_w = mktext("AC", color, 9)

    local pill = make_pill {
        forced_width = 54,
        content = wibox.widget {
            layout  = wibox.layout.fixed.horizontal,
            spacing = 4,
            icon_w, value_w,
        },
    }

    awful.widget.watch(
        "bash -c 'v=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null||echo AC);"..
        " s=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null||echo AC); echo $v $s'",
        30, function(_, out)
            local v, s = out:match("(%S+)%s+(%S+)")
            if not v then return end
            local teal = pal("teal", "#94e2d5")
            local red  = pal("red",  "#f38ba8")
            if s == "Charging" then
                icon_w.markup  = span(M.icons.battery_charging, color, 11)
                value_w.markup = span(v .. "%", color, 9)
            elseif s == "AC" then
                icon_w.markup  = span(M.icons.battery_full, teal, 11)
                value_w.markup = span("AC", teal, 9)
            else
                local n   = tonumber(v) or 0
                local ico = n > 80 and M.icons.battery_full
                         or n > 60 and M.icons.battery_high
                         or n > 40 and M.icons.battery_medium
                         or n > 15 and M.icons.battery_low
                         or             M.icons.battery_critical
                local col = n <= 15 and red or color
                icon_w.markup  = span(ico,        col,   11)
                value_w.markup = span(v .. "%",   color, 9)
            end
        end)
    return pill
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- WiFi widget
-- ═══════════════════════════════════════════════════════════════════════════════
function M.create_wifi(color)
    color = color or pal("blue", "#89b4fa")
    local icon_w = mkicon(M.icons.wifi, 12, color)
    local pill   = make_pill {
        content = icon_w,
        pad     = { left=4, right=8, top=4, bottom=4 },
    }

    awful.widget.watch(
        "bash -c \"ip a | grep -E '^[0-9]+: (wlan|wl)' | grep UP\"",
        4, function(_, out)
            local off = pal("overlay0", "#6c7086")
            icon_w.markup = (out and out ~= "")
                and span(M.icons.wifi,     color, 12)
                or  span(M.icons.wifi_off, off,   12)
        end)
    return pill
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- Layout icon — with notify callback on change
-- ═══════════════════════════════════════════════════════════════════════════════
function M.create_layout_icon(s, size, notify_fn)
    size = size or 15
    local color = beautiful.fg_normal or "#cdd6f4"

    local function layout_info()
        local name  = awful.layout.getname(awful.layout.get(s))
        local clean = name:gsub("awful%.layout%.suit%.", ""):gsub("%.", "")
        local e     = M.layout_names[clean]
        return (e and e.icon or "󰍹"), (e and e.name or clean)
    end

    local ico      = layout_info()
    local icon_w   = mkicon(ico, size, color)
    icon_w.forced_width = size + 24

    local pill = make_pill {
        content = icon_w,
        pad     = { left=4, right=6, top=4, bottom=4 },
    }

    local function refresh()
        local i, name = layout_info()
        icon_w.markup = span(i, color, size)
        if notify_fn then notify_fn(i, name) end
    end

    s:connect_signal("layout::change",    refresh)
    tag.connect_signal("property::layout", refresh)

    pill:buttons(gears.table.join(
        awful.button({}, 1, function() awful.layout.inc( 1) end),
        awful.button({}, 3, function() awful.layout.inc(-1) end),
        awful.button({}, 4, function() awful.layout.inc( 1) end),
        awful.button({}, 5, function() awful.layout.inc(-1) end)
    ))

    return pill
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- Launcher button (macOS-style rounded square with distro icon)
-- ═══════════════════════════════════════════════════════════════════════════════
function M.create_launcher()
    local mauve = pal("mauve", "#cba6f7")
    local bg_n  = beautiful.bg_focus    or "#313244"
    local bg_h  = beautiful.bg_minimize or "#45475a"

    local icon_w = mkicon(M.icons.launcher, 18, mauve)

    local w = wibox.widget {
        {
            icon_w,
            left   = 6,
            right  = 7,
            top    = 4,
            bottom = 4,
            widget = wibox.container.margin,
        },
        bg     = bg_n,
        shape  = function(cr, w2, h) gears.shape.rounded_rect(cr, w2, h, 8) end,
        widget = wibox.container.background,
    }

    w:connect_signal("button::press", function()
        awful.spawn("rofi -show drun")
    end)
    FX.hover(w,       bg_n, bg_h, 0.12)
    FX.press_flash(w, bg_n, bg_h, 0.10)
    return w
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- Clock
-- ═══════════════════════════════════════════════════════════════════════════════
function M.create_clock()
    local fg    = beautiful.fg_normal or "#cdd6f4"
    local muted = pal("overlay0", "#6c7086")
    return wibox.widget.textclock(
        '<span font="' .. FONT .. ' 11" foreground="' .. fg    .. '">󰅐 %H:%M</span>' ..
        '<span font="' .. FONT .. ' 8"  foreground="' .. muted .. '">  %a %d %b</span>',
        60)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- Taglist factory (used in both bar modes)
-- ═══════════════════════════════════════════════════════════════════════════════
function M.create_taglist(s)
    local radius = beautiful.island_radius or 8
    return awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = gears.table.join(
            awful.button({},       1, function(t) t:view_only() end),
            awful.button({"Mod4"}, 1, function(t)
                if client.focus then client.focus:move_to_tag(t) end
            end),
            awful.button({},       3, awful.tag.viewtoggle),
            awful.button({},       4, function(t) awful.tag.viewnext(t.screen) end),
            awful.button({},       5, function(t) awful.tag.viewprev(t.screen) end)
        ),
        layout = { spacing = 3, layout = wibox.layout.fixed.horizontal },
        widget_template = {
            {
                { id = "text_role", font = "JetBrainsMono Nerd Font Bold 10", widget = wibox.widget.textbox },
                left   = 10,
                right  = 10,
                top    = 3,
                bottom = 3,
                widget = wibox.container.margin,
            },
            id     = "background_role",
            shape  = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, radius) end,
            widget = wibox.container.background,
        },
    }
end

return M
