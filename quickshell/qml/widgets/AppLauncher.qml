// App Launcher Widget
// ─────────────────────────────────────────────────────────────────────────────
// Clickable button that triggers 'rofi -show drun' app launcher
// Shows app icon or text
// ─────────────────────────────────────────────────────────────────────────────

import QtQuick
import QtQuick.Layouts

Rectangle {
    id: launcher
    
    required property var theme
    
    color: theme.buttonBackground
    radius: theme.borderRadius
    border.width: theme.borderWidthThin
    border.color: theme.border
    
    // ─── Hover state ──────────────────────────────────────────────────
    property bool hovered: false
    
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 0
        
        Text {
            Layout.alignment: Qt.AlignCenter
            text: "󰣇"  // Nerd Font app icon
            
            color: theme.buttonForeground
            font.family: theme.fontSans
            font.pixelSize: theme.sizeBase + 2
        }
    }
    
    // ─── Interactive states ───────────────────────────────────────────
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        
        onEntered: {
            launcher.hovered = true
            parent.color = theme.buttonHover
        }
        
        onExited: {
            launcher.hovered = false
            parent.color = theme.buttonBackground
        }
        
        onClicked: {
            // Trigger rofi app launcher
            Qt.callLater(function() {
                var proc = new Process()
                proc.start("rofi", ["-show", "drun"])
            })
        }
    }
}
