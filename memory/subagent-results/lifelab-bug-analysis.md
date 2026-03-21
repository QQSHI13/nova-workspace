# LifeLab Bug Analysis Report

Generated: 2026-03-20

---

## Category 1: JavaScript Errors and Missing Declarations

**BUG-1: `clear()` resets `generation` twice in button handler** *(low)*
- The `btn-clear` onclick handler sets `generation = 0` after calling `clear()`, which already sets `generation = 0` internally. Results in double `updateStats()` call.
- Fix: Remove `generation = 0; updateStats();` from button handler.

**BUG-2: `toroidalMode` declared after it is referenced in `init()`** *(low)*
- `toroidalMode` is declared with `let` far below where it's used in `init()`. No TDZ error at runtime since `init()` is called after full parse, but fragile ordering.
- Fix: Move declaration to top of State section.

**BUG-3: `births`/`deaths` statistics stale on undo/redo** *(medium)*
- `births`/`deaths` are saved/restored from history but represent last-step deltas, not generation state. After undo/redo, displayed values are from the wrong generation.
- Fix: Reset `births`/`deaths` to 0 on undo/redo, or track separately.

**BUG-4: `step()` doesn't wrap coordinates in toroidal mode** *(HIGH)*
- In toroidal mode, `countNeighbors()` wraps coords but `step()` stores cells using un-wrapped neighbor coordinate keys (e.g., negative coords). Cells at border are computed but stored outside the logical grid and never rendered — silent data corruption.
- Fix: Wrap `cx`/`cy` with `((cx % width) + width) % width` when `toroidalMode` is true before using as cell keys.

**BUG-5: `loadPattern()` doesn't clear `futureHistory`** *(medium)*
- After loading a pattern, redo can still restore previous unrelated future states.
- Fix: Add `futureHistory = [];` inside `loadPattern()` after `saveHistory()`.

**BUG-6: `randomFill()` doesn't clear `futureHistory`** *(medium)*
- Same as BUG-5.
- Fix: Add `futureHistory = [];` inside `randomFill()` after `saveHistory()`.

**BUG-7: `clear()` doesn't clear `futureHistory`** *(medium)*
- After clearing the grid, redo can restore previous grid states — counter-intuitive.
- Fix: Add `futureHistory = [];` inside `clear()` after `saveHistory()`.

**BUG-8: `parseRule()` regex too permissive** *(low)*
- Regex `/B(\d*)\/?S?(\d*)/` accepts malformed rule strings like `"B3"` or `"garbage"` silently.
- Fix: Use stricter `/^B(\d*)\/S(\d*)$/` and return null on no match.

**BUG-9: `loadPatterns()` uses `Promise.all()` — single fetch failure drops all patterns** *(medium)*
- If any one category JSON fails, ALL categories fall back, and `FALLBACK_PATTERNS` is missing some categories (e.g., `seeds`).
- Fix: Use `Promise.allSettled()` to handle partial failures per category.

---

## Category 2: Performance Issues

**BUG-10: No debouncing on `resize` handler** *(medium)*
- `window.addEventListener('resize', resize)` fires on every pixel of resize, calling `render()` and reading `container.clientWidth` repeatedly. Causes jank on slower devices.
- Fix: Debounce with ~150ms delay.

**BUG-11: No throttling on `updateStats()` during `mousemove`** *(medium)*
- `updateStats()` and `render()` are called on every `mousemove` while drawing (60-200+ Hz). DOM writes interleaved with canvas ops cause layout thrashing.
- Fix: Throttle `updateStats()` to once per animation frame.

**BUG-12: Grid lines drawn for all visible cells every frame** *(medium)*
- Grid line loop runs at all zoom levels. At very low zoom, hundreds of canvas `moveTo`/`lineTo` calls fire every frame.
- Fix: Skip grid drawing below minimum zoom threshold (e.g., `cellW < 4`), or use offscreen canvas caching.

**BUG-13: `render()` called from event handlers AND animation loop simultaneously** *(low)*
- When simulation is playing, `render()` is called by both `loop()` and mouse events — frames rendered more than once per rAF.
- Fix: Use a dirty flag; defer all rendering to rAF.

**BUG-14: Missing `ctx.save()`/`ctx.restore()` around drawing block** *(low)*
- Canvas state (strokeStyle, lineWidth) is manually reset each frame but not wrapped in save/restore — fragile.

**BUG-15: `Array.shift()` O(n) for history ring buffer** *(low)*
- History is capped at 50 entries via `shift()` which is O(n). Minor for 50 items but antipattern.

---

## Category 3: Keyboard Shortcut Conflicts

