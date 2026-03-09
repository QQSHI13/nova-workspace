# QQ's Code Knowledge Base Index

> Auto-generated index for semantic search across all projects
> Generated: 2026-03-05

---

## 📁 Project Overview

| Project | Type | Tech Stack | URL |
|---------|------|------------|-----|
| esp32-button | Hardware | ESP32, PlatformIO, M5Atom | `/workspace/esp32-button/` |
| droptransfer | WebRTC P2P Tool | PeerJS, Vanilla JS | https://qqshi13.github.io/droptransfer/ |
| api-tester | HTTP Client | Vanilla JS, localStorage | https://qqshi13.github.io/api-tester/ |
| json-viewer | JSON Visualizer | Vanilla JS, CSS Variables | https://qqshi13.github.io/json-viewer/ |
| regex-tester | Pattern Matcher | Vanilla JS, RegExp | https://qqshi13.github.io/regex-tester/ |
| jwt-decoder | Token Inspector | Vanilla JS, Base64 | https://qqshi13.github.io/jwt-decoder/ |
| csv-json | Data Converter | Vanilla JS, FileReader API | https://qqshi13.github.io/csv-json/ |
| diff-viewer | Text Diff Tool | Vanilla JS, diff-match-patch | https://qqshi13.github.io/diff-viewer/ |
| flow | Pomodoro Timer | Vanilla JS, PWA, Wake Lock API | https://qqshi13.github.io/flow/ |
| nova-site | Portfolio Site | HTML/CSS, GitHub Pages | https://qqshi13.github.io/nova/ |
| QQSHI13.github.io | Main Hub | HTML/CSS | https://qqshi13.github.io/ |

---

## 📦 DropTransfer - P2P File Sharing

### Technologies
- **PeerJS** (v1.5.2) - WebRTC abstraction layer with cloud signaling
- **Vanilla JavaScript** - No frameworks, pure browser APIs
- **GitHub Pages** - Static hosting

### Key Features
- True peer-to-peer file transfer (no server storage)
- Auto-generated 6-digit transfer codes
- Chunked file transfer (16KB chunks) for large files
- Progress tracking with visual progress bar
- Drag-and-drop file selection
- Copy-to-clipboard for transfer codes
- Connection retry logic and auto-reconnect

### Architecture Patterns
- **Client-side only** - No backend required
- **WebRTC DataChannel** - For binary data transfer
- **Chunked streaming** - Files split into 16KB chunks
- **STUN servers** - Multiple Google STUN servers for NAT traversal
- **Event-driven** - PeerJS event handlers for connection state

### APIs/Endpoints
- PeerJS cloud signaling server (default)
- STUN servers:
  - stun:stun.l.google.com:19302
  - stun:stun1.l.google.com:19302
  - stun:stun2.l.google.com:19302
  - stun:stun3.l.google.com:19302
  - stun:stun4.l.google.com:19302

### Unique Implementation Details
- Uses `arrayBuffer()` to read files, then slices into chunks
- Each chunk sent as `{type: 'chunk', data: ArrayBuffer, index: n, total: N}`
- Receiver assembles chunks into Blob for download
- 20-second connection timeout with retry button
- Serializes binary data with `serialization: 'binary'`

### File Location
- `/home/qq/.openclaw/workspace/projects/droptransfer/index.html` (single file)

---

## 🧪 API Tester - HTTP Client

### Technologies
- **Vanilla JavaScript** - No frameworks
- **Fetch API** - For HTTP requests
- **localStorage** - Persist request history
- **GitHub Pages** - Static hosting

### Key Features
- All HTTP methods: GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS
- Request history (last 50 requests) with localStorage persistence
- Custom headers editor with add/remove
- JSON body editor with format/minify
- Basic auth with automatic Base64 encoding
- Response syntax highlighting (JSON)
- Shareable URLs via Base64 encoding
- Response headers viewer
- Response time and size metrics

### Architecture Patterns
- **Three-panel layout** - History sidebar, request panel, response panel
- **Tab-based UI** - Headers/Body/Auth tabs for request configuration
- **Debounce pattern** - For input handling (implied)
- **URL-based sharing** - Request state encoded in URL query params

