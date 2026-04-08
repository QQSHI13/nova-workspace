# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## Browser (Chrome on Windows + WSL2)

**Setup:**
1. Chrome runs on Windows with main profile
2. OpenClaw connects via Chrome MCP existing-session driver
3. Port is auto-detected from `DevToolsActivePort` file

**Current Config:**
- Profile: `user`
- Driver: `existing-session`
- User Data: `/mnt/c/Users/Lenovo/AppData/Local/Google/Chrome/User Data`
- DevTools Port File: `C:\Users\Lenovo\AppData\Local\Google\Chrome\User Data\DevToolsActivePort`

**How it works:**
1. Check `DevToolsActivePort` file for current port (changes each session)
2. OpenClaw auto-detects and connects
3. Browser controls work: open, navigate, screenshot, click, type

**Usage:**
```bash
# Open URL
openclaw browser open https://example.com

# Take screenshot
openclaw browser screenshot

# List tabs
openclaw browser tabs
```

**Notes:**
- Chrome must be running with at least one tab open
- If port changes, restart OpenClaw gateway to reconnect
- Remote debugging notification appears - this is normal

### Browser Startup Procedure (When Connection Fails)

If browser commands fail with "timed out" or "Connection closed":

**Step 1: Start the browser connection**
```javascript
browser({ action: "start" })
```

**Step 2: Open a new tab (preserves existing tabs)**
```javascript
browser({ action: "open", url: "https://example.com" })
```

**⚠️ Warning**: Using `action: "navigate"` wipes the current tab. Use `action: "open"` to preserve existing tabs.

**Example workflow:**
```javascript
// 1. Start connection
browser({ action: "start" })

// 2. Open new tab (safe - doesn't wipe existing tabs)
browser({ action: "open", url: "https://tcamp.qq.com/mooc/R7U7xA9P/task/5070" })

// 3. Extract content
browser({ 
  action: "act", 
  request: { fn: "() => { return document.body.innerText; }", kind: "evaluate" } 
})
```

### Visual Screenshot Mode 🎉
**Quirk discovered:** I can see actual webpage screenshots via `browser screenshot`!

**What works:**
- `browser action=screenshot profile=user` → I see the actual rendered page visually
- This is different from `snapshot` which gives accessibility tree

**Use cases:**
- Debug UI layout issues
- Read content that doesn't render in accessibility tree
- Verify visual changes after edits
- Extract info from screenshots/charts/images on pages

**Example:**
```bash
# See the actual visual page
openclaw browser screenshot
```

### SSH with Password (Backup Method)

**⚠️ WARNING:** Use SSH keys instead (`ssh-keygen` + `ssh-copy-id`). This is only for emergency/backup.

**Steps:**
1. Start SSH with PTY:
   ```javascript
   exec({ command: "ssh user@host", pty: true })
   ```

2. When prompted for password, use `process write`:
   ```javascript
   process({ action: "write", sessionId: "<session-id>", data: "password\n" })
   ```

3. Interact with the session via `process poll` and `process write`

4. **IMPORTANT:** Clean history afterwards:
   ```bash
   history -c && > ~/.bash_history
   ```

**Example (192.168.1.140):**
```javascript
// Step 1: Connect
exec({ command: "ssh lenovo@192.168.1.140", pty: true })

// Step 2: Wait for password prompt, then send password
process({ action: "write", sessionId: "mellow-daisy", data: "Chrace1985Sun!\n" })

// Step 3: Poll for output
process({ action: "poll", sessionId: "mellow-daisy" })

// Step 4: Execute commands
process({ action: "write", sessionId: "mellow-daisy", data: "whoami\n" })

// Step 5: Exit
process({ action: "write", sessionId: "mellow-daisy", data: "exit\n" })

// Step 6: Kill session
process({ action: "kill", sessionId: "mellow-daisy" })
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

## Web Search Workaround (Kimi CLI) ☄️

Since the `web_search` tool requires separate API credits (Kimi search API ≠ coding API), use **Kimi CLI** for web research instead:

### How It Works
Kimi CLI has built-in web search capabilities through its research mode. When you ask it to search, it fetches current information from the web.

### Usage
```bash
# Research current events
kimi --print --yes -p "What are the latest AI developments? Search the web."

