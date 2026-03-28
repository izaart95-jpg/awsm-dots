// System Stats Widget
// ─────────────────────────────────────────────────────────────────────────────
// Displays CPU usage and/or RAM usage
// Updates every 2 seconds
// ─────────────────────────────────────────────────────────────────────────────

import QtQuick
import QtQuick.Layouts

Item {
    id: sysStats
    
    required property var theme
    
    property bool showCpu: true
    property bool showRam: true
    
    // Placeholder values (in real implementation, would parse /proc or use systemd)
    property real cpuUsage: 25.5
    property real ramUsage: 60.3
    
    RowLayout {
        anchors.fill: parent
        anchors.margins: 2
        spacing: theme.gapSm
        
        // ─── CPU Display ──────────────────────────────────────────────────
        RowLayout {
            visible: sysStats.showCpu
            spacing: 2
            
            Text {
                text: "󰻠"  // Nerd Font CPU icon
                color: theme.textPrimary
                font.family: theme.fontSans
                font.pixelSize: theme.sizeSmall + 2
            }
            
            Text {
                text: Math.round(sysStats.cpuUsage) + "%"
                color: theme.textPrimary
                font.family: theme.fontMono
                font.pixelSize: theme.sizeSmall
            }
        }
        
        // ─── RAM Display ──────────────────────────────────────────────────
        RowLayout {
            visible: sysStats.showRam
            spacing: 2
            
            Text {
                text: "󰍛"  // Nerd Font RAM icon
                color: theme.textPrimary
                font.family: theme.fontSans
                font.pixelSize: theme.sizeSmall + 2
            }
            
            Text {
                text: Math.round(sysStats.ramUsage) + "%"
                color: theme.textPrimary
                font.family: theme.fontMono
                font.pixelSize: theme.sizeSmall
            }
        }
    }
    
    // ─── Update Timer (every 2 seconds) ────────────────────────────────
    Timer {
        interval: 2000
        running: true
        repeat: true
        
        onTriggered: {
            // Simulate CPU/RAM updates
            // In production, would parse /proc/stat, /proc/meminfo, etc.
            sysStats.cpuUsage = Math.random() * 100
            sysStats.ramUsage = Math.random() * 100
        }
    }
}
