# CollaBoard Bug Analysis Report

**Date:** 2026-03-20
**Source:** `index.html` (2787 lines), `sw.js` (173 lines)
**Analyzer:** Claude Sonnet 4.6

---

## BUG-001
**Severity:** Critical
**Category:** Sync / State Divergence
**Description:** Peer undo broadcasts only the `actionType`, not which specific stroke was removed. On the receiving peer, the handler blindly calls `strokes.pop()` — removing the last stroke in the *receiver's* local array, which is almost certainly not the same stroke the sender undid. This guarantees state divergence between peers after any undo.
**Location:** `index.html` lines 2287-2297 (receiving undo handler) and line 1445 (broadcast)
**Root Cause:** The broadcast message for `undo` sends `{ type: 'undo', actionType: action.type }` with no stroke identity. The receiver uses `strokes.pop()` which assumes the last stroke is the one to remove, but strokes from multiple users are interleaved.
**Suggested Fix:** Include a unique stroke ID (generated at draw time) in the broadcast and use that ID to locate and remove the correct stroke on all peers.

---

## BUG-002
**Severity:** Critical
**Category:** Sync / State Divergence
**Description:** When a peer client receives strokes from the host via `sendCanvasState`, the client accepts the host's `viewOffsetX`, `viewOffsetY`, and `zoomLevel` and overwrites its own viewport state. This forces a teleporting pan/zoom on join that the user did not request.
**Location:** `index.html` lines 2257-2272
**Root Cause:** Viewport state (pan/zoom) is bundled with canvas data state and overwritten on the client without any user consent or differential check.
**Suggested Fix:** Separate viewport state from canvas data in the sync protocol. Do not overwrite the joining client's viewport unless they explicitly request "match host view."

---

## BUG-003
**Severity:** Critical
**Category:** Canvas / Rendering
**Description:** `resizeCanvas()` calls `ctx.scale(devicePixelRatio, devicePixelRatio)` without first resetting the transform with `ctx.setTransform(1,0,0,1,0,0)`. Since `ctx.scale()` is cumulative, each resize call compounds the scale transform. After two resizes, the context transform is `scale(dpr²)`, which corrupts every coordinate.
**Location:** `index.html` lines 1109-1148 (`resizeCanvas`), line 1143 (`ctx.scale`)
**Root Cause:** `ctx.scale()` is cumulative. Repeated `resizeCanvas` calls compound the scale transform.
**Suggested Fix:** Call `ctx.setTransform(1, 0, 0, 1, 0, 0)` before `ctx.scale(devicePixelRatio, devicePixelRatio)` in `resizeCanvas`.

---

## BUG-004
**Severity:** Critical
**Category:** Memory Leak / Event Listeners
**Description:** There are two separate `beforeunload` listeners on `window` (lines 2383 and 2766). The outer one calls `cleanupPeer()` and `cleanupConnections()` but never clears `swUpdateInterval`. The inner one clears `swUpdateInterval` but does not call `cleanupPeer()`. Cleanup logic is fragmented and order-dependent.
**Location:** `index.html` lines 2383-2396, 2765-2770
**Root Cause:** SW cleanup is split across two separate `beforeunload` handlers.
**Suggested Fix:** Consolidate into a single `beforeunload` handler.

---

## BUG-005
**Severity:** Critical
**Category:** WebRTC / Connection
**Description:** In `joinRoom()`, the `conn.on('close', ...)` handler uses the *room code* as the peer ID to look up in the `connections` Map, but `connections` is keyed by the actual PeerJS peer ID (`conn.peer`). This breaks when reconnecting creates a new peer with a different ID.
**Location:** `index.html` lines 1885-1893
**Root Cause:** `roomCode` is used as a peer key when the actual peer ID should be `conn.peer`.
**Suggested Fix:** Use `conn.peer` as the key consistently.

---

## BUG-006
**Severity:** Critical
**Category:** WebRTC / Connection
**Description:** In `joinRoom()`, the `peer.on('error', ...)` handler ends with an unconditional `joinModal.classList.remove('hidden')` *outside* all if/else branches. Even when a retry is scheduled (where the modal should stay hidden), the modal immediately becomes visible, confusing the user.
**Location:** `index.html` lines 1923-1961
**Root Cause:** A stray `joinModal.classList.remove('hidden')` at the end of the error handler is not inside any conditional branch.
**Suggested Fix:** Remove the unconditional line; each branch already handles the modal appropriately.

