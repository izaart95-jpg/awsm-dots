// Press Effect
// ─────────────────────────────────────────────────────────────────────────────
// Scale transform on press for tactile feedback
// ─────────────────────────────────────────────────────────────────────────────

import QtQuick

Behavior on scale {
    NumberAnimation {
        duration: 100
        easing.type: Easing.OutQuad
    }
}
