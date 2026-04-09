# WinControl Skill

AI remote control for Windows desktop. Captures screen frames to `/tmp/wincontrol/` and provides an HTTP API for mouse/keyboard actions.

## What It Does

- **Frame Capture**: Saves screenshots to `/tmp/wincontrol/frame_XXXXXX.jpg` at 5 FPS
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
curl http://localhost:8767/frames
```

## File Structure

```
skills/wincontrol/
├── SKILL.md          # This file
├── server.py         # Main server (runs on Windows)
├── start.sh          # Start script (WSL)
├── stop.sh           # Stop script (WSL)
└── latest-frame.sh   # Get path to latest frame
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

### Viewing the Latest Frame

```bash
# Get path to latest frame
./latest-frame.sh
# Output: /tmp/wincontrol/frame_000042.jpg

# View in terminal (if supported)
cat $(./latest-frame.sh)

# Or use with other tools
python3 -c "
from PIL import Image
import os
latest = max([f for f in os.listdir('/tmp/wincontrol') if f.startswith('frame_')])
img = Image.open(f'/tmp/wincontrol/{latest}')
print(f'Size: {img.size}')
img.show()
"
```

### API Endpoints

#### GET Endpoints

| Endpoint | Description |
|----------|-------------|
| `GET /ping` | Check if server is running |
| `GET /screen` | Get screen dimensions `{width, height}` |
| `GET /frame` | Trigger a capture, returns `{ok, frame, path}` |
| `GET /frames` | List available frames `{count, frames[], directory}` |

#### POST Endpoints

| Endpoint | Body | Description |
|----------|------|-------------|
| `POST /click` | `{"x": 100, "y": 200, "button": "left"}` | Click at coordinates |
| `POST /drag` | `{"x1": 100, "y1": 200, "x2": 300, "y2": 400}` | Drag from A to B |
| `POST /scroll` | `{"x": 100, "y": 200, "direction": "down", "amount": 3}` | Scroll wheel |
| `POST /type` | `{"text": "Hello World"}` | Type text |
| `POST /key` | `{"key": "Enter"}` | Press special key |
| `POST /combo` | `{"keys": ["Ctrl", "C"]}` | Key combination |

### Example Commands

```bash
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
import os
from PIL import Image

API = "http://localhost:8767"

def click(x, y):
    requests.post(f"{API}/click", json={"x": x, "y": y})

def type_text(text):
    requests.post(f"{API}/type", json={"text": text})

def press(key):
    requests.post(f"{API}/key", json={"key": key})

def combo(keys):
    requests.post(f"{API}/combo", json={"keys": keys})

def get_latest_frame():
    """Get path to most recent frame"""
    frames = sorted([
        f for f in os.listdir('/tmp/wincontrol')
        if f.startswith('frame_')
    ])
    return f"/tmp/wincontrol/{frames[-1]}" if frames else None

def view_frame(path=None):
    """Open frame in default viewer"""
    if path is None:
        path = get_latest_frame()
    if path:
        Image.open(path).show()

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

- **FPS**: 5 frames per second
- **Retention**: Last 30 frames kept (6 seconds of history)
- **Quality**: 90% JPEG for clear text/UI
- **Naming**: `frame_XXXXXX.jpg` (sequential numbering)

To change settings, edit `server.py`:
```python
QUALITY = 90      # 1-100
FPS = 5           # Frames per second
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

Use with the `browser` tool or `canvas` for visual feedback:

```javascript
// View latest frame
const frame = require('child_process').execSync('./latest-frame.sh').toString().trim();
read(frame);

// Or take action
exec("curl -X POST http://localhost:8767/click -d '{\"x\":500,\"y\":300}'");
```

## License

GPL-3.0
