// Hover Effect
// ─────────────────────────────────────────────────────────────────────────────
// Fade opacity on hover
// ─────────────────────────────────────────────────────────────────────────────

import QtQuick

Behavior on opacity {
    NumberAnimation {
        duration: 150
        easing.type: Easing.OutQuad
    }
}
