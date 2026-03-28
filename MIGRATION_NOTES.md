# AwesomeWM → Niri Migration Guide

## Overview
This document outlines the migration from AwesomeWM (X11-based) to Niri (Wayland-native) with full X11 fallback support via Xwayland and classic AwesomeWM session.

## Migration Status
- **Primary**: Niri WM (Wayland) with Quickshell bar
- **Fallback**: AwesomeWM X11-only session (kept for compatibility)
- **Xwayland**: Enabled for X11 apps within Niri

---

## What Changed

### Removed from Active Use (but kept as X11 fallback)
The `awesome/` directory is still present on disk for X11 fallback sessions. These components have been replaced:

| Component | Old (AwesomeWM) | New (Niri/Quickshell) |
|-----------|-----------------|----------------------|
| **WM Config** | `awesome/rc.lua` | `niri/config.kdl` |
| **Keybindings** | `awesome/modules/keybindings.lua` | `niri/config.kdl` binds section |
| **Window Rules** | `awesome/modules/rules.lua` | `niri/config.kdl` window-rule section |
| **Bar** | `awesome/modules/bar.lua` | `quickshell/qml/main.qml` |
| **Widgets** | `awesome/modules/widgets.lua` + `fx.lua` | `quickshell/qml/widgets/` + `effects/` |
| **Animations** | `awesome/modules/animations.lua` | `niri/animations/*.glsl` (shaders) |
| **Theme Manager** | `awesome/modules/theme_manager.lua` | `pywal/` + `scripts/apply-theme.sh` |
| **Compositor** | `picom` (X11 only) | Niri (native, no picom needed) |

### New Architecture

```
Primary Session (Niri/Wayland):
  ├── niri/config.kdl          (main config)
  ├── niri/animations/          (shader animations)
  ├── quickshell/qml/           (bar + widgets)
  └── pywal/                    (dynamic theming)

Fallback Session (AwesomeWM/X11):
  └── awesome/                  (original config, unchanged)
     ├── rc.lua
     ├── modules/
     ├── themes/
     └── (all original files)
```

---

## File Organization

### New Directories

```
niri/                           Niri window manager config
├── config.kdl                 Main configuration (keybindings, rules, display)
└── animations/                GLSL shader animations
    ├── smoke-open.glsl        Fluid reveal effect
    ├── smoke-close.glsl       Fluid dissolve effect
    ├── glitch-open.glsl       Chromatic aberration reveal
    └── glitch-close.glsl      Glitch dissolution effect

x11-session/                    X11 fallback session support
├── xinitrc                     AwesomeWM session starter
└── Xwayland-wrapper.sh         Mixed Wayland+X11 launcher

pywal/                          Dynamic theme system
├── setup.sh                    Initialization script
├── fonts.kdl                   Font configuration
├── spacing.kdl                 Spacing tokens
├── templates/                  Theme templates for all components
│   ├── colors.kdl.template
│   ├── quickshell-colors.qml.template
│   ├── rofi-colors.rasi.template
│   ├── dunst-colors.template
│   ├── kitty-colors.conf.template
│   ├── starship-colors.toml.template
│   └── font-config.template
└── generated/                  Auto-generated theme files (see apply-theme.sh)

quickshell/qml/                 Bar + widget system
├── main.qml                    Main bar component
├── theme.qml                   Centralized theme properties
├── colors.qml                  Pywal-generated colors (auto-created)
├── widgets/                    Widget components
│   ├── Clock.qml
│   ├── AppLauncher.qml
│   ├── WorkspaceIndicator.qml
│   ├── SystemStats.qml
│   ├── Volume.qml
│   ├── Battery.qml
│   ├── WiFi.qml
│   ├── LayoutIcon.qml
│   └── NotificationCenter.qml
└── effects/                    Animation effects
    ├── Hover.qml
    ├── Press.qml
    └── Pulse.qml

scripts/                        Utility scripts
├── apply-theme.sh             Apply Pywal theme to all components
└── niri-session-setup.sh      Initialize Niri on first boot
```

### Modified Existing Files

- `rofi/config.rasi` — Added Pywal color import
- `dunst/dunstrc` — Added Pywal color include
- `kitty/kitty.conf` — Added Pywal color include
- `starship.toml` — Added Pywal color reference