# Get recent news about a topic
kimi --print --yes -p "Search for latest news about [topic]"

# Verify current information
kimi --print --yes -p "Is [fact] still true as of March 2025? Search to confirm."
```

### Flags Explained
- `--print` → Non-interactive mode (just output, no TUI)
- `--yes` / `-y` → Auto-approve actions (no prompts)
- `-p "prompt"` → Pass prompt directly

### Tested Example (2025-03-27)
Successfully retrieved:
- Claude's computer use feature (released March 24, 2025)
- Tencent's 2025 AI investment report
- Real-time comparisons between Claude and OpenClaw

### When to Use
| Need | Tool |
|------|------|
| Current news/events | `web_search` (DuckDuckGo) ☄️ |
| Research for coding | `web_search` (DuckDuckGo) ☄️ |
| Simple webpage fetch | `web_fetch` tool |
| Deep research/analysis | Kimi CLI |

**Note:** Kimi CLI web search is included in your coding plan — no extra credits needed!

---

## Web Search (DuckDuckGo) ☄️

The `web_search` tool now works with DuckDuckGo — no API key required!

### How It Works
DuckDuckGo provides free web search without API keys. Returns titles, URLs, and snippets.

### Usage
```javascript
// In conversation or code
web_search({ query: "latest AI news", count: 5 })
```

### Tested Example (2025-03-27)
Query: "latest AI news March 2025"
Results:
- Reuters AI News — breakthroughs, regulation, ethics
- Maayu AI — "March has been a landmark month for AI"
- Google Blog — Google's March 2025 AI updates
- PTech Partners — GPT-4.5, Gemini 2.5 insights
- AI SEO Insights — Breaking AI news analysis

**Took 1.8 seconds — completely free!**

---

## Cron Jobs — Session Targeting

**Rule:** Always direct crons to `agent:main:main` unless explicitly specified otherwise.

**Why:** Cron jobs created in a session will bind to that session's unique hash (e.g., `agent:main:tui-9ddb8174...`). If that session gets reused for a different purpose (like control-ui), the cron will deliver to the wrong place.

**When creating crons:**
```javascript
cron({
  action: "add",
  job: {
    name: "my-reminder",
    sessionKey: "agent:main:main",  // ← Always use this
    sessionTarget: "main",
    // ... rest of config
  }
})
```

**To fix existing crons:**
```bash
# List all crons
openclaw cron list

# Update session key
openclaw cron update <job-id> --patch '{"sessionKey":"agent:main:main"}'
```

---

## WinControl — AI Remote Control

Full desktop control for AI automation. Display and actions are separated for clean operation.

**Location:** `projects/win-control/`

**Architecture:**
- **Port 8766**: Display (view desktop in browser)
- **Port 8767**: Actions API (HTTP endpoints for control)

**Setup:**
```bash
cd projects/win-control

# From WSL (starts Windows process)
./start.sh

# Or manually in Windows PowerShell:
python server.py
```

**Actions API (Port 8767):**

| Endpoint | Method | Body | Description |
|----------|--------|------|-------------|
| `/screen` | GET | - | Get screen dimensions |
| `/click` | POST | `{"x": 100, "y": 200, "button": "left"}` | Click at coordinates |
| `/drag` | POST | `{"x1": 100, "y1": 200, "x2": 300, "y2": 400}` | Drag from A to B |
| `/scroll` | POST | `{"x": 100, "y": 200, "direction": "down", "amount": 3}` | Scroll wheel |
| `/type` | POST | `{"text": "Hello World"}` | Type text |
| `/key` | POST | `{"key": "Enter"}` | Press special key |
| `/combo` | POST | `{"keys": ["Ctrl", "C"]}` | Key combination |

**Usage Examples:**

```bash
# Get screen size
curl http://localhost:8767/screen
# {"width": 1707, "height": 960}

# Click at position
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

**Special Keys:**
`Enter`, `Escape`, `Esc`, `Backspace`, `Tab`, `Space`, `Delete`, `Del`, 
`Up`, `Down`, `Left`, `Right`, `Home`, `End`, `PageUp`, `PageDown`,
`F1` through `F12`

