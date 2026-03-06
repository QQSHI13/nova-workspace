# QQ's Deployed Tools Knowledge Base

A comprehensive documentation of all developer tools built and deployed by QQ.

---

## Overview

All tools follow a consistent architecture pattern:
- **Single-file HTML applications** - Self-contained, no build step required
- **Vanilla JavaScript** - No frontend frameworks, pure browser APIs
- **GitHub Dark Theme** - Consistent `#0d1117` background with `#58a6ff` accent
- **GitHub Pages hosting** - Free static hosting with custom domains
- **Progressive Web App (PWA) ready** - Service workers and manifests where applicable

---

## 1. DropTransfer 📦

**P2P file sharing with no server storage**

### Live URL
https://qqshi13.github.io/droptransfer/

### GitHub Repository
https://github.com/QQSHI13/droptransfer

### Tech Stack
| Component | Technology |
|-----------|------------|
| P2P Connection | WebRTC via PeerJS |
| Signaling | PeerJS Cloud (free tier) |
| File Chunking | Custom 16KB chunks (`CHUNK_SIZE = 16384`) |
| UI | Single-file HTML with embedded CSS/JS |
| Hosting | GitHub Pages |

### Key Implementation Details

**WebRTC DataChannel Architecture:**
```javascript
// Chunked file transfer for large files
const CHUNK_SIZE = 16384; // 16KB chunks
let receivedChunks = [];
let receivedSize = 0;
```

**Transfer Flow:**
1. Sender generates PeerJS ID (auto-generated)
2. Sender creates data channel and waits for receiver
3. Receiver enters sender's code to initiate connection
4. File metadata exchanged first (`name`, `size`, `type`)
5. File chunked and streamed via `dataChannel.send(chunk)`
6. Progress tracked via chunk acknowledgments
7. Receiver reconstructs file from chunks and triggers download

**Connection States:**
- `waiting` - Awaiting peer connection
- `connected` - Data channel established
- `transferring` - Active file transfer
- `completed` - Transfer finished

### Design Patterns
- **Factory Pattern**: Peer initialization with retry logic
- **Observer Pattern**: Event listeners for WebRTC state changes
- **Chunked Transfer**: Memory-efficient large file handling
- **Tab-based UI**: Send/Receive mode switching

### APIs/Endpoints
- **PeerJS Cloud**: `https://0.peerjs.com` (free public signaling)
- **WebRTC APIs**: `RTCPeerConnection`, `RTCDataChannel`
- **File APIs**: `FileReader`, `URL.createObjectURL()`, `Blob`

### Limitations
- Requires both peers to keep page open during transfer
- May fail behind strict NATs/firewalls (no TURN relay yet)
- No resume capability for interrupted transfers

---

## 2. API Tester ⚡

**Lightweight HTTP client in the browser**

### Live URL
https://qqshi13.github.io/api-tester/

### GitHub Repository
https://github.com/QQSHI13/api-tester

### Tech Stack
| Component | Technology |
|-----------|------------|
| HTTP Requests | Fetch API |
| State Persistence | localStorage |
| URL Sharing | Base64 + URL encoding |
| UI | CSS Grid layout (3-column responsive) |
| Hosting | GitHub Pages |

### Key Implementation Details

**Request Storage Schema:**
```javascript
// History stored in localStorage
{
  method: 'POST',
  url: 'https://api.example.com/users',
  headers: { 'Content-Type': 'application/json' },
  body: '{"name":"test"}',
  timestamp: 1700000000000
}
```

**URL Sharing Format:**
```
?m=POST&url=https://api.example.com&h=eyJDb250ZW50LVR5cGUiOiJhcHBsaWNhdGlvbi9qc29uIn0=&b=eyJuYW1lIjoidGVzdCJ9
```
- `m` = method
- `url` = URL (raw)
- `h` = Base64-encoded headers JSON
- `b` = Base64-encoded body

**HTTP Methods Supported:**
- GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS

**Response Handling:**
- Syntax highlighting for JSON responses
- Headers displayed in key-value table
- Status code with color coding (2xx=green, 4xx=red, 5xx=red)

