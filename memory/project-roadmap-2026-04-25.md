# 📋 Project Fix Roadmap — 2026-04-25

**Principle**: Fix what's shipped before building what's new. Stabilize → Make usable → Upgrade → Focus.

---

## Phase 1: Stabilize Old Projects 🩹
*Fix critical/high bugs in already-shipped projects. No new features.*

### 1.1 QuickNotes — BUILD FAILURE (Critical) ✅ DONE
- [x] Remove duplicate anonymous class block (CS0116)
- [x] Fix delete feature (wire up `DeleteNoteCommand`)
- [x] Fix configure editor (show `EditorConfigurationPage`)

### 1.2 tools-suite — Offline Broken + XSS
- [ ] Cache `shared/utils.js` in root service worker
- [ ] Fix `escapeHtml()` to escape quotes (`"` → `&quot;`, `'` → `&#39;`)
- [ ] Add error handling to `copyJSON()` (await clipboard promise)
- [ ] Web Serial cleanup on error/unload

### 1.3 flow — Timer Reset Bug
- [ ] `??` instead of `||` for `timeLeft` in `loadState()`
- [ ] Loop cycle advancement for long absences
- [ ] Add CSP meta tag
- [ ] Fix manifest `start_url`

### 1.4 M5Timer — Session Fraud ✅ DONE
- [x] Fix switch-mode timeout path (don't increment `completedWorkSessions`)
- [x] Reset `pongWaitStartTime` on all SYNC exits
- [x] Remove redundant NVS write on expiry

### 1.5 lifelab — XSS + Mobile
- [ ] Replace `innerHTML` with `textContent` for RLE status
- [ ] Add RLE input length limit (e.g., 50KB)
- [ ] Fix paste mode on touch devices
- [ ] Add CSP meta tag

### 1.6 QQSHI13.github.io / QQSHI13 — Minor
- [ ] Move 24-Point Solver to Web Worker (or cap attempts)
- [ ] Fix SW update toast (QQSHI13)
- [ ] Add `.catch()` to SW update check

**Phase 1 Goal**: All shipped projects work reliably and securely.

---

## Phase 2: Make droptransfer + collaboard Usable 🔧
*These are broken at the core. Fix critical issues to make them actually work.*

### 2.1 droptransfer — Security + Reliability
- [ ] Abort connection when encryption fails (never silently downgrade)
- [ ] Fix heartbeat — receiver must respond to pings
- [ ] Fix receiver progress (`setPath` not `set` with dotted key)
- [ ] Stream chunks instead of loading entire file into memory
- [ ] Add SRI to all CDN scripts
- [ ] Hash verification failure must abort transfer
- [ ] Fix seed/download timeout logic

### 2.2 collaboard — Security + Mobile
- [ ] Harden CSP (remove `unsafe-inline`, restrict `connect-src`)
- [ ] Add SRI to PeerJS CDN script
- [ ] Fix multi-touch drawing (ignore multi-touch gestures)
- [ ] Fix duplicate event listeners
- [ ] Handle LocalStorage quota exceeded
- [ ] Add `"use strict"`
- [ ] Fix export DPR scaling
- [ ] Fix collaborative redo of clear

**Phase 2 Goal**: Both projects are functional and secure enough for real use.

---

## Phase 3: Fully Upgrade lifelab 🚀
*Beyond bug fixes. Add features, improve UX, modernize.*

- [ ] Add `devicePixelRatio` support for crisp rendering on retina
- [ ] Replace `@import` with `<link>` for Google Fonts
- [ ] Fix Pentadecathlon pattern data
- [ ] Implement toroidal wrapping (remove dead `GRID_WIDTH`/`GRID_HEIGHT`)
- [ ] Add pattern search/filter in library
- [ ] Mobile UI improvements (touch gestures, pinch-to-zoom)
- [ ] Performance: use `OffscreenCanvas` or `requestAnimationFrame` throttling
- [ ] Add step-by-step simulation mode
- [ ] Export pattern as RLE/GIF

**Phase 3 Goal**: lifelab goes from "good" to "great" — the best web-based Life simulator.

---

## Phase 4: Focus on skylight-mod + battery-panic 🎮
*Sustained deep work on these two.*

### 4.1 skylight-mod (MC Fabric Mod)
- [ ] Fix difficulty capture order (save BEFORE setting PEACEFUL)
- [ ] Stop forcing Peaceful on all player joins (singleplayer only)
- [ ] Register freecam + time pause keybinds
- [ ] Wire config speed values to FreeCamera
- [ ] Remove dead mixins (`TimePauseMixin`, `MouseMixin`, `GameRendererMixin`)
- [ ] Fix ScreenshotHandler NPE guard
- [ ] Clean up unused imports and redundant `active` field
- [ ] Test on 1.21.1

### 4.2 battery-panic (Godot)
- [ ] Fix battery drain math (target: ~90-100s with all apps open)
- [ ] Validate save data type after JSON parse
- [ ] Replace `free()` with `queue_free()` everywhere
- [ ] Wire level progression system to gameplay
- [ ] Fix music system (actually load and play audio)
- [ ] Integrate orphaned subsystems: Tutorial, PauseMenu, Terminal, EventManager
- [ ] Add null guards after `load()`
- [ ] Reset session achievements between games
- [ ] Update post-it notes after task completion

**Phase 4 Goal**: Both projects are feature-complete and playable.

---

## atoms3-rainbow — Quick Fix
*One critical bug, then done.*
- [ ] Fix button debounce logic (separate `lastButtonReading` variable)
- [ ] Fix `randomSeed(analogRead(0))` → use `millis()` or `esp_random()`

---

## Execution Rules
- **One project at a time** within each phase
- **Read-only audit first**, then fix
- **Test after every fix** — deploy only when verified
- **Commit + push** after each project phase completes
- **Update this roadmap** as work progresses

---

*Plan created by Nova ☄️ — 2026-04-25*
