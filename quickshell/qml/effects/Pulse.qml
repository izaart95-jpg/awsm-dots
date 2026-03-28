// Pulse Effect
// ─────────────────────────────────────────────────────────────────────────────
// Opacity oscillation for attention-grabbing animations
// ─────────────────────────────────────────────────────────────────────────────

import QtQuick

Item {
    id: pulseEffect
    
    // Usage: target.effect: pulseEffect to apply pulsing animation
    SequentialAnimationGroup {
        running: true
        loops: Animation.Infinite
        
        NumberAnimation {
            target: pulseEffect
            property: "opacity"
            from: 0.7
            to: 1.0
            duration: 500
            easing.type: Easing.InOutQuad
        }
        
        NumberAnimation {
            target: pulseEffect
            property: "opacity"
            from: 1.0
            to: 0.7
            duration: 500
            easing.type: Easing.InOutQuad
        }
    }
}