---

## BUG-007
**Severity:** High
**Category:** Canvas / Rendering
**Description:** `isStrokeVisible()` computes screen bounds using `canvas.width` (backing-store pixels) and `viewOffsetX`/`viewOffsetY` (CSS pixels), but `canvas.width` is in physical pixels on high-DPI screens. The mixed units make the visibility check incorrect by a factor of `devicePixelRatio`, causing edge strokes to be incorrectly culled on HiDPI displays.
**Location:** `index.html` lines 1225-1238
**Root Cause:** `canvas.width` returns backing-store pixel dimensions while `viewOffsetX/Y` are in CSS pixel space.
**Suggested Fix:** Use `canvas.width / devicePixelRatio` (CSS width) in `isStrokeVisible`, or compare against `container.clientWidth` and `container.clientHeight`.

---

## BUG-008
**Severity:** High
**Category:** Sync / Race Condition
**Description:** `addStroke()` unconditionally clears `redoStack` when a new stroke is added. Remote draw events should not clear the local user's redo stack, as this breaks the undo/redo workflow for the local user whenever a collaborator draws.
**Location:** `index.html` lines 1300-1305 (`addStroke`), line 2209 (`handlePeerData 'draw' case`)
**Note:** Remote draws go through direct `strokes.push()` not `addStroke()`, so the immediate impact is mitigated. The root architectural concern remains.

---

## BUG-009
**Severity:** High
**Category:** Memory Leak / Timers
**Description:** The broadcast queue (`pendingBroadcasts`) uses `setTimeout(() => broadcast(nextData), 0)` for deferred retries. The `beforeunload` handler does not drain `pendingBroadcasts`. Pending items and their closures are not cleaned up on page unload.
**Location:** `index.html` lines 1509-1560
**Suggested Fix:** Clear `pendingBroadcasts` in the `beforeunload` handler.

---

## BUG-010
**Severity:** High
**Category:** Canvas / Drawing
**Description:** Single-click dots are drawn as `moveTo(x,y); lineTo(x,y)` with identical start/end points. While `lineCap: 'round'` typically renders a dot in modern browsers, this is technically undefined behavior for zero-length paths. Behavior varies across browsers and canvas implementations.
**Location:** `index.html` lines 1275-1278 (`startDrawing`)
**Suggested Fix:** Use `ctx.arc()` for single-point dots to guarantee cross-browser rendering.

---

## BUG-011
**Severity:** High
**Category:** WebRTC / Connection
**Description:** In `startKeepalive()`, `connData.lastPongReceived` is initialized to `Date.now()` at connection creation (before any pong is received). After 15 seconds of no data messages, the dead-connection check fires even for otherwise healthy connections that happen not to send data. The check fires if `lastPongReceived` is set and stale > 15s, but the initial value is set at creation time.
**Location:** `index.html` lines 922-946
**Suggested Fix:** Initialize `lastPongReceived` to `null` and only start the stale check after the first ping is sent, or use the last-sent-ping timestamp as the reference.

---

## BUG-012
**Severity:** High
**Category:** UI/UX
**Description:** The Space key activates pan mode but if the user Alt+Tabs away from the page while holding Space, neither `document` nor `window` receive the `keyup` event while the page is unfocused. Pan mode stays active permanently until Space is pressed again.
**Location:** `index.html` lines 2511-2516, 2578-2593
**Root Cause:** No `blur` or `visibilitychange` event handler resets `currentTool` when the page loses focus.
**Suggested Fix:** Add `window.addEventListener('blur', () => { if (currentTool === 'pan') { currentTool = 'pen'; updateToolButtons(); } })`.

---

## BUG-013
**Severity:** High
**Category:** Security / Input Validation
**Description:** `sanitizeHtml(data.color)` is used to sanitize peer-provided color values, but `sanitizeHtml` is an HTML entity escaper (`div.textContent = text; return div.innerHTML`), not a color validator. This provides no protection against malformed color strings. While canvas ignores invalid colors (falling back to black), the raw value is stored and re-broadcast. No strict allowlist of valid CSS colors is enforced.
**Location:** `index.html` lines 2197, 2265, 2308
**Suggested Fix:** Use a color-specific validator: `/^#[0-9a-fA-F]{3,8}$|^rgba?\([\d,.\s%]+\)$/.test(color)`.