**BUG-16: Space `preventDefault()` fires even on focused input elements** *(medium)*
- `e.preventDefault()` on Space keydown is unconditional, preventing normal Space behavior on sliders, dropdowns, etc.
- Fix: Add `if (['INPUT', 'TEXTAREA', 'SELECT'].includes(e.target.tagName)) return;`.

**BUG-17: Space keyup `preventDefault()` may block accessibility** *(low)*
- Some browsers use Space to activate focused buttons; calling `preventDefault()` on keyup can break this.

**BUG-18: `s`/`c`/`r` keys fire when settings modal is open** *(medium)*
- The keyboard guard only checks `INPUT/TEXTAREA/SELECT` tag names. If focus is on a modal button or div, `s` still steps, `c` still clears, etc.
- Fix: Add `if (settingsModal.classList.contains('active')) return;` before key handlers.

**BUG-19: `c` key fires when modal is open (same as BUG-18)** *(low)*

**BUG-20: No keyboard shortcut for toroidal mode; undocumented in help** *(low)*
- Toroidal toggle has no hotkey and is absent from the Help modal.

**BUG-21: `Ctrl+Shift+Z` redo shortcut undocumented in help modal** *(low)*
- Code supports both `Ctrl+Y` and `Ctrl+Shift+Z` for redo but help modal only shows `Ctrl+Y`.

---

## Category 4: Mobile/Touch Issues

**BUG-22: Single-finger touch draws even in pan mode** *(HIGH)*
- `onTouchStart()` always sets `isDrawing = true` and calls `setCell()` for single-finger touches with no check for `currentTool === 'pan'`. Users in pan mode will accidentally draw.
- Fix: Add `if (currentTool === 'pan') { isTouchPanning = true; ... return; }` for single-finger touch.

**BUG-23: `onTouchEnd` doesn't handle two-finger to one-finger pan transition** *(medium)*
- When pinch-zoom ends and one finger is lifted, `isDrawing`/`isTouchPanning` both become false. Remaining finger can't continue panning.
- Fix: On `touchend`, if remaining touches >= 1 and `isTouchPanning` was active, keep panning state.

**BUG-24: Pinch-zoom doesn't pivot around pinch center** *(HIGH)*
- Zoom scale is updated correctly but `offsetX`/`offsetY` are not adjusted to keep the pinch center point stationary. View shifts unexpectedly during pinch.
- Fix: Compute world-space position of pinch center, apply new zoom, then adjust offsets so pinch center maps back to the same screen position.

**BUG-25: No minimum gesture distance before activating two-finger mode** *(low)*
- `isTouchPanning` set immediately on second finger contact, interrupting drawing even on accidental touches.

**BUG-26: `touchStartDist = 0` initial value — division by zero edge case** *(low)*
- Already guarded by `if (touchStartDist > 0)` check, so no crash. Edge case only.

**BUG-27: Viewport meta doesn't prevent double-tap zoom on iOS Safari** *(medium)*
- `<meta name="viewport" content="width=device-width, initial-scale=1.0">` lacks `user-scalable=no`. iOS double-tap triggers browser zoom, conflicting with app's own zoom and desyncing zoom state.
- Fix: Add `user-scalable=no, maximum-scale=1` to viewport meta.

**BUG-28: Touch events only on canvas, not container** *(low)*
- Touches slightly outside canvas bounds during browser chrome show/hide not captured.

---

## Category 5: State Management Bugs

**BUG-29: `isHardReload()` timing heuristic unreliable** *(medium)*
- Uses `loadEventEnd - startTime < 500ms` to detect hard reload — fails on slow devices (too slow = always soft) or fast cached loads (always hard). Logic is fragile.
- Fix: Use service worker `request.cache === 'reload'` signal instead.

**BUG-30: `births`/`deaths` not reset in `clear()`** *(medium)*
- After `clear()`, stats panel continues showing previous step's births/deaths until next `step()`.
- Fix: Add `births = 0; deaths = 0;` inside `clear()`.

**BUG-31: `births`/`deaths` not reset in `randomFill()`** *(medium)*
- Same as BUG-30.
- Fix: Add `births = 0; deaths = 0;` inside `randomFill()`.

**BUG-32: `generation` not reset in `randomFill()` or `loadPattern()`** *(low)*
- Generation counter continues from previous value after random fill or pattern load. Misleading — generation 500 after loading a fresh pattern.
- Fix: Add `generation = 0;` in `randomFill()` and `loadPattern()`.

**BUG-33: Drawing cells never clears `futureHistory`** *(HIGH)*
- `step()` clears `futureHistory`, but direct cell drawing (lines 793-796, 816-820) never does. After using undo, drawing cells, then redoing, the redo states no longer match the drawn state — state inconsistency.
- Fix: Call `futureHistory = [];` whenever a cell is drawn or erased.