### Design Patterns
- **MVC Pattern**: Model (request data), View (UI), Controller (event handlers)
- **History Stack**: LIFO with 50-item limit
- **Responsive Layout**: CSS Grid with media query breakpoints
  - Desktop: 3-column (sidebar + request + response)
  - Tablet: 2-column (request + response)
  - Mobile: 1-column stacked

### APIs/Endpoints
- **Fetch API**: `fetch(url, options)`
- **localStorage**: `localStorage.getItem/setItem`
- **Clipboard API**: `navigator.clipboard.writeText`

### Security Notes
- All requests made directly from browser (CORS-dependent)
- No proxy server - API keys stay client-side
- URL sharing exposes request data in plaintext (Base64 not encryption)

---

## 3. JSON Visualizer 🌳

**Interactive collapsible JSON tree viewer**

### Live URL
https://qqshi13.github.io/json-viewer/

### GitHub Repository
https://github.com/QQSHI13/json-viewer

### Tech Stack
| Component | Technology |
|-----------|------------|
| JSON Parsing | Native `JSON.parse()` |
| Tree Rendering | Recursive DOM generation |
| Syntax Highlighting | CSS classes per type |
| UI | Split-pane layout |
| Hosting | GitHub Pages |

### Key Implementation Details

**Recursive Tree Builder:**
```javascript
function renderTree(obj, key, depth = 0) {
  if (typeof obj === 'object' && obj !== null) {
    // Collapsible container for objects/arrays
    return `<div class="node">
      <span class="toggle" onclick="toggle(this)">▶</span>
      <span class="key">${key}:</span>
      <div class="children">
        ${Object.entries(obj).map(([k, v]) => renderTree(v, k, depth + 1)).join('')}
      </div>
    </div>`;
  }
  // Primitive value
  return `<div class="leaf"><span class="key">${key}:</span>${formatValue(obj)}</div>`;
}
```

**Color Scheme (GitHub-inspired):**
| Type | Color |
|------|-------|
| String | `#a5d6ff` (light blue) |
| Number | `#79c0ff` (blue) |
| Boolean | `#ff7b72` (red/coral) |
| Null | `#ff7b72` (red/coral) |
| Key | `#7ee787` (green) |

**Validation & Stats:**
- Real-time JSON validation with error highlighting
- File size calculation (`Blob` size)
- Node count (recursive traversal)
- Nesting depth (max depth calculation)

### Design Patterns
- **Recursive Rendering**: Tree structure via recursive function calls
- **Event Delegation**: Single click handler for all toggle buttons
- **Live Validation**: Input debouncing for performance
- **Two-way Sync**: Editor ↔ Tree view synchronization

### APIs/Endpoints
- **JSON API**: `JSON.parse()`, `JSON.stringify()`
- **Clipboard API**: Copy formatted JSON

### Features
- Collapsible/expandable nodes
- One-click format/prettify
- One-click minify
- Copy to clipboard
- Pre-loaded sample data

---

## 4. Regex Tester 🔍

**Live regex pattern matching with substitution preview**

### Live URL
https://qqshi13.github.io/regex-tester/

### GitHub Repository
https://github.com/QQSHI13/regex-tester

### Tech Stack
| Component | Technology |
|-----------|------------|
| Regex Engine | Native JavaScript `RegExp` |
| Live Matching | Input event listeners |
| Pattern Library | Hardcoded common patterns |
| UI | Split-pane with regex input bar |
| Hosting | GitHub Pages |

### Key Implementation Details

**Live Match Highlighting:**
```javascript
function highlightMatches(text, pattern, flags) {
  const regex = new RegExp(pattern, flags);
  let match;
  let lastIndex = 0;
  let html = '';
  
  while ((match = regex.exec(text)) !== null) {
    // Add text before match
    html += escapeHtml(text.slice(lastIndex, match.index));
    // Add highlighted match
    html += `<mark class="match" data-groups="${encodeGroups(match)}">${escapeHtml(match[0])}</mark>`;
    lastIndex = match.index + match[0].length;
  }
  html += escapeHtml(text.slice(lastIndex));
  return html;
}
```

