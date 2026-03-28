-- modules/rules.lua
-- ─────────────────────────────────────────────────────────────────────────────
-- Client placement and property rules.
-- ─────────────────────────────────────────────────────────────────────────────

local awful    = require("awful")
local beautiful = require("beautiful")

local M = {}

function M.init(clientkeys, clientbuttons)
    awful.rules.rules = {
        -- ── All clients ───────────────────────────────────────────────────────
        {
            rule = {},
            properties = {
                border_width = beautiful.border_width,
                border_color = beautiful.border_normal,
                focus        = awful.client.focus.filter,
                raise        = true,
                keys         = clientkeys,
                buttons      = clientbuttons,
                screen       = awful.screen.preferred,
                placement    = awful.placement.no_overlap
                             + awful.placement.no_offscreen,
            },
        },
        -- ── Floating dialogs ──────────────────────────────────────────────────
        {
            rule_any = {
                class = { "Pavucontrol", "Arandr", "lxappearance" },
                type  = { "dialog" },
            },
            properties = {
                floating   = true,
                placement  = awful.placement.centered,
            },
        },
        -- ── Titlebars for normal windows and dialogs ──────────────────────────
        {
            rule_any = { type = { "normal", "dialog" } },
            properties = { titlebars_enabled = true },
        },
        -- ── Terminal: no titlebar ─────────────────────────────────────────────
        -- Uncomment if you prefer kitty/alacritty without a titlebar:
        -- {
        --     rule_any = { class = { "kitty", "Alacritty" } },
        --     properties = { titlebars_enabled = false },
        -- },
    }
end

return M
