-- modules/notify.lua
-- ─────────────────────────────────────────────────────────────────────────────
-- Centralized notification factory — theme-aware, supports pywal.
-- ─────────────────────────────────────────────────────────────────────────────

local naughty   = require("naughty")
local beautiful = require("beautiful")
local gears     = require("gears")

local M = {}
M._last = nil

-- ─── Raw naughty wrapper ──────────────────────────────────────────────────────
function M.show(opts)
    if M._last and M._last.box then
        naughty.destroy(M._last, naughty.notificationClosedReason.dismissedByCommand)
    end

    local bg     = opts.bg     or beautiful.notification_bg           or beautiful.bg_normal     or "#1e1e2e"
    local fg     = opts.fg     or beautiful.notification_fg           or beautiful.fg_normal     or "#cdd6f4"
    local border = opts.border or beautiful.notification_border_color or beautiful.border_focus  or "#cba6f7"
    local bwidth = opts.bwidth or beautiful.notification_border_width or 1
    local radius = opts.radius or beautiful.notification_shape_radius or 10
    local margin = opts.margin or beautiful.notification_margin       or 14

    M._last = naughty.notify {
        text         = opts.text or "",
        title        = opts.title,
        timeout      = opts.timeout or 1.8,
        bg           = bg,
        fg           = fg,
        border_color = border,
        border_width = bwidth,
        position     = opts.position or "top_middle",
        margin       = margin,
        shape        = function(cr, w, h)
            gears.shape.rounded_rect(cr, w, h, radius)
        end,
        icon          = opts.icon,
        icon_size     = opts.icon_size or beautiful.notification_icon_size or 32,
    }
    return M._last
end

-- ─── Layout toast ─────────────────────────────────────────────────────────────
function M.layout(icon, name)
    local FONT   = "JetBrainsMono Nerd Font"
    local accent = beautiful.border_focus or "#cba6f7"
    local fg     = beautiful.fg_normal    or "#cdd6f4"
    M.show {
        text = string.format(
            '<span font="%s 20" foreground="%s">%s</span>\n'..
            '<span font="%s 9"  foreground="%s">%s</span>',
            FONT, accent, icon, FONT, fg, name),
        timeout = 1.5,
    }
end

-- ─── Bar mode toast ───────────────────────────────────────────────────────────
function M.bar_mode(is_floating)
    local FONT  = "JetBrainsMono Nerd Font"
    local fg    = beautiful.fg_normal or "#cdd6f4"
    local icon  = is_floating and "󰖵" or "󰹃"
    local label = is_floating and "Island bar" or "Full bar"
    M.show {
        text = string.format('<span font="%s 10" foreground="%s">%s  %s</span>',
            FONT, fg, icon, label),
        timeout = 1.2,
    }
end

-- ─── Animation toggle toast ───────────────────────────────────────────────────
function M.anim_toggle(enabled)
    local FONT  = "JetBrainsMono Nerd Font"
    local fg    = beautiful.fg_normal or "#cdd6f4"
    local icon  = enabled and "󰜛" or "󰜚"
    local label = enabled and "Smoke ON" or "Animations OFF"
    M.show {
        text = string.format('<span font="%s 10" foreground="%s">%s  %s</span>',
            FONT, fg, icon, label),
        timeout = 1.5,
    }
end

-- ─── Theme switch toast ───────────────────────────────────────────────────────
function M.theme_switched(name)
    local FONT   = "JetBrainsMono Nerd Font"
    local accent = beautiful.border_focus or "#7aa2f7"
    local fg     = beautiful.fg_normal    or "#cdd6f4"
    local icons  = { catppuccin = "󰄛", tokyonight = "󰊠", pywal = "󰉔" }
    local icon   = icons[name] or "󰸌"
    M.show {
        text = string.format(
            '<span font="%s 18" foreground="%s">%s</span>\n'..
            '<span font="%s 9"  foreground="%s">%s</span>',
            FONT, accent, icon, FONT, fg, name),
        timeout = 1.8,
        border  = accent,
    }
end

return M
