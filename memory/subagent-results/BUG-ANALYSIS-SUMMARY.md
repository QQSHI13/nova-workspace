# Bug Analysis Summary - All Repos
**Date:** 2026-03-20  
**Analysis completed by:** 8 Claude Code agents (plan mode)

---

## Overview

| Repository | Critical | High | Medium | Low | Total |
|------------|----------|------|--------|-----|-------|
| QQSHI13.github.io | 1 | 7 | 25 | 25 | **58** |
| tools-suite | 4 | 5 | 13 | 14 | **36** |
| collaboard | 6 | 8 | 11 | 7 | **32** |
| flow | 0 | 7 | 13 | 14 | **34** |
| droptransfer | 3 | 4 | 8 | 9 | **24** |
| lifelab | 0 | 5 | 16 | 17 | **38** |
| nova-site | 1 | 4 | 6 | 6 | **17** |
| M5Timer | 0 | 4 | 6 | 4 | **14** |
| **TOTAL** | **15** | **44** | **88** | **86** | **233** |

---

## Critical Issues (Fix Immediately)

### QQSHI13.github.io
- **C1:** 404.html links to `/projects` (404s) - should be `/projects.html`

### tools-suite
- **XSS:** Regex Tester - `e.message` inserted into innerHTML without escaping
- **XSS:** JWT Decoder - payload values not escaped before HTML insertion
- **Crash:** Color Picker - extra `)` in querySelector breaks harmony generator
- **Crash:** Color Picker - `event.target` fails in Firefox (no event param)

### collaboard
- **BUG-001:** Peer undo removes wrong stroke - no stroke identity in broadcast
- **BUG-002:** Joining peer's viewport overwritten by host's state
- **BUG-003:** `ctx.scale(dpr, dpr)` cumulative on resize - corrupts coordinates
- **BUG-004:** Split `beforeunload` handlers - incomplete cleanup
- **BUG-005:** Close handler uses `roomCode` instead of `conn.peer` as Map key
- **BUG-006:** Unconditional modal unhide during auto-retry

### droptransfer
- **BUG-001:** ACK key mismatch - retried chunks never cleared, infinite retry loops
- **BUG-002:** Chunk validation inverted - rejects ALL valid binary chunks
- **BUG-003:** Size validation on pre-decryption data - AES-GCM padding causes failures

### nova-site
- **CSP breaks everything** - `script-src 'self'` blocks inline scripts AND Google Analytics

---

## High Priority Issues

### QQSHI13.github.io
- H1: `<meta charset>` after GA scripts (encoding issues)
- H2: No skip navigation link (WCAG violation)
- H3: No focus styles on nav links (keyboard users lost)
- H4: `outline: none` on inputs without replacement
- H5: Search input missing `<label>`
- H6: Missing `<meta description>` and OG tags
- H7: `jekyll-paginate` listed but not in plugins

### tools-suite
- File corruption: API Tester and JSON Viewer have duplicate `</html>` tags
- O(n³) performance: Life Pattern Generator - 20M comparisons/step at 80×80
- Full DOM rebuild per step: Life Pattern Generator destroys/recreates 6400 cells
- Stack overflow: Diff Viewer spreads Uint8Array into String.fromCharCode() (>65KB)
- Mobile unusable: Life Pattern Generator has zero touch handlers

### collaboard
- BUG-007: HiDPI stroke culling uses wrong pixels - strokes invisible on Retina
- BUG-012: Space pan mode stuck if user Alt+Tabs
- BUG-013: Peer color values sanitized with HTML escaper (not color allowlist)
- BUG-024: No scroll wheel zoom (missing feature)

### flow
- Interval leak: `onComplete()` calls `start()` without clearing old interval
- SW: No offline fallback - cache miss shows native error page
- manifest.json: Data URI icons not supported for PWA install
- manifest.json: Missing 512×512 icon (Chrome won't prompt)
- icon-192.png: File doesn't exist (dead link)

### droptransfer
- BUG-004: Race condition - null `encryptionKey` causes plaintext sends
- BUG-007: WebTorrent `client.on('error')` accumulates duplicate handlers
- BUG-008: `peer.reconnect()` called on destroyed peers, no backoff
- BUG-012: 20-second timeout aborts large folder zipping

### lifelab
- BUG-4: Toroidal `step()` stores cells at un-wrapped coordinates → data corruption
- BUG-22: Single-finger touch draws even when `currentTool === 'pan'`
- BUG-24: Pinch-zoom doesn't pivot around center
- BUG-33: Drawing never clears `futureHistory` → stale redo states
- BUG-35: Toroidal wrap boundaries use viewport-dependent dimensions

### nova-site
- `skipWaiting()` outside `waitUntil` - SW activates before cache populated
- `event.waitUntil()` on MessageEvent - TypeError crash
- Hard reload detection broken - `redirectCount === 0` true for all reloads
- Mutable `isHardReload` flag read/written across concurrent fetch events

### M5Timer
- BUG-03/11: `indexOf("break=")` matches inside `"longBreak="` - corrupts settings
- BUG-05: Interrupting WORK session still increments `completedWorkSessions`
- BUG-01: Negative `remainingSeconds` cast to uint32_t → infinite sleep
- BUG-02: Unsigned underflow skips final countdown beep

---

## Recommended Fix Priority

### Phase 1: Security & Crashes (Deploy Immediately)
1. **tools-suite XSS fixes** (Regex Tester, JWT Decoder)
2. **tools-suite Color Picker crashes**
3. **nova-site CSP fix** (unblocks all JS)
4. **droptransfer encryption bugs**

### Phase 2: Core Functionality
5. **collaboard** peer sync bugs
6. **flow** interval leak
7. **lifelab** toroidal/grid bugs
8. **M5Timer** timer accuracy bugs

### Phase 3: Performance & UX
9. **tools-suite** Life Pattern Generator performance
10. **QQSHI13.github.io** accessibility issues
11. **All repos** PWA improvements

### Phase 4: Polish
12. **All repos** Low priority issues

---

## Next Steps

**Approve this plan?** I'll spawn fix agents for each repository, starting with Critical and High priority issues.

Or tell me:
- Which repos to prioritize?
- Any specific bugs you want fixed first?
- Any repos to skip?
