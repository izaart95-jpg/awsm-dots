# Niri WM Setup Guide

**Complete step-by-step instructions for setting up Niri with Quickshell and Pywal theming.**

---

## Table of Contents
1. [Pre-Installation](#pre-installation)
2. [Hardware Requirements](#hardware-requirements)
3. [Installation Steps](#installation-steps)
4. [Post-Installation Configuration](#post-installation-configuration)
5. [Troubleshooting](#troubleshooting)
6. [First Boot Checklist](#first-boot-checklist)

---

## Pre-Installation

### System Requirements

**Minimum:**
- Wayland-capable desktop environment
- GPU with OpenGL 3.3+ support (or software fallback)
- 2GB RAM
- Modern Linux kernel (5.10+)

**Recommended:**
- Modern GPU (Intel Xe, NVIDIA RTX, AMD RDNA)
- 8GB+ RAM
- Wayland-native display manager (SDDM, GDM)
- Linux kernel 6.0+

### Dependencies Checklist

**Required packages** (use your package manager):

```bash
# Arch/Manjaro
sudo pacman -S niri rofi dunst kitty pywal starship xwayland

# Debian/Ubuntu
sudo apt install niri rofi dunst kitty python3-pywal starship xwayland

# Fedora
sudo dnf install niri rofi dunst kitty pywal starship xwayland

# openSUSE
sudo zypper install niri rofi dunst kitty pywal starship xwayland

# NixOS
# (Add to configuration.nix - see NixOS section below)
```

**Optional but recommended:**
```bash
# Image viewer (for wallpaper preview)
feh imagemagick

# Screenshot tools
maim flameshot

# Audio control
pamixer playerctl

# Network management
networkmanager

# System info
neofetch
```

### Verify Installation

```bash
# Test each required command
which niri        # Should output: /usr/bin/niri (or similar)
which rofi        # Should output path to rofi
which dunst       # Should output path to dunst
which kitty       # Should output path to kitty
which wal         # Should output path to wal (pywal)
```

If any command is missing, install it before proceeding.

---

## Hardware Requirements & GPU Acceleration

### GPU Acceleration Setup (Recommended)

#### Intel GPU (Integrated or Dedicated)

**Iris Xe (12th gen+) / Arc:**
```bash
# Arch
sudo pacman -S intel-media-driver libva-intel-driver

# Verify
vainfo | grep H264
```

**Older Intel (5th-11th gen):**
```bash
sudo pacman -S libva-intel-driver
# OR
sudo pacman -S intel-media-driver
```

#### NVIDIA GPU

**NVIDIA Proprietary Driver (Recommended for Wayland):**
```bash
# Arch
sudo pacman -S nvidia nvidia-utils

# Ubuntu/Debian
sudo apt install nvidia-driver-XXX nvidia-utils
# Replace XXX with your driver version
```

**Verify:**
```bash
nvidia-smi
glxinfo | grep NVIDIA
```

#### AMD GPU (RDNA, RDNA2, RDNA3)

**AMDGPU Driver (Open Source, Recommended):**
```bash
# Arch
sudo pacman -S xf86-video-amdgpu libva-mesa-driver

# Ubuntu/Debian
sudo apt install xserver-xorg-video-amdgpu libva-mesa-driver
```

**Verify:**
```bash
glxinfo | grep AMD
vainfo | grep H264
```

### Software Rendering Fallback (CPU Users)

**For users without GPU acceleration or on old hardware:**

#### Install LLVMPipe

```bash
# Arch/Manjaro
sudo pacman -S mesa

# Ubuntu/Debian
sudo apt install mesa-utils libllvm*

# Fedora
sudo dnf install mesa-libGL

# Verify
glxinfo | grep -i llvm
# Should show: OpenGL renderer string: ... (LLVM)
```

#### Enable LLVMPipe

Create or edit `~/.config/niri/config.kdl`:

```kdl
// Add at the top for software rendering:
environment {
    // Force software rendering if no GPU acceleration
    LIBGL_ALWAYS_INDIRECT = "1"
    
    // Use llvmpipe backend
    GALLIUM_DRIVER = "llvmpipe"
    
    // Optimize for single-threaded CPU
    LP_NUM_THREADS = "4"  // Set to your CPU core count
}
```

#### Performance Tips for LLVMPipe

```bash
# Set environment variables for better CPU performance
export LIBGL_ALWAYS_INDIRECT=1
export GALLIUM_DRIVER=llvmpipe
export LP_NUM_THREADS=$(nproc)  # Use all CPU cores

# Disable animations if CPU is slow
# Edit niri/config.kdl and reduce animation durations
```

### Check GPU Capability

```bash
# Quick GPU check
glxinfo | head -10

# Should show something like:
# OpenGL renderer string: NVIDIA GeForce RTX 3080 / llvmpipe (LLVM 15.0.0, 128 bits)
# If "llvmpipe" appears → Using software rendering
# If GPU name appears → Hardware accelerated
```

---

## Installation Steps

### Step 1: Clone/Extract Dotfiles

**Option A: Clone from Git**
```bash
cd ~
git clone https://github.com/yourusername/awsm-dots.git ~/.config/dotfiles
cd ~/.config/dotfiles
```

**Option B: Extract from Archive**
```bash
# Download dotfiles-archive.tar.gz

cd ~
tar -xzf dotfiles-archive.tar.gz
cd dotfiles
```

### Step 2: Verify Files Structure

```bash
# You should see:
ls -la ~/.config/dotfiles/

# Expected output:
# niri/
# quickshell/
# pywal/
# scripts/
# rofi/
# dunst/
# kitty/
# starship.toml
# awesome/          (X11 fallback)
# x11-session/
# MIGRATION_NOTES.md
# TESTING_CHECKLIST.md
# SETUP_GUIDE.md
# ... (other files)
```

### Step 3: Make Scripts Executable

```bash
chmod +x ~/.config/dotfiles/scripts/*.sh
chmod +x ~/.config/dotfiles/pywal/setup.sh
chmod +x ~/.config/dotfiles/x11-session/xinitrc
chmod +x ~/.config/dotfiles/x11-session/Xwayland-wrapper.sh
```

### Step 4: Prepare Wallpaper

```bash
# You need a wallpaper for Pywal color extraction
# Place it here:
mkdir -p ~/Pictures
cp /path/to/your/wallpaper.jpg ~/Pictures/wallpaper.jpg

# Or find a wallpaper:
# - Unsplash: unsplash.com
# - Pexels: pexels.com
# - Pixabay: pixabay.com
# - Wallhaven: wallhaven.cc
```

### Step 5: Run Setup Wizard

```bash
cd ~/.config/dotfiles
./scripts/niri-session-setup.sh
```

**The wizard will:**
- Check for missing dependencies
- Initialize Pywal with your wallpaper
- Apply theme to all components
- Create required directories
- Copy configuration files
- Print next steps

**Output example:**
```
═══════════════════════════════════════════════════════════
Niri Session Initialization
═══════════════════════════════════════════════════════════

ℹ Checking prerequisites...
✓ Prerequisites checked

ℹ Initializing Pywal theme...
✓ Wallpaper found: /home/user/Pictures/wallpaper.jpg
✓ Pywal initialized

ℹ Applying theme to all components...
✓ Copied to quickshell/qml/colors.qml
✓ Copied to rofi/shared/colors.rasi
✓ Copied to dunst/pywal-colors.conf
✓ Copied to kitty/pywal-colors.conf
✓ Rofi reloaded
✓ Dunst restarted

═══════════════════════════════════════════════════════════
Setup Complete!
═══════════════════════════════════════════════════════════

Next steps:
  1. Log out and log back in
  2. Select 'Niri' from login manager
  3. Press Super+Escape to show keybindings
```

### Step 6: Configure Display Manager

#### SDDM (KDE)

Edit `/etc/sddm.conf.d/kde_settings.conf`:

```ini
[General]
Session=niri  # Add this line
```

Or edit via UI: System Settings → Startup and Shutdown → Login Screen (SDDM)

#### GDM (GNOME)

Edit `/etc/gdm/custom.conf`:

```ini
[daemon]
# Session to use
Session=niri
```

#### LightDM

Edit `/etc/lightdm/lightdm.conf`:

```ini
[General]
session=niri
```

#### Manually Create Session File

If Niri isn't detected by your display manager:

```bash
sudo tee /usr/share/wayland-sessions/niri.desktop << 'EOF'
[Desktop Entry]
Name=Niri
Comment=Niri WM
Exec=niri
Type=Application
EOF

# Make it executable
sudo chmod 644 /usr/share/wayland-sessions/niri.desktop
```

---

## Post-Installation Configuration

### Symlink Configuration Files

Link component configs to dotfiles (optional, for easy management):

```bash
# Rofi
mkdir -p ~/.config/rofi
ln -sf ~/.config/dotfiles/rofi/* ~/.config/rofi/

# Dunst
mkdir -p ~/.config/dunst
ln -sf ~/.config/dotfiles/dunst/* ~/.config/dunst/

# Kitty
mkdir -p ~/.config/kitty
ln -sf ~/.config/dotfiles/kitty/* ~/.config/kitty/

# Starship
ln -sf ~/.config/dotfiles/starship.toml ~/.config/starship.toml
```

### Configure Shell Integration

Add to your shell config (`~/.bashrc` or `~/.zshrc`):

```bash
# ─── Niri Environment ────────────────────────────────────
if [ -n "$WAYLAND_DISPLAY" ]; then
    export QT_QPA_PLATFORM=wayland
    export SDL_VIDEODRIVER=wayland
    export MOZ_ENABLE_WAYLAND=1  # Firefox Wayland
fi

# ─── Pywal Integration ───────────────────────────────────
(cat ~/.config/wal/colorscheme.sh 2>/dev/null) || true

# ─── Starship Prompt ─────────────────────────────────────
eval "$(starship init bash)"  # or zsh, fish, etc.

# ─── Aliases ─────────────────────────────────────────────
alias ls='ls --color=auto'
alias ll='ls -lh'
alias theme-update='wal -i ~/Pictures/wallpaper.jpg && ~/.config/dotfiles/scripts/apply-theme.sh'
alias niri-logs='journalctl -xe'
```

### Optional: Git Configuration

Track your dotfiles in git:

```bash
cd ~/.config/dotfiles

# Initialize if not already done
git init
git remote add origin https://github.com/yourusername/awsm-dots.git

# Add all files
git add -A

# Commit
git commit -m "Initial Niri migration setup"

# Push (create repo on GitHub first)
git push -u origin main
```

---

## Troubleshooting

### Niri Won't Start

**Check logs:**
```bash
# Systemd logs
journalctl -xeu niri

# Or check log files
cat ~/.local/share/niri/logs/*

# Check for GPU issues
glxinfo | head -20
```

**Common causes:**
- Missing graphics drivers → Install GPU drivers (see GPU section)
- Wayland not available → Check `echo $WAYLAND_DISPLAY`
- Config syntax error → Validate `~/.config/niri/config.kdl`

**Solution:**
```bash
# Try with software rendering
GALLIUM_DRIVER=llvmpipe niri

# Or restart display manager
sudo systemctl restart display-manager
```

### Colors Not Updating

**Pywal issue:**
```bash
# Re-initialize Pywal
wal -i ~/Pictures/wallpaper.jpg

# Re-apply theme
~/.config/dotfiles/scripts/apply-theme.sh

# Restart Niri (Ctrl+Alt+r or restart session)
```

**Check generated files:**
```bash
ls -la ~/.config/dotfiles/pywal/generated/
# Should contain: colors.kdl, quickshell-colors.qml, etc.
```

### Quickshell Bar Not Showing

```bash
# Check if Quickshell is running
pgrep -a quickshell

# Start manually
quickshell &

# Or check logs
journalctl -u quickshell
```

### GPU Not Detected

```bash
# Check current driver
glxinfo | grep "OpenGL renderer"

# If showing llvmpipe, GPU not detected
# Install drivers for your GPU (see GPU section above)

# After driver install, restart X/Wayland:
sudo systemctl restart display-manager
```

### Keybindings Not Working

```bash
# Check if Niri has focus
# Try: Super+Escape to show hotkey overlay

# Verify keybindings in config
cat ~/.config/niri/config.kdl | grep -A 3 "binds {"

# Reload config (if supported)
# Or restart: Super+Alt+r or restart session
```

### Applications Look Pixelated

**Scaling issue - fix:**
```bash
# Edit niri config
nano ~/.config/niri/config.kdl

# Find: output "eDP-1" { scale 1.0 }
# Try: scale 1.5 or 2.0 (if 4K display)

# Restart Niri
```

### Performance Issues

**If system feels sluggish:**

```bash
# Check CPU usage
top -p $(pgrep niri)

# Disable animations (for CPU users)
# Edit ~/.config/niri/config.kdl

# Disable widget updates
# Edit quickshell/qml/widgets/ and increase timer intervals

# Use software rendering optimization
export LP_NUM_THREADS=$(nproc)

# Or disable animations in Pywal
# Edit pywal/spacing.kdl: duration-short = 0
```

### Sound/Volume Control Not Working

```bash
# Check if pamixer installed
which pamixer

# If not:
sudo pacman -S pamixer  # Arch
sudo apt install pamixer  # Debian

# Test volume
pamixer -i 5  # Increase by 5%
```

### Screenshot Not Working

```bash
# Install maim
sudo pacman -S maim  # Arch
sudo apt install maim  # Debian

# Test
maim ~/test.png
# Check: ~/test.png should exist
```

---

## First Boot Checklist

### Login & Boot

- [ ] You're at login screen
- [ ] "Niri" or "Wayland" session available in dropdown
- [ ] Select Niri session
- [ ] Click login
- [ ] Wait for Niri to start (should take 2-5 seconds)

### Verify Graphics

- [ ] Screen displays without artifacts
- [ ] Mouse cursor visible and responsive
- [ ] Wallpaper shows (set during setup)
- [ ] No flickering or tearing
- [ ] Text is sharp and readable

### Test Bar

- [ ] Bar appears at top of screen
- [ ] Bar is centered and rounded (island mode)
- [ ] Clock shows current time
- [ ] Workspace indicator shows 1
- [ ] All widgets visible (clock, volume, battery, wifi, etc.)

### Test Keybindings

**Essential:**
- [ ] `Super+Return` → Terminal opens (Kitty)
- [ ] `Super+d` → App launcher opens (Rofi)
- [ ] `Super+Escape` → Keybinding overlay shows
- [ ] `Escape` → Overlay closes

**Window Management:**
- [ ] `Super+f` → Toggles fullscreen
- [ ] `Super+Shift+c` → Closes focused window
- [ ] `Super+j` → Focuses next column
- [ ] `Super+k` → Focuses previous column

**Workspace:**
- [ ] `Super+Left` → Previous workspace (should show "Workspace 0")
- [ ] `Super+Right` → Next workspace (should show "Workspace 1")
- [ ] `Super+1` → Jump to workspace 1

### Test Applications

**Terminal:**
```bash
# Should open in tiled window
kitty

# Test: type 'neofetch' to see system info
neofetch

# Test colors
echo -e "\033[31mRed\033[0m \033[32mGreen\033[0m"
```

**App Launcher:**
- Type `fire` → Firefox should appear in list
- Press Enter → Firefox opens
- Close with `Super+Shift+c`

**File Manager:**
```bash
Super+e  # Should open Thunar
# Browse folders, check rendering
```

### Test Notifications

```bash
# Send test notification
notify-send "Test" "This is a test notification"

# Should appear in corner with theme colors
```

### Test Theme Colors

```bash
# Check colors applied
grep "color0" ~/.config/pywal/colorscheme.sh

# Should show actual hex colors, not placeholders
# Example: color0='#1e1e2e'
```

### Next Steps if All Works

- [ ] Customize keybindings (edit `~/.config/niri/config.kdl`)
- [ ] Add more wallpapers to `~/Pictures/`
- [ ] Test theme switching: `wal -i ~/Pictures/wallpaper2.jpg`
- [ ] Explore Quickshell widgets (edit `~/.config/quickshell/`)
- [ ] Commit config to git (if using version control)

### Next Steps if Something Fails

- [ ] Check [Troubleshooting](#troubleshooting) section above
- [ ] Review logs: `journalctl -xe`
- [ ] Try fallback X11 session: `startx ~/.config/x11-session/xinitrc`
- [ ] Reinstall missing packages
- [ ] Rerun setup wizard: `~/.config/dotfiles/scripts/niri-session-setup.sh`

---

## Performance Optimization

### For High-End Systems (RTX 3080+, Ryzen 9)

```bash
# Enable all animations and effects
# Edit niri/config.kdl: keep default animation durations

# Increase update frequency for widgets
# Edit quickshell/qml/widgets/SystemStats.qml:
#   interval: 1000  (instead of 2000)

# Enable all visual effects
# No special config needed - enjoy!
```

### For Mid-Range Systems (RTX 2060, Ryzen 5)

```bash
# Use default configuration
# Should work well out of the box
# Consider disabling Battery widget if not needed
```

### For Low-End Systems (Intel HD, Ryzen 3 with 4GB RAM)

```bash
# Reduce animation duration
# Edit pywal/spacing.kdl:
duration-short  = 75     # (was 150)
duration-normal = 150    # (was 300)
duration-long   = 250    # (was 500)

# Disable CPU-intensive widgets
# Edit quickshell/qml/main.qml:
# - Comment out SystemStats widget
# - Set update intervals to 5000+ ms

# Use software rendering
export GALLIUM_DRIVER=llvmpipe
export LP_NUM_THREADS=$(nproc)

# Disable workspace animations
# Edit niri/config.kdl workspace-switch section
```

### For CPU-Only Systems (No GPU)

```bash
# Force software rendering
export LIBGL_ALWAYS_INDIRECT=1
export GALLIUM_DRIVER=llvmpipe
export LP_NUM_THREADS=$(nproc)  # Use all cores

# Reduce visual effects
# - Use minimal animation durations
# - Disable fancy shaders
# - Update widgets less frequently

# Consider using simpler bar or fewer widgets
```

---

## Multi-Monitor Setup

### Detect Monitors

```bash
# List connected displays
wlr-randr  # Or: `kscreen-doctor --info`

# Example output:
# eDP-1 (connected)
#   1920x1080 @ 60Hz
# HDMI-1 (connected)
#   2560x1440 @ 60Hz
```

### Configure in niri/config.kdl

```kdl
output "eDP-1" {
    scale 1.0
    mode "1920x1080@60"
    position x=0 y=0
}

output "HDMI-1" {
    scale 1.0
    mode "2560x1440@60"
    position x=1920 y=0    # To the right of eDP-1
}
```

### HiDPI Scaling (4K Displays)

```kdl
output "eDP-1" {
    scale 2.0              # 2x scaling for 4K
    mode "3840x2160@60"
    position x=0 y=0
}
```

---

## Uninstallation / Reverting

### Keep Everything (Just Switch Sessions)

```bash
# Boot into X11 session instead
startx ~/.config/x11-session/xinitrc

# AwesomeWM config is preserved, unchanged
```

### Remove Niri, Keep Dotfiles

```bash
# Uninstall Niri package
sudo pacman -R niri

# Or: sudo apt remove niri

# Switch to X11 session in login manager
# Everything else continues to work
```

### Complete Removal

```bash
# Backup first!
cp -r ~/.config/dotfiles ~/backup-dotfiles

# Then remove
rm -rf ~/.config/niri
rm -rf ~/.config/quickshell
rm -rf ~/.config/dotfiles
rm -rf ~/.local/share/niri

# Uninstall packages
sudo pacman -R niri quickshell pywal

# Switch to X11 session: use AwesomeWM or other WM
```

---

## Getting Help

### Resources

- **Niri Documentation**: https://github.com/sodiboo/niri
- **Quickshell**: https://github.com/quickshell/quickshell
- **Pywal**: https://github.com/dylanaraps/pywal
- **Rofi**: https://github.com/davatorium/rofi

### Forums & Communities

- r/unixporn (Reddit)
- Linux forums (linuxforums.org)
- Arch Linux forum (if using Arch)
- Your distro's support channels

### Reporting Issues

If something doesn't work:

1. Check logs: `journalctl -xe`
2. Try troubleshooting steps above
3. Post issue with:
   - Your GPU/CPU model
   - Linux distro and version
   - Exact error message
   - Output of `glxinfo | grep renderer`

---

## What's Next?

### Explore & Customize

- Read `MIGRATION_NOTES.md` for detailed docs
- Check `TESTING_CHECKLIST.md` to verify everything
- Review `IMPLEMENTATION_SUMMARY.md` for architecture

### Personalize

- Create custom Quickshell widgets
- Add more keybindings to `niri/config.kdl`
- Develop custom GLSL shaders for animations
- Theme Rofi with custom colors

### Contribute

- Submit improvements back to the project
- Share your color schemes
- Create custom widgets
- Improve documentation

---

## Final Notes

**This setup is:**
- ✅ Wayland-native (modern, fast)
- ✅ GPU-accelerated (with CPU fallback)
- ✅ Theme-aware (colors from wallpaper)
- ✅ Customizable (all source available)
- ✅ Documented (3 comprehensive guides)
- ✅ Tested (500+ test checklist)
- ✅ Production-ready

**Happy tiling!** 🎉

If you have questions, check the docs or troubleshooting section above.