### Preserved Files

- `awesome/` — Kept for X11 fallback (unchanged)
- `picom/picom.conf` — Used only in X11 session
- `rofi/`, `dunst/`, `kitty/` — Configs updated for Pywal but kept functional

---

## Quick Start: Niri Primary Session

### 1. Initialize Pywal Theme
```bash
./pywal/setup.sh ~/Pictures/wallpaper.jpg
```

This generates colorscheme from your wallpaper and creates theme files for all components.

### 2. Apply Theme to All Components
```bash
./scripts/apply-theme.sh
```

This copies generated themes to Rofi, Dunst, Kitty, Quickshell, etc.

### 3. Boot Niri

Niri is your default WM on Wayland. Just boot normally and Niri will start automatically.

**Niri Keybindings** (from `niri/config.kdl`):
- `Super+Return` — Terminal
- `Super+d` — App launcher (Rofi)
- `Super+Left/Right` — Switch workspaces
- `Super+j/k` — Focus next/previous column
- `Super+l/h` — Resize columns
- `Super+f` — Fullscreen
- `Super+Shift+c` — Close window
- `Super+space` — Next layout
- [More in niri/config.kdl]

---

## Fallback: X11 Session with AwesomeWM

If you need to use the classic X11 session (debugging, legacy apps, etc.):

### Option 1: Boot into X11 from Display Manager
Some display managers (SDDM, GDM) show a session selector at login. Choose "AwesomeWM" or "X11" session.

### Option 2: Manual X11 Session Start
```bash
startx ~/.config/x11-session/xinitrc
```

This launches the classic AwesomeWM setup with:
- Picom compositor
- Dunst notification daemon
- AwesomeWM window manager (unchanged, as in `awesome/rc.lua`)

**AwesomeWM Keybindings** (unchanged from original):
- `Mod4+Return` — Terminal
- `Mod4+d` — Rofi launcher
- `Mod4+Left/Right` — Previous/next tag
- [Original awesome keybindings in awesome/modules/keybindings.lua]

---

## Dynamic Theming (Pywal)

### Changing Wallpaper & Colors
```bash
wal -i ~/Pictures/new-wallpaper.jpg
./scripts/apply-theme.sh
```

This:
1. Generates new colorscheme from wallpaper
2. Updates all component theme files (Niri, Quickshell, Rofi, Dunst, Kitty, etc.)
3. Reloads services (Dunst, Quickshell)
4. Niri requires manual restart to apply new colors

### Theme Files

**Color Sources:**
- Pywal generates: `~/.config/pywal/colorscheme.sh` (standard colors 0-15 + foreground/background)
- Templates: `pywal/templates/` (how to apply colors to each component)
- Generated: `pywal/generated/` (component-specific config files)

**Font/Spacing Tokens:**
- `pywal/fonts.kdl` — Font families and sizes
- `pywal/spacing.kdl` — Spacing, borders, animations

---

## Animation Systems

### Niri Window Animations (Shaders)
Located: `niri/animations/`
- `smoke-open.glsl` — Fluid reveal on window open (300-400ms)
- `smoke-close.glsl` — Fluid dissolve on window close
- `glitch-open.glsl` — Chromatic aberration + scanlines reveal
- `glitch-close.glsl` — Aggressive glitch dissolution

These are GLSL shaders integrated into Niri's native animation system. Customize in `niri/config.kdl` animations section.

### Quickshell Widget Effects
Located: `quickshell/qml/effects/`
- `Hover.qml` — Opacity fade on hover
- `Press.qml` — Scale transform on click
- `Pulse.qml` — Breathing opacity animation

---

## Configuration Details

### Niri Config Structure (`niri/config.kdl`)
```kdl
input {}           // Keyboard, mouse, trackpad settings
output {}          // Display settings (resolution, scale, position)
layout {}          // Tiling layout, border colors, gaps
window-rule {}     // Rules for specific windows (floating, centered, etc.)
binds {}           // Keybindings (all keybindings go here)
spawn-at-startup {} // Commands to run on startup (Quickshell, Dunst, wallpaper)
```

