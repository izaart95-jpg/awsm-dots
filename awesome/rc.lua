-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

package.path = package.path .. ";/usr/share/lua/5.4/?.lua;/usr/share/lua/5.4/?/init.lua"
package.cpath = package.cpath .. ";/usr/lib/lua/5.4/?.so"

-- Load rubato for animations
local rubato_available = false
local rubato = nil
local success, result = pcall(function() return require("rubato") end)

if success then
    rubato_available = true
    rubato = result
    print("DEBUG: [Animations] Rubato library loaded successfully.")
else
    print("DEBUG: [Animations] FAILED to load Rubato. Error: " .. tostring(result))
end

-- Load theme
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/catppuccin.lua")

-- ============================================
-- Window Gaps Configuration
-- ============================================
-- Set gap size (adjust this value to your preference)
beautiful.useless_gap = 4  -- 8px gaps between windows

-- Optional: Different gap sizes for different layouts
local function set_gap_size()
    local layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))

    -- No gaps for floating and max layouts
    if layout and (layout:find("floating") or layout:find("max")) then
        beautiful.useless_gap = 0
    else
        beautiful.useless_gap = 4  -- Your desired gap size
    end
end

-- Update gaps when layout changes
screen.connect_signal("layout::change", set_gap_size)
tag.connect_signal("property::layout", set_gap_size)

-- ============================================
-- CONFIGURATION
-- ============================================
local terminal = "kitty"
local modkey = "Mod4"
local bar_pos = "top"

-- Nerd Font Icons
local icons = {
    launcher    = "󰣇",
    cpu         = "",
    memory      = "",
    battery_full = "󰁹",
    battery_charging = "󰂄",
    battery_high = "󰂀",
    battery_medium = "󰁾",
    battery_low = "󰁼",
    battery_critical = "󰁺",
    volume_high = "󰕾",
    volume_medium = "󰖀",
    volume_low = "󰕿",
    volume_muted = "󰖁",
    wifi = "󰤨",
    wifi_off = "󰤮",
    clock = "󰅐",
    layout_tile = "󰍹",
    layout_left = "󰍺",
    layout_bottom = "󰍸",
    layout_floating = "󰍶",
    layout_max = "󰍷",
    arrow = "󰅂",
    floating = "󰖬",
    ontop = "󰖳"
}

-- Layouts
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.floating,
    awful.layout.suit.max,
}

-- ============================================
-- Helper Functions
-- ============================================

-- Create an icon widget
local function icon_widget(icon, size, color)
    size = size or 14
    color = color or "#cdd6f4"
    return wibox.widget {
        markup = '<span font="JetBrainsMono Nerd Font ' .. size .. '" foreground="' .. color .. '">' .. icon .. '</span>',
        widget = wibox.widget.textbox
    }
end

-- Create a label widget
local function label(text, color, size)
    size = size or 10
    color = color or "#cdd6f4"
    return wibox.widget {
        markup = '<span font="JetBrainsMono Nerd Font ' .. size .. '" foreground="' .. color .. '">' .. text .. '</span>',
        widget = wibox.widget.textbox
    }
end

-- Create a monitor widget (fixed width to avoid overlapping)
local function create_monitor(icon, color, unit)
    local icon_w = icon_widget(icon, 12, color)
    local value_w = label("0" .. unit, color, 9)

    local content = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        spacing = 6,
        icon_w,
        value_w
    }

    -- Wrap in a constraint to fix width
    local fixed = wibox.widget {
        content,
        forced_width = 70,   -- Adjust as needed
        widget = wibox.container.constraint
    }

    local container = wibox.widget {
        {
            fixed,
            left = 8,
            right = 8,
            top = 4,
            bottom = 4,
            widget = wibox.container.margin
        },
        bg = "#00000000",
        shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 6) end,
        widget = wibox.container.background,
    }

    container:connect_signal("mouse::enter", function()
        container.bg = "#2a2c3a"
    end)
    container:connect_signal("mouse::leave", function()
        container.bg = "#00000000"
    end)

    return {
        widget = container,
        value = value_w,
        update = function(self, val)
            self.value.markup = '<span font="JetBrainsMono Nerd Font 9" foreground="' .. color .. '">' .. val .. unit .. '</span>'
        end
    }