---

## BUG-014
**Severity:** High
**Category:** WebRTC / Topology
**Description:** Code comments reference a "multi-peer mesh" topology, but the `peer.on('connection', ...)` handler in `joinRoom()` explicitly rejects connections from any peer that is not the host (`conn.peer !== roomCode && !conn.peer.startsWith(roomCode)`). A true mesh is architecturally blocked.
**Location:** `index.html` lines 1899-1905
**Suggested Fix:** Either remove the mesh comment (document star topology), or implement proper room membership tracking.

---

## BUG-015
**Severity:** Medium
**Category:** Canvas / Performance
**Description:** `redrawCanvas()` calls `isStrokeVisible()` per stroke in a guard, then passes strokes to `drawStroke()` which calls `isStrokeVisible()` again internally. Each stroke's visibility is computed twice per redraw — doubling the culling computation.
**Location:** `index.html` lines 1394-1399
**Suggested Fix:** Remove the inner `isStrokeVisible` guard in `drawStroke` and rely on callers to filter.

---

## BUG-016
**Severity:** Medium
**Category:** Sync / Undo
**Description:** When the host calls `clearCanvas()`, it pushes a restore snapshot to its own `undoStack`. However, the `clear` broadcast to peers causes them to call `strokes = []` without tracking the clear in any undo stack. If the host then undoes the clear, only the host's canvas is restored — all peer canvases remain blank.
**Location:** `index.html` lines 2216-2219 (peer clear handler), 1402-1419 (clearCanvas)
**Suggested Fix:** On receiving a `clear` event, peers should also push to their undo stack. Undo-clear broadcasts must carry the full stroke data.

---

## BUG-017
**Severity:** Medium
**Category:** UI/UX
**Description:** `navigator.clipboard.writeText(roomCode)` in `copyCodeBtn` handler is called without handling the Promise rejection. If clipboard permission is denied or the page is not focused, the operation silently fails while the "Copied!" toast is still shown to the user.
**Location:** `index.html` lines 2690-2695
**Suggested Fix:** Add `.catch(err => showToast('Copy Failed', 'Could not copy to clipboard', 'error'))`.

---

## BUG-018
**Severity:** Medium
**Category:** UI/UX
**Description:** The `Ctrl+Shift+C` shortcut uses `e.key === 'C'` (locale-sensitive). On international keyboards, `Shift+C` may produce a different character. Should use `e.code === 'KeyC'` which is keyboard-layout-independent.
**Location:** `index.html` lines 2555-2559

---

## BUG-019
**Severity:** Medium
**Category:** Memory / Timers
**Description:** `handleConnection()` stores a `connectionTimer` in the connections Map. `removePeer()` clears it if `connData` exists. If both `onDataConnClose` and `onConnClose` fire for the same peer, the second `removePeer()` call finds no entry (deleted by first call) and skips timer cleanup. This is safe due to JS single-threading, but fragile.
**Location:** `index.html` lines 2324-2379
**Suggested Fix:** Clear the timer in both `onDataConnClose` and `onConnClose` directly, before calling `removePeer`.

---

## BUG-020
**Severity:** Medium
**Category:** Canvas / State
**Description:** The `undo` function uses `strokes.lastIndexOf(action.stroke)` which relies on object reference equality (`===`). This works only because `addStroke` stores the same reference in both `strokes` and `undoStack`. The correctness depends on this invariant, which is easy to accidentally break in future refactoring.
**Location:** `index.html` lines 1431-1434
**Suggested Fix:** Assign unique IDs to strokes at creation time and find by ID for undo operations.

---

## BUG-021
**Severity:** Medium
**Category:** WebRTC / Signaling
**Description:** When an `unavailable-id` PeerJS error occurs in `initPeer()`, a new room code is silently generated. If the user had already shared the old code with collaborators, they will fail to join with no explanation.
**Location:** `index.html` lines 1729-1734
**Suggested Fix:** Show a modal or prominent toast explaining the code changed, and display the new code prominently.

---

