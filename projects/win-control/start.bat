@echo off
REM Start WinControl Server on Windows
REM Run this in PowerShell or CMD

cd /d "%~dp0"

echo Starting WinControl Server...
echo.

REM Check if Python is available
python --version >nul 2>&1
if errorlevel 1 (
    echo Error: Python not found
    exit /b 1
)

REM Check if already running
tasklist | findstr "python.exe" | findstr "server.py" >nul
if not errorlevel 1 (
    echo WinControl is already running!
    echo Display: http://localhost:8766
    echo Actions: http://localhost:8767
    exit /b 0
)

REM Install dependencies if needed
pip install pywin32 pillow mss websockets -q 2>nul

REM Start server
start "WinControl" python server.py

REM Wait for startup
timeout /t 2 /nobreak >nul

echo.
echo WinControl started!
echo.
echo Display (view only):  http://localhost:8766
echo Actions API:          http://localhost:8767
echo.
echo To stop: Close the WinControl window or run: taskkill /f /fi "WINDOWTITLE eq WinControl"
