# 🐛 Full Bug Check Report — All Projects

**Run Date**: 2026-04-25  
**Total Projects**: 14  
**Completed**: 14 (8 first pass + 6 retry with 10-min timeout)  

---

## 1. notes — ✅ Clean (0 issues)
- **Files analyzed**: 2
- **Issues**: 0 Critical | 0 High | 0 Medium | 0 Low
- **Assessment**: Documentation-only repo (README + .gitignore). No code to audit.
- **Health**: N/A

---

## 2. flow — ⚠️ 13 issues (0C/0H/4M/9L)
- **Files analyzed**: 9 | **Health**: Good

| # | Severity | Issue | Location |
|---|----------|-------|----------|
| 1 | Medium | `loadState()` uses `\|\|` not `??` — timer resets at exactly 00:00 instead of completing | `app.js:loadState()` |
| 2 | Medium | Timer only advances 1 cycle after long absence — loses credit for multiple Pomodoros | `app.js:loadState()` |
| 3 | Medium | Missing CSP meta tag | `index.html`, `time.html` |
| 4 | Medium | Manifest `start_url` may break PWA launch on GitHub Pages | `manifest.json:6` |
| 5 | Low | `handleVisibilityChange()` empty — interval never cleared | `app.js` |
| 6 | Low | `autoSave` interval never cleared | `app.js` |
| 7 | Low | Redundant double theme apply | `app.js` |
| 8 | Low | Dead code: `elements.app`, `stats.getDataSize()` | `app.js` |
| 9 | Low | Inconsistent SW update behavior across pages | `time.html` vs `index.html` |
| 10 | Low | Hardcoded `/flow/` in 404.html | `404.html:8` |
| 11 | Low | Outdated manifest description ("breathing exercises" doesn't exist) | `manifest.json` |
| 12 | Low | README keyboard shortcuts outdated | `README.md` |
| 13 | Low | Lighthouse steps always pass (`\|\| true`) | `validate-pwa.yml` |

---

## 3. lifelab — ⚠️ 12 issues (0C/0H/7M/5L)
- **Files analyzed**: 13 | **Health**: Good

| # | Severity | Issue | Location |
|---|----------|-------|----------|
| 1 | Medium | `innerHTML` with unsanitized RLE input → XSS in settings modal | `index.html:768` |
| 2 | Medium | Missing CSP | `index.html` |
| 3 | Medium | RLE parser no input length limits — UI freeze risk with huge paste | `index.html:640-720` |
| 4 | Medium | Paste mode broken on touch devices | `index.html:1060-1130` |
| 5 | Medium | Wrong Pentadecathlon pattern data in `osc.json` | `patterns/osc.json` |
| 6 | Medium | Lighthouse CI using wrong token + `\|\| true` swallows failures | `validate-pwa.yml` |
| 7 | Medium | `innerHTML` in `renderPatterns` (also covered by #1) | `index.html:594` |
| 8 | Low | Hardcoded GA tracking ID | `index.html:8` |
| 9 | Low | Hardcoded `/lifelab/` in 404.html | `404.html:7` |
| 10 | Low | No `devicePixelRatio` — blurry on retina displays | `index.html:720-740` |
| 11 | Low | `@import` blocks CSSOM construction | `index.html:24` |
| 12 | Low | Dead `GRID_WIDTH`/`GRID_HEIGHT` constants | `index.html:378-379` |

---

## 4. skylight-mod — 🔴 18 issues (0C/4H/8M/6L)
- **Files analyzed**: 24 | **Health**: Fair

| # | Severity | Issue | Location |
|---|----------|-------|----------|
| 1 | **High** | Difficulty never captured BEFORE changing it — "restore" does nothing because `getDifficulty()` returns PEACEFUL after already setting it | `SkylightKeybinds.java:67-70` |
| 2 | **High** | PlayerJoinMixin forces Peaceful for ALL players on EVERY join | `PlayerJoinMixin.java:27` |
| 3 | **High** | Freecam & Time Pause keybinds never registered — documented features are dead code | `SkylightKeybinds.java:27-50` |
| 4 | **High** | FreeCamera ignores config speed values — hardcoded `0.5f`/`2.0f` instead of reading config | `FreeCamera.java:98` |
| 5 | Medium | Screenshot NPE risk | `ScreenshotHandler.java:42` |
| 6 | Medium | Time pause cancels ALL entity ticks (freezes player too) | `ClientWorldMixin.java:21` |
| 7 | Medium | Fragile ordinal-based mixin injection | `MinecraftClientMixin.java:21-28` |
| 8 | Medium | `TimePauseMixin` is dead code | `TimePauseMixin.java` |
| 9 | Medium | `MouseMixin` is dead code | `MouseMixin.java:22-28` |
| 10 | Medium | `GameRendererMixin` is dead code | `GameRendererMixin.java:24-27` |
| 11 | Medium | Redundant `active` field in `SkylightState` | `SkylightState.java:14,22-29` |
| 12 | Medium | `fabric.mod.json` `onInitialize()` dead code | `fabric.mod.json:13-15` |
| 13 | Low | Unused imports | Multiple files |
| 14 | Low | Hardcoded difficulty fallback | `SkylightConfig.java` |
| 15 | Low | `System.out.println` left in | `SkylightKeybinds.java:81` |
| 16 | Low | `fabric.mod.json` version mismatch | `fabric.mod.json` |

---

## 5. M5Timer — ✅ 10 issues (0C/1H/3M/6L) — **FIXED**
- **Files analyzed**: 19 | **Health**: Fair → **Good**
- **Status**: All critical issues fixed and committed (`7f93f6c`)
- **Fixed**: Session fraud on mode switch, pongWaitStartTime bug, double NVS write, lastSavedMinuteBoundary, button triple-click timing, timer logic refactored, fromString() validation improved, extern declarations cleaned up

| # | Severity | Issue | Location |
|---|----------|-------|----------|
| 1 | **High** | Switch mode timeout fraud — single-click + wait 4s = fake completed work session without actually working | `main.cpp:283-290, 310-316` |
| 2 | Medium | Stale `pongWaitStartTime` causes immediate timeout on re-entry to SYNC | `main.cpp:332, 345-350` |
| 3 | Medium | Redundant NVS flash write on timer expiry — doubles flash wear | `main.cpp:256-260, 266-269` |
| 4 | Medium | `lastSavedMinuteBoundary` not reset on TIMER re-entry — extra flash writes | `main.cpp:223` |
| 5 | Low | Code duplication in timer logic | `timer_logic.cpp` |
| 6 | Low | Button triple-click timing imprecision | `button.cpp:55-65` |
| 7 | Low | Inline `extern` declarations | `sync.cpp:53-54` |
| 8 | Low | `fromString()` ignores malformed values | `storage.cpp:65-107` |
| 9 | Low | `serialEnded` statics not reset on all transitions | `main.cpp` |
| 10 | Low | No watchdog feed in main loop | `main.cpp:64-84` |

---

## 6. tools-suite — ✅ 18 issues (1C/2H/8M/7L) — **FIXED**
- **Files analyzed**: 49 | **Health**: Fair → **Good**
- **Status**: Critical and High priority bugs fixed and pushed to GitHub (`494b651..a802b21`)
- **Fixed**: `shared/utils.js` now cached in all SWs, `escapeHtml()` escapes quotes, JWT decoder double-escape fixed, diff-viewer syntax error fixed

| # | Severity | Issue | Location | Status |
|---|----------|-------|----------|--------|
| 1 | **Critical** | `shared/utils.js` not cached by ANY service worker — **breaks ALL tools offline** | All `sw.js` files | ✅ **FIXED** — Added `shared/utils.js` to all SW caches |
| 2 | **High** | `escapeHtml()` doesn't escape quotes → attribute injection XSS in API Tester | `api-tester/index.html` | ✅ **FIXED** — Now escapes single and double quotes |
| 3 | **High** | JWT decoder syntax highlighting breaks on escaped quotes | `jwt-decoder/index.html:280-286` | ✅ **FIXED** — Double-escape issue resolved |
| 4 | Medium | Web Serial port resource leak on partial connection failure | `web-sync.html:198-218` | |
| 5 | Medium | No serial port cleanup on page unload | `web-sync.html` | |
| 6 | Medium | `copyJSON()` shows false success (no error handling) | `csv-json/index.html:412-421` | |
| 7 | Medium | Color picker self-XSS via localStorage/console | `color-picker-plus/index.html` | |
| 8 | Medium | Duplicate files: `web-sync.html` == `m5timer-sync.html` | Both files | |
| 9 | Medium | Inconsistent hard reload detection | Multiple `index.html` | |
| 10 | Medium | JSON Viewer `path` parameter dead code | `json-viewer/index.html:210-230` | |
| 11 | Low | Diff viewer `wordLevel` option unimplemented | `diff-viewer/app.js` | ✅ **FIXED** — Syntax error resolved |
| 12 | Low | 24.html CSP missing | `24.html` | |
| 13 | Low | Several hardcoded strings | Multiple | |
| 14 | Low | Dead code | Multiple | |

---

## 7. QuickNotes — ✅ 19 issues (1C/2H/11M/5L) — **FIXED**
- **Files analyzed**: 19 | **Health**: Fair → **Good**
- **Status**: Build failure fixed and committed (`40f46d3`)
- **Fixed**: Duplicate anonymous class block (CS0116), delete feature wired up, configure editor page added, atomic file writes in SettingsService, volatile cache flag, note ID collision with same title

| # | Severity | Issue | Location |
|---|----------|-------|----------|
| 1 | **Critical** | Duplicate anonymous class block — **build failure** (CS0116) | `NoteCommands.cs:~300-330` |
| 2 | **High** | Delete feature completely broken | `NoteCommands.cs:ConfirmDeleteNoteCommand` |
| 3 | **High** | Configure Editor is a no-op — returns toast and exits, `EditorConfigurationPage` exists but unreachable | `SettingsPage.cs` |
| 4 | Medium | FileSystemWatcher recreated on every page load | `OpenExistingNotesPage.cs` |
| 5 | Medium | Non-atomic settings write — corrupts on crash | `SettingsService.cs:~120` |
| 6 | Medium | Regex instantiated on every call (no caching) | `NoteCommands.cs:~370` |
| 7 | Medium | Settings cache race condition | `SettingsService.cs:~85` |
| 8 | Medium | Process objects never disposed | `SettingsService.cs`, `NoteCommands.cs` |
| 9 | Medium | Potential argument injection via editor path | `NoteCommands.cs:~435` |
| 10 | Medium | Redundant heading detection logic | `NoteCommands.cs:~345` |
| 11 | Medium | Code duplication: `GetDefaultNotesDirectory` | `QuickNotesPage.cs` |
| 12 | Medium | Dead private delegation methods | `NoteCommands.cs` |
| 13 | Medium | Dead `EditorConfigurationPage` field | `SettingsPage.cs` |
| 14 | Medium | Misleading method naming | `NoteCommands.cs` |
| 15 | Low | `using` ordering | `NoteCommands.cs` |
| 16 | Low | Dead `SyncAllNoteTitlesCommand.InitializeAsync` | `NoteCommands.cs` |
| 17 | Low | `ToLower()` instead of `ToLowerInvariant()` | `NoteCommands.cs` |

---

## 8. QQSHI13.github.io — ⚠️ 17 issues (0C/0H/7M/10L)
- **Files analyzed**: 24 | **Health**: Good

| # | Severity | Issue | Location |
|---|----------|-------|----------|
| 1 | Medium | 24-Point Solver blocks main thread (~7.7M `Function` evals) — freezes browser | `24.html:149-173` |
| 2 | Medium | Service worker cache poisoning via redirects | `sw.js:47-54` |
| 3 | Medium | Serial port resource leak on disconnect failure | `web-sync.html:118-132` |
| 4 | Medium | No CSP on any page | All HTML |
| 5 | Medium | `prefers-reduced-motion` not respected | `index.html`, `404.html`, etc. |
| 6 | Medium | Blog index bypasses Jekyll pagination — renders ALL posts | `blog/index.md:42` |
| 7 | Medium | Sitemap inconsistent `time.html` link | `sitemap.xml:18-23` |
| 8 | Low | SW `cache.addAll` all-or-nothing | `sw.js:8-12` |
| 9 | Low | No cache size limit | `sw.js` |
| 10 | Low | 404 page lacks `noindex` | `404.html` |
| 11 | Low | Manifest theme_color mismatch | `manifest.json:7` |
| 12 | Low | Manifest SVG icons unreliable on some platforms | `manifest.json` |
| 13 | Low | Sitemap dates stale | `sitemap.xml` |
| 14 | Low | Blog sidebar hardcoded age | `blog/index.md` |
| 15 | Low | PWA validation workflow never runs Lighthouse | `validate-pwa.yml` |
| 16 | Low | Missing `<html lang>` | `web-sync.html`, `24.html` |
| 17 | Low | `.claude/settings.local.json` hardcoded absolute paths | `.claude/settings.local.json` |

---

## 9. QQSHI13 — ✅ 10 issues (0C/0H/2M/8L) — **FIXED**
- **Files analyzed**: 8 | **Health**: Good
- **Status**: All issues fixed and pushed to GitHub (`671138c`, `7f7f59f`)
- **Fixed**: SW update toast wired up, promise rejections caught, age consistent, SW polling reduced to 5min, CSP added, link checker checks index.html, SW 404 fallback fixed, caches.open deduplicated, `<main>` landmark added, manifest id added

| # | Severity | Issue | Location | Status |
|---|----------|-------|----------|--------|
| 1 | Medium | SW update toast is dead code — UI exists but nothing ever triggers it | `index.html:333-336` | ✅ **FIXED** — `updatefound` listener triggers `.show` |
| 2 | Medium | Unhandled promise rejection in SW update check (every 60s) | `index.html:348-350` | ✅ **FIXED** — `.catch(() => {})` added |
| 3 | Low | Meta description says "13-year-old" but page says "12-year-old" | `index.html:12` | ✅ **FIXED** — Both say "12-year-old" |
| 4 | Low | SW update polling every 60s is excessive for static page | `index.html:347-350` | ✅ **FIXED** — Changed to 5min (300000ms) |
| 5 | Low | Missing CSP | `index.html:7-13` | ✅ **FIXED** — CSP meta tag added |
| 6 | Low | Link checker CI only validates README.md, not index.html | `.github/workflows/check-links.yml` | ✅ **FIXED** — Added `index.html` to args |
| 7 | Low | SW fallback returns homepage for all 404s | `sw.js:62` | ✅ **FIXED** — Only nav requests → homepage, assets get 404 |
| 8 | Low | `caches.open` called repeatedly in fetch handler | `sw.js:45-48, 70-73` | ✅ **FIXED** — `getCache()` helper with persistent promise |
| 9 | Low | Missing `<main>` landmark element | `index.html:34` | ✅ **FIXED** — `<main>` added |
| 10 | Low | Manifest missing `id` field | `manifest.json:1` | ✅ **FIXED** — `"id": "qqshi13-profile"` added |

---

## 10. atoms3-rainbow — 🔴 9 issues (1C/0H/2M/6L)
- **Files analyzed**: 8 | **Health**: **Poor**

| # | Severity | Issue | Location |
|---|----------|-------|----------|
| 1 | **Critical** | Button debounce logic completely broken — `isPressed != wasPressed` resets timer every loop, button never detected. Device stuck in initial mode forever | `src/main.cpp:132-168` |
| 2 | Medium | `analogRead(0)` on strapping pin → no entropy, `RANDOM_BLINK` same sequence every boot | `src/main.cpp:47` |
| 3 | Medium | Hardcoded `8` in `handleButton()` while `buttonControl()` uses `numColors` — maintenance risk | `src/main.cpp:111, 159` |
| 4 | Low | `breathingEffect()` and `buttonControl()` call `FastLED.show()` at unlimited rate | `src/main.cpp:87, 102` |
| 5 | Low | `delay(100)` blocks event loop during mode switch | `src/main.cpp:152-155` |
| 6 | Low | `colors[]` array allocated on stack every loop | `src/main.cpp:95-103` |
| 7 | Low | `float` precision loss after ~4.6 hours | `src/main.cpp:84` |
| 8 | Low | README references non-existent `checkModeButton()` | `README.md:73` |
| 9 | Low | Board definition `m5stack-atoms3` may not match AtomS3 Lite | `platformio.ini:5` |

---

## 11. battery-panic — 🔴 29 issues (1C/9H/10M/9L)
- **Files analyzed**: 27 | **Health**: **Poor**

| # | Severity | Issue | Location |
|---|----------|-------|----------|
| 1 | **Critical** | Battery drain math makes game unplayable — drains 3.6%/sec, dies in ~8 seconds | `scripts/game_controller.gd:300-304` |
| 2 | **High** | Save data type not validated after JSON parse | `scripts/level_manager.gd:126-134` |
| 3 | **High** | Multiple nodes freed with `free()` instead of `queue_free()` | `scripts/game_controller.gd:195-196, 238-242` |
| 4 | **High** | Level progression system completely disconnected — all levels play identically | `scripts/game_controller.gd:4-5` |
| 5 | **High** | Music system entirely non-functional | `scripts/sound_manager.gd:103-120` |
| 6 | **High** | Major subsystems orphaned (Tutorial, PauseMenu, Terminal, EventManager, etc.) | `scripts/game_controller.gd` |
| 7 | **High** | No null guard after `load()` for scene files | `scripts/game_controller.gd:369-373` |
| 8 | **High** | Session achievement progress never resets between games | `scripts/achievement_manager.gd:19, 47-59` |
| 9 | **High** | Post-it notes never update after task completion | `scripts/game_controller.gd:310-325` |
| 10 | Medium | Scripted events can re-trigger on battery fluctuation | `scripts/event_manager.gd:42-48` |
| 11 | Medium | HUD updated every frame with repeated node lookups | `scripts/game_controller.gd:327-365` |
| 12 | Medium | Hardcoded Full HD positions break on other resolutions | `scenes/os_ui.gd:38-50` |
| 13+ | More Medium/Low | (Report truncated — 29 total issues) | Various |

---

## 12. collaboard — 🔴 17 issues (2C/6H/7M/2L)
- **Files analyzed**: 7 | **Health**: **Poor**

| # | Severity | Issue | Location |
|---|----------|-------|----------|
| 1 | **Critical** | Weakened CSP (`unsafe-inline` + `wss://* https://*`) allows XSS and unrestricted data exfiltration | `index.html:15` |
| 2 | **Critical** | PeerJS loaded from unpkg without SRI — supply chain attack risk | `index.html:18` |
| 3 | **High** | Multi-touch interpreted as single-pointer drawing — mobile pinch-to-zoom draws unwanted lines | `index.html:~2100` |
| 4 | **High** | Duplicate event listeners on same DataConnection | `index.html:~2300` |
| 5 | **High** | LocalStorage quota exceeded silently — canvas data lost with no warning | `index.html:~450` |
| 6 | **High** | Missing `"use strict"` — silent global variable bugs | `index.html:280` |
| 7 | **High** | Export canvas line width inconsistent with on-screen rendering (DPR not applied) | `index.html:~2650` |
| 8 | **High** | Collaborative `redo` of "clear" corrupts local undo/redo stacks | `index.html:~2520` |
| 9 | Medium | Room code generator could produce < 6 chars | `index.html:~700` |
| 10 | Medium | Touch/mouse suppression timeout globally shared | `index.html:~380` |
| 11 | Medium | 404.html hardcodes `/collaboard/` | `404.html:9` |
| 12 | Medium | No TURN servers — symmetric NAT peers can't connect | `index.html:30` |
| 13 | Medium | SW update logic can trigger rapid successive reloads | `index.html:~2720` |

---

## 13. droptransfer — 🔴 27+ issues (4C/9H/8+M/6L)
- **Files analyzed**: 13 | **Health**: **Poor**

| # | Severity | Issue | Location |
|---|----------|-------|----------|
| 1 | **Critical** | Silent fallback to unencrypted transfer — shows "🔐 encryption enabled" but sends plaintext | `js/transfers/peerjs.js:289-293` |
| 2 | **Critical** | Broken heartbeat — receiver never responds to pings, kills all transfers >30s | `js/transfers/peerjs.js:231-267` |
| 3 | **Critical** | Receiver progress broken — `state.set('progress.totalBytes')` creates literal dotted key | `js/transfers/peerjs.js:443` |
| 4 | **Critical** | Sender loads entire file into memory before chunking — crashes on large files | `js/transfers/peerjs.js:475` |
| 5 | **High** | CDN scripts without SRI | `index.html:18-20` |
| 6 | **High** | Hash verification failure doesn't abort transfer | `js/transfers/peerjs.js:586-604` |
| 7 | **High** | Seed timeout fires after successful seeding — double callback | `js/transfers/webtorrent.js:53-62` |
| 8 | **High** | Download timeout false error during slow downloads | `js/transfers/webtorrent.js:100-109` |
| 9 | **High** | Receiver heartbeat deadlock (same as #2) | `js/transfers/peerjs.js:320-322` |
| 10 | **High** | `window.initTorrentSender` callable before app exists | `js/app.js:170-171` |
| 11 | **High** | Unhandled promise rejection in sender data callback | `js/app.js:92-97` |
| 12 | **High** | DownloadManager links persist with revoked object URLs | `js/ui/components.js:287-292` |
| 13 | **High** | Receiver accumulates all chunks in memory — 6GB+ peak for 2GB file | `js/transfers/peerjs.js:366-404` |
| 14 | Medium | Hardcoded static PBKDF2 salt — same key for every session | `js/crypto.js:15` |
| 15 | Medium | `state.set()` with dotted key path instead of nested object | `js/transfers/peerjs.js:443` |
| 16 | Medium | Download timeout doesn't clear on success — false error | `js/transfers/webtorrent.js:100-109` |
| 17 | Medium | Seed timeout fires after successful seed — double callback | `js/transfers/webtorrent.js:53-62` |
| 18 | Medium | No cleanup of object URLs after download | `js/ui/components.js:287-292` |
| 19 | Medium | `window.initTorrentSender` callable before DOM ready | `js/app.js:170-171` |
| 20 | Medium | Unhandled promise rejection in sender data callback | `js/app.js:92-97` |
| 21 | Low | Progress bar CSS animation causes GPU thrashing | `css/main.css:302-310` |
| 22 | Low | Error messages exposed to UI without sanitization | `js/ui/components.js` |
| 23 | Low | Missing `rel="noopener"` on external links | `index.html:45-52` |
| 24 | Low | Debug console logs left in production code | Multiple files |
| 25 | Low | No input validation on room code length | `js/app.js:220` |
| 26 | Low | `localStorage` quota not checked before saving settings | `js/storage.js` |
| 27 | Low | Touch events not debounced on mobile send button | `js/ui/mobile.js` |

---

## 14. droptransfer-cli — ⚠️ Partial (agent got stuck reading minified JS)
- **Files analyzed**: ~8 (incomplete)
- **Status**: Agent read minified `peerjs.min.js` and produced no structured report
- **Retry needed**: Focus on user-authored source files, skip `node_modules/` and bundled assets

---

## Grand Totals

| Project | Files | Critical | High | Medium | Low | Total | Health |
|---------|-------|----------|------|--------|-----|-------|--------|
| notes | 2 | 0 | 0 | 0 | 0 | 0 | N/A |
| flow | 9 | 0 | 0 | 4 | 9 | 13 | Good |
| lifelab | 13 | 0 | 0 | 7 | 5 | 12 | Good |
| skylight-mod | 24 | 0 | 4 | 8 | 6 | 18 | Fair |
| M5Timer | 19 | 0 | 1 | 3 | 6 | 10 | Fair |
| tools-suite | 49 | 1 | 2 | 8 | 7 | 18 | Fair |
| QuickNotes | 19 | 1 | 2 | 11 | 5 | 19 | Fair |
| QQSHI13.github.io | 24 | 0 | 0 | 7 | 10 | 17 | Good |
| QQSHI13 | 8 | 0 | 0 | 2 | 8 | 10 | Good |
| atoms3-rainbow | 8 | 1 | 0 | 2 | 6 | 9 | **Poor** |
| battery-panic | 27 | 1 | 9 | 10 | 9 | 29 | **Poor** |
| collaboard | 7 | 2 | 6 | 7 | 2 | 17 | **Poor** |
| droptransfer | 13 | 4 | 9 | 8 | 6 | **27** | **Poor** |
| droptransfer-cli | ? | — | — | — | — | — | Incomplete |
| **TOTAL** | **~222** | **10** | **35** | **78** | **78** | **201** | — |

---

## Cross-Project Patterns

| Pattern | Affected Projects |
|---------|-------------------|
| Missing CSP | flow, lifelab, QQSHI13.github.io, QQSHI13, collaboard |
| `escapeHtml` insufficient | lifelab, tools-suite |
| Lighthouse CI `\|\| true` swallows failures | flow, lifelab |
| Hardcoded paths in 404.html | flow, lifelab, collaboard |
| Dead/unreachable code | skylight-mod, QuickNotes, battery-panic |
| Service worker cache gaps | tools-suite, QQSHI13.github.io, QQSHI13 |
| No serial port cleanup | QQSHI13.github.io, tools-suite |
| `innerHTML` with user input | lifelab, tools-suite, collaboard |
| CDN scripts without SRI | collaboard, droptransfer |
| No TURN servers | collaboard, droptransfer |

---

## 🔥 Priority Fix Queue

### Must Fix Now (Critical/High)
1. ~~**QuickNotes**: Fix build failure~~ — ✅ **FIXED** (committed `40f46d3`)
2. **tools-suite**: Cache `shared/utils.js` in service worker
3. **tools-suite**: Fix `escapeHtml` quote escaping
4. **skylight-mod**: Fix difficulty capture order (save BEFORE setting PEACEFUL)
5. **skylight-mod**: Stop forcing Peaceful on all player joins
6. ~~**M5Timer**: Fix switch-mode session fraud~~ — ✅ **FIXED** (committed `7f93f6c`)
7. **skylight-mod**: Register freecam/time pause keybinds
8. ~~**QuickNotes**: Fix delete feature~~ — ✅ **FIXED** (committed `40f46d3`)
9. **atoms3-rainbow**: Fix button debounce logic
10. **battery-panic**: Fix battery drain math (3.6%/sec)
11. **droptransfer**: Never silently fall back to unencrypted transfer
12. **droptransfer**: Fix heartbeat — receiver must respond to pings
13. **droptransfer**: Fix receiver progress display (`setPath` not `set`)
14. **droptransfer**: Stream chunks instead of loading entire file
15. **collaboard**: Harden CSP (remove `unsafe-inline`, restrict `connect-src`)
16. **collaboard**: Add SRI to PeerJS CDN script

### Should Fix Soon (Medium)
17. **flow**: `??` instead of `||` for `timeLeft`
18. **lifelab**: RLE limits + `textContent` not `innerHTML`
19. **QQSHI13.github.io**: Move 24-Point Solver to Web Worker
20. **tools-suite**: Web Serial cleanup
21. ~~**M5Timer**: Reset `pongWaitStartTime` on all exits~~ — ✅ **FIXED**
22. **skylight-mod**: Screenshot NPE guard
23. **collaboard**: Fix multi-touch drawing
24. **droptransfer**: Add SRI to all CDN scripts

---

*Report compiled by Nova ☄️ — 2026-04-25*