**Built-in Pattern Library (12 patterns):**
| Pattern | Regex |
|---------|-------|
| Email | `[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}` |
| URL | `https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)` |
| IP Address | `\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b` |
| Phone | `[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}` |
| Date (YYYY-MM-DD) | `\d{4}-(?:0[1-9]|1[0-2])-(?:0[1-9]|[12]\d|3[01])` |
| Hex Color | `#(?:[0-9a-fA-F]{3}){1,2}` |
| Credit Card | `(?:4[0-9]{12}(?:[0-9]{3})?\|5[1-5][0-9]{14}\|3[47][0-9]{13})` |
| HTML Tags | `<([a-z][a-z0-9]*)\b[^>]*>(.*?)<\/\1>` |
| Username | `^[a-zA-Z0-9_-]{3,16}$` |
| Password (Strong) | `^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$` |
| IPv6 | `(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}\|...)` |
| MAC Address | `([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})` |

**Substitution Preview:**
- Supports `$&` (matched text), `$1-$9` (capture groups)
- Real-time replace preview

### Design Patterns
- **Real-time Processing**: Debounced input handling
- **Pattern Library**: Dropdown selection populates regex input
- **Visual Feedback**: Color-coded matches with hover tooltips for groups

### APIs/Endpoints
- **RegExp API**: Native JavaScript regex engine
- **String methods**: `match()`, `replace()`, `split()`

### Flags Support
- `g` - Global match
- `i` - Ignore case
- `m` - Multiline

---

## 5. JWT Decoder 🔑

**Decode and inspect JSON Web Tokens**

### Live URL
https://qqshi13.github.io/jwt-decoder/

### GitHub Repository
https://github.com/QQSHI13/jwt-decoder

### Tech Stack
| Component | Technology |
|-----------|------------|
| Base64 Decoding | Native `atob()` with URL-safe handling |
| JSON Parsing | Native `JSON.parse()` |
| Expiry Detection | `Date.now()` comparison |
| UI | 3-panel layout (Input/Header/Payload) |
| Hosting | GitHub Pages |

### Key Implementation Details

**JWT Structure Parsing:**
```javascript
function decodeJWT(token) {
  const [headerB64, payloadB64, signature] = token.split('.');
  
  return {
    header: JSON.parse(base64UrlDecode(headerB64)),
    payload: JSON.parse(base64UrlDecode(payloadB64)),
    signature: signature // Raw base64url string
  };
}

function base64UrlDecode(str) {
  // Replace URL-safe chars and add padding
  const padding = '='.repeat((4 - str.length % 4) % 4);
  const base64 = str.replace(/-/g, '+').replace(/_/g, '/') + padding;
  return decodeURIComponent(escape(atob(base64)));
}
```

**Expiry Detection:**
```javascript
function checkExpiry(payload) {
  if (!payload.exp) return null;
  
  const now = Math.floor(Date.now() / 1000);
  const expiresIn = payload.exp - now;
  
  if (expiresIn < 0) return { status: 'expired', color: 'red' };
  if (expiresIn < 3600) return { status: 'expires_soon', color: 'yellow' };
  return { status: 'valid', color: 'green' };
}
```

**Sample Tokens Included:**
- Valid token example
- Expired token example
- Token with custom claims

### Design Patterns
- **Pipeline Processing**: Parse → Decode → Validate → Display
- **Defensive Coding**: Try-catch around parsing with user-friendly errors
- **Visual Status**: Color-coded expiry badges

### APIs/Endpoints
- **Base64**: `atob()`, `btoa()` with URL-safe variants
- **Date API**: `Date.now()`, `new Date().toLocaleString()`

### JWT Claims Supported
- Standard: `iss`, `sub`, `aud`, `exp`, `nbf`, `iat`, `jti`
- Custom: Any additional payload claims

---

## 6. CSV to JSON Converter 📊

**Transform CSV data to JSON instantly**

### Live URL
https://qqshi13.github.io/csv-json/

