# Niri WM Migration - Testing Checklist

This checklist verifies all components of the Niri migration are working correctly.

---

## Pre-Setup Tests

### Environment Check
- [ ] Check Wayland session available: `echo $WAYLAND_DISPLAY` (non-empty on Wayland)
- [ ] Check GPU drivers installed: `glxinfo | grep "OpenGL renderer"`
- [ ] Verify systemd-logind running: `systemctl status systemd-logind`
- [ ] Check for conflicting window managers (none running)

### Prerequisites
- [ ] `niri` installed: `which niri`
- [ ] `rofi` installed: `which rofi`
- [ ] `dunst` installed: `which dunst`
- [ ] `kitty` installed: `which kitty`
- [ ] `wal` (pywal) installed: `which wal`
- [ ] `quickshell` installed: `which quickshell`

---

## Setup Phase Tests

### 1. Pywal Initialization
```bash
./pywal/setup.sh ~/Pictures/wallpaper.jpg
```

- [ ] No errors during setup
- [ ] Pywal generates colorscheme: `$HOME/.config/pywal/colorscheme.sh` exists
- [ ] Generated color files exist: `pywal/generated/` contains:
  - [ ] `colors.kdl`
  - [ ] `quickshell-colors.qml`
  - [ ] `rofi-colors.rasi`
  - [ ] `dunst-colors.conf`
  - [ ] `kitty-colors.conf`
  - [ ] `starship-colors.toml`
  - [ ] `font-config.kdl`

### 2. Theme Application
```bash
./scripts/apply-theme.sh
```

- [ ] No errors during theme application
- [ ] Files copied to component directories:
  - [ ] `quickshell/qml/colors.qml` exists
  - [ ] `rofi/shared/colors.rasi` exists
  - [ ] `dunst/pywal-colors.conf` exists
  - [ ] `kitty/pywal-colors.conf` exists
  - [ ] `starship-colors.toml` exists
- [ ] Dunst reloaded successfully
- [ ] No color parsing errors in generated files

### 3. Session Setup
```bash
./scripts/niri-session-setup.sh
```

- [ ] Setup completes without errors
- [ ] Niri config copied to: `$HOME/.config/niri/config.kdl`
- [ ] Quickshell files available in: `$HOME/.config/quickshell/`
- [ ] X11 session helper scripts executable

---

## Niri Session Boot Tests

### Boot into Niri
- [ ] Boot successfully (from login manager or manual `niri`)
- [ ] Niri starts without crashing
- [ ] No errors in logs: `journalctl -xe` or `~/.local/share/niri/log`

### Display & Graphics
- [ ] Wallpaper displays correctly
- [ ] Screen resolution is correct
- [ ] Scaling is appropriate (no blurry text)
- [ ] Mouse cursor visible and responsive
- [ ] Display doesn't flicker or tear

### Window Management
- [ ] Can open windows (terminal, browser, app launcher)
- [ ] Windows appear on screen
- [ ] Windows are tiled by default (tile layout)
- [ ] Window borders show active/inactive color
- [ ] Can focus windows with mouse click
- [ ] Can focus windows with keyboard (Super+j/k)

---

## Keybinding Tests

### Launch Commands
- [ ] `Super+Return` → Terminal (Kitty) opens
- [ ] `Super+d` → App launcher (Rofi) opens
- [ ] `Super+r` → Run command dialog opens
- [ ] `Super+w` → Window switcher opens
- [ ] `Super+b` → Browser (Firefox) opens
- [ ] `Super+e` → File manager (Thunar) opens

### Window Management
- [ ] `Super+f` → Fullscreen toggle works
- [ ] `Super+Shift+c` → Close window works
- [ ] `Super+Ctrl+Space` → Toggle floating/tiled works
- [ ] `Super+t` → Toggle "on top" works
- [ ] `Super+m` → Maximize column works
- [ ] `Super+n` → Minimize column works

### Layout & Navigation
- [ ] `Super+j/k` → Focus next/previous column works
- [ ] `Super+i/u` → Focus next/previous row works
- [ ] `Super+Shift+j/k` → Move window left/right works
- [ ] `Super+Shift+i/u` → Move window up/down works
- [ ] `Super+l/h` → Resize column width works
- [ ] `Super+space` → Next layout (tile → floating → fullscreen) works
- [ ] `Super+Shift+space` → Previous layout works

### Workspace Navigation
- [ ] `Super+Left` → Previous workspace works
- [ ] `Super+Right` → Next workspace works
- [ ] `Super+1` through `Super+5` → Jump to workspace 1-5 works
- [ ] Workspace indicator shows current workspace
- [ ] Creating windows in new workspace works

### Utilities
- [ ] `Print` → Screenshot taken to `~/Pictures/ss-*.png`
- [ ] `Super+Print` → Selection screenshot works
- [ ] `Super+Escape` → Keybinding overlay displays

### Media Keys
- [ ] `XF86AudioRaiseVolume` → Volume increases
- [ ] `XF86AudioLowerVolume` → Volume decreases
- [ ] `XF86AudioMute` → Mute toggle works
- [ ] `XF86AudioPlay` → Play/pause media
- [ ] `XF86AudioNext` → Next track
- [ ] `XF86AudioPrev` → Previous track

