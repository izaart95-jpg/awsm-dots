# Distribution Guide - Sharing Your Niri Dotfiles

**How to create and share your dotfiles for easy installation by others.**

---

## Overview

The dotfiles archive system allows you to:
- 📦 Package entire configuration as a single file
- 🔗 Share easily (GitHub, cloud storage, etc.)
- ✅ Include integrity verification (SHA256)
- 🚀 Enable one-command installation
- 📚 Include comprehensive documentation

---

## Creating Distribution Archive

### Step 1: Prepare Your Dotfiles

```bash
cd ~/.config/dotfiles
# Or wherever your dotfiles are located

# Make sure everything is ready:
# - All configurations are tested
# - Documentation is complete
# - No personal data/secrets
# - All scripts are executable
```

### Step 2: Generate Archive

```bash
./scripts/create-archive.sh
```

This creates three files:

1. **`dotfiles-archive-YYYYMMDD.tar.gz`** — The archive (main file)
2. **`dotfiles-archive-YYYYMMDD.tar.gz.sha256`** — Checksum for verification
3. **`ARCHIVE_INFO.txt`** — Information about the archive

### Step 3: What's in the Archive

The archive automatically includes:

```
dotfiles-archive-YYYYMMDD.tar.gz
├── niri/                 (Niri configuration)
├── quickshell/           (Bar + widgets)
├── pywal/                (Theme system)
├── scripts/              (Helper scripts)
├── rofi/                 (App launcher)
├── dunst/                (Notifications)
├── kitty/                (Terminal)
├── awesome/              (X11 fallback)
├── x11-session/          (X11 support)
├── starship.toml         (Shell prompt)
├── README.md             (Archive README)
├── INSTALL.sh            (Quick installer)
├── SETUP_GUIDE.md        (Setup instructions)
├── MIGRATION_NOTES.md    (Detailed guide)
├── TESTING_CHECKLIST.md  (Verification)
└── IMPLEMENTATION_SUMMARY.md (Architecture)
```

**Note**: `pywal/generated/` is excluded (auto-generated during setup)

---

## Distributing the Archive

### Option 1: GitHub Releases (Recommended)

#### Setup GitHub Repository

```bash
cd ~/.config/dotfiles

# Initialize if needed
git init
git remote add origin https://github.com/yourusername/niri-dotfiles.git

# Add all files
git add -A
git commit -m "Niri WM dotfiles with Quickshell and Pywal"

# Push to GitHub
git branch -M main
git push -u origin main
```

#### Create Release with Archive

1. Generate archive: `./scripts/create-archive.sh`
2. Go to GitHub → Releases → "Create a new release"
3. **Tag**: `v1.0.0`
4. **Title**: `Niri WM Dotfiles Archive`
5. **Description**: 
   ```markdown
   Complete Niri WM setup with:
   - Quickshell bar (9 widgets)
   - Pywal dynamic theming
   - GLSL shader animations
   - 60+ keybindings
   - X11 fallback
   
   **Quick Start:**
   1. Download archive
   2. Extract: `tar -xzf dotfiles-archive-*.tar.gz`
   3. Run: `cd dotfiles && ./INSTALL.sh`
   4. Log out, select Niri, enjoy!
   
   **Verification:**
   ```
   sha256sum -c dotfiles-archive-*.tar.gz.sha256
   ```
   ```
6. Upload files:
   - `dotfiles-archive-YYYYMMDD.tar.gz`
   - `dotfiles-archive-YYYYMMDD.tar.gz.sha256`
   - `ARCHIVE_INFO.txt`
7. Publish release

### Option 2: Cloud Storage

Upload to any of these services:

**File Hosters:**
- Google Drive
- Dropbox
- OneDrive
- Nextcloud

**Example** (Google Drive):
```bash
# Upload archive
rclone copy dotfiles-archive-*.tar.gz drive:Public/

# Share link publicly
# → Right-click → Share → Get link
```

### Option 3: Self-Hosted

Host on your own server:

```bash
# Via SFTP/SCP
scp dotfiles-archive-*.tar.gz user@server.com:/var/www/downloads/

# Access via: https://server.com/downloads/dotfiles-archive-*.tar.gz
```

### Option 4: AUR (Arch Linux Repository)

For Arch users, create AUR package:

```bash
# 1. Create PKGBUILD file
cat > PKGBUILD << 'EOF'
pkgname=niri-dotfiles
pkgver=1.0.0
pkgrel=1
pkgdesc="Niri WM dotfiles with Quickshell bar and Pywal theming"
arch=('any')
url="https://github.com/yourusername/niri-dotfiles"
license=('GPL')

source=("https://github.com/yourusername/niri-dotfiles/archive/v${pkgver}.tar.gz")
sha256sums=('XXXXXXXXXXXX')

package() {
    cp -r ${srcdir}/niri-dotfiles-${pkgver}/* ${pkgdir}/opt/niri-dotfiles/
    chmod +x ${pkgdir}/opt/niri-dotfiles/scripts/*.sh
}
EOF

# 2. Update sha256sum
# 3. Test: makepkg -si
# 4. Submit to AUR
```

---

## Sharing Instructions

### For GitHub Release

```markdown
# Installation Instructions

**Quick Start (3 steps):**

1. Download the latest release: `dotfiles-archive-*.tar.gz`

2. Extract and install:
   ```bash
   tar -xzf dotfiles-archive-*.tar.gz
   cd dotfiles
   ./INSTALL.sh
   ```

3. Log out and select "Niri" session from login manager

**Verification:**

Verify archive integrity:
```bash
sha256sum -c dotfiles-archive-*.tar.gz.sha256
```

**Requirements:**

- Linux (Arch, Debian, Fedora, Ubuntu, etc.)
- Wayland display environment
- ~200MB disk space

**Documentation:**

After extraction, read in this order:
1. `SETUP_GUIDE.md` ← Start here
2. `MIGRATION_NOTES.md`
3. `TESTING_CHECKLIST.md`

**Features:**

- ✅ Wayland-native (Niri)
- ✅ Modern QML bar (Quickshell)
- ✅ 9 real-time widgets
- ✅ Dynamic theming (Pywal)
- ✅ GLSL shader animations
- ✅ 60+ keybindings
- ✅ X11 fallback (AwesomeWM)
- ✅ GPU acceleration + CPU fallback

**Support:**

- Check `SETUP_GUIDE.md` troubleshooting section
- Review `TESTING_CHECKLIST.md` to verify
- See docs for detailed information
```

### For Personal Use / Blog Post

```markdown
## Niri WM Dotfiles Setup

I've migrated from AwesomeWM to Niri WM and created a complete configuration package.

**What's included:**
- Window manager (Niri) with 60+ keybindings
- Modern bar (Quickshell) with 9 widgets
- Dynamic theming system (Pywal)
- Shader-based animations
- Full documentation and testing suite

**Download:**
[Download latest archive](link-to-archive)

**Installation:**
1. Extract: `tar -xzf dotfiles-archive-*.tar.gz`
2. Install: `cd dotfiles && ./INSTALL.sh`
3. Log out, select Niri, enjoy!

**More info:**
See included SETUP_GUIDE.md for detailed instructions.
```

---

## Maintenance & Updates

### When to Regenerate Archive

After making changes to:
- `niri/config.kdl` (keybindings, window rules)
- `quickshell/qml/` (widgets, bar layout)
- `pywal/` (theme system)
- `rofi/`, `dunst/`, `kitty/` (app configs)
- Documentation

### Update Process

```bash
# 1. Make your changes
nano niri/config.kdl
# ... edit

# 2. Test thoroughly
# See TESTING_CHECKLIST.md

# 3. Commit changes
git add -A
git commit -m "Update: improved keybindings"
git push

# 4. Create new archive
./scripts/create-archive.sh

# 5. Release new version
# → GitHub releases → Create release
# → Upload archive + checksum
```

### Version Numbering

Use semantic versioning:

- **v1.0.0** — Initial release
- **v1.0.1** — Bug fix
- **v1.1.0** — New features
- **v2.0.0** — Major changes/breaking changes

---

## Troubleshooting Distribution

### Issue: Archive is too large

**Solution**: Exclude unnecessary files in `create-archive.sh`:

```bash
# Edit create-archive.sh to skip:
# - Large wallpapers in ~/Pictures
# - Git history (clone without .git)
# - Cache/temporary files
```

### Issue: SHA256 doesn't match

**Cause**: Archive was modified or corrupted during download

**Solution**:
1. Re-download the archive
2. Verify with provided checksum
3. Report issue if problem persists

### Issue: Installation fails on user's system