### GitHub Repository
https://github.com/QQSHI13/csv-json

### Tech Stack
| Component | Technology |
|-----------|------------|
| CSV Parsing | Custom parser (no libraries) |
| File Input | FileReader API |
| Type Inference | `!isNaN()`, regex boolean checks |
| UI | Split-pane with options bar |
| Hosting | GitHub Pages |

### Key Implementation Details

**CSV Parser Logic:**
```javascript
function parseCSV(csv, options) {
  const lines = csv.split(/\r?\n/).filter(line => line.trim());
  const headers = parseLine(lines[0]);
  
  return lines.slice(1).map(line => {
    const values = parseLine(line);
    const obj = {};
    headers.forEach((header, i) => {
      let value = values[i] || '';
      if (options.trim) value = value.trim();
      if (options.parseNumbers && !isNaN(value)) value = Number(value);
      if (options.parseBooleans) {
        if (value.toLowerCase() === 'true') value = true;
        if (value.toLowerCase() === 'false') value = false;
      }
      obj[header] = value;
    });
    return obj;
  });
}

function parseLine(line) {
  // Handle quoted fields with commas
  const result = [];
  let current = '';
  let inQuotes = false;
  
  for (const char of line) {
    if (char === '"') {
      inQuotes = !inQuotes;
    } else if (char === ',' && !inQuotes) {
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

**Conversion Options:**
| Option | Description |
|--------|-------------|
| First row as headers | Use first CSV row as JSON keys |
| Trim whitespace | Remove leading/trailing spaces from values |
| Parse numbers | Convert numeric strings to numbers |
| Parse booleans | Convert "true"/"false" to booleans |
| Minify output | Single-line JSON without formatting |

**File Handling:**
- Drag & drop support with `dragover`, `dragleave`, `drop` events
- FileReader for text extraction
- CSV/TXT MIME type validation

### Design Patterns
- **Streaming-friendly**: Line-by-line processing (could handle large files)
- **Options Pattern**: Configurable transformation behavior
- **Dual Input**: File upload OR paste text

### APIs/Endpoints
- **File API**: `FileReader.readAsText()`
- **Drag & Drop API**: `DataTransfer.files`
- **Download API**: `URL.createObjectURL()` + anchor click

### CSV Format Support
- Comma-separated values
- Tab-separated values (auto-detected)
- Quoted fields with embedded commas
- Multiline fields (within quotes)

---

## 7. Diff Viewer

**Side-by-side and inline text comparison**

### Live URL
https://qqshi13.github.io/diff-viewer/

### GitHub Repository
https://github.com/QQSHI13/diff-viewer

### Tech Stack
| Component | Technology |
|-----------|------------|
| Diff Algorithm | `diff-match-patch` library (Google) |
| Syntax Highlighting | None (plain text with diff colors) |
| View Modes | Split-pane + Inline |
| UI | 3-column layout (Original | Modified | Diff) |
| Hosting | GitHub Pages |

### Key Implementation Details

**Diff Algorithm:**
```javascript
const dmp = new diff_match_patch();

