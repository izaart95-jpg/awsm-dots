// Notification Center Widget
// ─────────────────────────────────────────────────────────────────────────────
// Displays recent notifications from Dunst
// Currently a stub - full implementation would integrate with D-Bus
// ─────────────────────────────────────────────────────────────────────────────

import QtQuick

Item {
    id: notificationCenter
    
    required property var theme
    
    // Stub properties
    property list<var> notifications: []
    property int notificationCount: 0
    
    visible: notificationCount > 0
    
    Text {
        anchors.centerIn: parent
        
        text: notificationCenter.notificationCount > 0 
            ? notificationCenter.notificationCount + " ●" 
            : ""
        
        color: parent.theme.warning
        font.family: parent.theme.fontMono
        font.pixelSize: parent.theme.sizeSmall
    }
    
    // ─── TODO: Integrate with D-Bus notification system ────────────────
    // This would connect to org.freedesktop.Notifications and show
    // incoming notifications in a list format
}
