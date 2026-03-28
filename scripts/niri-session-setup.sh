#!/bin/bash
# Niri Session Setup Script
# ─────────────────────────────────────────────────────────────────────────────
# Initialize Niri on first run: set up Pywal, apply theme, start services
# Run this after cloning/pulling the dotfiles
# Usage: ./scripts/niri-session-setup.sh
# ─────────────────────────────────────────────────────────────────────────────

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Functions
log_info() { echo -e "${BLUE}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_warn() { echo -e "${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Niri Session Initialization${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

# ─── Check prerequisites ───────────────────────────────────────────────────
log_info "Checking prerequisites..."

MISSING_DEPS=()

# Check for required commands
for cmd in niri rofi dunst kitty wal; do
    if ! command -v $cmd &> /dev/null; then
        MISSING_DEPS+=("$cmd")
    fi
done

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    log_warn "Missing packages: ${MISSING_DEPS[*]}"
    log_info "Install them with: pacman -S ${MISSING_DEPS[*]} (or your package manager)"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_error "Setup cancelled"
        exit 1
    fi
fi

log_success "Prerequisites checked"
echo ""

# ─── Initialize Pywal ──────────────────────────────────────────────────────
log_info "Initializing Pywal theme..."

WALLPAPER="$HOME/Pictures/wallpaper.jpg"

if [ ! -f "$WALLPAPER" ]; then
    log_warn "Default wallpaper not found at: $WALLPAPER"
    log_info "Searching for wallpaper in ~/Pictures..."
    
    # Find first image in Pictures
    WALLPAPER=$(find "$HOME/Pictures" -type f \( -iname "*.jpg" -o -iname "*.png" \) | head -1)
    
    if [ -z "$WALLPAPER" ]; then
        log_error "No wallpaper found in ~/Pictures"
        log_info "Please provide a wallpaper and run again"
        exit 1
    fi
    
    log_success "Found wallpaper: $WALLPAPER"
fi

# Run Pywal setup
if ! "$PROJECT_ROOT/pywal/setup.sh" "$WALLPAPER"; then
    log_error "Pywal initialization failed"
    exit 1
fi

log_success "Pywal initialized"
echo ""

# ─── Apply theme to all components ─────────────────────────────────────────
log_info "Applying theme to all components..."

if ! "$PROJECT_ROOT/scripts/apply-theme.sh"; then
    log_error "Theme application failed"
    exit 1
fi

log_success "Theme applied"
echo ""

# ─── Create required directories ───────────────────────────────────────────
log_info "Creating required directories..."

mkdir -p "$HOME/.config/niri"
mkdir -p "$HOME/.config/quickshell"
mkdir -p "$HOME/.local/share/niri"

log_success "Directories created"
echo ""

# ─── Copy/Link Niri config ────────────────────────────────────────────────
log_info "Setting up Niri configuration..."

NIRI_CONFIG="$HOME/.config/niri/config.kdl"

if [ -f "$NIRI_CONFIG" ]; then
    log_warn "Niri config already exists at: $NIRI_CONFIG"
    read -p "Overwrite? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cp "$PROJECT_ROOT/niri/config.kdl" "$NIRI_CONFIG"
        log_success "Niri config updated"
    fi
else
    cp "$PROJECT_ROOT/niri/config.kdl" "$NIRI_CONFIG"
    log_success "Niri config created"
fi

echo ""

# ─── Copy Quickshell config ────────────────────────────────────────────────
log_info "Setting up Quickshell..."

QS_CONFIG="$HOME/.config/quickshell/main.qml"

if [ ! -d "$HOME/.config/quickshell" ]; then
    mkdir -p "$HOME/.config/quickshell"
    cp "$PROJECT_ROOT/quickshell/qml/"* "$HOME/.config/quickshell/" 2>/dev/null || true
    log_success "Quickshell installed"
else
    log_warn "Quickshell already configured"
fi

echo ""

# ─── Verify X11 session support ────────────────────────────────────────────
log_info "Verifying X11 session support..."

if [ -f "$PROJECT_ROOT/x11-session/xinitrc" ]; then
    chmod +x "$PROJECT_ROOT/x11-session/xinitrc"
    log_success "X11 session available at: ~/.config/x11-session/xinitrc"
fi

echo ""

# ─── Display summary ───────────────────────────────────────────────────────
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo "Next steps:"
echo "  1. Log out and log back in (or restart your session)"
echo "  2. Select 'Niri' from the login manager session menu"
echo "  3. Or manually start with: niri"
echo ""
echo "After booting into Niri:"
echo "  - Press 'Super+d' to open app launcher (Rofi)"
echo "  - Press 'Super+Return' to open terminal (Kitty)"
echo "  - Press 'Super+Escape' to show keybindings"
echo "  - Press 'Super+Left/Right' to switch workspaces"
echo ""
echo "To change theme/wallpaper:"
echo "  wal -i ~/Pictures/your-wallpaper.jpg"
echo "  ./scripts/apply-theme.sh"
echo ""
echo "For X11 fallback session:"
echo "  startx ~/.config/x11-session/xinitrc"
echo ""
echo "Configuration files:"
echo "  - Niri: $NIRI_CONFIG"
echo "  - Quickshell: $HOME/.config/quickshell/"
echo "  - Rofi: $PROJECT_ROOT/rofi/"
echo "  - Dunst: $PROJECT_ROOT/dunst/"
echo "  - Kitty: $PROJECT_ROOT/kitty/"
echo ""
echo "Documentation:"
echo "  - Full guide: $PROJECT_ROOT/MIGRATION_NOTES.md"
echo ""
