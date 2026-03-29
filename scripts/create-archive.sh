#!/bin/bash
# Create Dotfiles Archive for Distribution
# ─────────────────────────────────────────────────────────────────────────────
# Packages entire dotfiles directory into distributable archive
# Usage: ./scripts/create-archive.sh
# Output: dotfiles-archive-YYYYMMDD.tar.gz
# ─────────────────────────────────────────────────────────────────────────────

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TIMESTAMP=$(date +%Y%m%d)
ARCHIVE_NAME="dotfiles-archive-${TIMESTAMP}.tar.gz"
TEMP_DIR=$(mktemp -d)

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Creating Dotfiles Archive${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

# ─── Prepare temporary directory ───────────────────────────────────────────
echo -e "${BLUE}Preparing archive contents...${NC}"

ARCHIVE_DIR="$TEMP_DIR/dotfiles"
mkdir -p "$ARCHIVE_DIR"

# Copy main directories
echo "  Copying niri/ ..."
cp -r "$PROJECT_ROOT/niri" "$ARCHIVE_DIR/"

echo "  Copying quickshell/ ..."
cp -r "$PROJECT_ROOT/quickshell" "$ARCHIVE_DIR/"

echo "  Copying pywal/ ..."
cp -r "$PROJECT_ROOT/pywal" "$ARCHIVE_DIR/"

echo "  Copying scripts/ ..."
cp -r "$PROJECT_ROOT/scripts" "$ARCHIVE_DIR/"

echo "  Copying rofi/ ..."
cp -r "$PROJECT_ROOT/rofi" "$ARCHIVE_DIR/"

echo "  Copying dunst/ ..."
cp -r "$PROJECT_ROOT/dunst" "$ARCHIVE_DIR/"

echo "  Copying kitty/ ..."
cp -r "$PROJECT_ROOT/kitty" "$ARCHIVE_DIR/"

echo "  Copying x11-session/ ..."
cp -r "$PROJECT_ROOT/x11-session" "$ARCHIVE_DIR/"

echo "  Copying awesome/ (X11 fallback) ..."
cp -r "$PROJECT_ROOT/awesome" "$ARCHIVE_DIR/" 2>/dev/null || true

# Copy documentation
echo "  Copying documentation ..."
for doc in MIGRATION_NOTES.md TESTING_CHECKLIST.md IMPLEMENTATION_SUMMARY.md SETUP_GUIDE.md; do
    if [ -f "$PROJECT_ROOT/$doc" ]; then
        cp "$PROJECT_ROOT/$doc" "$ARCHIVE_DIR/"
        echo "    ✓ $doc"
    fi
done

# Copy configuration files
echo "  Copying config files ..."
cp "$PROJECT_ROOT/starship.toml" "$ARCHIVE_DIR/" 2>/dev/null || true
[ -f "$PROJECT_ROOT/.gitignore" ] && cp "$PROJECT_ROOT/.gitignore" "$ARCHIVE_DIR/"

# Make scripts executable in archive
chmod +x "$ARCHIVE_DIR/scripts/"*.sh
chmod +x "$ARCHIVE_DIR/pywal/setup.sh"
chmod +x "$ARCHIVE_DIR/x11-session/"*.sh

# Create README for archive
cat > "$ARCHIVE_DIR/README.md" << 'EOFREADME'
# Niri WM Dotfiles Archive

Complete setup for Niri window manager with Quickshell bar and Pywal theming.

## Quick Start

1. **Extract archive:**
   ```bash
   tar -xzf dotfiles-archive-*.tar.gz
   cd dotfiles
   ```

2. **Run setup:**
   ```bash
   ./scripts/niri-session-setup.sh
   ```

3. **Reboot and select Niri session from login manager**

## Documentation

- **SETUP_GUIDE.md** — Step-by-step installation guide (START HERE)
- **MIGRATION_NOTES.md** — Detailed migration and usage guide
- **TESTING_CHECKLIST.md** — Comprehensive testing procedures
- **IMPLEMENTATION_SUMMARY.md** — Technical architecture overview

## What's Included

- **niri/** — Niri WM configuration with keybindings and GLSL animations
- **quickshell/** — Modern QML-based bar with 9 widgets
- **pywal/** — Dynamic theme system (colors from wallpaper)
- **scripts/** — Setup and theme application helpers
- **rofi/, dunst/, kitty/** — Pre-configured application configs
- **awesome/** — Classic X11 fallback session
- **x11-session/** — X11 session launcher

## Requirements

- Wayland-capable Linux system
- GPU drivers (or CPU fallback with llvmpipe)
- ~200MB disk space

## Getting Help

1. Read **SETUP_GUIDE.md** for detailed instructions
2. Check **TESTING_CHECKLIST.md** to verify installation
3. Review **MIGRATION_NOTES.md** for troubleshooting
4. Consult project docs:
   - https://github.com/sodiboo/niri
   - https://github.com/quickshell/quickshell
   - https://github.com/dylanaraps/pywal

## Features

- ✅ Wayland-native window manager (Niri)
- ✅ Modern QML bar (Quickshell) with 9 widgets
- ✅ GLSL shader animations (smoke + glitch effects)
- ✅ Dynamic theming from wallpaper (Pywal)
- ✅ 60+ migrated keybindings
- ✅ X11 fallback session (AwesomeWM)
- ✅ GPU-accelerated with CPU fallback (llvmpipe)
- ✅ Comprehensive documentation

## License & Credits

Configuration and scripts created for Niri WM migration.
Respects all upstream project licenses.

**Happy tiling!** 🎉
EOFREADME

# Create INSTALL.sh helper script
cat > "$ARCHIVE_DIR/INSTALL.sh" << 'EOFINSTALL'
#!/bin/bash
# Quick Installation Helper
# ─────────────────────────────────────────────────────────────────────────────

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       Niri WM Dotfiles - Quick Installation              ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if in correct directory
if [ ! -f "SETUP_GUIDE.md" ]; then
    echo -e "${RED}✗ Please run this script from the dotfiles directory${NC}"
    exit 1
fi

echo -e "${BLUE}This script will:${NC}"
echo "  1. Check system dependencies"
echo "  2. Create required directories"
echo "  3. Run the setup wizard"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled"
    exit 1
fi

echo ""
echo -e "${BLUE}Step 1: Checking dependencies...${NC}"

MISSING=()
for cmd in niri rofi dunst kitty wal; do
    if ! command -v $cmd &> /dev/null; then
        MISSING+=("$cmd")
    fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
    echo -e "${RED}✗ Missing packages: ${MISSING[*]}${NC}"
    echo ""
    echo "Install them with:"
    echo "  Arch: sudo pacman -S ${MISSING[*]}"
    echo "  Debian: sudo apt install ${MISSING[*]}"
    echo "  Fedora: sudo dnf install ${MISSING[*]}"
    exit 1
fi

echo -e "${GREEN}✓ All dependencies found${NC}"

echo ""
echo -e "${BLUE}Step 2: Preparing wallpaper...${NC}"

if [ ! -d "$HOME/Pictures" ]; then
    mkdir -p "$HOME/Pictures"
    echo -e "${GREEN}✓ Created ~/Pictures${NC}"
fi

if [ ! -f "$HOME/Pictures/wallpaper.jpg" ]; then
    echo -e "${RED}⚠ No wallpaper found at ~/Pictures/wallpaper.jpg${NC}"
    echo ""
    echo "Please provide a wallpaper:"
    echo "  1. Place an image at: ~/Pictures/wallpaper.jpg"
    echo "  2. Or copy: cp /path/to/image.jpg ~/Pictures/wallpaper.jpg"
    echo ""
    read -p "Continue with placeholder? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
    # Create simple placeholder
    convert -size 1920x1080 xc:#1e1e2e "$HOME/Pictures/wallpaper.jpg" 2>/dev/null || \
    echo "# Placeholder" > "$HOME/Pictures/wallpaper.jpg"
else
    echo -e "${GREEN}✓ Wallpaper found${NC}"
fi

echo ""
echo -e "${BLUE}Step 3: Running setup wizard...${NC}"
echo ""

chmod +x ./scripts/niri-session-setup.sh
./scripts/niri-session-setup.sh

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo "Next:"
echo "  1. Log out and log back in"
echo "  2. Select 'Niri' from login manager"
echo "  3. Press Super+Escape to see keybindings"
echo ""
EOFINSTALL

chmod +x "$ARCHIVE_DIR/INSTALL.sh"

echo -e "${GREEN}✓ Files prepared${NC}"
echo ""

# ─── Create archive ───────────────────────────────────────────────────────
echo -e "${BLUE}Creating archive: $ARCHIVE_NAME${NC}"

cd "$TEMP_DIR"
tar -czf "$ARCHIVE_NAME" dotfiles/
ARCHIVE_PATH="$TEMP_DIR/$ARCHIVE_NAME"

# ─── Calculate size ───────────────────────────────────────────────────────
SIZE=$(du -h "$ARCHIVE_PATH" | cut -f1)
CHECKSUM=$(sha256sum "$ARCHIVE_PATH" | cut -d' ' -f1)

echo -e "${GREEN}✓ Archive created${NC}"
echo ""

# ─── Move to project root ──────────────────────────────────────────────────
mv "$ARCHIVE_PATH" "$PROJECT_ROOT/$ARCHIVE_NAME"
echo "Archive saved: ${GREEN}$PROJECT_ROOT/$ARCHIVE_NAME${NC}"
echo "Size: $SIZE"
echo "SHA256: $CHECKSUM"
echo ""

# ─── Create checksum file ──────────────────────────────────────────────────
echo "$CHECKSUM  $ARCHIVE_NAME" > "$PROJECT_ROOT/${ARCHIVE_NAME}.sha256"
echo "Checksum file: ${GREEN}${ARCHIVE_NAME}.sha256${NC}"

# ─── Create summary file ───────────────────────────────────────────────────
cat > "$PROJECT_ROOT/ARCHIVE_INFO.txt" << EOF
Dotfiles Archive Information
════════════════════════════════════════════════════════════════════════════════

Archive: $ARCHIVE_NAME
Created: $(date)
Size: $SIZE
Checksum (SHA256): $CHECKSUM

Contents:
  - niri/              Niri WM configuration + GLSL animations
  - quickshell/        QML bar with 9 widgets
  - pywal/             Dynamic theming system
  - scripts/           Setup and helper scripts
  - rofi/              App launcher configuration
  - dunst/             Notification daemon configuration
  - kitty/             Terminal configuration
  - awesome/           Classic X11 fallback
  - x11-session/       X11 session support
  - Documentation:
    * SETUP_GUIDE.md               ← START HERE
    * MIGRATION_NOTES.md           (detailed guide)
    * TESTING_CHECKLIST.md         (verify installation)
    * IMPLEMENTATION_SUMMARY.md    (architecture)
    * README.md                    (archive readme)

Quick Start:
════════════════════════════════════════════════════════════════════════════════

1. Extract:
   tar -xzf $ARCHIVE_NAME

2. Install:
   cd dotfiles
   ./INSTALL.sh

3. Reboot and select Niri from login manager

Requirements:
════════════════════════════════════════════════════════════════════════════════

- Wayland-capable Linux system
- Required packages: niri, rofi, dunst, kitty, pywal, starship
- GPU drivers (or llvmpipe for CPU)
- Display manager with Wayland support (SDDM, GDM, LightDM)

For detailed instructions, see SETUP_GUIDE.md inside the archive.

Verification:
════════════════════════════════════════════════════════════════════════════════

Verify archive integrity:
  sha256sum -c ${ARCHIVE_NAME}.sha256

EOF

echo -e "${BLUE}Archive info saved: ${GREEN}ARCHIVE_INFO.txt${NC}"
echo ""

# ─── Cleanup ───────────────────────────────────────────────────────────────
rm -rf "$TEMP_DIR"

echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Archive Creation Complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo "Files ready for distribution:"
echo "  1. ${GREEN}$ARCHIVE_NAME${NC}"
echo "  2. ${GREEN}${ARCHIVE_NAME}.sha256${NC} (for integrity verification)"
echo "  3. ${GREEN}ARCHIVE_INFO.txt${NC} (information file)"
echo ""
echo "Share these files with others to let them install Niri WM!"
echo ""
echo "To verify archive after download:"
echo "  ${YELLOW}sha256sum -c ${ARCHIVE_NAME}.sha256${NC}"
echo ""