---

## Quickshell Bar Tests

### Bar Display
- [ ] Bar appears at top of screen
- [ ] Bar height is consistent with theme (32px)
- [ ] Island mode: bar is rounded rectangle centered at top
- [ ] Bar background color matches theme
- [ ] Border/outline visible

### Widgets - Clock
- [ ] Clock widget displays current time
- [ ] Time updates every second
- [ ] Time format is HH:MM (24-hour)

### Widgets - App Launcher
- [ ] App launcher icon visible in bar
- [ ] Click launches Rofi app launcher
- [ ] Hover effect visible (color change)

### Widgets - Workspace Indicator
- [ ] Shows 5 workspace dots (1-5)
- [ ] Current workspace highlighted in primary color
- [ ] Click on dot switches workspace
- [ ] Indicator updates when workspace changes

### Widgets - System Stats
- [ ] RAM usage displayed (percentage)
- [ ] CPU usage displayed (if enabled)
- [ ] Icons visible (RAM icon, CPU icon)
- [ ] Values update every 2 seconds
- [ ] Ranges 0-100%

### Widgets - Volume
- [ ] Volume icon visible
- [ ] Volume percentage displayed
- [ ] Click to mute/unmute
- [ ] Icon changes based on volume level
- [ ] Scroll wheel adjusts volume

### Widgets - Battery
- [ ] Battery percentage displayed
- [ ] Battery icon shown
- [ ] Icon changes at different charge levels
- [ ] Charging state indicated
- [ ] Border color indicates charge level (green > yellow > red)

### Widgets - WiFi
- [ ] WiFi icon visible
- [ ] Connected state shows signal strength icon
- [ ] Disconnected state shows off icon
- [ ] Color indicates connection status (green when connected)

### Widgets - Layout Indicator
- [ ] Layout icon visible
- [ ] Icon matches current layout (tile/floating/fullscreen)
- [ ] Click cycles to next layout
- [ ] Updates when layout changes via keyboard

---

## Animation Tests

### Window Open Animations
- [ ] Opening new window: plays animation (should see one of below)
  - [ ] Smoke effect: fluid reveal from mist
  - [ ] Glitch effect: chromatic aberration + scanlines
- [ ] Animation duration ~300-400ms
- [ ] Window appears fully opaque after animation

### Window Close Animations
- [ ] Closing window: plays animation
  - [ ] Smoke effect: fluid dissolve into mist
  - [ ] Glitch effect: aggressive distortion → fade to black
- [ ] Animation duration ~300-400ms
- [ ] Window disappears cleanly

### Widget Animations (Quickshell)
- [ ] Hover over buttons: opacity change smooth (150ms)
- [ ] Click buttons: slight scale transform (100ms)
- [ ] No animations are janky or stuttering

---

## Theme & Colors Tests

### Pywal Integration
- [ ] Colors match wallpaper (dominant colors extracted)
- [ ] Text is readable on background (good contrast)
- [ ] All UI elements have appropriate colors

### Component Color Application
- [ ] **Rofi**: Uses correct colors from `rofi/shared/colors.rasi`
  - [ ] Launcher background is dark
  - [ ] Text is light/readable
  - [ ] Selection highlight is primary color

- [ ] **Dunst**: Uses colors from `dunst/pywal-colors.conf`
  - [ ] Normal notifications have correct colors
  - [ ] Critical notifications are red
  - [ ] Text visible and readable

- [ ] **Kitty**: Uses colors from `kitty/pywal-colors.conf`
  - [ ] Terminal background color correct
  - [ ] Text color correct
  - [ ] Cursor color matches theme
  - [ ] All 16 ANSI colors display correctly

- [ ] **Quickshell**: Uses colors from `quickshell/qml/colors.qml`
  - [ ] Bar background color correct
  - [ ] Widget colors consistent
  - [ ] Text is readable

- [ ] **Niri**: Colors from `niri/config.kdl`
  - [ ] Window borders show active/inactive colors
  - [ ] Primary color is used for focused windows

### Theme Switching (Wallpaper Change)
```bash
wal -i ~/Pictures/different-wallpaper.jpg
./scripts/apply-theme.sh
```

- [ ] New wallpaper displays
- [ ] Colors update across all components
- [ ] Rofi colors change
- [ ] Dunst notifications use new colors
- [ ] Quickshell widgets update
- [ ] Kitty new instances use new colors
- [ ] (Niri: requires restart to see color changes)

---

## Notification Tests (Dunst)

### Basic Notifications
- [ ] Notification appears in corner
- [ ] Notification auto-closes after timeout (5s for normal)
- [ ] Notification uses correct colors
- [ ] Text is readable

### Critical Notifications
- [ ] Critical notification stays on screen (no timeout)
- [ ] Critical notification has red color scheme
- [ ] Must be manually closed or clicked away

### Notification Actions
- [ ] Click notification to perform action (if app provides it)
- [ ] Right-click to close
- [ ] Middle-click to close all