end

-- Create volume widget (fixed width)
local function create_volume()
    local icon_w = icon_widget(icons.volume_high, 12, "#bac2de")
    local value_w = label("0%", "#bac2de", 9)

    local content = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        spacing = 6,
        icon_w,
        value_w
    }

    local fixed = wibox.widget {
        content,
        forced_width = 70,
        widget = wibox.container.constraint
    }

    local container = wibox.widget {
        {
            fixed,
            left = 8,
            right = 8,
            top = 4,
            bottom = 4,
            widget = wibox.container.margin
        },
        bg = "#00000000",
        shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 6) end,
        widget = wibox.container.background,
    }

    container:buttons(gears.table.join(
        awful.button({}, 1, function() awful.spawn("pamixer -t") end),
        awful.button({}, 4, function() awful.spawn("pamixer -i 5") end),
        awful.button({}, 5, function() awful.spawn("pamixer -d 5") end)
    ))

    container:connect_signal("mouse::enter", function()
        container.bg = "#2a2c3a"
    end)
    container:connect_signal("mouse::leave", function()
        container.bg = "#00000000"
    end)

    return {
        widget = container,
        icon = icon_w,
        value = value_w,
        update = function(self, val, muted)
            if muted == "true" or val == 0 then
                self.icon.markup = '<span font="JetBrainsMono Nerd Font 12" foreground="#bac2de">' .. icons.volume_muted .. '</span>'
            elseif val < 33 then
                self.icon.markup = '<span font="JetBrainsMono Nerd Font 12" foreground="#bac2de">' .. icons.volume_low .. '</span>'
            elseif val < 66 then
                self.icon.markup = '<span font="JetBrainsMono Nerd Font 12" foreground="#bac2de">' .. icons.volume_medium .. '</span>'
            else
                self.icon.markup = '<span font="JetBrainsMono Nerd Font 12" foreground="#bac2de">' .. icons.volume_high .. '</span>'
            end
            self.value.markup = '<span font="JetBrainsMono Nerd Font 9" foreground="#bac2de">' .. val .. '%</span>'
        end
    }
end

-- Create battery widget (fixed width)
local function create_battery()
    local icon_w = icon_widget(icons.battery_full, 12, "#f9e2af")
    local value_w = label("AC", "#f9e2af", 9)

    local content = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        spacing = 6,
        icon_w,
        value_w
    }

    local fixed = wibox.widget {
        content,
        forced_width = 70,
        widget = wibox.container.constraint
    }

    local container = wibox.widget {
        {
            fixed,
            left = 8,
            right = 8,
            top = 4,
            bottom = 4,
            widget = wibox.container.margin
        },
        bg = "#00000000",
        shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 6) end,
        widget = wibox.container.background,
    }

    container:connect_signal("mouse::enter", function()
        container.bg = "#2a2c3a"
    end)
    container:connect_signal("mouse::leave", function()
        container.bg = "#00000000"
    end)

    return {
        widget = container,
        icon = icon_w,
        value = value_w,
        update = function(self, val, status)
            if status == "Charging" then
                self.icon.markup = '<span font="JetBrainsMono Nerd Font 12" foreground="#f9e2af">' .. icons.battery_charging .. '</span>'
                self.value.markup = '<span font="JetBrainsMono Nerd Font 9" foreground="#f9e2af">' .. val .. '%</span>'
            elseif status == "AC" then
                self.icon.markup = '<span font="JetBrainsMono Nerd Font 12" foreground="#94e2d5">' .. icons.battery_full .. '</span>'
                self.value.markup = '<span font="JetBrainsMono Nerd Font 9" foreground="#94e2d5">AC</span>'
            else
                local v = tonumber(val) or 0
                if v > 80 then
                    self.icon.markup = '<span font="JetBrainsMono Nerd Font 12" foreground="#f9e2af">' .. icons.battery_full .. '</span>'
                elseif v > 60 then
                    self.icon.markup = '<span font="JetBrainsMono Nerd Font 12" foreground="#f9e2af">' .. icons.battery_high .. '</span>'
                elseif v > 40 then
                    self.icon.markup = '<span font="JetBrainsMono Nerd Font 12" foreground="#f9e2af">' .. icons.battery_medium .. '</span>'
                elseif v > 15 then
                    self.icon.markup = '<span font="JetBrainsMono Nerd Font 12" foreground="#f9e2af">' .. icons.battery_low .. '</span>'
                else
                    self.icon.markup = '<span font="JetBrainsMono Nerd Font 12" foreground="#f38ba8">' .. icons.battery_critical .. '</span>'
                end
                self.value.markup = '<span font="JetBrainsMono Nerd Font 9" foreground="#f9e2af">' .. val .. '%</span>'
            end
        end
    }
