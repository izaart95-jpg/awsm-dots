#!/bin/bash
# Xwayland Mixed Session Launcher
# ─────────────────────────────────────────────────────────────────────────────
# Allows running X11 applications within Niri/Wayland session
# Automatically manages Xwayland instance
# ─────────────────────────────────────────────────────────────────────────────

set -e

XWAYLAND_SOCKET="${XDG_RUNTIME_DIR}/Xwayland-${DISPLAY}"
XWAYLAND_LOG="${XDG_RUNTIME_DIR}/Xwayland.log"

# Check if Xwayland is already running
if [ -S "$XWAYLAND_SOCKET" ]; then
    echo "Xwayland already running on $DISPLAY"
    exit 0
fi

echo "Starting Xwayland on $DISPLAY..."

# Start Xwayland with specified display number
Xwayland :"${DISPLAY#:}" \
    -rootless \
    -listen unix \
    > "$XWAYLAND_LOG" 2>&1 &

XWAYLAND_PID=$!

# Wait for Xwayland to be ready
sleep 1

if ps -p $XWAYLAND_PID > /dev/null; then
    echo "✓ Xwayland started (PID: $XWAYLAND_PID)"
    # Keep process alive
    wait $XWAYLAND_PID
else
    echo "✗ Failed to start Xwayland"
    cat "$XWAYLAND_LOG"
    exit 1
fi
