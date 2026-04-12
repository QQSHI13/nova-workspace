@echo off
REM WinControl Start Script for Native Windows

echo [WinControl] Starting server...
echo [WinControl] Screenshot will be saved as: screenshot.jpg in this folder
echo [WinControl] Press Ctrl+C to stop and cleanup
echo.

REM Check if Python is available
python --version >nul 2>&1
if errorlevel 1 (
    echo [WinControl] Error: Python not found. Please install Python 3.
    exit /b 1
)

REM Install dependencies if needed
echo [WinControl] Checking dependencies...
python -c "import win32api, win32con, mss, PIL" >nul 2>&1
if errorlevel 1 (
    echo [WinControl] Installing dependencies...
    pip install pywin32 pillow mss
)

REM Start the server
python "%~dp0server.py"