end

-- Create WiFi widget with status updates
local function create_wifi()
    local icon_w = icon_widget(icons.wifi, 12, "#89b4fa")
    
    local container = wibox.widget {
        {
            icon_w,
            left = 8,
            right = 8,
            top = 4,
            bottom = 4,
            widget = wibox.container.margin
        },
        bg = "#00000000",
        shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 6) end,
        widget = wibox.container.background,
    }
    
    container:connect_signal("mouse::enter", function()
        container.bg = "#2a2c3a"
    end)
    container:connect_signal("mouse::leave", function()
        container.bg = "#00000000"
    end)
    
    -- Update WiFi status every 5 seconds
    awful.widget.watch("bash -c 'nmcli -t -f wifi g 2>/dev/null || echo disabled'", 5, function(_, out)
        if out and out:match("enabled") then
            icon_w.markup = '<span font="JetBrainsMono Nerd Font 12" foreground="#89b4fa">' .. icons.wifi .. '</span>'
        else
            icon_w.markup = '<span font="JetBrainsMono Nerd Font 12" foreground="#6c7086">' .. icons.wifi_off .. '</span>'
        end
    end)
    
    return container
end

-- Create layout icon widget
local function create_layout_icon(s, size)
    size = size or 16
    local icons_map = {
        ["tile"] = icons.layout_tile,
        ["tileleft"] = icons.layout_left,
        ["tilebottom"] = icons.layout_bottom,
        ["floating"] = icons.layout_floating,
        ["max"] = icons.layout_max,
    }

    local function get_current_icon()
        local layout = awful.layout.getname(awful.layout.get(s))
        local clean = string.gsub(layout, "awful.layout.suit.", "")
        clean = string.gsub(clean, "%.", "")
        return icons_map[clean] or icons.layout_tile
    end

    local icon_w = icon_widget(get_current_icon(), size, "#cdd6f4")

    local container = wibox.widget {
        {
            icon_w,
            left = 8,
            right = 8,
            top = 4,
            bottom = 4,
            widget = wibox.container.margin
        },
        bg = "#00000000",
        shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 6) end,
        widget = wibox.container.background,
    }

    local function update_icon()
        icon_w.markup = '<span font="JetBrainsMono Nerd Font ' .. size .. '" foreground="#cdd6f4">' .. get_current_icon() .. '</span>'
    end

    s:connect_signal("layout::change", update_icon)

    container:connect_signal("mouse::enter", function()
        container.bg = "#2a2c3a"
    end)
    container:connect_signal("mouse::leave", function()
        container.bg = "#00000000"
    end)

    container:buttons(gears.table.join(
        awful.button({}, 1, function() awful.layout.inc(1) end),
        awful.button({}, 3, function() awful.layout.inc(-1) end),
        awful.button({}, 4, function() awful.layout.inc(1) end),
        awful.button({}, 5, function() awful.layout.inc(-1) end)
    ))

    return container
end

-- Format RAM
local function format_ram(mb)
    if mb >= 1024 then
        return string.format("%.1fG", mb / 1024)
    end
    return mb .. "M"
end

-- ============================================
-- Error Handling
-- ============================================
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Startup Error",
        text = awesome.startup_errors
    })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        if in_error then return end
        in_error = true
        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Error",
            text = tostring(err)
        })
        in_error = false
    end)