function computeDiff(original, modified) {
  const diffs = dmp.diff_main(original, modified);
  dmp.diff_cleanupSemantic(diffs); // Optimize for human readability
  return diffs;
}
// Returns: [[-1, "deleted"], [0, "unchanged"], [1, "inserted"], ...]
```

**Split View Rendering:**
```javascript
function renderSplitView(diffs) {
  const leftLines = [];
  const rightLines = [];
  let leftLineNum = 1;
  let rightLineNum = 1;

  diffs.forEach(([type, text]) => {
    const lines = text.split('\n').filter(l => l);
    lines.forEach(line => {
      if (type === 0) { // Equal
        leftLines.push({ type: 'unchanged', content: line, num: leftLineNum++ });
        rightLines.push({ type: 'unchanged', content: line, num: rightLineNum++ });
      } else if (type === -1) { // Deleted
        leftLines.push({ type: 'removed', content: line, num: leftLineNum++ });
      } else if (type === 1) { // Inserted
        rightLines.push({ type: 'added', content: line, num: rightLineNum++ });
      }
    });
  });
  
  // Render aligned panes with line numbers
}
```

**Inline View Rendering:**
- Single column with `+` / `-` / ` ` markers
- Added lines (green), Removed lines (red), Unchanged (gray)

**Shareable URLs:**
- Base64-encodes both original and modified text
- URL hash contains full diff state

### Design Patterns
- **Strategy Pattern**: Split view vs Inline view as interchangeable renderers
- **Line-based Diff**: Character diff aggregated to line level for display
- **URL State Sync**: Base64 encoding for shareable diffs

### APIs/Endpoints
- **diff-match-patch**: Google's diff library
- **Clipboard API**: Copy diff output as unified diff format

### View Modes
| Mode | Description |
|------|-------------|
| Split | Side-by-side original vs modified |
| Inline | Single column with +/- markers |

### Stats Tracked
- Lines added
- Lines removed
- Lines unchanged

---

## 8. Time & Flow ⏱️

**Pomodoro timer with progress ring and PWA support**

### Live URL
https://qqshi13.github.io/flow/

### GitHub Repository
https://github.com/QQSHI13/flow

### Tech Stack
| Component | Technology |
|-----------|------------|
| Timer Engine | `setInterval()` with 1-second ticks |
| State Persistence | Cookies (optional) |
| Audio | Web Audio API (oscillator-based) |
| Wake Lock | Screen Wake Lock API |
| PWA | Service Worker + Manifest |
| UI | SVG progress ring + CSS animations |
| Hosting | GitHub Pages |

### Key Implementation Details

**Progress Ring SVG:**
```javascript
// SVG circle with stroke-dasharray for progress
const circumference = 2 * Math.PI * radius;
progressCircle.style.strokeDasharray = circumference;