### APIs/Endpoints
- Supports any HTTP endpoint
- Built-in presets:
  - JSON Placeholder (https://jsonplaceholder.typicode.com)
  - HTTPBin (https://httpbin.org)
  - GitHub API (https://api.github.com)
  - ReqRes (https://reqres.in)
  - PokeAPI (https://pokeapi.co)

### Unique Implementation Details
- History stored as array of `{method, url, status, time}` objects
- Share URL format: `?share={base64-encoded-request-json}`
- Response syntax highlighting via regex replacements
- Status code color coding (2xx green, 3xx yellow, 4xx/5xx red)

### File Location
- `/home/qq/.openclaw/workspace/projects/api-tester/index.html` (single file)

---

## 🌳 JSON Viewer - Interactive JSON Visualizer

### Technologies
- **Vanilla JavaScript** - No dependencies
- **CSS Variables** - Theming with GitHub dark colors
- **GitHub Pages** - Static hosting

### Key Features
- Collapsible tree view for nested objects/arrays
- Live validation with error display
- Syntax highlighting (strings, numbers, booleans, null, keys)
- Format and minify JSON
- Expand all / Collapse all buttons
- Statistics: file size, node count, max depth
- Copy to clipboard
- Sample data pre-loaded

### Architecture Patterns
- **Two-panel layout** - Input textarea, visual tree view
- **Recursive rendering** - `renderTree()` function handles nested structures
- **Path-based toggling** - Each node has unique path for collapse/expand
- **Debounce** - 300ms debounce on input for performance

### Data Structures
- Tree nodes use CSS classes: `.json-key`, `.json-string`, `.json-number`, `.json-boolean`, `.json-null`
- Toggle buttons use `▼`/`▶` indicators with `collapsed` class

### Unique Implementation Details
- Recursive `renderTree(data, key, isLast, path)` function
- `countNodes()` and `getMaxDepth()` for statistics
- Uses `escapeHtml()` to prevent XSS in JSON values
- Tree paths use hyphen-separated indices (e.g., `root-0-key`)

### File Location
- `/home/qq/.openclaw/workspace/projects/json-viewer/index.html` (single file)

---

## 🔍 Regex Tester - Live Pattern Matcher

### Technologies
- **Vanilla JavaScript** - No dependencies
- **Native RegExp** - JavaScript regex engine
- **GitHub Pages** - Static hosting

### Key Features
- Live regex matching as you type (200ms debounce)
- Match highlighting in test text with `<span class="match">`
- 12 built-in common patterns (email, URL, phone, date, etc.)
- Substitution preview with `$1`, `$&` support
- Capture groups display on click
- Flags support: g (global), i (ignore case), m (multiline)
- Error messages for invalid regex

### Common Patterns Library
```javascript
[
  { name: 'Email', pattern: '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}' },
  { name: 'URL', pattern: 'https?://[^\\s]+' },
  { name: 'IP Address', pattern: '\\b(?:[0-9]{1,3}\\.){3}[0-9]{1,3}\\b' },
  { name: 'Phone Number', pattern: '\\+?\\d{1,3}[-.\\s]?(\\(?\\d{3}\\)?[-.\\s]?)?\\d{3}[-.\\s]?\\d{4}' },
  { name: 'Date (YYYY-MM-DD)', pattern: '\\d{4}-\\d{2}-\\d{2}' },
  { name: 'Hex Color', pattern: '#[a-fA-F0-9]{6}' },
  { name: 'Credit Card', pattern: '\\b(?:\\d{4}[-\\s]?){3}\\d{4}\\b' },
  { name: 'HTML Tag', pattern: '<[^>]+>' },
  { name: 'Markdown Link', pattern: '\\[([^\\]]+)\\]\\(([^)]+)\\)' }
]
```

### Unique Implementation Details
- Uses `while ((match = regex.exec(text)) !== null)` for global matching
- Stores matches in `window.currentMatches` for group display
- Substitution uses `text.replace(regex, replacement)`
- Click handler on matches shows capture groups in sidebar

### File Location
- `/home/qq/.openclaw/workspace/projects/regex-tester/index.html` (single file)

---

## 🔑 JWT Decoder - Token Inspector

### Technologies
- **Vanilla JavaScript** - No dependencies
- **Base64 URL decoding** - Native `atob()` with URL-safe handling
- **GitHub Pages** - Static hosting

### Key Features
- Instant JWT decoding on paste/input
- Three sections: Header, Payload, Signature
- Syntax highlighting for JSON
- Expiry detection with color badges:
  - Red = EXPIRED
  - Yellow = Expires soon (< 24h)
  - Green = Valid
- Copy payload button
- Sample tokens (Simple, Admin, Expired, Firebase)

### JWT Structure Handling
```javascript
// JWT format: header.payload.signature
const parts = token.split('.');
const header = JSON.parse(base64UrlDecode(parts[0]));
const payload = JSON.parse(base64UrlDecode(parts[1]));
const signature = parts[2]; // Not decoded
```

### Base64 URL Decoding
```javascript
function base64UrlDecode(str) {
  // Add padding
  const padding = 4 - str.length % 4;
  if (padding !== 4) str += '='.repeat(padding);
  // Replace URL-safe chars
  str = str.replace(/-/g, '+').replace(/_/g, '/');
  return atob(str);
}
```

### Unique Implementation Details
- Detects `exp` claim and compares with `Date.now()`
- Expiry formatted as "Nd left" or "Expires soon"
- Sample tokens include realistic JWT structures

### File Location
- `/home/qq/.openclaw/workspace/projects/jwt-decoder/index.html` (single file)

---

## 📊 CSV to JSON Converter

### Technologies
- **Vanilla JavaScript** - No dependencies
- **FileReader API** - For file upload handling
- **GitHub Pages** - Static hosting

### Key Features
- Drag-and-drop CSV file upload
- Paste CSV text directly
- Smart delimiter detection (comma or tab)
- Options:
  - First row as headers
  - Trim whitespace
  - Parse numbers
  - Parse booleans
  - Minify output
- Live statistics: row count, column count, JSON size
- Copy JSON to clipboard
- Download as .json file

### CSV Parsing Algorithm
```javascript
// Handles quoted fields with commas
function parseLine(line) {
  const result = [];
  let current = '';
  let inQuotes = false;
  
  for (let char of line) {
    if (char === '"') {
      if (inQuotes && nextChar === '"') {
        current += '"'; // Escaped quote
        i++;
      } else {
        inQuotes = !inQuotes;
      }
    } else if (char === delimiter && !inQuotes) {
      result.push(current);
      current = '';
    } else {
      current += char;
    }
  }
  result.push(current);
  return result;
}
```

### Data Transformations
- Numbers: `/^-?\d+\.?\d*$/` → `parseFloat()`
- Booleans: `/^(true|false)$/i` → boolean
- Headers: If disabled, generates `Column1`, `Column2`, etc.

### Unique Implementation Details
- Auto-detects delimiter: `text.includes('\t') ? '\t' : ','`
- Shows drop zone initially, switches to textarea after file load
- 300ms debounce on input for live conversion

### File Location
- `/home/qq/.openclaw/workspace/projects/csv-json/index.html` (single file)

---

## 📑 Diff Viewer - Text Comparison Tool

### Technologies
- **Vanilla JavaScript** - No frameworks
- **Custom diff-match-patch** - Ported/embedded library
- **highlight.js** - For syntax highlighting (CDN)
- **GitHub Pages** - Static hosting

### Key Features
- Split view (side-by-side) and inline view
- Line numbers for both original and modified
- Added/removed/unchanged line highlighting
- Character-level diff (Myers diff algorithm)
- Swap inputs button
- Paste from clipboard buttons
- Copy diff result as unified diff format
- Statistics: added count, removed count, unchanged count

### Myers Diff Algorithm Implementation
The embedded `diff.js` implements the classic Myers diff algorithm:
- `diff_commonPrefix()` - Binary search for common prefix
- `diff_commonSuffix()` - Binary search for common suffix
- `diff_bisect()` - Core diff algorithm using edit graph
- `diff_cleanupSemantic()` - Post-processing for cleaner diffs

### Diff Types
```javascript
const DIFF_DELETE = -1;
const DIFF_INSERT = 1;
const DIFF_EQUAL = 0;
// Returns array of [type, text] tuples
```

### View Modes
1. **Split View**: Two panes (Original | Modified) with aligned lines
2. **Inline View**: Single pane with +/- markers

### Unique Implementation Details
- Line-by-line rendering with `escapeHtml()` for safety
- Empty line placeholders for alignment in split view
- Unified diff format export: `- removed`, `+ added`, `  unchanged`

### File Locations
- `/home/qq/.openclaw/workspace/projects/diff-viewer/index.html`
- `/home/qq/.openclaw/workspace/projects/diff-viewer/diff.js` (algorithm)
- `/home/qq/.openclaw/workspace/projects/diff-viewer/app.js` (UI logic)
- `/home/qq/.openclaw/workspace/projects/diff-viewer/style.css`

---

## ⏰ Flow - Pomodoro Timer (PWA)

### Technologies
- **Vanilla JavaScript** - Modular architecture
- **CSS Animations** - SVG progress ring, button animations
- **Wake Lock API** - Prevents screen sleep
- **Web Audio API** - Generated chime sounds
- **Cookie API** - State persistence
- **Fullscreen API** - Fullscreen mode
- **Service Worker** - PWA support
- **GitHub Pages** - Static hosting

### Key Features
- Work/Break/Long Break cycles
- Customizable durations (settings modal)
- Progress ring SVG animation
- Sound notifications (Web Audio generated)
- Keyboard shortcuts:
  - Space: Play/Pause
  - R: Reset (running) / Switch mode (paused)
  - F: Toggle fullscreen
- Wake Lock during timer
- Persistent state with cookies
- Mobile-responsive with touch targets

### Timer Modes
```javascript
const MODES = {
  work: { label: 'Deep Work', defaultMinutes: 25 },
  shortBreak: { label: 'Short Break', defaultMinutes: 5 },
  longBreak: { label: 'Long Break', defaultMinutes: 15 }
};
```

### State Management
```javascript
const state = {
  mode: 'work',
  timeLeft: 25 * 60,
  isRunning: false,
  workSessionsCompleted: 0,
  timerInterval: null,
  wakeLock: null,
  audioCtx: null,
  // Settings
  customWorkMinutes: 25,
  customShortBreakMinutes: 5,
  customLongBreakMinutes: 15,
  cookiesEnabled: true,
  soundEnabled: true
};
```

### SVG Progress Ring
```javascript
// Circle with r=120, circumference = 2 * π * 120 ≈ 754
const circumference = 754;
const offset = circumference - (timeLeft / totalTime) * circumference;
progressCircle.style.strokeDashoffset = offset;
```

### Audio Generation
Uses Web Audio API to generate pleasant chime:
- Oscillator with exponential ramp
- Gain node for envelope
- No external audio files

### Unique Implementation Details
- Wake Lock API: `navigator.wakeLock.request('screen')`
- Mobile detection: `navigator.userAgentData?.mobile`
- Button press animation via CSS class + reflow
- State auto-saved every 10 seconds

### File Locations
- `/home/qq/.openclaw/workspace/flow/index.html`
- `/home/qq/.openclaw/workspace/flow/app.js` (25KB)
- `/home/qq/.openclaw/workspace/flow/styles.css` (13KB)
- `/home/qq/.openclaw/workspace/flow/manifest.json` (PWA)
- `/home/qq/.openclaw/workspace/flow/sw.js` (service worker)

---

## ☄️ Nova Site - Portfolio Page

### Technologies
- **HTML5** - Semantic structure
- **CSS3** - Grid, flexbox, custom properties
- **Google Fonts** - Inter font family
- **GitHub Pages** - Static hosting

### Key Features
- Animated stars background (JS-generated)
- Floating avatar animation
- Project grid with hover effects
- GitHub/OpenClaw connect buttons
- Responsive design

### CSS Custom Properties
```css
:root {
  --bg-deep: #0a0a0f;
  --bg-primary: #0f0f1a;
  --accent: #6366f1;
  --comet: #f472b6;
}
```

### Star Animation
```javascript
for (let i = 0; i < 50; i++) {
  const star = document.createElement('div');
  star.className = 'star';
  star.style.left = Math.random() * 100 + '%';
  star.style.top = Math.random() * 100 + '%';
  star.style.animationDelay = Math.random() * 3 + 's';
  starsContainer.appendChild(star);
}
```

### File Locations
- `/home/qq/.openclaw/workspace/projects/nova-site/index.html`
- `/home/qq/.openclaw/workspace/projects/nova-site/style.css`

---

## 🏠 QQSHI13.github.io - Main Hub

### Technologies
- **HTML5** - Clean semantic markup
- **CSS3** - Grid layout, transitions
- **Google Fonts** - Inter font
- **GitHub Pages** - Static hosting

### Key Features
- Grid of all tools with icons
- Consistent card hover effect (translateY + border color)
- Links to all sub-projects
- Mobile-responsive grid

### Projects Listed
1. ⏱️ Flow - Pomodoro timer
2. 🕐 Time - Minimalist clock
3. 🎮 24 - 24 points game solver
4. 📦 DropTransfer - P2P file sharing
5. ⚡ API Tester - HTTP client
6. 🌳 JSON Visualizer - Tree viewer
7. 🔍 Regex Tester - Pattern matcher
8. 🔑 JWT Decoder - Token inspector
9. 📊 CSV to JSON - Data converter

### Additional Pages
- `/time.html` - Fullscreen clock (minimalist)
- `/24.html` - 24 game solver

### File Locations
- `/home/qq/.openclaw/workspace/QQSHI13.github.io/index.html`
- `/home/qq/.openclaw/workspace/QQSHI13.github.io/time.html`
- `/home/qq/.openclaw/workspace/QQSHI13.github.io/24.html`

---

## 🎮 24 Game Solver

### Technologies
- **Vanilla JavaScript** - Algorithm implementation
- **CSS3** - Modern styling with CSS variables
- **Google Fonts** - Roboto

### Algorithm
Brute-force search with:
1. **Permutations** - All 4! orderings of numbers
2. **Operators** - All 4³ combinations of +, -, *, /
3. **Structures** - 5 different expression tree shapes

```javascript
const structures = [
  (a, b, c, d, op1, op2, op3) => `((${a}${op1}${b})${op2}${c})${op3}${d}`,
  (a, b, c, d, op1, op2, op3) => `(${a}${op1}(${b}${op2}${c}))${op3}${d}`,
  (a, b, c, d, op1, op2, op3) => `${a}${op1}((${b}${op2}${c})${op3}${d})`,
  (a, b, c, d, op1, op2, op3) => `${a}${op1}(${b}${op2}(${c}${op3}${d}))`,
  (a, b, c, d, op1, op2, op3) => `(${a}${op1}${b})${op3}(${c}${op2}${d})`
];
```

### Unique Implementation
- Uses `eval()` to calculate expression values
- Filters by `Math.abs(value - 24) < 1e-6` for floating point comparison
- Deduplication via `Set` for unique solutions

### File Location
- `/home/qq/.openclaw/workspace/QQSHI13.github.io/24.html`

---

## 🕐 Time - Fullscreen Clock

### Technologies
- **HTML5** - Minimal structure
- **CSS3** - Centered styling, shadows
- **JavaScript** - Simple interval timer

### Features
- Large digital clock display
- Updates every second
- Centered with CSS transform
- Decorative styling with shadows

### Implementation
```javascript
setInterval(() => {
  const date = new Date();
  const str = `${pad(date.getHours())}:${pad(date.getMinutes())}`;
  document.getElementById("time").innerHTML = str;
}, 1000);
```

### File Location
- `/home/qq/.openclaw/workspace/QQSHI13.github.io/time.html`

---

## 📂 Pi Project

### Overview
Raspberry Pi 5 home server project (8GB RAM, 32GB disk)

### Planned Services
1. **Nginx** - Web server/reverse proxy
2. **NAS** - Network Attached Storage
3. **Pi-hole** - DNS ad blocker
4. **Mesh network** - WiFi mesh
5. **OpenClaw** - AI agent runtime
6. **Claude Code** - AI coding assistant
7. **OpenAI Codex** - AI coding model
8. **Kimi Code** - AI coding assistant

### API Keys
- ARK_API_KEY configured for Kimi

### File Location
- `/home/qq/.openclaw/workspace/pi-project/MAIN.md`

---

## 📦 App Inventory

### Purpose
Windows fresh start preparation - inventory of installed software

### Files
- `MASTER-INVENTORY.md` - Overview
- `windows-installed-programs.txt` - Full program list
- `winget-packages.txt` - Winget packages
- `windows-pip-packages.txt` - Python packages
- `windows-npm-global.txt` - npm global packages
- `winget-clean-list.md` - Curated list to keep
- `winget-install-sequence.md` - Installation order
- `FRESH-START-TODO.md` - Task checklist

### PowerShell Scripts
- `collect-windows-inventory.ps1` - Original inventory script
- `collect-windows-inventory-fixed.ps1` - Fixed version

### File Locations
- `/home/qq/.openclaw/workspace/app-inventory/`

---

## 🔍 Common Patterns Across Projects

### CSS Theme (GitHub Dark)
```css
:root {
  --bg: #0d1117;
  --surface: #161b22;
  --surface-hover: #21262d;
  --border: #30363d;
  --text: #c9d1d9;
  --text-secondary: #8b949e;
  --accent: #58a6ff;
  --success: #238636;
  --error: #da3633;
}
```

### Common JavaScript Utilities
```javascript
// Debounce
function debounce(fn, ms) {
  let timeout;
  return (...args) => {
    clearTimeout(timeout);
    timeout = setTimeout(() => fn(...args), ms);
  };
}

// Escape HTML
function escapeHtml(text) {
  const div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML;
}

// Format bytes
function formatBytes(bytes) {
  if (bytes === 0) return '0 B';
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

// Copy to clipboard with feedback
async function copyToClipboard(text, button) {
  await navigator.clipboard.writeText(text);
  const original = button.textContent;
  button.textContent = 'Copied!';
  setTimeout(() => button.textContent = original, 1500);
}
```

### SVG Data URIs for Icons
All projects use inline SVG data URIs for favicons:
```html
<link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' ...%3E%3C/svg%3E">
```

---

## 📊 Architecture Summary

| Aspect | Pattern |
|--------|---------|
| **Styling** | CSS Variables for theming, consistent GitHub dark palette |
| **Layout** | Flexbox and CSS Grid, responsive breakpoints |
| **State** | Vanilla JS objects, localStorage/cookies for persistence |
| **Events** | addEventListener, debounced input handlers |
| **HTTP** | Fetch API for API tester |
| **P2P** | WebRTC via PeerJS for DropTransfer |
| **Audio** | Web Audio API for Flow timer |
| **Files** | FileReader API for CSV upload |
| **PWA** | Service Worker + Manifest for Flow |

---

## 🔧 ESP32 Pomodoro Button - Hardware Project

### Project Info
- **Type**: Embedded Hardware (ESP32)
- **Location**: `/home/qq/.openclaw/workspace/esp32-button/`
- **Cost**: ~¥149-189 per unit
- **Status**: Design complete, ready for fabrication

### Hardware Stack
- **MCU**: M5Stack Atom Lite (ESP32-PICO-D4)
- **Power**: TP4056 charger + XC6206 LDO + 3.7V 500mAh LiPo
- **Connection**: GROVE 4P (HY2.0-4P) cable
- **Mounting**: Backpack style (single M2 center screw)

### Firmware Stack
- **Framework**: Arduino (via PlatformIO)
- **Libraries**: M5Atom, FastLED
- **Storage**: EEPROM for settings persistence
- **Sync**: Serial over USB (115200 baud)

### Key Features
- Standalone Pomodoro timer (no PC required)
- Three modes: Work, Short Break, Long Break
- Session tracking (long break after N work sessions)
- RGB LED status: 🔴 Work, 🟢 Short break, 🔵 Long break
- Active buzzer for timer complete alarm
- Settings sync via serial commands

### File Structure
```
esp32-button/
├── hardware/
│   ├── schematic.md         # Circuit design (backpack mounting)
│   ├── BOM.md              # Component list (~¥149-189)
│   └── EasyEDA-Guide.md    # PCB design steps
├── 3d-models/
│   └── backpack.scad       # Simple backpack case (no lid)
├── firmware/
│   ├── platformio.ini      # PlatformIO config
│   └── src/
│       ├── config.h        # Pin definitions
│       ├── main.cpp        # Main state machine
│       ├── PomodoroButton  # Click detection (single/long press)
│       ├── Timer           # Pomodoro logic with long break
│       ├── LED             # RGB animations
│       ├── Buzzer          # Alarm sounds
│       ├── Storage         # EEPROM settings
│       └── USBHID          # Serial sync protocol
├── web-sync/
│   └── index.html          # Web Serial API interface
└── docs/
    ├── Assembly-Guide.md   # Build instructions
    └── 3D-Case-Spec.md     # Backpack case spec
```

### Pin Mapping (GROVE 4P)
| Pin | Color | Function |
|-----|-------|----------|
| 1 | Black | GND |
| 2 | Red | 5V (3.3V from LDO) |
| 3 | Yellow | G26 → Buzzer |
| 4 | White | G32 (spare) |

### Settings Protocol
```
Command: SET:work=25,break=5,longBreak=15,sessions=4,sound=1
Response: OK
```

### Build Steps
1. Order Atom Lite (¥55)
2. Design PCB in EasyEDA (24x24mm, center M2 hole)
3. Order PCB from JLCPCB (~¥40-50/5pcs)
4. Order components from LCSC (~¥14)
5. Order battery 503040 500mAh (~¥20)
6. 3D print backpack (~¥20-40)
7. Assemble: Screw Atom Lite + Extension + Backpack together

---

## 🔗 Related Resources

- GitHub: https://github.com/QQSHI13
- Main Site: https://qqshi13.github.io
- Nova Portfolio: https://qqshi13.github.io/nova/
- OpenClaw: https://openclaw.ai

---

*Index generated for semantic search and code-aware assistance*