end

-- ============================================
-- Screen Setup
-- ============================================
awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    local wallpaper = os.getenv("HOME") .. "/Pictures/wallpaper.jpg"
    if beautiful.wallpaper then
        wallpaper = beautiful.wallpaper
    end
    awful.spawn.with_shell("feh --bg-fill " .. wallpaper .. " 2>/dev/null || true")

    -- Tags (7 workspaces)
    awful.tag({"1", "2", "3", "4", "5", "6", "7"}, s, awful.layout.layouts[1])
    s.mypromptbox = awful.widget.prompt()

    -- Taglist
    s.mytaglist = awful.widget.taglist({
        screen = s,
        filter = awful.widget.taglist.filter.all,
        buttons = gears.table.join(
            awful.button({}, 1, function(t) t:view_only() end),
            awful.button({modkey}, 1, function(t)
                if client.focus then client.focus:move_to_tag(t) end
            end),
            awful.button({}, 3, awful.tag.viewtoggle),
            awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
            awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end)
        ),
        layout = { spacing = 4, layout = wibox.layout.fixed.horizontal },
        widget_template = {
            {
                { id = "text_role", font = "JetBrainsMono Nerd Font Bold 10", widget = wibox.widget.textbox },
                left = 10, right = 10, top = 3, bottom = 3,
                widget = wibox.container.margin,
            },
            id = "background_role",
            shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 6) end,
            widget = wibox.container.background,
        },
    })

    -- Clock
    local clock = wibox.widget.textclock(
        '<span font="JetBrainsMono Nerd Font 11" foreground="#cdd6f4">󰅐 %H:%M</span>' ..
        '<span font="JetBrainsMono Nerd Font 9" foreground="#6c7086">  %a %d %b</span>', 60)

    -- System Monitors
    local cpu = create_monitor(icons.cpu, "#fab387", "%")
    local ram = create_monitor(icons.memory, "#89b4fa", "")
    local volume = create_volume()
    local battery = create_battery()
    local wifi = create_wifi()

    -- Update CPU (better detection using mpstat)
    awful.widget.watch("bash -c 'mpstat 1 1 2>/dev/null | awk \"/Average/ {print 100 - \\$NF}\" || echo 0'", 2,
        function(_, out)
            local v = out:match("(%d+)") or "0"
            cpu:update(v)
        end)

    -- Update RAM
    awful.widget.watch("bash -c \"free -m | awk 'NR==2{printf \\\"%d\\\", $3}'\"", 3,
        function(_, out)
            local v = out:match("(%d+)") or "0"
            ram:update(format_ram(tonumber(v)))
        end)

    -- Update Volume
    awful.widget.watch("bash -c 'v=$(pamixer --get-volume 2>/dev/null||echo 0); m=$(pamixer --get-mute 2>/dev/null||echo false); echo $v $m'", 1,
        function(_, out)
            local v, m = out:match("(%d+)%s+(%S+)")
            v = tonumber(v) or 0
            volume:update(v, m)
        end)

    -- Update Battery
    awful.widget.watch("bash -c 'v=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null||echo AC); s=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null||echo AC); echo $v $s'", 30,
        function(_, out)
            local v, s = out:match("(%S+)%s+(%S+)")
            if v then battery:update(v, s) end
        end)

    -- Launcher
    local launcher = wibox.widget {
        {
            icon_widget(icons.launcher, 20, "#cba6f7"),
            left = 12, right = 12, top = 4, bottom = 4,
            widget = wibox.container.margin,
        },
        bg = "#313244",
        shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 8) end,
        widget = wibox.container.background,
    }

    launcher:connect_signal("button::press", function()
        awful.spawn("rofi -show drun")
    end)
    launcher:connect_signal("mouse::enter", function()
        launcher.bg = "#45475a"
    end)
    launcher:connect_signal("mouse::leave", function()
        launcher.bg = "#313244"
    end)

    -- Position button
    local pos_btn = wibox.widget {
        {
            icon_widget(icons.arrow, 12, "#6c7086"),
            left = 8, right = 8, top = 4, bottom = 4,
            widget = wibox.container.margin,
        },
        bg = "#00000000",
        shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 6) end,
        widget = wibox.container.background,
    }

    pos_btn:connect_signal("mouse::enter", function()
        pos_btn.bg = "#2a2c3a"
    end)
    pos_btn:connect_signal("mouse::leave", function()
        pos_btn.bg = "#00000000"
    end)

    local bar_positions = {"top", "bottom", "left", "right"}
    local current_bar_pos = 1

    pos_btn:connect_signal("button::press", function()
        current_bar_pos = (current_bar_pos % #bar_positions) + 1
        bar_pos = bar_positions[current_bar_pos]
        for scr in screen do
            if scr.mywibar then scr.mywibar:remove() end
        end
        awesome.emit_signal("request::desktop_decoration")
    end)

    -- Layout button
    local layout_icon = create_layout_icon(s, 16)

    -- System tray
    local tray = wibox.container.margin(wibox.widget.systray(), 4, 4, 4, 4)

    -- Build right widgets
    local right_widgets = wibox.layout.fixed.horizontal()
    right_widgets.spacing = 4

    right_widgets:add(cpu.widget)
    right_widgets:add(ram.widget)
    right_widgets:add(volume.widget)
    right_widgets:add(battery.widget)
    right_widgets:add(wifi)
    right_widgets:add(tray)
    right_widgets:add(pos_btn)
    right_widgets:add(layout_icon)

    -- Create wibar
    s.mywibar = awful.wibar({
        position = bar_pos,
        screen = s,
        height = 34,
        bg = beautiful.bg_normal .. "f0",
        border_width = 0,
    })

    s.mywibar:setup {
        layout = wibox.layout.align.horizontal,
        expand = "none",
        {
            layout = wibox.layout.fixed.horizontal,
            spacing = 4,
            launcher,
            icon_widget("󰁍", 12, "#45475a"),
            wibox.container.margin(s.mytaglist, 0, 0, 2, 2),
            s.mypromptbox
        },
        wibox.container.margin(clock, 0, 0, 0, 0),
        right_widgets
    }
end)