function updateProgress(percent) {
  const offset = circumference - (percent / 100) * circumference;
  progressCircle.style.strokeDashoffset = offset;
}
```

**Timer State Machine:**
```
Work (25min) → Short Break (5min) → Work → ... → Long Break (15min after 4 sessions)
```

**Audio Generation (Web Audio API):**
```javascript
function playChime() {
  const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
  const oscillator = audioCtx.createOscillator();
  const gainNode = audioCtx.createGain();
  
  oscillator.connect(gainNode);
  gainNode.connect(audioCtx.destination);
  
  oscillator.frequency.value = 523.25; // C5 note
  gainNode.gain.setValueAtTime(0.3, audioCtx.currentTime);
  gainNode.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 1);
  
  oscillator.start();
  oscillator.stop(audioCtx.currentTime + 1);
}
```

**Wake Lock Implementation:**
```javascript
async function requestWakeLock() {
  if ('wakeLock' in navigator) {
    state.wakeLock = await navigator.wakeLock.request('screen');
  }
}
// Prevents screen from sleeping during timer
```

**State Persistence (Cookies):**
```javascript
const cookies = {
  set(name, value, days) {
    const expires = new Date();
    expires.setTime(expires.getTime() + days * 24 * 60 * 60 * 1000);
    document.cookie = `${name}=${encodeURIComponent(value)};expires=${expires.toUTCString()};path=/`;
  },
  get(name) {
    const match = document.cookie.match(new RegExp('(^| )' + name + '=([^;]+)'));
    return match ? decodeURIComponent(match[2]) : null;
  }
};
```

### Design Patterns
- **State Machine**: Work → Short Break → Work → Long Break cycle
- **Module Pattern**: Grouped by functionality (utils, cookies, audio, UI)
- **Feature Detection**: Progressive enhancement for Wake Lock, Web Audio
- **Fullscreen API**: Optional distraction-free mode

### Keyboard Shortcuts
| Key | Action |
|-----|--------|
| Space | Play/Pause |
| R | Reset (running) / Switch mode (paused) |
| F | Toggle fullscreen |

### PWA Features
- **Manifest**: `manifest.json` with icons, theme colors
- **Service Worker**: Caches core assets for offline use
- **Standalone Mode**: Can be "installed" on mobile/desktop

### Configuration
```javascript
const CONFIG = {
  SESSIONS_BEFORE_LONG_BREAK: 4,
  DEFAULTS: {
    workMinutes: 25,
    shortBreakMinutes: 5,
    longBreakMinutes: 15,
    cookiesEnabled: true,
    soundEnabled: true
  }
};
```

### APIs/Endpoints
- **Web Audio API**: `AudioContext`, `OscillatorNode`
- **Screen Wake Lock API**: `navigator.wakeLock.request()`
- **Fullscreen API**: `document.documentElement.requestFullscreen()`
- **Cookie API**: `document.cookie`
- **Service Worker API**: Cache-first strategy

---

## 9. Nova ☄️

**Personal site and tools directory**

### Live URL
https://qqshi13.github.io/

### GitHub Repository
https://github.com/QQSHI13/QQSHI13.github.io

### Tech Stack
| Component | Technology |
|-----------|------------|
| Routing | Static file paths (GitHub Pages) |
| Styling | CSS Grid + Flexbox |
| Icons | Emoji + Inline SVG |
| Hosting | GitHub Pages (root) |

### Key Implementation Details

**Site Structure:**
```
qqshi13.github.io/
├── index.html          # Tools directory (landing page)
├── time.html           # Minimalist digital clock
├── 24.html             # 24-point game solver
├── flow/               # Pomodoro timer (separate repo)
├── droptransfer/       # P2P file sharing (separate repo)
├── api-tester/         # HTTP client (separate repo)
├── json-viewer/        # JSON viewer (separate repo)
├── regex-tester/       # Regex tool (separate repo)
├── jwt-decoder/        # JWT inspector (separate repo)
├── csv-json/           # CSV converter (separate repo)
├── diff-viewer/        # Diff tool (separate repo)
└── nova/               # About page (separate repo)
```

**Tools Grid (Landing Page):**
```html
<div class="tools-grid">
  <a href="/flow/" class="tool-card">
    <div class="tool-icon">⏱️</div>
    <div class="tool-info">
      <div class="tool-title">Flow</div>
      <div class="tool-desc">Pomodoro timer with progress ring</div>
    </div>
    <div class="arrow">→</div>
  </a>
  <!-- ... more tools ... -->
</div>
```

**Card Hover Effects:**
- Scale transform on hover
- Border color change to accent (`#58a6ff`)
- Arrow opacity fade-in

### Design Patterns
- **Component Pattern**: Reusable tool card structure
- **Responsive Grid**: `auto-fit` with `minmax()` for fluid layouts
- **Consistent Branding**: Same color scheme across all tools

### Sub-Pages

#### time.html - Minimalist Digital Clock
- Full-screen digital clock
- HH:MM:SS format
- Updates every second via `setInterval`

#### 24.html - 24 Points Game Solver
- Mathematical expression solver
- Finds combinations of 4 numbers that equal 24
- Uses brute-force permutation with operators (+, -, *, /)

---

## Common Design System

### Color Palette
| Variable | Value | Usage |
|----------|-------|-------|
| `--bg` | `#0d1117` | Page background |
| `--surface` | `#161b22` | Card backgrounds |
| `--surface-hover` | `#21262d` | Hover states |
| `--border` | `#30363d` | Borders, dividers |
| `--text` | `#c9d1d9` | Primary text |
| `--text-secondary` | `#8b949e` | Secondary text |
| `--accent` | `#58a6ff` | Links, buttons, highlights |
| `--success` | `#238636` | Success states, added lines |
| `--error` | `#da3633` | Errors, removed lines |

### Typography
- **Font Family**: `-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif`
- **Monospace**: `'JetBrains Mono', 'Fira Code', monospace` (for code)

### Spacing Scale
- `--space-1`: `4px`
- `--space-2`: `8px`
- `--space-3`: `16px`
- `--space-4`: `24px`
- `--space-5`: `32px`
- `--space-6`: `40px`

### Breakpoints
- **Mobile**: `< 600px`
- **Tablet**: `600px - 900px`
- **Desktop**: `> 900px`

