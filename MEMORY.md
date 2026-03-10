# MEMORY.md - Nova's Long-Term Memory

## Who I Am
- Name: Nova
- Emoji: ☄️
- Personality: Casual, straightforward, gets things done

## Who I'm Helping
- Name: QQ
- Timezone: Asia/Shanghai

## QQ's System Setup
- **Dual-boot**: Windows + native Ubuntu (not just WSL)
- **WSL**: Ubuntu installed, needs to be backed up before Windows reset
- **Browser plan**: Thorium + 夸克 (Quark) only (NO Chrome/Firefox!)

## Current Project: Windows Fresh Start
- **Goal**: Reset Windows (keeping personal files) and reinstall apps cleanly
- **Inventory**: All app inventory saved in `/home/qq/.openclaw/workspace/app-inventory/`
- **Todo list**: `/home/qq/.openclaw/workspace/app-inventory/FRESH-START-TODO.md` (full plan + installation sequence)
- **QQ's decision**: Wait for latest Windows Insider release before wiping
- **Important command QQ wants me to remember**:
  ```powershell
  irm "https://christitus.com/win" | iex
  ```

## ~~New Project: Raspberry Pi 5 Home Server~~ - ABANDONED
- **Status**: ❌ Project cancelled (2026-03-05)
- ~~Hardware~~: Raspberry Pi 5 (8GB RAM, 32GB storage)
- ~~Planned services~~: Nginx, NAS, Pi-hole, Mesh network, OpenClaw, Claude Code, OpenAI Codex, Kimi Code
- **Note**: Project files remain at `/home/qq/.openclaw/workspace/pi-project/` for reference

## Time & Flow Project (GitHub Pages) - COMPLETED
- **Merged**: QQ's original time.html clock + Pomodoro timer
- **Live at**: https://qqshi13.github.io/flow/
- **Final Features**:
  - Digital clock view
  - Pomodoro timer (25min work / 5min break) with progress ring
  - **Settings GUI** (click ⚙️) - change work/break duration with input fields
  - Sound notifications when timer ends
  - **Mobile-optimized** (touch-friendly, responsive)
  - **Desktop horizontal layout** - side-by-side clock and timer on wide screens
  - **Keyboard shortcuts**:
    - **Space** = Play/Pause timer (Flow view only)
    - **R** = cycles: Reset timer → Switch work/break mode
    - **M** = toggle between Clock view ↔ Flow view
- **Repo**: https://github.com/QQSHI13/flow
- **Status**: ✅ Completed and deployed

## Official Projects (QQ's Tools Collection)

### DropTransfer - P2P File Transfer
- **Live**: https://qqshi13.github.io/droptransfer/
- **Repo**: https://github.com/QQSHI13/droptransfer
- **Tech**: PeerJS (WebRTC), vanilla JS, dark theme
- **Features**:
  - True P2P file transfer (no server)
  - Auto-generated peer IDs
  - Chunked transfer for large files
  - Progress tracking
  - Connection retry logic
- **Status**: 🔄 Active development - fixing connection issues

### API Tester - HTTP Client
- **Live**: https://qqshi13.github.io/api-tester/
- **Repo**: https://github.com/QQSHI13/api-tester
- **Tech**: vanilla JS, localStorage, GitHub Pages
- **Features**:
  - All HTTP methods (GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS)
  - Request history (stored in localStorage)
  - Custom headers editor
  - JSON formatting/minifying
  - Basic auth support
  - Response headers viewer
  - Shareable request URLs
  - Dark theme (GitHub-style)
- **Status**: ✅ Completed and deployed

### JSON Visualizer
- **Live**: https://qqshi13.github.io/json-viewer/
- **Repo**: https://github.com/QQSHI13/json-viewer
- **Tech**: vanilla JS, GitHub Pages
- **Features**:
  - Collapsible tree view
  - Syntax highlighting
  - Live validation with error messages
  - Format/minify tools
  - Stats panel (size, nodes, depth)
- **Status**: ✅ Completed and deployed

### Regex Tester
- **Live**: https://qqshi13.github.io/regex-tester/
- **Repo**: https://github.com/QQSHI13/regex-tester
- **Tech**: vanilla JS, GitHub Pages
- **Features**:
  - Live pattern matching
  - Match highlighting
  - 12 common patterns library
  - Substitution preview
  - Capture groups display
- **Status**: ✅ Completed and deployed

## EvoMap Network - Active Node

- **Node ID**: node_d96f82bd79889904
- **Registered**: 2026-03-02
- **Status**: Active, heartbeating every 15 minutes
- **Credits**: 800
- **Reputation**: 0

### Tasks Already Solved (Don't retry)
| Task | Status | Asset Published |
|------|--------|-----------------|
| Automated Rollbacks: 自动回滚失败的部署 | ✅ Solved | Yes - sha256:0b603cae... |
| Extraterrestrial life evidence detection | ✅ Solved | Yes - sha256:7781ce5b... |
| 多模态记忆存储：文本、图像、音频 | ✅ Solved | Yes - sha256:4fba5876... |

**Note**: All 3 assigned tasks now complete. Publishing duplicate assets will be rejected with "quarantine" or "duplicate_asset" errors.

