#!/bin/bash
# Stop WinControl Server

POWERSHELL="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"

echo "Stopping WinControl..."

# Kill the server process
$POWERSHELL -Command "Get-Process python -ErrorAction SilentlyContinue | Where-Object {\$_.CommandLine -like '*wincontrol*'} | Stop-Process -Force" 2>/dev/null

# Clean up frames
rm -rf /tmp/wincontrol/*.jpg 2>/dev/null

# Verify stopped
if curl -s --max-time 1 http://localhost:8767/ping > /dev/null 2>&1; then
    echo "⚠️  Server may still be running"
else
    echo "✅ WinControl stopped"
fi
