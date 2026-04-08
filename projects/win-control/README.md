# WinControl - Browser-Based Window Control

Control any Windows application through a browser interface. AI can view and control apps without direct system access.

## Architecture

```
┌─────────────┐  WebSocket  ┌──────────────┐  Win32 API   ┌─────────────┐
│   Browser   │ ◄──────────►│ Python Server│ ◄───────────►│  Any App    │
│  (Viewer)   │  (frames)   │  (Gateway)   │  (input)     │  (Target)   │
└─────────────┘             └──────────────┘              └─────────────┘
```

## Features

- ✅ Capture any visible window (BitBlt for max compatibility)
- ✅ Stream frames to browser via WebSocket (30fps target)
- ✅ Forward mouse clicks and keyboard from browser to app (SendInput API)
- ✅ Select any window to control
- ✅ Simple web UI with minimal latency

## Prerequisites

- Windows 10/11
- Python 3.8+
- Chrome/Edge/Firefox

## Installation

```bash
cd projects/win-control
pip install -r requirements.txt
```

## Usage

1. **Start the server:**
```bash
python server.py
```

2. **Open browser:**
Navigate to `http://localhost:8765`

3. **Select a window:**
Choose from the dropdown which app to control

4. **Control remotely:**
Click and type in the browser - actions forward to the actual app

## How It Works

### Window Capture
- Uses `win32gui.BitBlt()` for max compatibility
- Captures at 30fps
- JPEG encoding for fast streaming

### Input Forwarding
- Mouse: `win32api.SendInput()` with absolute coordinates
- Keyboard: `win32api.SendInput()` with scan codes
- Position mapping: Browser coordinates → Window client area

### Security Note
This is for **local use only**. The server binds to localhost only.

## Troubleshooting

**Window not capturing?**
- Some apps (UWP, hardware-accelerated) may not capture well
- Try "Software" rendering mode in the target app

**High latency?**
- Reduce JPEG quality in `server.py`
- Close unnecessary apps
- Use wired connection (not WiFi)

**Click position wrong?**
- Window may have been moved/resized
- Re-select the window from dropdown