### Published Assets
- Atomic File Writer (GDI: 41.5)
- Auto Rollback System (GDI: 40.45)

### Worker Domains Enabled
- javascript
- nodejs
- web
- automation

### JWT Decoder
- **Live**: https://qqshi13.github.io/jwt-decoder/
- **Repo**: https://github.com/QQSHI13/jwt-decoder
- **Tech**: vanilla JS, GitHub Pages
- **Features**:
  - Decode JWT header, payload, signature
  - Syntax highlighting
  - Expiry detection (red/yellow/green badges)
  - Copy payload button
  - Sample tokens included
- **Status**: ✅ Completed and deployed

### CSV to JSON Converter
- **Live**: https://qqshi13.github.io/csv-json/
- **Repo**: https://github.com/QQSHI13/csv-json
- **Tech**: vanilla JS, GitHub Pages
- **Features**:
  - Drag-and-drop CSV files
  - Paste CSV text
  - Smart parsing options (headers, trim, numbers, booleans)
  - Copy or download JSON
  - Live stats (rows, cols, size)
- **Status**: ✅ Completed and deployed

### Diff Viewer
- **Live**: https://qqshi13.github.io/diff-viewer/
- **Repo**: https://github.com/QQSHI13/diff-viewer
- **Tech**: vanilla JS, diff-match-patch, GitHub Pages
- **Features**:
  - Side-by-side or inline diff view
  - Line numbers with change markers
  - Copy diff output
  - Shareable URLs (base64 encoded)
  - Swap inputs button
  - Stats panel (+/- counts)
- **Status**: ✅ Completed and deployed

### Nova ☄️ - Personal Site
- **Live**: https://qqshi13.github.io/nova/
- **Repo**: https://github.com/QQSHI13/nova
- **Tech**: vanilla JS, CSS animations, GitHub Pages
- **Features**:
  - Animated stars background
  - Project showcase grid
  - Links to all tools
  - Connect links (GitHub, OpenClaw)
- **Status**: ✅ Completed and deployed

## Things to Remember
- Always backup WSL first before any Windows reset!
- Windows reset will break GRUB - need to repair with Ubuntu live USB
- QQ keeps personal files during reset, but still backup WSL/Ubuntu!
- **Credits Rule**: Add "Nova ☄️" to credits in every website I build

## Income Generation / Monetization

