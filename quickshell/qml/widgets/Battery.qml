// Battery Widget
// ─────────────────────────────────────────────────────────────────────────────
// Displays battery percentage and charging status
// Updates every 30 seconds
// ─────────────────────────────────────────────────────────────────────────────

import QtQuick
import QtQuick.Layouts

Rectangle {
    id: batteryWidget
    
    required property var theme
    
    property int percentage: 85
    property bool charging: false
    property bool hasBattery: true
    
    color: theme.buttonBackground
    radius: theme.borderRadius
    border.width: theme.borderWidthThin
    border.color: {
        // Color changes based on charge level
        if (percentage > 75) return theme.success
        if (percentage > 40) return theme.border
        if (percentage > 20) return theme.warning
        return theme.error
    }
    
    RowLayout {
        anchors.centerIn: parent
        anchors.margins: 2
        spacing: 2
        
        Text {
            text: {
                if (charging) {
                    if (percentage > 75) return "󰂅"   // Charging 80%
                    if (percentage > 50) return "󰂄"   // Charging 60%
                    if (percentage > 25) return "󰂃"   // Charging 40%
                    return "󰂂"                         // Charging 20%
                } else {
                    if (percentage > 75) return "󰁹"   // Full
                    if (percentage > 50) return "󰂀"   // Mid
                    if (percentage > 25) return "󰂂"   // Low
                    return "󰂎"                         // Critical
                }
            }
            
            color: theme.buttonForeground
            font.family: theme.fontSans
            font.pixelSize: theme.sizeSmall + 2
        }
        
        Text {
            text: batteryWidget.percentage + "%"
            color: theme.buttonForeground
            font.family: theme.fontMono
            font.pixelSize: theme.sizeSmall
        }
    }
    
    // ─── Update battery status every 30 seconds ────────────────────────
    Timer {
        interval: 30000
        running: true
        repeat: true
        
        onTriggered: {
            // In production, would read from /sys/class/power_supply/BAT0/ or upower
            // batteryWidget.percentage = readBatteryPercentage()
            // batteryWidget.charging = readChargingStatus()
        }
    }
}