---

## Deployment Architecture

### GitHub Pages Setup
```yaml
# All repos use gh-pages branch or main branch
# Settings → Pages → Source: Deploy from a branch
# Branch: main /root (or /docs)
```

### Repository Structure
Each tool is a **separate repository** under `QQSHI13`:
- Allows independent versioning
- Separate issue tracking
- Independent deployments
- Clean git history per tool

### Domain Structure
```
https://qqshi13.github.io/           # Nova landing page
https://qqshi13.github.io/flow/       # Time & Flow
https://qqshi13.github.io/droptransfer/  # DropTransfer
https://qqshi13.github.io/api-tester/    # API Tester
https://qqshi13.github.io/json-viewer/   # JSON Visualizer
https://qqshi13.github.io/regex-tester/  # Regex Tester
https://qqshi13.github.io/jwt-decoder/   # JWT Decoder
https://qqshi13.github.io/csv-json/      # CSV to JSON
https://qqshi13.github.io/diff-viewer/   # Diff Viewer
https://qqshi13.github.io/nova/          # Nova about page
```

---

## Performance Characteristics

### Bundle Sizes
| Tool | Size | Notes |
|------|------|-------|
| DropTransfer | ~24KB | Includes PeerJS CDN |
| API Tester | ~38KB | Largest due to UI complexity |
| JSON Visualizer | ~15KB | |
| Regex Tester | ~17KB | |
| JWT Decoder | ~14KB | |
| CSV to JSON | ~17KB | |
| Diff Viewer | ~25KB | Includes diff-match-patch |
| Time & Flow | ~39KB | Includes PWA assets |
| Nova | ~7KB | Simple landing page |

### CDN Dependencies
- **PeerJS**: `https://unpkg.com/peerjs@1.5.2/dist/peerjs.min.js` (DropTransfer only)
- **diff-match-patch**: Bundled in diff-viewer repo

### Loading Strategy
- No external CSS files (embedded in HTML)
- No external JS files (except PeerJS)
- Inline SVG icons (no icon font)
- Data URI favicons (no separate requests)

---

## Security Considerations

### Client-Side Only
- No server-side processing for any tool
- No data leaves the browser (except API Tester's user-initiated requests)

### API Tester Privacy
- Requests made directly from browser
- No proxy/logging server
- API keys visible in URL when sharing

### DropTransfer Security
- P2P encryption via WebRTC DTLS
- No file storage on servers
- Transfer codes are temporary (session-based)

### Content Security
- No eval() or inline script injection
- XSS-resistant via `textContent` assignment
- HTML escaping for user input display

---

## Future Enhancement Ideas

### DropTransfer
- [ ] Custom TURN server for NAT traversal
- [ ] Multi-file selection
- [ ] Transfer resume capability
- [ ] End-to-end encryption (additional layer)

### API Tester
- [ ] Environment variables / secrets management
- [ ] Response history
- [ ] Import/export collections
- [ ] GraphQL support

### JSON Visualizer
- [ ] JSON Schema validation
- [ ] Search/filter functionality
- [ ] Diff between two JSON files
- [ ] Export to different formats

### Regex Tester
- [ ] Regex explanation breakdown
- [ ] Performance benchmark
- [ ] Match replacement preview improvements
- [ ] Save custom patterns

### JWT Decoder
- [ ] JWT signing/verification
- [ ] Key management (JWK)
- [ ] Token generation

### CSV to JSON
- [ ] JSON to CSV conversion
- [ ] Schema inference
- [ ] Large file streaming
- [ ] Column mapping UI

### Diff Viewer
- [ ] Syntax highlighting integration
- [ ] Three-way merge view
- [ ] Patch file generation
- [ ] Word-level diff option

### Time & Flow
- [ ] Statistics dashboard
- [ ] Task labeling
- [ ] Integration with calendar APIs
- [ ] Team/room sessions

---

## Credits

All tools built by **QQ** with assistance from **Nova** ☄️

Running on [OpenClaw](https://openclaw.ai)
