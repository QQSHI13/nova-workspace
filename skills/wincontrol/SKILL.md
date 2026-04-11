# WinControl Skill

AI remote control for Windows desktop. Captures screen on-demand via POST request and provides an HTTP API for mouse/keyboard actions.

## What It Does

- **On-Demand Capture**: POST to `/capture` to save screenshot, returns file path
- **Action API**: Control mouse and keyboard via HTTP endpoints on port 8767
- **WSL Integration**: Runs on Windows but saves frames to WSL's `/tmp` for easy access

## Quick Start

The server runs on Windows Python but can access WSL files directly using forward-slash paths:

```bash
# From WSL
cd ~/.openclaw/workspace/skills/wincontrol
./start.sh
```

Or start manually:
```bash
/mnt/c/Windows/System32/cmd.exe /c "python //wsl.localhost/Ubuntu/home/$USER/.openclaw/workspace/skills/wincontrol/server.py" &

# Verify
curl http://localhost:8767/ping
```

## Verify Installation

```bash
# Health check
curl http://localhost:8767/ping
# Output: {"ok": true}

# Capture a screenshot
curl -X POST http://localhost:8767/capture
# Output: {"ok": true, "path": "/tmp/wincontrol/frame_000001.jpg", "frame": 1, "screen": {"width": 1280, "height": 720}}

# View the screenshot
read /tmp/wincontrol/frame_000001.jpg
```

## File Structure

```
skills/wincontrol/
├── SKILL.md          # This file
├── server.py         # Main server (runs on Windows)
├── start.sh          # Start script (WSL - may need tweaking)
└── stop.sh           # Stop script (WSL)
```

## API Reference

### Capture Screen
```bash
curl -X POST http://localhost:8767/capture
```
Returns: `{"ok": true, "path": "/tmp/wincontrol/frame_000001.jpg", "frame": 1, "screen": {"width": 1280, "height": 720}}`

### Mouse Actions
```bash
# Click
curl -X POST http://localhost:8767/click -d '{"x": 500, "y": 300}'

# Drag
curl -X POST http://localhost:8767/drag -d '{"x1": 100, "y1": 200, "x2": 300, "y2": 400}'

# Scroll
curl -X POST http://localhost:8767/scroll -d '{"x": 500, "y": 300, "direction": "down", "amount": 3}'
```

### Keyboard Actions
```bash
# Type text
curl -X POST http://localhost:8767/type -d '{"text": "Hello World"}'

# Press special key
curl -X POST http://localhost:8767/key -d '{"key": "Enter"}'

# Key combination
curl -X POST http://localhost:8767/combo -d '{"keys": ["Ctrl", "C"]}'
```

### Other Endpoints
```bash
# List all endpoints
curl http://localhost:8767/ping
```

## Special Keys Reference

Single keys for `/key` endpoint:
- `Enter`, `Return`
- `Escape`, `Esc`
- `Backspace`, `Tab`, `Space`
- `Delete`, `Del`
- `Up`, `Down`, `Left`, `Right`
- `Home`, `End`, `PageUp`, `PageDown`
- `F1` through `F12`

Modifiers for `/combo` endpoint:
- `Ctrl`, `Control`
- `Alt`
- `Shift`
- `Win`, `Windows`

## Common Workflows

### Capture and View
```bash
FILE=$(curl -s -X POST http://localhost:8767/capture | python3 -c "import sys,json; print(json.load(sys.stdin)['path'])")
read "$FILE"
```

### Click and Verify
```bash
# Click somewhere
curl -X POST http://localhost:8767/click -d '{"x": 500, "y": 300}'
sleep 0.5

# Capture to see result
curl -X POST http://localhost:8767/capture
```

### Open Notepad and Type
```bash
# Win+R to open Run
curl -X POST http://localhost:8767/combo -d '{"keys": ["Win", "R"]}'
sleep 0.5

# Type notepad
curl -X POST http://localhost:8767/type -d '{"text": "notepad"}'
curl -X POST http://localhost:8767/key -d '{"key": "Enter"}'
sleep 1

# Type message
curl -X POST http://localhost:8767/type -d '{"text": "Hello from WinControl!"}'
```

## WSL2 Configuration

### Prerequisites
1. **WSL2 with Ubuntu** (or your preferred distro)
2. **Python 3** on Windows side
3. **Dependencies**: pywin32, pillow, mss (auto-installed)

