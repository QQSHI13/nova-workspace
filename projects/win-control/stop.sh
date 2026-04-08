#!/bin/bash
# Stop WinControl Server

echo "Stopping WinControl..."
powershell.exe -Command "Get-Process python -ErrorAction SilentlyContinue | Where-Object {\$_.CommandLine -like '*server.py*'} | Stop-Process -Force" 2>/dev/null
echo "Done"
