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
- **Live at**: https://qqshi13.github.io/flow/time-flow.html
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

## Communication Preferences
- **Don't ask for confirmation** - QQ prefers I just do it and report back
- Deploy immediately after making changes unless told otherwise

## Language Preference
- **Chinese (中文)** for presentations/speech content when audience is Chinese
- English for technical documentation and code

## Presentation Projects
- **OpenClaw Hackathon Presentation** (2026-02-28)
  - File: `OpenClaw_Hackathon_Presentation_CN.md`
  - Topic: QQ's AI coding journey with OpenClaw at age 12
  - Language: Chinese
  - Conversion script: `md-to-pptx.ps1` (auto-installs pandoc)
