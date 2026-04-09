# WinControl Skill

AI remote control for Windows desktop. Captures screen on-demand via POST request and provides an HTTP API for mouse/keyboard actions.

## What It Does

- **On-Demand Capture**: POST to `/capture` to save screenshot, returns file path
- **Action API**: Control mouse and keyboard via HTTP endpoints on port 8767
- **WSL Integration**: Runs on Windows but saves frames to WSL's `/tmp` for easy access

## Quick Start

```bash
# From WSL
cd ~/.openclaw/workspace/skills/wincontrol
./start.sh
```

Verify it's working:
```bash
curl http://localhost:8767/ping

# Capture a screenshot (returns file path)
curl -X POST http://localhost:8767/capture
# Output: {"ok": true, "path": "/tmp/wincontrol/frame_000001.jpg", "frame": 1}
```

## File Structure

```
skills/wincontrol/
├── SKILL.md          # This file
├── server.py         # Main server (runs on Windows)
├── start.sh          # Start script (WSL)
└── stop.sh           # Stop script (WSL)
```

## Usage

### Starting the Server

```bash
./start.sh
```

Output:
```
✅ WinControl started successfully!

Actions API:    http://localhost:8767
Frames:         /tmp/wincontrol/
```

### Capturing Screenshots

```bash
# Capture and get file path
curl -X POST http://localhost:8767/capture
# Returns: {"ok": true, "path": "/tmp/wincontrol/frame_000001.jpg", "frame": 1}

# View the captured frame
read /tmp/wincontrol/frame_000001.jpg

# Or capture and view in one go
FILE=$(curl -s -X POST http://localhost:8767/capture | python3 -c "import sys,json; print(json.load(sys.stdin)['path'])")
read "$FILE"
```

### API Endpoints

#### GET Endpoints

| Endpoint | Description |
|----------|-------------|
| `GET /ping` | Check if server is running |
| `GET /screen` | Get screen dimensions `{width, height}` |
| `GET /frames` | List available frames `{count, frames[], directory}` |

#### POST Endpoints

| Endpoint | Body | Description |
|----------|------|-------------|
| `POST /capture` | (none) | Capture screen, returns `{ok, path, frame}` |
| `POST /click` | `{"x": 100, "y": 200, "button": "left"}` | Click at coordinates |
| `POST /drag` | `{"x1": 100, "y1": 200, "x2": 300, "y2": 400}` | Drag from A to B |
| `POST /scroll` | `{"x": 100, "y": 200, "direction": "down", "amount": 3}` | Scroll wheel |
| `POST /type` | `{"text": "Hello World"}` | Type text |
| `POST /key` | `{"key": "Enter"}` | Press special key |
| `POST /combo` | `{"keys": ["Ctrl", "C"]}` | Key combination |

### Example Commands

```bash
# Capture screenshot
curl -X POST http://localhost:8767/capture

# Get screen size
curl http://localhost:8767/screen

# Click at position (500, 300)
curl -X POST http://localhost:8767/click \
  -H "Content-Type: application/json" \
  -d '{"x": 500, "y": 300}'

# Type text
curl -X POST http://localhost:8767/type \
  -d '{"text": "Hello from AI"}'

# Press Enter
curl -X POST http://localhost:8767/key \
  -d '{"key": "Enter"}'

# Copy (Ctrl+C)
curl -X POST http://localhost:8767/combo \
  -d '{"keys": ["Ctrl", "C"]}'

# Paste (Ctrl+V)
curl -X POST http://localhost:8767/combo \
  -d '{"keys": ["Ctrl", "V"]}'

# Alt+Tab (switch window)
curl -X POST http://localhost:8767/combo \
  -d '{"keys": ["Alt", "Tab"]}'

# Win+D (show desktop)
curl -X POST http://localhost:8767/combo \
  -d '{"keys": ["Win", "D"]}'
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

## WSL Guide

### Prerequisites

1. **WSL2 with Ubuntu** (or your preferred distro)
2. **Python 3** on Windows side
3. **PowerShell** access from WSL

### Installation

1. The server uses Windows Python packages:
   - `pywin32` - Windows API access
   - `pillow` - Image processing
   - `mss` - Screen capture

2. These are auto-installed on first run via `start.sh`

### How It Works

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   WSL       │────▶│   Windows    │────▶│  /tmp/      │
│  start.sh   │     │  server.py   │     │  wincontrol/│
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

The server runs on Windows but writes frames to `\\wsl$\Ubuntu\tmp\wincontrol` (Windows path) which maps to `/tmp/wincontrol/` in WSL.

### Troubleshooting

**Issue**: `powershell.exe not found`
- Ensure WSL interop is enabled in `/etc/wsl.conf`:
```ini
[interop]
enabled = true
appendWindowsPath = true
```

**Issue**: Frames not appearing in `/tmp/wincontrol/`
- Check WSL distro name: `wsl -l -v` in Windows PowerShell
- The server uses `Ubuntu` by default. If yours is different, edit `server.py`:
```python
FRAME_DIR = r'\\wsl$\YourDistroName\tmp\wincontrol'
```

**Issue**: Permission denied when accessing frames
- Ensure the directory exists before starting: `mkdir -p /tmp/wincontrol`

**Issue**: Port 8767 already in use
```bash
# Find and kill the process
lsof -i :8767
kill <PID>
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

# Example: Click, capture, and see result
click(500, 300)
time.sleep(0.5)
frame_path = capture()
print(f"Screenshot saved to: {frame_path}")

# Example workflow
def open_notepad():
    combo(["Win", "R"])  # Open Run dialog
    time.sleep(0.5)
    type_text("notepad")
    press("Enter")
    time.sleep(1)
    type_text("Hello from WinControl!")

if __name__ == "__main__":
    open_notepad()
```

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
powershell.exe -Command "Get-Process python | Where-Object {$_.CommandLine -like '*server.py*'} | Stop-Process -Force"

# Clean up frames
rm -rf /tmp/wincontrol/*.jpg
```

## Security Notes

- Server binds to `localhost` only (not accessible from network)
- No authentication - anyone with WSL access can control your desktop
- Be careful running this on shared machines
- Frames are saved to `/tmp/` which may be accessible to other users

## Integration with OpenClaw

```javascript
// Capture and view
const result = exec("curl -s -X POST http://localhost:8767/capture");
const data = JSON.parse(result.stdout);
read(data.path);

// Or take action then capture
exec("curl -X POST http://localhost:8767/click -d '{\"x\":500,\"y\":300}'");
exec("sleep 0.5");
const frame = exec("curl -s -X POST http://localhost:8767/capture");
```

## License

GPL-3.0