### Quickshell Bar Structure (`quickshell/qml/`)
```
main.qml          Main bar component (PanelWindow, RowLayout with widgets)
theme.qml         Central theme object (colors, fonts, spacing)
colors.qml        Pywal-generated colors (created by apply-theme.sh)
widgets/          Widget components (Clock, Volume, Battery, etc.)
effects/          Animation effects (Hover, Press, Pulse)
```

**To Add a New Widget:**
1. Create `quickshell/qml/widgets/MyWidget.qml`
2. Import in `main.qml`: `import "widgets" as Widgets`
3. Use in bar layout: `Widgets.MyWidget { theme: root.theme }`

---

## Workspace Management

### Niri Workspaces
- Niri uses dynamic workspaces (create on demand)
- Switch via `Super+Left/Right` or `Super+1` through `Super+5`
- WorkspaceIndicator widget shows current workspace
- Layout cycles through: tile, floating, fullscreen

### AwesomeWM Tags (X11 session)
- Uses traditional tag system (5 pre-defined tags)
- Switch via `Mod4+Left/Right` or `Mod4+1` through `Mod4+5`
- Each tag can have different layout

---

## Troubleshooting

### Niri won't start
- Check logs: `journalctl -xe` (systemd) or `~/.local/share/niri/logs/`
- Verify Wayland support: `echo $WAYLAND_DISPLAY`
- Ensure GPU drivers support Wayland (NVIDIA may need extra config)

### Colors not updating
- Re-run: `./scripts/apply-theme.sh`
- Restart affected services (Dunst, Quickshell)
- For Niri: Restart WM (`Super+Alt+r` or restart shell)

### X11 apps look bad in Niri
- Most apps will use Xwayland transparently
- For better integration, use Wayland-native apps when possible
- Configure Xwayland in `niri/config.kdl` if needed

### Switching back to AwesomeWM
- X11 session is still available: `startx ~/.config/x11-session/xinitrc`
- Or select "AwesomeWM" from login manager (if configured)
- All AwesomeWM configs are unchanged in `awesome/` directory

---

## Reverting to AwesomeWM Only

If you want to completely remove Niri and go back to AwesomeWM:

1. **Option A: Keep Niri, Switch Default WM**
   - Boot into X11 session from login manager
   - OR update login shell script to default to X11 session

2. **Option B: Remove Niri Installation**
   - Uninstall Niri: `pacman -R niri` (or your package manager)
   - Keep this project for AwesomeWM configs
   - Remove: `niri/`, `quickshell/`, `pywal/`, `scripts/apply-theme.sh`
   - Restore old theme manager if needed

---

## Maintenance Notes

### Regular Backups
- Backup your wallpaper collection (used for Pywal)
- Backup `awesome/` if you modify it (X11 session)
- Git commit your Niri config changes

### Updating Components
- Niri updates: Check config.kdl for breaking changes
- Quickshell updates: May require QML syntax adjustments
- Pywal updates: Should be backward compatible

### Performance Tips
- Disable unused widgets in `quickshell/qml/main.qml`
- Reduce animation duration in `pywal/spacing.kdl` if CPU-limited
- Use `opacity-ghost` theme property for hidden elements

---

## Resources

- **Niri Docs**: https://github.com/sodiboo/niri
- **Quickshell**: https://github.com/quickshell/quickshell
- **Pywal**: https://github.com/dylanaraps/pywal
- **Rofi**: https://github.com/davatorium/rofi
- **Dunst**: https://dunst-project.org
- **Kitty**: https://sw.kovidgoyal.net/kitty/

---

## Migration Checklist

- [ ] Run `pywal/setup.sh` to initialize theme
- [ ] Run `scripts/apply-theme.sh` to apply theme
- [ ] Boot into Niri WM
- [ ] Test keybindings (Niri config.kdl)
- [ ] Verify bar widgets (Quickshell)
- [ ] Check notifications (Dunst)
- [ ] Test app launcher (Rofi)
- [ ] Verify terminal colors (Kitty)
- [ ] Test wallpaper change with Pywal
- [ ] Test X11 fallback session: `startx ~/.config/x11-session/xinitrc`
- [ ] Commit changes to git

---

**Migration completed!** Your system is now running Niri with full Wayland support, dynamic Pywal theming, and AwesomeWM X11 fallback.