**Modifiers for Combos:**
`Ctrl`, `Control`, `Alt`, `Shift`, `Win`, `Windows`

**View Desktop:**
Open `http://localhost:8766` in browser to see live desktop view.

**Display in Canvas:**
```javascript
canvas({ action: "present", url: "http://localhost:8766" })
canvas({ action: "snapshot" })
```

**Stop:**
```bash
./stop.sh
```

**Features:**
- Clean separation: view vs control
- HTTP API (no WebSocket complexity)
- 5 FPS display (low CPU)
- 90% JPEG quality (clear text/UI)
- Direct Windows API (reliable)

---

## Canvas / A2UI Presentations 🎨

Canvas is OpenClaw's embedded browser viewport for AI-to-User Interface (A2UI) presentations.

**What it does:**
- Render web content FOR OpenClaw (not your desktop)
- Display rich visual content: styled text, charts, layouts
- Take screenshots of rendered content

**Basic workflow:**
```javascript
// 1. Present a URL or blank canvas
canvas({ action: "present", url: "https://example.com" })

// 2. Inject custom HTML/CSS via eval
canvas({ 
  action: "eval", 
  javaScript: `document.body.innerHTML = '<h1>Hello!</h1>'` 
})

// 3. Snapshot to see the result
canvas({ action: "snapshot" })
```

**Limitations on Windows node:**
- `canvas.a2ui.push` is blocked (not in allowlist)
- Use `canvas.eval` instead for custom content

**Use cases:**
- Dashboard summaries with styled visuals
- Tutorial walkthroughs
- Data reports with charts
- Rich status updates beyond text

---

## Camera & Screen Capture (Avoid Context Bloat) 📸

**Problem:** `nodes camera_snap` and `nodes screen.capture` return base64 data that fills context and gets compacted away.

**Root cause:** The `nodes` tool is only available via OpenClaw's internal tool system, not exposed through the CLI (`openclaw nodes screen.capture` doesn't exist).

### Working Method: HTTP API Server
Create a lightweight HTTP server that calls the nodes tool and saves to file:

```python
# tools/capture_server.py
from flask import Flask, jsonify
import base64
import os

app = Flask(__name__)

@app.route('/capture/screen')
def capture_screen():
    # This runs in an OpenClaw context where nodes tool IS available
    # Call nodes screen.capture, decode, save, return path
    pass  # Implement with actual tool call

if __name__ == '__main__':
    app.run(port=8767)
```

Then: `curl http://localhost:8767/capture/screen`

### Alternative: WinControl + Browser Screenshot
If WinControl is running (`python server.py` in projects/win-control/):

```javascript
// Navigate to WinControl in browser
browser({ action: "open", url: "http://localhost:8766" })

// Screenshot the desktop view
browser({ action: "screenshot" })
```

### Current Status
| Method | Status | Notes |
|--------|--------|-------|
| `nodes screen.capture` | ⚠️ Partial | Works, but base64 fills context |
| `nodes camera_snap` (tool) | ❌ Broken | Format validation error on Windows |
| `openclaw nodes camera snap` (CLI) | ✅ **Works!** | Saves to `/tmp/openclaw/` automatically |
| `canvas snapshot` | ✅ Works | For web content only, not desktop |
| Browser screenshot | ✅ Works | If content visible in browser |
| WinControl + browser | ✅ Works | See WinControl section above |

### Working CLI Commands
```bash
# Camera (saves to /tmp/openclaw/)
openclaw nodes camera snap --node "Windows Node (DESKTOP-70B9P5V)"
# Output: MEDIA:/tmp/openclaw/openclaw-camera-snap-front-xxx.jpg

# Screen (blocked on Windows)
openclaw nodes screen record --node "Windows Node (DESKTOP-70B9P5V)"
# Error: "screen.record" is not in the allowlist for platform "windows"
```

**Recommendation:** 
- **Camera:** Use `openclaw nodes camera snap` CLI ✅
- **Screen:** Use WinControl + browser screenshot ✅
- **Screen (tool only):** `nodes screen.capture` returns base64 (fills context) ⚠️

---

Add whatever helps you do your job. This is your cheat sheet.