**BUG-34: History buffer exhausted quickly during playback** *(low)*
- `saveHistory()` is called on every `step()` including auto-play. At 60 FPS, 50-entry history is exhausted in under a second. No user feedback about this limitation.

**BUG-35: Toroidal wrapping uses viewport-dependent `width`/`height`** *(HIGH)*
- `width`/`height` are computed as `Math.ceil(canvas.width / cellSize)` — the visible cell count at default zoom. These are used for toroidal wrap boundaries in `countNeighbors()`. At different zoom levels or after window resize, the wrap dimensions change. Cells added outside initial bounds wrap differently. The toroidal grid has no fixed logical size.
- Fix: Define a fixed logical grid size (e.g., `GRID_W = 200`, `GRID_H = 200`) independent of zoom/viewport.

**BUG-36: `spacePressed` not reset on window blur** *(medium)*
- If user holds Space and alt-tabs away, the `keyup` for Space fires on the other window. `spacePressed` stays `true` indefinitely, leaving canvas in `grab` cursor and incorrect pan state.
- Fix: Add `window.addEventListener('blur', () => { spacePressed = false; spacePanningOccurred = false; })`.

**BUG-37: Middle-mouse pan doesn't prevent OS clipboard paste on Linux** *(low)*
- No `e.preventDefault()` on middle-mouse button down. Linux desktop environments paste clipboard on middle-click, conflicting with pan gesture.

**BUG-38: `loadPattern()` merges into existing grid instead of replacing** *(medium)*
- Pattern cells are added on top of any existing cells. Most users expect loading a pattern to start fresh.
- Fix: Call `grid.clear()` before placing pattern cells in `loadPattern()`.

---

## Summary Table

| Bug | Category | Severity | Short Description |
|-----|----------|----------|-------------------|
| 4 | JS Errors | **HIGH** | Toroidal step stores cells at un-wrapped coordinates |
| 22 | Mobile | **HIGH** | Single-finger touch draws in pan mode |
| 24 | Mobile | **HIGH** | Pinch-zoom doesn't pivot around pinch center |
| 33 | State | **HIGH** | Drawing cells doesn't clear futureHistory |
| 35 | State | **HIGH** | Toroidal wrapping uses viewport-dependent dimensions |
| 3 | JS Errors | medium | births/deaths stale after undo/redo |
| 5 | JS Errors | medium | loadPattern() doesn't clear futureHistory |
| 6 | JS Errors | medium | randomFill() doesn't clear futureHistory |
| 7 | JS Errors | medium | clear() doesn't clear futureHistory |
| 9 | JS Errors | medium | Promise.all causes total pattern fallback on partial failure |
| 10 | Performance | medium | No debounce on resize handler |
| 11 | Performance | medium | No throttle on updateStats() during mousemove |
| 12 | Performance | medium | Grid lines drawn every frame regardless of zoom |
| 16 | Keyboard | medium | Space preventDefault fires on focused inputs |
| 18 | Keyboard | medium | Hotkeys fire when settings modal is open |
| 23 | Mobile | medium | touchend doesn't handle two-finger to one-finger pan transition |
| 27 | Mobile | medium | Viewport meta missing user-scalable=no |
| 29 | State | medium | isHardReload() timing heuristic unreliable |
| 30 | State | medium | births/deaths not reset in clear() |
| 31 | State | medium | births/deaths not reset in randomFill() |
| 36 | State | medium | spacePressed not reset on window blur |
| 38 | State | medium | loadPattern() merges into existing grid |
| 1 | JS Errors | low | generation reset twice in clear button handler |
| 2 | JS Errors | low | toroidalMode declared far from usage |
| 8 | JS Errors | low | parseRule() regex too permissive |
| 13 | Performance | low | render() called from event handlers AND animation loop |
| 14 | Performance | low | Missing ctx.save()/restore() |
| 15 | Performance | low | Array.shift() O(n) for history |
| 17 | Keyboard | low | Space keyup preventDefault may block accessibility |
| 19 | Keyboard | low | c key fires when modal open |
| 20 | Keyboard | low | No hotkey for toroidal toggle |
| 21 | Keyboard | low | Ctrl+Shift+Z redo undocumented |
| 25 | Mobile | low | No minimum distance threshold for two-finger gesture |
| 26 | Mobile | low | touchStartDist=0 edge case (guarded) |
| 28 | Mobile | low | Touch events only on canvas element |
| 32 | State | low | generation not reset in randomFill/loadPattern |
| 34 | State | low | History buffer exhausted quickly during playback |
| 37 | State | low | Middle-mouse pan doesn't prevent Linux paste |

**Total: 38 bugs — 5 HIGH, 16 medium, 17 low**
