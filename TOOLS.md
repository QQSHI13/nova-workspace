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

---

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

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

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
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

Add whatever helps you do your job. This is your cheat sheet.