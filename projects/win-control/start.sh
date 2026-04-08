#!/bin/bash
# Start WinControl Server from WSL (runs on Windows via PowerShell)
# Usage: ./start.sh

cd "$(dirname "$0")"

WIN_PATH=$(wslpath -w "$PWD/server.py")

echo "Starting WinControl Server on Windows..."
echo ""

# Check if PowerShell is available
if ! command -v powershell.exe &> /dev/null; then
    echo "Error: powershell.exe not found"
    exit 1
fi

# Check if already running
if powershell.exe -Command "Get-Process python -ErrorAction SilentlyContinue | Where-Object {$_.CommandLine -like '*server.py*'}" 2>/dev/null | grep -q python; then
    echo "WinControl is already running!"
    echo "Display: http://localhost:8766"
    echo "Actions: http://localhost:8767"
    exit 0
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
    echo "Display (view only):  http://localhost:8766"
    echo "Actions API:          http://localhost:8767"
    echo ""
    echo "Action endpoints:"
    echo "  POST /click    {x: 100, y: 200, button: 'left'}"
    echo "  POST /drag     {x1: 100, y1: 200, x2: 300, y2: 400}"
    echo "  POST /scroll   {x: 100, y: 200, direction: 'down', amount: 3}"
    echo "  POST /type     {text: 'Hello World'}"
    echo "  POST /key      {key: 'Enter'}"
    echo "  POST /combo    {keys: ['Ctrl', 'C']}"
    echo "  GET  /screen   (returns screen dimensions)"
    echo ""
    echo "To stop: ./stop.sh or pkill -f 'python.*server.py'"
else
    echo "❌ Failed to start WinControl (server may still be starting)"
    echo "Try: curl http://localhost:8767/ping"
    exit 1
fi
