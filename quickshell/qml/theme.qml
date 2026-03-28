// Quickshell Theme Configuration
// ─────────────────────────────────────────────────────────────────────────────
// Central theme object imported by all widgets
// Colors are dynamically imported from Pywal-generated colors.qml
// ─────────────────────────────────────────────────────────────────────────────

import QtQuick
import "colors.qml" as Colors

QtObject {
    // ─── Color Palette ────────────────────────────────────────────────────
    readonly property QtObject colors: Colors.QtObject {}
    
    // Fallback colors if colors.qml not yet generated
    readonly property color foreground: colors.foreground ?? "#cdd6f4"
    readonly property color background: colors.background ?? "#1e1e2e"
    
    readonly property color primary: colors.primary ?? "#89b4fa"
    readonly property color accent: colors.accent ?? "#cba6f7"
    readonly property color success: colors.success ?? "#a6e3a1"
    readonly property color warning: colors.warning ?? "#f9e2af"
    readonly property color error: colors.error ?? "#f38ba8"
    readonly property color info: colors.info ?? "#89dceb"
    
    // Component-specific colors
    readonly property color buttonBackground: colors.buttonBackground ?? "#313244"
    readonly property color buttonForeground: colors.buttonForeground ?? "#cdd6f4"
    readonly property color buttonHover: colors.buttonHover ?? "#45475a"
    
    readonly property color widgetBackground: colors.widgetBackground ?? "#1e1e2e"
    readonly property color widgetForeground: colors.widgetForeground ?? "#cdd6f4"
    readonly property color border: colors.border ?? "#45475a"
    
    readonly property color textPrimary: colors.textPrimary ?? "#cdd6f4"
    readonly property color textSecondary: colors.textSecondary ?? "#a6adc8"
    readonly property color textMuted: colors.textMuted ?? "#6c7086"
    
    // ─── Typography ───────────────────────────────────────────────────────
    readonly property string fontMono: "JetBrainsMono Nerd Font"
    readonly property string fontSans: "Noto Sans"
    readonly property string fontEmoji: "Noto Color Emoji"
    
    readonly property int sizeBase: 10
    readonly property int sizeSmall: 8
    readonly property int sizeLarge: 12
    readonly property int sizeTitle: 14
    readonly property int sizeHeading: 16
    
    readonly property real lineHeightTight: 1.2
    readonly property real lineHeightNormal: 1.5
    readonly property real lineHeightLoose: 1.8
    
    // ─── Spacing & Layout ─────────────────────────────────────────────────
    readonly property int unit: 4
    
    readonly property int spaceXs: unit * 1      // 4px
    readonly property int spaceSm: unit * 2      // 8px
    readonly property int spaceMd: unit * 3      // 12px
    readonly property int spaceLg: unit * 4      // 16px
    readonly property int spaceXl: unit * 6      // 24px
    readonly property int space2xl: unit * 8     // 32px
    
    readonly property int gapXs: 2
    readonly property int gapSm: 4
    readonly property int gapMd: 8
    readonly property int gapLg: 12
    readonly property int gapXl: 16
    
    // ─── Borders & Radius ─────────────────────────────────────────────────
    readonly property int borderWidthThin: 1
    readonly property int borderWidthNormal: 2
    readonly property int borderWidthThick: 3
    readonly property int borderRadius: 4
    readonly property int borderRadiusLg: 8
    
    // ─── Bar Layout ────────────────────────────────────────────────────────
    readonly property int barHeight: 32
    readonly property int barPadding: spaceSm
    readonly property int barItemHeight: barHeight - (barPadding * 2)
    readonly property int barGap: gapSm
    
    // Island bar mode
    readonly property int islandMarginTop: spaceMd
    readonly property int islandMarginSide: spaceLg
    readonly property int islandBorderRadius: borderRadiusLg
    
    // ─── Animations ───────────────────────────────────────────────────────
    readonly property int durationShort: 150    // ms
    readonly property int durationNormal: 300
    readonly property int durationLong: 500
    
    // ─── Opacity ──────────────────────────────────────────────────────────
    readonly property real opacityFull: 1.0
    readonly property real opacityHigh: 0.9
    readonly property real opacityMid: 0.7
    readonly property real opacityLow: 0.5
    readonly property real opacityVeryLow: 0.3
    readonly property real opacityGhost: 0.1
}