### Path Configuration

For WSL2, update `server.py` if your distro name differs:

```python
# Default for Ubuntu:
FRAME_DIR = r'\\wsl.localhost\Ubuntu\tmp\wincontrol'

# For other distros, check with:
# wsl -l -v  (in Windows PowerShell)
```

Common distro paths:
- Ubuntu: `\\wsl.localhost\Ubuntu\tmp\wincontrol`
- Debian: `\\wsl.localhost\Debian\tmp\wincontrol`

### Troubleshooting

**Issue**: Server starts but curl fails
- Check if port 8767 is in use: `lsof -i :8767`
- Kill existing process: `kill <PID>`

**Issue**: Frames not appearing in `/tmp/wincontrol/`
- Ensure directory exists: `mkdir -p /tmp/wincontrol`
- Check WSL distro name in `server.py` matches your setup

**Issue**: Python module errors
- Manually install deps on Windows:
```bash
/mnt/c/Windows/System32/cmd.exe /c "pip install pywin32 pillow mss"
```

**Issue**: Wrong distro name
- Update `server.py` with your distro name:
```python
# Check your distro: grep ID= /etc/os-release
FRAME_DIR = r'\\wsl.localhost\Ubuntu\tmp\wincontrol'  # or Debian, etc.
```

## How It Works

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   WSL       │────▶│   Windows    │────▶│  /tmp/      │
│   (curl)    │     │  server.py   │     │  wincontrol/│
└─────────────┘     └──────────────┘     └─────────────┘
      │                    │                    │
      │              ┌─────┴─────┐              │
      │              │  Port     │              │
      │              │  8767     │              │
      │              └───────────┘              │
      │                                         │
      └─────────────────────────────────────────┘
                   (WSL accesses /tmp directly)
```

The server runs on Windows Python but writes frames to `\wsl.localhost\\<Distro>\tmp\wincontrol` which maps to `/tmp/wincontrol/` in WSL.

## Frame Management

- **Capture**: On-demand via `POST /capture`
- **Quality**: 90% JPEG for clear text/UI
- **Format**: `frame_000001.jpg`, `frame_000002.jpg`, etc.
- **Location**: `/tmp/wincontrol/`
- **No auto-cleanup**: Frames persist until manually deleted

To change quality, edit `server.py`:
```python
QUALITY = 90      # 1-100
```

## Stopping the Server

```bash
./stop.sh
```

Or manually:
```bash
# Kill Python process on Windows
/mnt/c/Windows/System32/cmd.exe /c "taskkill /F /FI \"IMAGENAME eq python.exe\" /FI \"WINDOWTITLE eq *wincontrol*\" 2>nul || taskkill /F /IM python.exe 2>nul"

# Clean up frames
rm -rf /tmp/wincontrol/*.jpg
```

## Python Client Example

```python
import requests
import time

API = "http://localhost:8767"

def capture():
    """Capture screen and return file path"""
    r = requests.post(f"{API}/capture")
    return r.json().get("path")

def click(x, y):
    requests.post(f"{API}/click", json={"x": x, "y": y})

def type_text(text):
    requests.post(f"{API}/type", json={"text": text})

def press(key):
    requests.post(f"{API}/key", json={"key": key})

def combo(keys):
    requests.post(f"{API}/combo", json={"keys": keys})

# Example workflow
if __name__ == "__main__":
    # Click at position
    click(500, 300)
    time.sleep(0.5)
    
    # Capture result
    frame_path = capture()
    print(f"Screenshot saved to: {frame_path}")
```

## Security Notes

- Server binds to `localhost` only (not accessible from network)
- No authentication - anyone with WSL access can control your desktop
- Be careful running this on shared machines
- Frames are saved to `/tmp/` which may be accessible to other users

## Integration with OpenClaw

```javascript
// Capture and view
const result = await exec("curl -s -X POST http://localhost:8767/capture");
const data = JSON.parse(result.stdout);
await read(data.path);

// Or take action then capture
await exec("curl -X POST http://localhost:8767/click -d '{\"x\":500,\"y\":300}'");
await exec("sleep 0.5");
const frame = await exec("curl -s -X POST http://localhost:8767/capture");
```

## License

GPL-3.0
