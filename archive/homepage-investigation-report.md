# Homepage Investigation Report

## Summary

Investigated 3 homepages for QQ:
1. **Main site** (qqshi13.github.io) - `/home/qq/.openclaw/workspace/projects/QQSHI13.github.io/`
2. **Tools Suite** - `/home/qq/.openclaw/workspace/projects/tools-suite/`
3. **Nova site** - `/home/qq/.openclaw/workspace/projects/nova-site/`

---

## 1. Main Site (qqshi13.github.io)

### Location
`/home/qq/.openclaw/workspace/projects/QQSHI13.github.io/`

### Files
- `index.html` - Main landing page ✅
- `projects.html` - Projects listing page ✅
- `404.html` - Custom 404 page ✅

### Issues Found

#### 🔴 CRITICAL: Link Issue
**File:** `index.html` line 168
**Issue:** The CTA button links to `/projects` but this will fail on GitHub Pages
```html
<a href="/projects" class="cta-button">
```
**Fix:** Change to `./projects.html` or `projects.html`
```html
<a href="projects.html" class="cta-button">
```

#### 🟡 MINOR: Outdated Stats
**File:** `index.html` lines 173-184
**Issue:** Stats show "8 Projects" but projects.html lists 8 projects - this is correct but should be verified.

### Links Checked
| Link | Status | Notes |
|------|--------|-------|
| Nova ☄️ | ✅ OK | Links to https://qqshi13.github.io/nova/ |
| OpenClaw | ✅ OK | External link |
| /projects | 🔴 BROKEN | Should be projects.html |

### HTML/CSS/JS Quality
- ✅ Valid HTML5 structure
- ✅ Responsive design with media queries
- ✅ No inline JavaScript errors
- ✅ CSS properly scoped with CSS variables

---

## 2. Tools Suite (qqshi13.github.io/tools-suite/)

### Location
`/home/qq/.openclaw/workspace/projects/tools-suite/`

### Files
- `index.html` - Main tools listing ✅
- `manifest.json` - PWA manifest ✅
- `sw.js` - Service worker ✅
- `README.md` ✅

### Tool Directories (9 tools)
1. `api-tester/` ✅
2. `color-picker-plus/` ✅
3. `csv-json/` ✅
4. `diff-viewer/` ✅
5. `json-viewer/` ✅
6. `jwt-decoder/` ✅
7. `keycode-logger/` ✅
8. `life-pattern-generator/` ✅
9. `regex-tester/` ✅

### Issues Found

#### 🔴 CRITICAL: Missing M5Timer Link
**Issue:** The deployed version has a link to `web-sync.html` for "M5Timer Sync" but this file doesn't exist in the local repo.

**Deployed version shows:**
```html
<a href="web-sync.html" class="tool-card">
    <h3>M5Timer Sync</h3>
    <p>Configure your M5Capsule Pomodoro timer via USB serial</p>
</a>
```

**Local version is MISSING this link.**

**Fix:** Add the M5Timer Sync tool card to the local index.html. The web-sync.html file should be created or the link should be removed from the deployed version.

#### 🟡 WARNING: Inconsistent Tool Naming
The tool is called "M5Timer Sync" in the deployed version but the ESP32 project is in `/home/qq/.openclaw/workspace/projects/esp32-button/`.

### Links Checked
All tool links are relative (e.g., `color-picker-plus/`) which is correct for GitHub Pages.

| Tool | Link | Status |
|------|------|--------|
| Color Picker++ | color-picker-plus/ | ✅ OK |
| API Tester | api-tester/ | ✅ OK |
| JSON Viewer | json-viewer/ | ✅ OK |
| Regex Tester | regex-tester/ | ✅ OK |
| JWT Decoder | jwt-decoder/ | ✅ OK |
| CSV to JSON | csv-json/ | ✅ OK |
| Diff Viewer | diff-viewer/ | ✅ OK |
| Keycode Logger | keycode-logger/ | ✅ OK |
| Game of Life | life-pattern-generator/ | ✅ OK |
| M5Timer Sync | web-sync.html | 🔴 MISSING locally |

### HTML/CSS/JS Quality
- ✅ Valid HTML5 structure
- ✅ Responsive grid layout
- ✅ PWA manifest and service worker
- ✅ No JavaScript errors

---

## 3. Nova Site (qqshi13.github.io/nova/)

### Location
`/home/qq/.openclaw/workspace/projects/nova-site/`

### Files
- `index.html` - Nova's personal page ✅
- `style.css` - External stylesheet ✅
- `manifest.json` - PWA manifest ✅
- `sw.js` - Service worker ✅

### Issues Found

#### 🟡 WARNING: URL Mismatch
**File:** `index.html` line 27
**Issue:** Open Graph URL points to `nova-site/` but site is deployed at `nova/`
```html
<meta property="og:url" content="https://qqshi13.github.io/nova-site/">
```
**Fix:** Update to correct URL
```html
<meta property="og:url" content="https://qqshi13.github.io/nova/">
```

#### 🟡 WARNING: Schema.org URL Mismatch
**File:** `index.html` lines 34-47
**Issue:** Same issue in structured data
```json
"url": "https://qqshi13.github.io/nova-site/"
```
**Fix:** Update to correct URL
```json
"url": "https://qqshi13.github.io/nova/"
```

### Project Links Checked (13 projects)
All project links are absolute URLs to qqshi13.github.io subdirectories:

| Project | URL | Status |
|---------|-----|--------|
| Flow | /flow/ | ✅ OK |
| API Tester | /api-tester/ | ✅ OK |
| JSON Viewer | /json-viewer/ | ✅ OK |
| Regex Tester | /regex-tester/ | ✅ OK |
| JWT Decoder | /jwt-decoder/ | ✅ OK |
| CSV to JSON | /csv-json/ | ✅ OK |
| Diff Viewer | /diff-viewer/ | ✅ OK |
| DropTransfer | /droptransfer/ | ✅ OK |
| Keycode Logger | /keycode-logger/ | ✅ OK |
| CollaBoard | /collaboard/ | ✅ OK |
| LifeLab | /lifelab/ | ✅ OK |
| Quick Notes | github.com/QQSHI13/quick-notes | ✅ OK |
| ESP32 Pomodoro | github.com/QQSHI13/esp32-button | ✅ OK |

### HTML/CSS/JS Quality
- ✅ Excellent accessibility (skip links, ARIA labels, focus indicators)
- ✅ Valid HTML5 with semantic structure
- ✅ Content Security Policy header
- ✅ Open Graph and Twitter Card meta tags
- ✅ Schema.org structured data
- ✅ Reduced motion support for accessibility
- ✅ High contrast mode support
- ✅ External CSS file properly linked
- ✅ No JavaScript errors

---

## Fix Summary

### Immediate Fixes Needed

1. **Main Site - index.html**
   - Change `/projects` to `projects.html` (line ~168)

2. **Tools Suite - index.html**
   - Either add `web-sync.html` file OR remove M5Timer Sync from deployed version
   - Current local version is missing this tool

3. **Nova Site - index.html**
   - Fix Open Graph URL from `nova-site` to `nova` (line 27)
   - Fix Schema.org URL from `nova-site` to `nova` (line 45)

### Verification Steps After Fixes

1. Test all links on main site
2. Verify tools-suite has consistent content between local and deployed
3. Confirm nova-site social sharing previews work correctly

---

## Actions Taken

None yet - awaiting approval to make fixes.
