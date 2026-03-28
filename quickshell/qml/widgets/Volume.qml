// Volume Control Widget
// ─────────────────────────────────────────────────────────────────────────────
// Displays current volume level with icon
// Click to mute/unmute, scroll to adjust volume
// ─────────────────────────────────────────────────────────────────────────────

import QtQuick
import QtQuick.Layouts

Rectangle {
    id: volumeWidget
    
    required property var theme
    
    property int volume: 75
    property bool muted: false
    
    color: theme.buttonBackground
    radius: theme.borderRadius
    border.width: theme.borderWidthThin
    border.color: theme.border
    
    RowLayout {
        anchors.centerIn: parent
        anchors.margins: 2
        spacing: 2
        
        Text {
            id: volIcon
            
            text: {
                if (muted) return "󰖁"     // Nerd Font muted icon
                if (volume > 60) return "󰕾"   // high volume
                if (volume > 30) return "󰖉"   // medium volume
                return "󰕿"                     // low volume
            }
            
            color: theme.buttonForeground
            font.family: theme.fontSans
            font.pixelSize: theme.sizeSmall + 2
        }
        
        Text {
            text: muted ? "MUTE" : volume + "%"
            color: theme.buttonForeground
            font.family: theme.fontMono
            font.pixelSize: theme.sizeSmall
        }
    }
    
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        
        onEntered: {
            parent.color = theme.buttonHover
        }
        
        onExited: {
            parent.color = theme.buttonBackground
        }
        
        onClicked: {
            // Toggle mute
            volumeWidget.muted = !volumeWidget.muted
        }
        
        onWheel: {
            // Adjust volume with scroll wheel
            if (wheel.angleDelta.y > 0) {
                volumeWidget.volume = Math.min(100, volumeWidget.volume + 5)
            } else {
                volumeWidget.volume = Math.max(0, volumeWidget.volume - 5)
            }
        }
    }
}
