// Main Quickshell Bar
// ─────────────────────────────────────────────────────────────────────────────
// Top bar with widgets: launcher, clock, workspace indicator, system stats
// Island mode (floating) by default; can toggle full-width
// ─────────────────────────────────────────────────────────────────────────────

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

import "theme.qml" as ThemeModule
import "widgets" as Widgets
import "effects" as Effects

ShellRoot {
    id: root
    
    readonly property var theme: ThemeModule.QtObject {}
    
    // ─── Bar Configuration ────────────────────────────────────────────────
    property bool islandMode: true
    property bool floating: islandMode
    
    PanelWindow {
        id: panel
        
        anchors.centerX: parent.centerX
        anchors.top: parent.top
        anchors.topMargin: theme.islandMarginTop
        anchors.leftMargin: theme.islandMarginSide
        anchors.rightMargin: theme.islandMarginSide
        
        width: islandMode ? implicitWidth : parent.width
        height: theme.barHeight
        
        color: theme.widgetBackground
        
        layer.enabled: islandMode
        layer.effect: ShaderEffect {
            id: bgShader
            
            property color bgColor: theme.widgetBackground
            property real opacity: theme.opacityHigh
            property int radius: theme.islandBorderRadius
            
            fragmentShader: "
                uniform lowp sampler2D source;
                uniform lowp vec4 bgColor;
                uniform lowp float opacity;
                uniform highp float radius;
                varying highp vec2 qt_TexCoord0;
                
                void main() {
                    lowp vec4 tex = texture2D(source, qt_TexCoord0);
                    gl_FragColor = vec4(bgColor.rgb, opacity);
                }
            "
        }
        
        // ─── Border for island mode ───────────────────────────────────────
        border.width: islandMode ? theme.borderWidthThin : 0
        border.color: theme.border
        
        // ─── Bar Contents ─────────────────────────────────────────────────
        RowLayout {
            anchors.fill: parent
            anchors.margins: theme.barPadding
            spacing: theme.barGap
            
            // ─── Left Section: Launcher + Workspace Indicator ─────────────
            RowLayout {
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                spacing: theme.barGap
                
                // App Launcher Icon
                Widgets.AppLauncher {
                    Layout.preferredWidth: theme.barItemHeight
                    Layout.preferredHeight: theme.barItemHeight
                    theme: root.theme
                }
                
                // Workspace/Tag Indicator
                Widgets.WorkspaceIndicator {
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: theme.barItemHeight
                    theme: root.theme
                }
            }
            
            // ─── Center Section: Clock ────────────────────────────────────
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignCenter
                
                Widgets.Clock {
                    anchors.centerIn: parent
                    theme: root.theme
                }
            }
            
            // ─── Right Section: System Widgets ────────────────────────────
            RowLayout {
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                spacing: theme.barGap
                
                // WiFi Status
                Widgets.WiFi {
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: theme.barItemHeight
                    theme: root.theme
                }
                
                // System Stats (CPU, RAM)
                Widgets.SystemStats {
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: theme.barItemHeight
                    theme: root.theme
                    showCpu: false
                    showRam: true
                }
                
                // Volume Control
                Widgets.Volume {
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: theme.barItemHeight
                    theme: root.theme
                }
                
                // Battery (if available)
                Widgets.Battery {
                    Layout.preferredWidth: 35
                    Layout.preferredHeight: theme.barItemHeight
                    theme: root.theme
                    visible: hasBattery
                }
                
                // Layout Indicator
                Widgets.LayoutIcon {
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: theme.barItemHeight
                    theme: root.theme
                }
            }
        }
    }
    
    // ─── Notification Center (Optional) ────────────────────────────────────
    // Widgets.NotificationCenter {
    //     theme: root.theme
    // }
}
