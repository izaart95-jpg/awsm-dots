#!/bin/bash
# Apply Theme Script
# ─────────────────────────────────────────────────────────────────────────────
# Applies Pywal-generated theme files to all components
# Reloads services to apply changes immediately
# Usage: ./scripts/apply-theme.sh
# ─────────────────────────────────────────────────────────────────────────────

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

PYWAL_GENERATED="$PROJECT_ROOT/pywal/generated"

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Applying Pywal Theme to All Components${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"

# Check if generated files exist
if [ ! -d "$PYWAL_GENERATED" ]; then
    echo -e "${RED}✗ Error: Generated themes not found at $PYWAL_GENERATED${NC}"
    echo "Run './pywal/setup.sh [wallpaper]' first"
    exit 1
fi

echo ""
echo -e "${BLUE}Copying theme files to component configs...${NC}"

# ─── Niri (KDL) ────────────────────────────────────────────────────────────
NIRI_CONFIG="$PROJECT_ROOT/niri/config.kdl"
if [ -f "$PYWAL_GENERATED/colors.kdl" ]; then
    # Niri uses colors.kdl - could be included or merged
    echo -e "  ${GREEN}✓${NC} colors.kdl (for reference)"
else
    echo -e "  ${RED}✗${NC} colors.kdl not generated"
fi

# ─── Quickshell (QML) ───────────────────────────────────────────────────────
QS_THEME_DIR="$PROJECT_ROOT/quickshell/qml"
if [ ! -d "$QS_THEME_DIR" ]; then
    mkdir -p "$QS_THEME_DIR"
fi

if [ -f "$PYWAL_GENERATED/quickshell-colors.qml" ]; then
    cp "$PYWAL_GENERATED/quickshell-colors.qml" "$QS_THEME_DIR/colors.qml"
    echo -e "  ${GREEN}✓${NC} Copied to quickshell/qml/colors.qml"
else
    echo -e "  ${RED}✗${NC} quickshell-colors.qml not generated"
fi

# ─── Rofi (Rasi) ────────────────────────────────────────────────────────────
ROFI_DIR="$PROJECT_ROOT/rofi/shared"
if [ ! -d "$ROFI_DIR" ]; then
    mkdir -p "$ROFI_DIR"
fi

if [ -f "$PYWAL_GENERATED/rofi-colors.rasi" ]; then
    cp "$PYWAL_GENERATED/rofi-colors.rasi" "$ROFI_DIR/colors.rasi"
    echo -e "  ${GREEN}✓${NC} Copied to rofi/shared/colors.rasi"
else
    echo -e "  ${RED}✗${NC} rofi-colors.rasi not generated"
fi

# ─── Dunst (Config) ─────────────────────────────────────────────────────────
DUNST_DIR="$PROJECT_ROOT/dunst"
if [ -f "$PYWAL_GENERATED/dunst-colors.conf" ]; then
    cp "$PYWAL_GENERATED/dunst-colors.conf" "$DUNST_DIR/pywal-colors.conf"
    echo -e "  ${GREEN}✓${NC} Copied to dunst/pywal-colors.conf"
else
    echo -e "  ${RED}✗${NC} dunst-colors.conf not generated"
fi

# ─── Kitty (Conf) ───────────────────────────────────────────────────────────
KITTY_DIR="$PROJECT_ROOT/kitty"
if [ -f "$PYWAL_GENERATED/kitty-colors.conf" ]; then
    cp "$PYWAL_GENERATED/kitty-colors.conf" "$KITTY_DIR/pywal-colors.conf"
    echo -e "  ${GREEN}✓${NC} Copied to kitty/pywal-colors.conf"
else
    echo -e "  ${RED}✗${NC} kitty-colors.conf not generated"
fi

# ─── Starship (TOML) ────────────────────────────────────────────────────────
if [ -f "$PYWAL_GENERATED/starship-colors.toml" ]; then
    cp "$PYWAL_GENERATED/starship-colors.toml" "$PROJECT_ROOT/starship-colors.toml"
    echo -e "  ${GREEN}✓${NC} Copied to starship-colors.toml"
else
    echo -e "  ${RED}✗${NC} starship-colors.toml not generated"
fi

# ─── Reload Services ────────────────────────────────────────────────────────
echo ""
echo -e "${BLUE}Reloading services...${NC}"

# Dunst
if command -v dunst &> /dev/null; then
    pkill -HUP dunst 2>/dev/null || true
    sleep 0.2 && dunst &
    echo -e "  ${GREEN}✓${NC} Dunst restarted"
fi

# Quickshell (if running via systemd user service)
if systemctl --user is-active --quiet quickshell 2>/dev/null; then
    systemctl --user restart quickshell
    echo -e "  ${GREEN}✓${NC} Quickshell restarted"
fi

# Niri (if running)
if [ -n "$WAYLAND_DISPLAY" ] && command -v niri &> /dev/null; then
    # Note: Niri doesn't have a native reload command yet
    # Configuration changes require manual reload or restart
    echo -e "  ${GREEN}ℹ${NC} Niri: Restart required to apply config changes"
fi

echo ""
echo -e "${GREEN}✓ Theme application complete!${NC}"
echo ""
echo "Summary:"
echo "  - Component theme files updated"
echo "  - Dunst reloaded"
echo "  - Quickshell restarted (if running)"
echo "  - To apply Niri config: Restart Niri or reload manually"
echo ""
