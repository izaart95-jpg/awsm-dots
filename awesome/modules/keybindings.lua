-- modules/keybindings.lua
-- ─────────────────────────────────────────────────────────────────────────────
-- All global and client keybindings.
-- New bindings vs original:
--   Mod4+Shift+t  — toggle theme (catppuccin ↔ tokyonight)
--   Mod4+Shift+a  — toggle window animations
--   Mod4+Shift+b  — toggle island / full bar
--   Mod4+Shift+f  — toggle FX widget animations
-- ─────────────────────────────────────────────────────────────────────────────

local awful         = require("awful")
local gears         = require("gears")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

local M = {}

function M.init(cfg)
    local terminal    = cfg.terminal      or "kitty"
    local modkey      = cfg.modkey        or "Mod4"
    local anim        = cfg.animations    -- modules/animations
    local bar         = cfg.bar           -- modules/bar
    local theme_mgr   = cfg.theme_manager -- modules/theme_manager
    local fx          = cfg.fx            -- modules/fx
    local notify      = cfg.notify        -- modules/notify

    -- ─── Helper: themed naughty fallback (if notify module unavailable) ───────
    local function toast(text)
        if notify then
            notify.show { text = text, timeout = 1.5 }
            return
        end
        local naughty   = require("naughty")
        local beautiful = require("beautiful")
        naughty.notify {
            text         = text,
            timeout      = 1.5,
            bg           = beautiful.bg_normal   or "#1e1e2e",
            border_color = beautiful.border_focus or "#cba6f7",
            border_width = 1,
            position     = "top_middle",
            shape        = function(cr, w, h)
                require("gears").shape.rounded_rect(cr, w, h, 8)
            end,
        }
    end

    -- ─── Global keys ──────────────────────────────────────────────────────────
    local globalkeys = gears.table.join(

        -- Awesome
        awful.key({ modkey },           "s",     hotkeys_popup.show_help,
            { description = "help", group = "awesome" }),
        awful.key({ modkey, "Control" }, "r",    awesome.restart,
            { description = "reload awesome", group = "awesome" }),
        awful.key({ modkey, "Shift" },   "q",    awesome.quit,
            { description = "quit awesome", group = "awesome" }),

        -- ── Theme toggle ──────────────────────────────────────────────────────
        awful.key({ modkey, "Shift" }, "t", function()
            if theme_mgr then
                theme_mgr.toggle()
                if notify then
                    notify.theme_switched(theme_mgr.current)
                end
            end
        end, { description = "toggle theme", group = "awesome" }),

        -- ── Animation toggle ──────────────────────────────────────────────────
        awful.key({ modkey, "Shift" }, "a", function()
            if anim then
                local on = anim.toggle()
                if notify then notify.anim_toggle(on)
                else toast(on and "󰜛  Animations ON" or "󰜚  Animations OFF") end
            end
        end, { description = "toggle animations", group = "awesome" }),

        -- ── FX (widget animations) toggle ─────────────────────────────────────
        awful.key({ modkey, "Shift" }, "f", function()
            if fx then
                local on = fx.toggle()
                local FONT = "JetBrainsMono Nerd Font"
                local beautiful = require("beautiful")
                local fg = beautiful.fg_normal or "#cdd6f4"
                toast(string.format('<span font="%s 10" foreground="%s">%s  Widget FX %s</span>',
                    FONT, fg,
                    on and "󰻟" or "󰻠",
                    on and "ON" or "OFF"))
            end
        end, { description = "toggle widget FX", group = "awesome" }),

        -- ── Bar toggle ────────────────────────────────────────────────────────
        awful.key({ modkey, "Shift" }, "b", function()
            if bar then bar.toggle_floating() end
        end, { description = "toggle island/full bar", group = "awesome" }),

        -- ── Tags ──────────────────────────────────────────────────────────────
        awful.key({ modkey },           "Left",   awful.tag.viewprev,
            { description = "previous tag", group = "tag" }),
        awful.key({ modkey },           "Right",  awful.tag.viewnext,
            { description = "next tag", group = "tag" }),
        awful.key({ modkey },           "Escape", awful.tag.history.restore,
            { description = "go back", group = "tag" }),

        -- ── Focus ─────────────────────────────────────────────────────────────
        awful.key({ modkey }, "j", function() awful.client.focus.byidx( 1) end,
            { description = "focus next", group = "client" }),
        awful.key({ modkey }, "k", function() awful.client.focus.byidx(-1) end,
            { description = "focus previous", group = "client" }),

        -- ── Swap ──────────────────────────────────────────────────────────────
        awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx( 1) end,
            { description = "swap next", group = "client" }),
        awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end,
            { description = "swap previous", group = "client" }),

        -- ── Layout resize ─────────────────────────────────────────────────────
        awful.key({ modkey }, "l", function() awful.tag.incmwfact( 0.05) end,
            { description = "increase master width", group = "layout" }),
        awful.key({ modkey }, "h", function() awful.tag.incmwfact(-0.05) end,
            { description = "decrease master width", group = "layout" }),
        awful.key({ modkey }, "space", function() awful.layout.inc( 1) end,
            { description = "next layout", group = "layout" }),
        awful.key({ modkey, "Shift" }, "space", function() awful.layout.inc(-1) end,
            { description = "previous layout", group = "layout" }),

        -- ── Launchers ─────────────────────────────────────────────────────────
        awful.key({ modkey }, "Return", function() awful.spawn(terminal) end,
            { description = "terminal", group = "launcher" }),
        awful.key({ modkey }, "d", function() awful.spawn("rofi -show drun") end,
            { description = "app launcher", group = "launcher" }),
        awful.key({ modkey }, "r", function() awful.spawn("rofi -show run") end,
            { description = "run command", group = "launcher" }),
        awful.key({ modkey }, "w", function() awful.spawn("rofi -show window") end,
            { description = "window switcher", group = "launcher" }),
        awful.key({ modkey }, "b", function() awful.spawn("firefox") end,
            { description = "browser", group = "launcher" }),
        awful.key({ modkey }, "e", function() awful.spawn("thunar") end,
            { description = "file manager", group = "launcher" }),

        -- ── Screenshots ───────────────────────────────────────────────────────
        awful.key({}, "Print", function()
            awful.spawn("maim ~/Pictures/ss-" .. os.time() .. ".png")
        end, { description = "screenshot", group = "utils" }),
        awful.key({ modkey }, "Print", function()
            awful.spawn("maim -s ~/Pictures/ss-" .. os.time() .. ".png")
        end, { description = "screenshot selection", group = "utils" }),

        -- ── Media ─────────────────────────────────────────────────────────────
        awful.key({}, "XF86AudioRaiseVolume", function() awful.spawn("pamixer -i 5")         end,
            { description = "volume up",    group = "media" }),
        awful.key({}, "XF86AudioLowerVolume", function() awful.spawn("pamixer -d 5")         end,
            { description = "volume down",  group = "media" }),
        awful.key({}, "XF86AudioMute",        function() awful.spawn("pamixer -t")           end,
            { description = "mute",         group = "media" }),
        awful.key({}, "XF86AudioPlay",        function() awful.spawn("playerctl play-pause") end,
            { description = "play/pause",   group = "media" }),
        awful.key({}, "XF86AudioNext",        function() awful.spawn("playerctl next")       end,
            { description = "next track",   group = "media" }),
        awful.key({}, "XF86AudioPrev",        function() awful.spawn("playerctl previous")   end,
            { description = "previous track", group = "media" })
    )

    -- ── Tag switch / move (1–5) ────────────────────────────────────────────────
    for i = 1, 5 do
        globalkeys = gears.table.join(globalkeys,
            awful.key({ modkey }, "#" .. (i + 9), function()
                local s = awful.screen.focused()
                local t = s.tags[i]
                if t then t:view_only() end
            end, { description = "view tag #" .. i, group = "tag" }),
            awful.key({ modkey, "Control" }, "#" .. (i + 9), function()
                local s = awful.screen.focused()
                local t = s.tags[i]
                if t then awful.tag.viewtoggle(t) end
            end, { description = "toggle tag #" .. i, group = "tag" }),
            awful.key({ modkey, "Shift" }, "#" .. (i + 9), function()
                if client.focus then
                    local t = client.focus.screen.tags[i]
                    if t then client.focus:move_to_tag(t) end
                end
            end, { description = "move client to tag #" .. i, group = "tag" })
        )
    end

    root.keys(globalkeys)

    root.buttons(gears.table.join(
        awful.button({}, 3, function() awful.spawn("rofi -show drun") end),
        awful.button({}, 4, awful.tag.viewnext),
        awful.button({}, 5, awful.tag.viewprev)
    ))

    -- ─── Client keys & buttons ────────────────────────────────────────────────
    local clientkeys = gears.table.join(
        awful.key({ modkey },           "f", function(c)
            c.fullscreen = not c.fullscreen; c:raise()
        end, { description = "fullscreen", group = "client" }),
        awful.key({ modkey, "Shift" },  "c", function(c) c:kill() end,
            { description = "close", group = "client" }),
        awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle,
            { description = "toggle floating", group = "client" }),
        awful.key({ modkey }, "t", function(c) c.ontop = not c.ontop end,
            { description = "toggle on top", group = "client" }),
        awful.key({ modkey }, "n", function(c) c.minimized = true end,
            { description = "minimize", group = "client" }),
        awful.key({ modkey }, "m", function(c)
            c.maximized = not c.maximized; c:raise()
        end, { description = "maximize", group = "client" })
    )

    local clientbuttons = gears.table.join(
        awful.button({}, 1, function(c)
            c:emit_signal("request::activate", "mouse_click", { raise = true })
        end),
        awful.button({ modkey }, 1, function(c)
            c:emit_signal("request::activate", "mouse_click", { raise = true })
            awful.mouse.client.move(c)
        end),
        awful.button({ modkey }, 3, function(c)
            c:emit_signal("request::activate", "mouse_click", { raise = true })
            awful.mouse.client.resize(c)
        end)
    )

    return clientkeys, clientbuttons
end

return M