### Ko-fi Setup (Primary Method for China)
**Status:** Ready to implement
**Payment Method:** Ko-fi → PayPal → Chinese Bank
**Why:** Only solution that works in China (GitHub Sponsors, Patreon, Stripe don't support China)

**Steps:**
1. Create PayPal account (https://paypal.com/c2)
2. Sign up at Ko-fi (https://ko-fi.com)
3. Username: qqshi13 or qqtools
4. Connect PayPal to Ko-fi
5. Set up page with projects showcase
6. Add Ko-fi link to all projects

**Expected Earnings:**
- Month 1-3: ¥200-1000/month
- Month 3-6: ¥1000-3000/month
- Month 6+: ¥3000-5000+/month

**Files Created:**
- `/home/qq/.openclaw/workspace/kofi-setup/README.md` - Complete setup guide
- `/home/qq/.openclaw/workspace/github-sponsors-setup/` - Alternative (not for China)

### Other Methods (Not for China)
- ~~GitHub Sponsors~~ - Not available in China
- ~~Patreon~~ - Not available in China  
- ~~Stripe~~ - Not available in China
- ~~Open Collective~~ - Not available in China

## OpenClaw Browser Setup (WSL2 + Windows)
**Working Method (DO NOT USE OLD METHOD):**
- Uses **raw remote CDP** profile pointing to Windows Chrome
- **Config**: `browser.defaultProfile: "nova"` ← USE THIS PROFILE
- **Profile**: `browser.profiles.nova.cdpUrl: "http://127.0.0.1:9222"`
- **Requirements**:
  1. WSL2 in mirrored networking mode (in `.wslconfig`: `networkingMode=mirrored`)
  2. Chrome/Thorium launched with `--remote-debugging-port=9222`
  3. OpenClaw config with nova profile (attachOnly: true)
- **Old methods to AVOID**: 
  - Chrome extension relay (`chrome` profile) - doesn't work well in WSL2 split-host
  - `remote` profile (use `nova` instead)

## New Skills Installed
- **Scrapling** - Web scraping framework with anti-bot bypass, stealth browsing, spiders, and JS rendering
- **Weixia** - 喂虾社区 - Let OpenClaw Agent入驻、发帖、回帖、接收通知
- **GitHub** - Interact with GitHub using the `gh` CLI
- **Self-Improving Agent** - Captures learnings, errors, and corrections to enable continuous improvement
- **Tavily Search** - Web search integration

## New Skills Installed (Clawhub)
- **scrapling** (replaces scrapling-official-0.4.2)
- **weixia** (replaces weixia-1.0.4)
- **github**
- **self-improving-agent**
- **tavily-search**

## Communication Preferences
- **Don't ask for confirmation** - QQ prefers I just do it and report back
- Deploy immediately after making changes unless told otherwise
- **"Hey" signal** - When QQ says "hey", it means they think I've stopped working or there's a system problem. I should respond immediately to confirm I'm active.

## Language Preference
- **Chinese (中文)** for presentations/speech content when audience is Chinese
- English for technical documentation and code

## Presentation Projects
- **OpenClaw Hackathon Presentation** (2026-02-28)
  - File: `OpenClaw_Hackathon_Presentation_CN.md`
  - Topic: QQ's AI coding journey with OpenClaw at age 12
  - Language: Chinese
  - Conversion script: `md-to-pptx.ps1` (auto-installs pandoc)

## Future Project Ideas (Non-Web)

### ESP32 Pomodoro Button - HARDWARE PROJECT (In Progress)
- **Status**: 🔄 Design complete - Simple backpack style
- **Location**: `/home/qq/.openclaw/workspace/esp32-button/`
- **Hardware**: M5Stack Atom Lite + backpack extension board
- **Cost**: ~¥149-189 per unit
- **Mounting**: Single M2 screw through center hole
- **What it does**: Standalone Pomodoro timer with serial settings sync
- **Features**:
  - **Single click**: Reset timer / Switch mode
  - **Long press**: Enter serial sync mode
  - **LED**: Red (work), Green (short break), Blue (long break)
  - **Buzzer**: End-of-timer alarm
  - **Long break**: After N work sessions
- **Power**: 3.7V 500mAh LiPo, 3-6 month battery life
- **Charging**: USB-C via TP4056
- **Connection**: GROVE 4P cable between boards
- **Case**: Simple 3D printed backpack (no lid)
- **Firmware**: PlatformIO, serial sync over USB

### Quick Notes - DESKTOP APP (In Progress)
- **Status**: ✅ Builds working - Major bug fixes completed (2026-03-08)
- **Type**: Desktop utility (Tauri - Rust + Web)
- **What it does**: Global hotkey opens floating note window, saves to ~/notes/
- **Features**: 
  - Global hotkey Ctrl+Shift+N
  - Always-on-top floating window
  - Markdown editor with live preview
  - Auto-save to ~/notes/ as .md files
  - System tray integration
  - GitHub dark theme
  - Settings panel with auto-save interval
  - Notes list sidebar
- **Platform**: Windows, macOS, Linux
- **Tech**: Tauri v2, vanilla JS, marked.js
- **Repo**: https://github.com/QQSHI13/quick-notes
- **Issues Fixed**: 30+ bugs including:
  - Orphaned code causing build failures (Rust)
  - Missing setupEventListeners() function (JS)
  - autoSave function override causing stack overflow
  - Key detection issues (Shift+C/Q)
  - Preview toggle button broken
  - Sidebar state mismatch
- **Builds Available**: All platforms (Windows .msi/.exe, Linux .deb/.AppImage/.rpm, macOS .dmg)
- **Location**: `~/.openclaw/workspace/projects/quick-notes/builds/releases/v1.0.12/` (cleaned up old platform folders)
- **Latest Update**: 2026-03-10 - Cleaned up old build artifacts, organized to releases/v1.0.12/

---

## Current Project Status Summary (2026-03-10)

### Web Tools (GitHub Pages) - ALL COMPLETED
| Project | Status | Notes |
|---------|--------|-------|
| Time & Flow | ✅ | Clock + Pomodoro, all features working |
| API Tester | ✅ | Recently bug-fixed (4 bugs) |
| JSON Viewer | ✅ | Recently bug-fixed (5 bugs) |
| Regex Tester | ✅ | Recently bug-fixed (2 bugs) |
| JWT Decoder | ✅ | Recently bug-fixed (3 bugs) |
| CSV to JSON | ✅ | Recently bug-fixed (8 bugs) |
| Diff Viewer | ✅ | Recently bug-fixed (4 bugs, critical fix) |
| DropTransfer | ✅ | Recently enhanced (E2E encryption, WebTorrent, folders) |
| Nova Site | ✅ | Recently bug-fixed (broken links) |
| LifeLab | ✅ | Recently bug-fixed (sidebar, rules) |
| CollaBoard | ✅ | Recently bug-fixed (modal, connection) |

### Desktop Apps
| Project | Status | Notes |
|---------|--------|-------|
| Quick Notes | ✅ | Builds working! 30+ bugs fixed, all platforms ready |

### Network/EvoMap
| Project | Status | Notes |
|---------|--------|-------|
| EvoMap Node | ✅ | Active, 800 credits, 3 tasks completed |
| Event Bus Asset | ✅ | Built and ready to publish |

### Recent Accomplishments (2026-03-08)
- Quick Notes desktop app: Fixed 10+ critical bugs causing initialization failures
- Fixed orphaned code in Rust (lib.rs) causing build errors
- Fixed missing setupEventListeners() function in JavaScript
- All CI builds now passing (Windows, macOS, Linux)
- Created auto-monitor script for fetching builds from GitHub Actions
- All installers saved to workspace: `projects/quick-notes/builds/`
- UI fixes: code button display, responsive toolbar, code block icon
- Added step-by-step debug status to trace initialization hang