## BUG-022
**Severity:** Medium
**Category:** Service Worker / PWA
**Description:** In `sw.js`, `self.skipWaiting()` is called at the top of the `install` handler (line 13) — before `event.waitUntil` completes. The SW activates before the cache is fully populated. A user refreshing immediately after install may get a cache miss served as a network failure.
**Location:** `sw.js` lines 11-24
**Suggested Fix:** Move `self.skipWaiting()` inside the `.then()` callback after caching is complete.

---

## BUG-023
**Severity:** Medium
**Category:** Service Worker / PWA
**Description:** In `sw.js`, the stale-while-revalidate fetch handler catches network failures with `catch(() => cachedResponse)`. If `cachedResponse` is `undefined` (cache miss) and the network also fails, the catch returns `undefined` — not a valid `Response` — causing a SW error and a network failure page for the user.
**Location:** `sw.js` lines 108-125
**Suggested Fix:** `catch(() => cachedResponse || new Response('', { status: 503, statusText: 'Service Unavailable' }))`.

---

## BUG-024
**Severity:** Medium
**Category:** UI/UX — Missing Feature
**Description:** No scroll wheel zoom is implemented. Mouse wheel zoom centered on the cursor is the standard interaction model for infinite canvas applications. Users on desktop will expect it to work and be confused when it doesn't.
**Location:** `index.html` — no `wheel` event listener
**Suggested Fix:** Add a `wheel` event listener with `e.preventDefault()` that adjusts `zoomLevel` centered on the mouse cursor position using the standard formula: `newOffset = mousePos - (mousePos - offset) * (newZoom / oldZoom)`.

---

## BUG-025
**Severity:** Medium
**Category:** Accessibility
**Description:** Color palette buttons (`div.color-btn`) and size palette buttons (`div.size-btn`) are `<div>` elements without `tabindex` or ARIA roles. They are not keyboard-focusable and are invisible to screen readers. The toolbar action buttons use `<button>` (correct), but the palette items are inaccessible.
**Location:** `index.html` lines 576-604
**Suggested Fix:** Change to `<button>` elements, or add `role="radio"`, `tabindex="0"`, and `aria-checked` attributes.

---

## BUG-026
**Severity:** Medium
**Category:** UI/UX / Touch
**Description:** Multi-touch handling is missing. If a user places a second finger while drawing, `e.touches` still contains items from the second finger, causing a drawing jump as coordinates snap to the new finger position. There is no `e.touches.length === 1` guard in `startDrawing` or `continueDrawing`.
**Location:** `index.html` lines 2434-2438
**Suggested Fix:** Add `if (e.touches.length !== 1) return;` at the start of `startDrawing` and `continueDrawing` for touch events.

---

## BUG-027
**Severity:** Low
**Category:** UI/UX
**Description:** `generateRoomCode()` uses `Math.random().toString(36).substring(2, 8)`. For very small random values, the base-36 string may have fewer than 6 characters after slicing, producing a shorter-than-expected room code.
**Location:** `index.html` line 1020
**Suggested Fix:** Use character-by-character generation with guaranteed length, e.g., `Array.from({length: 6}, () => Math.floor(Math.random() * 36).toString(36)).join('')`.

---

## BUG-028
**Severity:** Low
**Category:** Memory Leak
**Description:** `peerCursors` Map stores DOM elements for each peer cursor. While `removeAllPeerCursors()` is called on cleanup, if cursors are created but the container is being destroyed simultaneously, the Map holds references to detached DOM nodes briefly. Negligible in practice.
**Location:** `index.html` lines 1590-1651

---

## BUG-029
**Severity:** Low
**Category:** Canvas / Rendering
**Description:** The canvas CSS grid background (`background-size: 20px 20px`) is fixed and does not scale with `zoomLevel`. When the user zooms in or out, the grid spacing stays constant while canvas content scales, creating a visual disconnect that breaks the grid's usefulness as a drawing reference.
**Location:** `index.html` lines 321-325 (CSS), zoom functions lines 1478-1497
**Suggested Fix:** Dynamically update `canvas.style.backgroundSize = (20 * zoomLevel) + 'px'` in the zoom functions.

---

## BUG-030
**Severity:** Low
**Category:** Security
**Description:** The CSP header allows `'unsafe-inline'` for both `script-src` and `style-src`. This significantly weakens XSS protection. The single-file architecture requires inline scripts, but this is worth documenting as a known security tradeoff.
**Location:** `index.html` line 16

---