-- ============================================
-- Keybindings
-- ============================================
local globalkeys = gears.table.join(
    awful.key({modkey}, "s", hotkeys_popup.show_help, {description = "help", group = "awesome"}),
    awful.key({modkey}, "Left", awful.tag.viewprev, {description = "previous tag", group = "tag"}),
    awful.key({modkey}, "Right", awful.tag.viewnext, {description = "next tag", group = "tag"}),
    awful.key({modkey}, "Escape", awful.tag.history.restore, {description = "go back", group = "tag"}),
    awful.key({modkey}, "j", function() awful.client.focus.byidx(1) end, {description = "focus next", group = "client"}),
    awful.key({modkey}, "k", function() awful.client.focus.byidx(-1) end, {description = "focus previous", group = "client"}),
    awful.key({modkey, "Shift"}, "j", function() awful.client.swap.byidx(1) end, {description = "swap with next", group = "client"}),
    awful.key({modkey, "Shift"}, "k", function() awful.client.swap.byidx(-1) end, {description = "swap with previous", group = "client"}),
    awful.key({modkey}, "l", function() awful.tag.incmwfact(0.05) end, {description = "increase master width", group = "layout"}),
    awful.key({modkey}, "h", function() awful.tag.incmwfact(-0.05) end, {description = "decrease master width", group = "layout"}),
    awful.key({modkey}, "space", function() awful.layout.inc(1) end, {description = "next layout", group = "layout"}),
    awful.key({modkey, "Shift"}, "space", function() awful.layout.inc(-1) end, {description = "previous layout", group = "layout"}),
    awful.key({modkey}, "Return", function() awful.spawn(terminal) end, {description = "open terminal", group = "launcher"}),
    awful.key({modkey}, "d", function() awful.spawn("rofi -show drun") end, {description = "app launcher", group = "launcher"}),
    awful.key({modkey}, "r", function() awful.spawn("rofi -show run") end, {description = "run command", group = "launcher"}),
    awful.key({modkey}, "w", function() awful.spawn("rofi -show window") end, {description = "window switcher", group = "launcher"}),
    awful.key({modkey}, "b", function() awful.spawn("firefox") end, {description = "browser", group = "launcher"}),
    awful.key({modkey}, "e", function() awful.spawn("thunar") end, {description = "file manager", group = "launcher"}),
    awful.key({}, "Print", function() awful.spawn("maim ~/Pictures/ss-" .. os.time() .. ".png") end, {description = "screenshot", group = "utils"}),
    awful.key({modkey}, "Print", function() awful.spawn("maim -s ~/Pictures/ss-" .. os.time() .. ".png") end, {description = "screenshot selection", group = "utils"}),
    awful.key({}, "XF86AudioRaiseVolume", function() awful.spawn("pamixer -i 5") end, {description = "volume up", group = "media"}),
    awful.key({}, "XF86AudioLowerVolume", function() awful.spawn("pamixer -d 5") end, {description = "volume down", group = "media"}),
    awful.key({}, "XF86AudioMute", function() awful.spawn("pamixer -t") end, {description = "mute", group = "media"}),
    awful.key({}, "XF86AudioPlay", function() awful.spawn("playerctl play-pause") end, {description = "play/pause", group = "media"}),
    awful.key({}, "XF86AudioNext", function() awful.spawn("playerctl next") end, {description = "next track", group = "media"}),
    awful.key({}, "XF86AudioPrev", function() awful.spawn("playerctl previous") end, {description = "previous track", group = "media"}),
    awful.key({modkey, "Control"}, "r", awesome.restart, {description = "reload awesome", group = "awesome"}),
    awful.key({modkey, "Shift"}, "a", function()
        enable_animations = not enable_animations
        naughty.notify({
            title = "Animations " .. (enable_animations and "Enabled" or "Disabled"),
            text = "Window animations are now " .. (enable_animations and "ON" or "OFF"),
            timeout = 2
        })
    end, {description = "toggle window animations", group = "awesome"}),
    awful.key({modkey, "Shift"}, "q", awesome.quit, {description = "quit awesome", group = "awesome"})
)

