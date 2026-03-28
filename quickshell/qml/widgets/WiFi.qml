// WiFi Status Widget
// ─────────────────────────────────────────────────────────────────────────────
// Displays WiFi connectivity status and signal strength
// Updates every 5 seconds
// ─────────────────────────────────────────────────────────────────────────────

import QtQuick

Text {
    id: wifiWidget
    
    required property var theme
    
    property bool connected: true
    property int signalStrength: 75  // 0-100
    
    text: {
        if (!connected) return "󰖪"      // WiFi off
        if (signalStrength > 75) return "󰖩"   // Full signal
        if (signalStrength > 50) return "󰖧"   // Strong signal
        if (signalStrength > 25) return "󰖨"   // Weak signal
        return "󰖪"                           // Very weak/no signal
    }
    
    color: connected ? theme.success : theme.error
    font.family: theme.fontSans
    font.pixelSize: theme.sizeSmall + 2
    
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    
    // ─── Update WiFi status every 5 seconds ────────────────────────────
    Timer {
        interval: 5000
        running: true
        repeat: true
        
        onTriggered: {
            // In production, would check network status via nmcli or similar
            // wifiWidget.connected = checkWiFiConnection()
            // wifiWidget.signalStrength = getSignalStrength()
        }
    }
}
