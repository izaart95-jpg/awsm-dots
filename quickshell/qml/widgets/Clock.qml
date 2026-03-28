// Clock Widget
// ─────────────────────────────────────────────────────────────────────────────
// Displays current time, updates every second
// ─────────────────────────────────────────────────────────────────────────────

import QtQuick

Item {
    id: clock
    
    required property var theme
    
    Text {
        id: timeDisplay
        anchors.centerIn: parent
        
        color: theme.textPrimary
        font.family: theme.fontMono
        font.pointSize: theme.sizeBase
        
        text: Qt.formatTime(new Date(), "hh:mm")
    }
    
    // ─── Timer to update every second ──────────────────────────────────
    Timer {
        interval: 1000
        running: true
        repeat: true
        
        onTriggered: {
            timeDisplay.text = Qt.formatTime(new Date(), "hh:mm")
        }
    }
}
