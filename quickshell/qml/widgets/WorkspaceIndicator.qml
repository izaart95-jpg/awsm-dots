// Workspace Indicator Widget
// ─────────────────────────────────────────────────────────────────────────────
// Shows current Niri workspace number and allows switching
// Displays 1-5 workspace indicators with current highlighted
// ─────────────────────────────────────────────────────────────────────────────

import QtQuick
import QtQuick.Layouts

Rectangle {
    id: wsIndicator
    
    required property var theme
    
    color: theme.widgetBackground
    radius: theme.borderRadius
    border.width: theme.borderWidthThin
    border.color: theme.border
    
    property int currentWorkspace: 0  // 0-indexed, 0-4 for 5 workspaces
    
    RowLayout {
        anchors.centerIn: parent
        anchors.margins: theme.spaceSm
        spacing: theme.gapXs
        
        // Create 5 workspace indicators
        Repeater {
            model: 5
            
            Rectangle {
                id: wsButton
                
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
                
                radius: theme.borderRadius
                color: index === wsIndicator.currentWorkspace 
                    ? theme.primary 
                    : theme.border
                border.width: 0
                
                Text {
                    anchors.centerIn: parent
                    text: index + 1
                    
                    color: index === wsIndicator.currentWorkspace 
                        ? theme.widgetBackground 
                        : theme.textMuted
                    
                    font.family: theme.fontMono
                    font.pixelSize: 8
                    font.bold: true
                }
                
                MouseArea {
                    anchors.fill: parent
                    
                    onClicked: {
                        wsIndicator.currentWorkspace = index
                        // Send workspace switch command to Niri via IPC or keybinding
                        // For now, this is visual only
                        // Integration with Niri IPC would go here
                    }
                }
            }
        }
    }
}
