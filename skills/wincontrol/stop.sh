#!/bin/bash
# Stop WinControl Server

echo "Stopping WinControl..."

# Kill Python process on Windows (kills all python processes as fallback)
/mnt/c/Windows/System32/cmd.exe /c "taskkill /F /FI \"IMAGENAME eq python.exe\" /FI \"WINDOWTITLE eq *wincontrol*\" 2>nul || taskkill /F /IM python.exe 2>nul" 2>/dev/null

# Clean up frames
rm -rf /tmp/wincontrol/*.jpg 2>/dev/null

# Verify stopped
if curl -s --max-time 1 http://localhost:8767/ping > /dev/null 2>&1; then
    echo "⚠️  Server may still be running"
else
    echo "✅ WinControl stopped"
fi