### Dunst Reload
```bash
pkill -HUP dunst
```
- [ ] Dunst reloads without crashing
- [ ] Continues working normally

---

## Application Compatibility Tests

### Terminal (Kitty)
```bash
Super+Return
```
- [ ] Kitty opens without errors
- [ ] Colors display correctly
- [ ] Terminal is responsive
- [ ] Text rendering is sharp
- [ ] Can run commands normally
- [ ] Ctrl+C, exit, etc. work

### App Launcher (Rofi)
```bash
Super+d
```
- [ ] Rofi opens immediately
- [ ] Shows installed applications
- [ ] Search functionality works (type to filter)
- [ ] Colors are correct
- [ ] Launch app on Enter
- [ ] Close on Escape

### Browser (Firefox)
```bash
Super+b
```
- [ ] Browser opens correctly
- [ ] Renders Wayland content properly
- [ ] No graphical glitches
- [ ] Hardware acceleration working (if available)

### File Manager (Thunar)
```bash
Super+e
```
- [ ] File manager opens
- [ ] Browse folders works
- [ ] Icon rendering correct
- [ ] Dragging files works

---

## X11 Fallback Tests

### Boot X11 Session
```bash
startx ~/.config/x11-session/xinitrc
```

- [ ] X11 session starts successfully
- [ ] AwesomeWM initializes
- [ ] Picom compositor running (check with `ps aux | grep picom`)
- [ ] Dunst running
- [ ] Bar visible with original island bar design
- [ ] Wallpaper displays

### AwesomeWM Functionality
- [ ] AwesomeWM keybindings work (Mod4+...)
- [ ] Tag switching works (Mod4+Left/Right)
- [ ] Window management works
- [ ] Rofi launcher works
- [ ] Terminal opens
- [ ] Notifications display

### Return to Niri
- [ ] Exit X11 session: `killall awesome` or Mod4+Shift+q
- [ ] Boot back into Niri
- [ ] Niri works normally (no lasting issues from X11 session)

---

## Performance Tests

### Resource Usage
- [ ] Niri startup time < 3 seconds
- [ ] Quickshell bar smooth (no stuttering)
- [ ] Widgets update without freezing UI
- [ ] Opening windows responsive (< 1s)
- [ ] Closing windows responsive

### CPU Usage
```bash
top -p $(pgrep niri)
```
- [ ] Niri CPU usage idle < 5%
- [ ] Occasional spikes when opening windows (acceptable)
- [ ] Returns to idle when settled

### Memory Usage
```bash
ps aux | grep niri
```
- [ ] Niri memory usage < 100MB
- [ ] Quickshell memory usage < 50MB
- [ ] No memory leaks over time

### Battery Usage (if on battery)
- [ ] System doesn't drain battery faster than before
- [ ] Animations don't cause unnecessary wake-ups
- [ ] Screen saver/DPMS works

---

## Error Handling Tests

### Crash Recovery
- [ ] Kill Niri process: `killall niri`
- [ ] Can manually restart: `niri`
- [ ] No data loss

- [ ] Kill a widget: `killall quickshell`
- [ ] Can restart from command line
- [ ] Niri continues working

### Missing Files
- [ ] Delete `niri/config.kdl` and restart
- [ ] Niri should fail gracefully with error message
- [ ] Restore file and verify recovery

- [ ] Delete theme files and restart services
- [ ] Components fall back to defaults
- [ ] Rerun setup to fix

### Invalid Config
- [ ] Introduce syntax error in `niri/config.kdl`
- [ ] Niri fails with parse error (check logs)
- [ ] Error message is understandable

---

## Cleanup & Finalization

### Documentation Review
- [ ] MIGRATION_NOTES.md is readable and accurate
- [ ] Configuration paths are correct
- [ ] Keybinding list matches actual bindings
- [ ] Fallback instructions are clear

### Git Commit
- [ ] All new files are tracked
- [ ] `.gitignore` includes temporary files (generated/, etc.)
- [ ] Commit message describes migration

### Final Checks
- [ ] No hardcoded paths (should use `$HOME`, `$XDG_CONFIG_HOME`, etc.)
- [ ] No debug logging enabled
- [ ] No commented-out code left behind
- [ ] Scripts are executable: `chmod +x scripts/*.sh`

---

## Sign-Off

- [ ] All tests passed
- [ ] No critical issues remaining
- [ ] Performance acceptable
- [ ] X11 fallback working
- [ ] Documentation complete
- [ ] Ready for daily use

**Tested by:** ________________

**Date:** ________________

**Notes/Issues found:**
```
(list any remaining issues or quirks)
```

---

## Quick Regression Tests (After Updates)

After updating Niri, Quickshell, or other components, run these quick tests:

- [ ] Niri starts and displays correctly
- [ ] Bar appears with all widgets
- [ ] Keybindings work
- [ ] Can open windows
- [ ] Colors are correct
- [ ] No obvious glitches or artifacts
- [ ] Logs show no critical errors

---

**Testing Complete!** 🎉

Your Niri migration is verified and ready for daily use.
