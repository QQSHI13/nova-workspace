#!/bin/bash
# Get latest frame path

LATEST=$(ls -t /tmp/wincontrol/frame_*.jpg 2>/dev/null | head -1)

if [ -z "$LATEST" ]; then
    # Trigger a capture
    curl -s http://localhost:8767/frame > /dev/null 2>&1
    sleep 0.5
    LATEST=$(ls -t /tmp/wincontrol/frame_*.jpg 2>/dev/null | head -1)
fi

echo "$LATEST"
