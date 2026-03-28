// Layout Indicator Widget
// ─────────────────────────────────────────────────────────────────────────────
// Shows current Niri window layout (tiling mode)
// Click to cycle through available layouts
// ─────────────────────────────────────────────────────────────────────────────

import QtQuick

Rectangle {
    id: layoutWidget
    
    required property var theme
    
    property string layoutName: "tile"  // "tile", "floating", "fullscreen", etc.
    
    color: theme.buttonBackground
    radius: theme.borderRadius
    border.width: theme.borderWidthThin
    border.color: theme.border
    
    width: 32
    height: 32
    
    Text {
        anchors.centerIn: parent
        
        text: {
            switch (layoutWidget.layoutName) {
                case "tile": return "󰪑"      // Tiling layout
                case "floating": return "󱕾"  // Floating layout
                case "fullscreen": return "󰊓"  // Fullscreen
                default: return "█"             // Generic layout
            }
        }
        
        color: theme.buttonForeground
        font.family: theme.fontSans
        font.pixelSize: theme.sizeBase + 2
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
            // Cycle to next layout
            var layouts = ["tile", "floating", "fullscreen"]
            var currentIndex = layouts.indexOf(layoutWidget.layoutName)
            var nextIndex = (currentIndex + 1) % layouts.length
            layoutWidget.layoutName = layouts[nextIndex]
            
            // Would send command to Niri to change layout here
        }
    }
}
