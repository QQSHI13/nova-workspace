#!/bin/bash
# Start WinControl Server from WSL (runs on Windows via PowerShell)
# Usage: ./start.sh

cd "$(dirname "$0")"

# Use full path to PowerShell (more reliable in WSL2)
POWERSHELL="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"

# Create /tmp/wincontrol in WSL first
mkdir -p /tmp/wincontrol

echo "Starting WinControl Server on Windows..."
echo ""

# Check if PowerShell exists
if [ ! -f "$POWERSHELL" ]; then
    echo "Error: PowerShell not found at $POWERSHELL"
    exit 1
fi

# Check if already running
if curl -s --max-time 2 http://localhost:8767/ping > /dev/null 2>&1; then
    echo "✅ WinControl is already running!"
    echo "API: http://localhost:8767"
    echo "Frames: /tmp/wincontrol/"
    exit 0
fi

# Copy server to Windows Desktop (avoids WSL path issues)
WIN_USER=$($POWERSHELL -Command "\$env:USERNAME" 2>/dev/null | tr -d '\r')
if [ -z "$WIN_USER" ]; then
    WIN_USER="$USER"
fi

DESKTOP_PATH="/mnt/c/Users/$WIN_USER/Desktop"
SERVER_WIN="$DESKTOP_PATH/wincontrol_server.py"

echo "Copying server to Windows Desktop..."
cp server.py "$SERVER_WIN" 2>/dev/null

if [ ! -f "$SERVER_WIN" ]; then
    echo "❌ Failed to copy server to Desktop"
    echo "Trying alternative method..."
    # Fallback: use WSL path directly
    WIN_PATH=$(wslpath -w "$PWD/server.py")
else
    echo "✅ Server copied to Desktop"
    WIN_PATH="C:\\Users\\$WIN_USER\\Desktop\\wincontrol_server.py"
fi

# Install dependencies and start server
echo "Installing dependencies (if needed)..."
$POWERSHELL -Command "pip install pywin32 pillow mss -q 2>&1 | Out-Null; Start-Process python -ArgumentList '$WIN_PATH' -WindowStyle Hidden" &

# Wait for startup
echo "Waiting for server to start..."
sleep 4

# Check if started
for i in 1 2 3; do
    if curl -s --max-time 2 http://localhost:8767/ping > /dev/null 2>&1; then
        echo ""
        echo "✅ WinControl started successfully!"
        echo ""
        echo "Actions API:    http://localhost:8767"
        echo "Frames:         /tmp/wincontrol/"
        echo ""
        echo "Quick test:"
        echo "  curl http://localhost:8767/ping"
        echo "  curl -X POST http://localhost:8767/capture"
        echo ""
        echo "To stop: ./stop.sh"
        exit 0
    fi
    echo "  Attempt $i/3..."
    sleep 2
done

echo ""
echo "❌ Failed to start WinControl"
echo ""
echo "Try manual start:"
echo "  cp server.py /mnt/c/Users/\$USER/Desktop/"
echo "  /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -Command \"pip install pywin32 pillow mss -q; python C:\\Users\\%USERNAME%\\Desktop\\wincontrol_server.py\""
exit 1