## BUG-031
**Severity:** Low
**Category:** UI/UX
**Description:** If the user clicks "Leave Room," cancels the `confirm()` dialog, and a pending reconnect timer fires before they can do anything else, a phantom reconnection attempt occurs. The reconnect proceeds even though the user expressed intent to leave. This resolves itself on a subsequent "Leave Room" confirmation, but the intermediate state is unexpected.
**Location:** `index.html` lines 1974-1984

---

## BUG-032
**Severity:** Low
**Category:** Canvas / Export
**Description:** The download/export function creates a canvas at current viewport dimensions (`cssWidth`/`cssHeight`) and only captures what is visible. Content panned out of view is not exported. Users have no way to export the full canvas extent, and there is no documentation of this limitation.
**Location:** `index.html` lines 2596-2633
**Suggested Fix:** Compute the bounding box of all strokes and export at full extent, or add a tooltip/warning explaining the limitation.

---

## Summary Table

| ID | Severity | Category | Short Description |
|----|----------|----------|-------------------|
| BUG-001 | **Critical** | Sync | Peer undo removes wrong stroke (no stroke identity in broadcast) |
| BUG-002 | **Critical** | Sync | Joining peer's viewport forcibly overwritten by host |
| BUG-003 | **Critical** | Canvas | Cumulative `ctx.scale()` corrupts transform on every resize |
| BUG-004 | **Critical** | Memory Leak | Two `beforeunload` listeners with split, fragmented cleanup logic |
| BUG-005 | **Critical** | WebRTC | `roomCode` used as peer key in close handler instead of `conn.peer` |
| BUG-006 | **Critical** | WebRTC | Unconditional modal-show at end of join error handler |
| BUG-007 | High | Canvas | Viewport culling uses backing-store pixels vs CSS pixels on HiDPI |
| BUG-008 | High | Sync | Remote draws may interact with local redo stack |
| BUG-009 | High | Memory | `pendingBroadcasts` not drained on page unload |
| BUG-010 | High | Canvas | Single-click dot rendering is browser-dependent (zero-length path) |
| BUG-011 | High | WebRTC | Keepalive initial timestamp causes false-positive dead connection |
| BUG-012 | High | UI/UX | Space pan mode sticks when page loses focus (Alt+Tab) |
| BUG-013 | High | Security | Color sanitized with HTML escaper, not color allowlist |
| BUG-014 | High | WebRTC | Mesh topology mentioned in comments but blocked in implementation |
| BUG-015 | Medium | Canvas | Double visibility check per stroke in `redrawCanvas` |
| BUG-016 | Medium | Sync | Clear undo not propagated to peers (restores only on host) |
| BUG-017 | Medium | UI/UX | Clipboard write failure silently ignored, shows false "Copied" toast |
| BUG-018 | Medium | UI/UX | `Ctrl+Shift+C` uses locale-sensitive `e.key` instead of `e.code` |
| BUG-019 | Medium | Memory | Double `removePeer` call leaves timer clearing fragile |
| BUG-020 | Medium | Canvas | Undo relies on fragile object reference identity |
| BUG-021 | Medium | WebRTC | Silent room code change on PeerJS ID collision |
| BUG-022 | Medium | SW/PWA | SW `skipWaiting()` fires before cache population completes |
| BUG-023 | Medium | SW/PWA | SW stale-while-revalidate returns `undefined` Response on double failure |
| BUG-024 | Medium | UI/UX | No scroll wheel zoom (major missing feature for infinite canvas) |
| BUG-025 | Medium | Accessibility | Color/size palette uses non-interactive divs, not keyboard-accessible |
| BUG-026 | Medium | UI/UX | No multi-touch guard causes drawing jumps on two-finger touch |
| BUG-027 | Low | UI/UX | Room code may be shorter than 6 chars for tiny `Math.random()` values |
| BUG-028 | Low | Memory | Minor cursor element leak on simultaneous removal+creation |
| BUG-029 | Low | Canvas | CSS grid background does not scale with zoom level |
| BUG-030 | Low | Security | CSP allows `unsafe-inline` for scripts and styles |
| BUG-031 | Low | UI/UX | Phantom reconnect after leave-room cancel dialog |
| BUG-032 | Low | Export | Download captures only viewport, not full infinite canvas |

**Total: 6 Critical, 8 High, 11 Medium, 7 Low**
