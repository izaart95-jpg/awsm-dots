# 🚀 START HERE - Niri WM Setup

**Welcome! This file will guide you to exactly what you need.**

---

## What Do You Want to Do?

### 1. Install Niri WM (I'm a new user) ✨

**Start here**: [`README_QUICKSTART.md`](README_QUICKSTART.md) (5 min read)

Then follow: [`SETUP_GUIDE.md`](SETUP_GUIDE.md) (20 min setup)

```bash
# TL;DR:
./INSTALL.sh
# Log out, select Niri, done!
```

**Then verify it works**: [`TESTING_CHECKLIST.md`](TESTING_CHECKLIST.md) (30 min)

---

### 2. I Have an Old Computer / No GPU 💻

**Read first**: [`SETUP_GUIDE.md` § Software Rendering Fallback](SETUP_GUIDE.md#software-rendering-fallback-cpu-users)

**Key section**: LLVMPipe setup for CPU-only systems

**Then install normally**: Follow step 1 above

---

### 3. Something Broke, Need Help 🆘

**Troubleshooting**: [`SETUP_GUIDE.md` § Troubleshooting](SETUP_GUIDE.md#troubleshooting)

**Or**: Check [`TESTING_CHECKLIST.md` § Error Handling](TESTING_CHECKLIST.md#error-handling-tests)

---

### 4. I Want to Share This with Others 📦

**Guide**: [`DISTRIBUTION_GUIDE.md`](DISTRIBUTION_GUIDE.md) (20 min read)

**Quick version:**
```bash
./scripts/create-archive.sh
# Upload the generated .tar.gz file
# Others can then: tar -xzf dotfiles-archive-*.tar.gz && cd dotfiles && ./INSTALL.sh
```

---

### 5. I Want to Understand Everything 📚

**Full guide**: [`MIGRATION_NOTES.md`](MIGRATION_NOTES.md) (45 min read)

**Technical deep-dive**: [`IMPLEMENTATION_SUMMARY.md`](IMPLEMENTATION_SUMMARY.md) (30 min read)

**Navigation**: [`INDEX.md`](INDEX.md) (find anything specific)

---

### 6. I Already Know What I'm Doing ⚡

**Just give me the files:**
```bash
# Configuration is in niri/, quickshell/, pywal/
# Run setup: ./INSTALL.sh
# Done!
```

---

## 📖 All Documentation

| Document | Purpose | Read Time | Best For |
|----------|---------|-----------|----------|
| **[README_QUICKSTART.md](README_QUICKSTART.md)** | Quick overview | 5 min | New users |
| **[SETUP_GUIDE.md](SETUP_GUIDE.md)** | Step-by-step install | 20 min | Installation |
| **[TESTING_CHECKLIST.md](TESTING_CHECKLIST.md)** | Verify everything | 30 min | Verification |
| **[MIGRATION_NOTES.md](MIGRATION_NOTES.md)** | Complete guide | 45 min | Detailed usage |
| **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** | Technical details | 30 min | Architecture |
| **[DISTRIBUTION_GUIDE.md](DISTRIBUTION_GUIDE.md)** | Share with others | 20 min | Distribution |
| **[INDEX.md](INDEX.md)** | Find anything | — | Navigation |
| **[FINAL_SUMMARY.md](FINAL_SUMMARY.md)** | Overview of everything | 10 min | Summary |

---

## ⚡ Super Quick Start

```bash
# 1. Run installer (checks deps, sets up Pywal, applies theme)
./INSTALL.sh

# 2. Log out from current session

# 3. Log back in, select "Niri" from session dropdown

# 4. Click login

# 5. Done! You're using Niri now 🎉
```

**That's it!**

---

## 🎯 First Commands to Try

After logging into Niri:

```bash
# Show all keybindings
Super+Escape

# Open terminal
Super+Return

# Launch app
Super+d

# Next workspace
Super+Right

# Focus next window
Super+j

# Fullscreen toggle
Super+f

# Close window
Super+Shift+c
```

---

## 📦 What You Get

| Component | What It Does |
|-----------|-------------|
| **Niri WM** | Modern Wayland window manager |
| **Quickshell Bar** | Modern bar with 9 widgets (clock, volume, battery, etc.) |
| **Pywal Theming** | Automatic color extraction from wallpaper |
| **Shader Animations** | Smooth smoke & glitch effects for windows |
| **X11 Fallback** | Classic AwesomeWM session still available |
| **60+ Keybindings** | All from AwesomeWM migrated to Niri |
| **GPU Acceleration** | Works on Intel, NVIDIA, AMD + CPU fallback |

---

## ✅ Quick Checklist

- [ ] Read README_QUICKSTART.md (5 min)
- [ ] Run `./INSTALL.sh`
- [ ] Log out and select Niri
- [ ] Press `Super+Escape` to see keybindings
- [ ] Try `Super+d` to launch apps
- [ ] Test `Super+Return` for terminal
- [ ] Verify widgets in bar (clock, volume, etc.)
- [ ] Read TESTING_CHECKLIST.md to verify all features
- [ ] Customize in niri/config.kdl if desired

---

## 🆘 If Something Goes Wrong

1. **Check logs:**
   ```bash
   journalctl -xe
   ```

2. **Read troubleshooting:**
   - [SETUP_GUIDE.md § Troubleshooting](SETUP_GUIDE.md#troubleshooting)

3. **Try X11 fallback:**
   ```bash
   startx ~/.config/x11-session/xinitrc
   ```

4. **Rerun setup:**
   ```bash
   ./scripts/niri-session-setup.sh
   ```

---

## 💡 Pro Tips

### Change Wallpaper (Auto-Update All Colors)
```bash
wal -i ~/Pictures/your-wallpaper.jpg
./scripts/apply-theme.sh
# Colors update everywhere!
```

### Customize Keybindings
Edit `niri/config.kdl`:
```kdl
binds {
    "Super+d".action = "spawn" "rofi -show drun"
    "Super+Return".action = "spawn" "kitty"
    # Add more here...
}
```

### Add/Remove Widgets
Edit `quickshell/qml/main.qml` and comment out widgets you don't want

### Adjust Performance
See: [SETUP_GUIDE.md § Performance Optimization](SETUP_GUIDE.md#performance-optimization)

---

## 📊 System Requirements

### Minimum
- Any Linux system
- Wayland-capable
- 2GB RAM
- ~200MB disk space

### Recommended
- Modern CPU/GPU
- 8GB+ RAM
- Wayland display manager (SDDM, GDM)

### Older Systems
Works fine with llvmpipe (CPU rendering)! See [SETUP_GUIDE.md § Software Rendering](SETUP_GUIDE.md#software-rendering-fallback-cpu-users)

---

## 📞 Need Help?

### Common Questions

**Q: Will Niri work on my old laptop?**
A: Yes! See Software Rendering section in SETUP_GUIDE.md

**Q: Can I still use X11?**
A: Yes! X11 fallback is always available: `startx ~/.config/x11-session/xinitrc`

**Q: How do I change colors?**
A: One command: `wal -i wallpaper.jpg && ./scripts/apply-theme.sh`

**Q: Are there tutorials?**
A: See SETUP_GUIDE.md and MIGRATION_NOTES.md

**Q: Can I customize keybindings?**
A: Yes! Edit niri/config.kdl and restart (Super+Alt+r)

### Full Support
- [SETUP_GUIDE.md Troubleshooting](SETUP_GUIDE.md#troubleshooting) — Most issues
- [TESTING_CHECKLIST.md](TESTING_CHECKLIST.md) — Verify everything works
- [MIGRATION_NOTES.md](MIGRATION_NOTES.md) — Detailed usage guide
- [INDEX.md](INDEX.md) — Find anything

---

## 🎉 You're Ready!

Everything is prepared and tested. Choose your path above and get started!

### Quick Path (5 minutes)
```
README_QUICKSTART.md → INSTALL.sh → Done!
```

### Thorough Path (1 hour)
```
SETUP_GUIDE.md → INSTALL.sh → TESTING_CHECKLIST.md → Customize
```

### Sharing Path (30 minutes)
```
SETUP_GUIDE.md → INSTALL.sh → DISTRIBUTION_GUIDE.md → Share!
```

---

**Questions?** Scroll up and find your scenario above! 👆

**Ready to start?** → Go to [README_QUICKSTART.md](README_QUICKSTART.md)

**Happy tiling!** 🚀🎉