-- Tag keybindings
for i = 1, 7 do
    globalkeys = gears.table.join(globalkeys,
        awful.key({modkey}, "#" .. i + 9, function()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then tag:view_only() end
        end, {description = "view tag #" .. i, group = "tag"}),
        awful.key({modkey, "Control"}, "#" .. i + 9, function()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then awful.tag.viewtoggle(tag) end
        end, {description = "toggle tag #" .. i, group = "tag"}),
        awful.key({modkey, "Shift"}, "#" .. i + 9, function()
            if client.focus then
                local tag = client.focus.screen.tags[i]
                if tag then client.focus:move_to_tag(tag) end
            end
        end, {description = "move focused client to tag #" .. i, group = "tag"})
    )
end

root.keys(globalkeys)

-- Mouse bindings
root.buttons(gears.table.join(
    awful.button({}, 3, function() awful.spawn("rofi -show drun") end),
    awful.button({}, 4, awful.tag.viewnext),
    awful.button({}, 5, awful.tag.viewprev)
))

-- ============================================
-- Client Rules
-- ============================================
local clientkeys = gears.table.join(
    awful.key({modkey}, "f", function(c)
        c.fullscreen = not c.fullscreen
        c:raise()
    end, {description = "toggle fullscreen", group = "client"}),
    awful.key({modkey, "Shift"}, "c", function(c) c:kill() end, {description = "close", group = "client"}),
    awful.key({modkey, "Control"}, "space", awful.client.floating.toggle, {description = "toggle floating", group = "client"}),
    awful.key({modkey}, "t", function(c) c.ontop = not c.ontop end, {description = "toggle keep on top", group = "client"}),
    awful.key({modkey}, "n", function(c) c.minimized = true end, {description = "minimize", group = "client"}),
    awful.key({modkey}, "m", function(c)
        c.maximized = not c.maximized
        c:raise()
    end, {description = "maximize", group = "client"})
)

