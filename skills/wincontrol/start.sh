#!/bin/bash
# Start WinControl Server from WSL (runs on Windows via PowerShell)
# Usage: ./start.sh

cd "$(dirname "$0")"

WIN_PATH=$(wslpath -w "$PWD/server.py")

# Create /tmp/wincontrol in WSL first
mkdir -p /tmp/wincontrol

echo "Starting WinControl Server on Windows..."
echo ""

# Check if PowerShell is available
if ! command -v powershell.exe &> /dev/null; then
    echo "Error: powershell.exe not found"
    exit 1
fi

# Check if already running
if curl -s http://localhost:8767/ping > /dev/null 2>&1; then
    echo "WinControl is already running!"
    echo "API: http://localhost:8767"
    echo "Frames: /tmp/wincontrol/"
    exit 0
fi

# Check if WSL path is accessible from Windows
WSL_NAME=$(powershell.exe -Command "(Get-ChildItem 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss' | Get-ItemProperty).DistributionName" 2>/dev/null | head -1 | tr -d '\r')
if [ -z "$WSL_NAME" ]; then
    WSL_NAME="Ubuntu"
fi

# Install dependencies and start server in background
powershell.exe -WindowStyle Hidden -Command "
    cd '$PWD'
    pip install pywin32 pillow mss -q 2>$null
    Start-Process python -ArgumentList '$WIN_PATH' -WindowStyle Hidden
" &

# Wait for startup
sleep 3

# Check if started
if curl -s http://localhost:8767/ping > /dev/null 2>&1; then
    echo ""
    echo "✅ WinControl started successfully!"
    echo ""
    echo "Actions API:    http://localhost:8767"
    echo "Frames:         /tmp/wincontrol/"
    echo ""
    echo "Quick test:"
    echo "  curl http://localhost:8767/screen"
    echo "  curl http://localhost:8767/frames"
    echo ""
    echo "To stop: ./stop.sh or pkill -f 'python.*server.py'"
else
    echo "❌ Failed to start WinControl (server may still be starting)"
    echo "Try: curl http://localhost:8767/ping"
    exit 1
fi