**Have them check:**
1. Are dependencies installed? `which niri rofi dunst kitty`
2. Is Wayland available? `echo $WAYLAND_DISPLAY`
3. Check logs: `journalctl -xe`
4. Are GPU drivers installed? `glxinfo | grep renderer`
5. Run setup manually: `./pywal/setup.sh ~/Pictures/wallpaper.jpg`

---

## Best Practices

### Before Releasing

- [ ] Run TESTING_CHECKLIST.md completely
- [ ] Test on multiple systems if possible
- [ ] Remove personal data/secrets
- [ ] Update all documentation
- [ ] Verify no hardcoded paths (use $HOME, $XDG_*, etc.)
- [ ] Test archive extraction works
- [ ] Verify checksum generation

### Archive Contents

**Include:**
- ✅ All configuration files
- ✅ All scripts and helpers
- ✅ Complete documentation
- ✅ License files
- ✅ README and installation guide

**Exclude:**
- ❌ Generated files (pywal/generated/)
- ❌ Cache directories
- ❌ Git history (.git/)
- ❌ Node modules or build artifacts
- ❌ Personal data or secrets
- ❌ Large wallpaper collections (link instead)

### Documentation Quality

**Essential docs to include:**
1. README.md (overview)
2. SETUP_GUIDE.md (installation + troubleshooting)
3. MIGRATION_NOTES.md (detailed usage)
4. TESTING_CHECKLIST.md (verification)

**Keep updated:**
- Update docs with each release
- Add troubleshooting for reported issues
- Include hardware requirements
- Document dependencies clearly

---

## Example Distribution Workflow

### Week 1: Initial Release

```bash
# Day 1: Create and test
./scripts/create-archive.sh
# → Thorough testing with TESTING_CHECKLIST.md

# Day 3: Upload to GitHub
# → Create release with archive + checksum + info

# Day 5: Announce
# → Post on r/unixporn or forums
# → Share on personal blog
# → Post in Discord communities
```

### Week 2: Feedback & Updates

```bash
# Receive feedback from users
# - Bug reports
# - Feature requests
# - Compatibility issues

# Implement critical fixes
# Test updates
# Release v1.0.1
```

### Ongoing Maintenance

```bash
# Regular updates:
# - Monthly: Minor improvements
# - Quarterly: Major features
# - As-needed: Critical bug fixes

# Keep documentation fresh
# Update for Niri/Quickshell releases
```

---

## Sharing Channels

### Social Media

- **r/unixporn** — Post screenshots + archive link
- **r/NixOS** — If using NixOS
- **r/archlinux** — Arch-specific communities
- **Twitter/X** — Showcase screenshots, link to archive

### Communities

- **Linux Forums** — linuxforums.org, forums.fedoraforum.org
- **Discord Servers** — Linux/Wayland communities
- **Lemmy** — Federated version of Reddit
- **Mastodon** — Decentralized social media

### Project Sites

- **GitHub** — Primary distribution (releases)
- **GitLab** — Alternative git hosting
- **Codeberg** — Privacy-focused git
- **AUR** — Arch User Repository (for Arch users)

---

## Checklist: Ready to Share?

- [ ] All files tested with TESTING_CHECKLIST.md
- [ ] Documentation complete and accurate
- [ ] No personal data or secrets in archive
- [ ] Archive created successfully
- [ ] SHA256 checksum verified
- [ ] Installation tested from scratch
- [ ] Multiple systems tested (if possible)
- [ ] GPU/CPU fallback tested
- [ ] X11 fallback tested
- [ ] Archive can be extracted cleanly
- [ ] INSTALL.sh runs without errors
- [ ] Setup wizard completes successfully
- [ ] First boot works as expected
- [ ] Keybindings functional
- [ ] Theme colors applied correctly
- [ ] All widgets visible and updating
- [ ] Animations smooth
- [ ] Documentation reviewed
- [ ] Release notes written
- [ ] Archive uploaded
- [ ] Checksum uploaded
- [ ] Ready to announce!

---

## Next Steps

1. **Create archive**: `./scripts/create-archive.sh`
2. **Test it**: Extract and run `./INSTALL.sh` from scratch
3. **Upload**: Push to GitHub releases (or preferred platform)
4. **Share**: Post announcement in community channels
5. **Support**: Monitor for issues and feedback
6. **Iterate**: Improve based on user feedback

---

**Your dotfiles are ready to share! 🚀**

Archive created, checksums verified, docs included. Now just upload and share! 📦