local clientbuttons = gears.table.join(
    awful.button({}, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({modkey}, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({modkey}, 3, function(c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

awful.rules.rules = {
    { rule = {},
      properties = {
          border_width = beautiful.border_width,
          border_color = beautiful.border_normal,
          focus = awful.client.focus.filter,
          raise = true,
          keys = clientkeys,
          buttons = clientbuttons,
          screen = awful.screen.preferred,
          placement = awful.placement.no_overlap + awful.placement.no_offscreen
      }
    },
    { rule_any = { class = {"Pavucontrol", "Arandr"}, type = {"dialog"} },
      properties = { floating = true, placement = awful.placement.centered }
    },
    { rule_any = { type = {"normal", "dialog"} },
      properties = { titlebars_enabled = true }
    },
}

-- ============================================
-- Window Animation Configuration
-- ============================================
local enable_animations = true
local animation_duration = 0.15
local animation_scale = 0.85

-- Animation functions
local function animate_window_scale(c, final_geo)
    if not enable_animations or not rubato_available then
        c:geometry(final_geo)
        return
    end

    -- Calculate start geometry (smaller)
    local start_geo = {
        x = final_geo.x + (final_geo.width * (1 - animation_scale)) / 2,
        y = final_geo.y + (final_geo.height * (1 - animation_scale)) / 2,
        width = final_geo.width * animation_scale,
        height = final_geo.height * animation_scale
    }

    -- Set initial geometry
    c:geometry(start_geo)
    c.opacity = 0

    -- Create the timed animation object
    local anim = rubato.timed {
        duration = animation_duration,
        pos = 0, -- Start position (0%)
    }

    -- Subscribe to updates
    anim:subscribe(function(pos)
        -- Interpolate geometry based on pos (0 to 1)
        local cur_w = start_geo.width + (final_geo.width - start_geo.width) * pos
        local cur_h = start_geo.height + (final_geo.height - start_geo.height) * pos
        local cur_x = start_geo.x + (final_geo.x - start_geo.x) * pos
        local cur_y = start_geo.y + (final_geo.y - start_geo.y) * pos

        c:geometry { x = cur_x, y = cur_y, width = cur_w, height = cur_h }
        c.opacity = pos
    end)

    -- Start animation by setting target to 1 (100%)
    anim.target = 1
end

-- Client signals with animation
client.connect_signal("manage", function(c)
    -- Get final geometry first
    local final_geo = {
        x = c:geometry().x,
        y = c:geometry().y,
        width = c:geometry().width,
        height = c:geometry().height
    }

    -- Apply animation
    animate_window_scale(c, final_geo)

    if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
        awful.placement.no_offscreen(c)
    end
    c.shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 8) end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- ============================================
-- Titlebars (NO buttons - clean design)
-- ============================================
client.connect_signal("request::titlebars", function(c)
    local buttons = gears.table.join(
        awful.button({}, 1, function()
            c:emit_signal("request::activate", "mouse_click", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({}, 3, function()
            c:emit_signal("request::activate", "mouse_click", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    local titlebar = awful.titlebar(c, {
        size = beautiful.titlebar_size or 28,
        bg = beautiful.titlebar_bg_normal or "#1e1e2e",
        position = "top"
    })

    local title_widget = awful.titlebar.widget.titlewidget(c)
    title_widget:set_align("center")
    title_widget.buttons = buttons

    titlebar:setup {
    { widget = wibox.widget.base.empty_widget() },
    {
        title_widget,
        buttons = buttons,
        layout  = wibox.layout.flex.horizontal,
    },
    { widget = wibox.widget.base.empty_widget() },
    layout = wibox.layout.align.horizontal,
}
end)

-- ============================================
-- Startup Applications
-- ============================================
awful.spawn.with_shell("pkill -9 picom 2>/dev/null; pkill -9 dunst 2>/dev/null; true")
awful.spawn.with_shell("dunst &")
awful.spawn.with_shell("picom -b &")
local wallpaper = os.getenv("HOME") .. "/Pictures/wallpaper.jpg"
awful.spawn.with_shell("feh --bg-fill " .. wallpaper .. " 2>/dev/null || true")
