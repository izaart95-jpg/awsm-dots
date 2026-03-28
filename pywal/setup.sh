#!/bin/bash
# Pywal Setup & Theme Generation Script
# ─────────────────────────────────────────────────────────────────────────────
# Initializes Pywal and generates theme files for all components
# Usage: ./pywal/setup.sh [wallpaper_path]
# ─────────────────────────────────────────────────────────────────────────────

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
PYWAL_DIR="$CONFIG_HOME/pywal"
TEMPLATES_DIR="$SCRIPT_DIR/templates"
OUTPUT_DIR="$SCRIPT_DIR/generated"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Default wallpaper
WALLPAPER="${1:-$HOME/Pictures/wallpaper.jpg}"

if [ ! -f "$WALLPAPER" ]; then
    echo "✗ Error: Wallpaper not found: $WALLPAPER"
    exit 1
fi

echo "Initializing Pywal with wallpaper: $WALLPAPER"

# Initialize Pywal colorscheme from wallpaper
wal -i "$WALLPAPER" --backend colorz

# Source Pywal-generated colors
source "$PYWAL_DIR/colorscheme.sh"

echo "✓ Pywal initialized"
echo "Generated colors:"
echo "  Color 0: $color0  | Color 8: $color8"
echo "  Color 1: $color1  | Color 9: $color9"
echo "  Color 2: $color2  | Color 10: $color10"
echo "  Color 3: $color3  | Color 11: $color11"
echo "  Color 4: $color4  | Color 12: $color12"
echo "  Color 5: $color5  | Color 13: $color13"
echo "  Color 6: $color6  | Color 14: $color14"
echo "  Color 7: $color7  | Color 15: $color15"

# ─── Generate component-specific configs from templates ──────────────────────

echo "Generating component themes from templates..."

# Utility function: substitute colors in template
substitute_colors() {
    local template="$1"
    local output="$2"
    
    if [ ! -f "$template" ]; then
        echo "  ✗ Template not found: $template"
        return 1
    fi
    
    # Use Pywal's environment variables to substitute in template
    export color0 color1 color2 color3 color4 color5 color6 color7 \
           color8 color9 color10 color11 color12 color13 color14 color15 \
           foreground background
    
    envsubst < "$template" > "$output"
    echo "  ✓ Generated: $(basename $output)"
}

# Generate Niri colors (KDL format)
substitute_colors "$TEMPLATES_DIR/colors.kdl.template" \
    "$OUTPUT_DIR/colors.kdl"

# Generate Quickshell theme (QML format)
substitute_colors "$TEMPLATES_DIR/quickshell-colors.qml.template" \
    "$OUTPUT_DIR/quickshell-colors.qml"

# Generate Rofi colors (Rasi format)
substitute_colors "$TEMPLATES_DIR/rofi-colors.rasi.template" \
    "$OUTPUT_DIR/rofi-colors.rasi"

# Generate Dunst colors
substitute_colors "$TEMPLATES_DIR/dunst-colors.template" \
    "$OUTPUT_DIR/dunst-colors.conf"

# Generate Kitty colors (Conf format)
substitute_colors "$TEMPLATES_DIR/kitty-colors.conf.template" \
    "$OUTPUT_DIR/kitty-colors.conf"

# Generate Starship colors (TOML format)
substitute_colors "$TEMPLATES_DIR/starship-colors.toml.template" \
    "$OUTPUT_DIR/starship-colors.toml"

# Generate Font configuration
substitute_colors "$TEMPLATES_DIR/font-config.template" \
    "$OUTPUT_DIR/font-config.kdl"

echo ""
echo "✓ All component themes generated in: $OUTPUT_DIR"
echo ""
echo "Next steps:"
echo "  1. Run: scripts/apply-theme.sh"
echo "  2. Reload Niri and Quickshell"
