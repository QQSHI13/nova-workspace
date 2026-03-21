# DropTransfer — Comprehensive Bug Analysis
Generated: 2026-03-20

---

## BUG-001 — ACK Key Mismatch: Chunks Are Never Cleared from pendingAcks
**Severity:** Critical
**Category:** Logic Error / Protocol Bug
**File:** `index.html`
**Lines:** 802–803 (sender ACK handler) vs. 1304 (receiver ACK sender)

**Description:**
The sender constructs the `ackKey` using `data.chunkIndex`:
```js
const ackKey = `${data.fileIndex}-${data.chunkIndex}`;  // line 802
pendingAcks.delete(ackKey);
```
But the receiver sends the ACK with `chunkIndex: data.index` (line 1304):
```js
conn.send({ type: 'ack', chunkIndex: data.index, fileIndex: data.fileIndex });
```
`pendingAcks` is populated with key format `${fileIndex}-${i}`. On retry (lines 977–1013), the retry re-reads from `targetFileObj.file` rather than the original `buffer` (pre-read `ArrayBuffer`). If the file was a zipped blob, `.size` is used instead of `buffer.byteLength`, which could differ after encryption.

**Impact:** Under any packet loss scenario triggering retry, `pendingAcks` entries are never cleared for retried chunks, leading to infinite retry loops or false "Transfer failed" errors after all data has been received.

**Suggested Fix:** Ensure ACK field names are exactly symmetric. Use a single canonical name (`chunkIndex`) everywhere and add logging to confirm ACK keys match stored pendingAcks keys.

---

## BUG-002 — Chunk Validation Logic Is Inverted (Always True)
**Severity:** Critical
**Category:** Logic Error / Security
**File:** `index.html`
**Line:** 1251

**Description:**
```js
if (!data.data || !(data.data instanceof ArrayBuffer || data.data.byteLength === undefined)) {
```
The condition is logically inverted. When PeerJS binary serialization is used, data arrives as `Uint8Array`, not `ArrayBuffer`. `data.data instanceof ArrayBuffer` is `false`, and `data.data.byteLength === undefined` is also `false` (Uint8Array has `byteLength`). So the condition becomes `!(false || false)` = `true`, rejecting every valid chunk.

**Impact:** All incoming encrypted chunks in binary serialization mode are rejected with "Invalid chunk data received," completely breaking file reception when encryption is active.

**Suggested Fix:**
```js
if (!data.data || !(data.data instanceof ArrayBuffer || ArrayBuffer.isView(data.data))) {
```

---

## BUG-003 — Size Validation Incorrectly Uses Pre-Decryption Encrypted Size
**Severity:** Critical
**Category:** Logic Error
**File:** `index.html`
**Lines:** 1260–1268

**Description:**
Size validation runs against `chunkData` BEFORE decryption (line 1257 assigns `chunkData = data.data`, validation at 1262–1268 runs BEFORE the decryption block at 1271–1279). AES-GCM adds a 16-byte authentication tag to each chunk. Every encrypted chunk is `originalSize + 16` bytes. With 256KB chunks, the inflated projected size exceeds `expectedFileSize + CHUNK_SIZE`, causing valid transfers to be rejected.

**Impact:** Any encrypted transfer of a file larger than approximately one chunk size fails size validation and is aborted mid-transfer.

**Suggested Fix:** Move size validation to after the decryption step, or subtract 16 bytes per chunk from the comparison when encryption is active.

---

## BUG-004 — Race Condition: encryptionKey May Be Null When sendFiles() Is Called
**Severity:** High
**Category:** Race Condition
**File:** `index.html`
**Lines:** 731–739

**Description:**
```js
peer.on('connection', async (connection) => {
    encryptionKey = await deriveKey(peer.id, connection.peer);  // async
    // If this throws, encryptionKey stays null
    handleConnection();  // called unconditionally
```
If PBKDF2 key derivation fails (e.g., SubtleCrypto unavailable) and the catch only logs it, `encryptionKey` stays `null`. The sender then proceeds to send chunks in plaintext. Meanwhile the receiver has a valid `encryptionKey` and tries to decrypt them, causing decryption failures on every chunk.

**Impact:** Silent mixed-state transfer where receiver expects encryption but sender sends plaintext, corrupting the entire transfer.

**Suggested Fix:** Guard `handleConnection()` with a check that `encryptionKey` is not null, and abort the transfer with a user-visible error if key derivation fails.

---

## BUG-005 — fileStart Handler Saves Wrong File Using Wrong Index
**Severity:** High
**Category:** Logic Error
**File:** `index.html`
**Lines:** 1241–1246

**Description:**
When `fileStart` arrives for file N, the code saves accumulated chunks as `fileInfo.files[currentFileIndex]`. If `fileInfo` is `null` (if `fileStart` arrives before `metadata`), `fileInfo.files[currentFileIndex]` throws TypeError. If files arrive out-of-order, wrong metadata is attached to blobs.

**Impact:** Multi-file transfers (non-zipped P2P mode) can produce downloaded files with incorrect names/paths. With null `fileInfo`, the app crashes.

**Suggested Fix:** Add null guard: `if (fileInfo && receivedChunks.length > 0)`. Handle out-of-order file indices.

---

## BUG-006 — Sender Resets pendingAcks Globally Between Files
**Severity:** High
**Category:** Logic Error / Race Condition
**File:** `index.html`
**Line:** 874

**Description:**
```js
pendingAcks.clear();  // Inside per-file loop
```
`pendingAcks` is a module-level `Map`. Clearing it at the start of each file iteration means late ACKs from the previous file that arrive during the next file's send phase are silently lost. The per-file ACK wait loop (lines 959–1016) waits AFTER all chunks for one file are sent — late ACKs from the previous file arriving during this wait can cause `pendingAcks` to never fully drain.

**Impact:** Multi-file transfers (non-zipped) may hit the retry mechanism unnecessarily, causing 30-second per-file waits and eventual "Transfer failed" errors.

---

## BUG-007 — WebTorrent client.on('error') Accumulates Event Listeners
**Severity:** High
**Category:** Memory Leak / Event Listener Accumulation
**File:** `index.html`
**Lines:** 1537–1540 and 1650–1655

**Description:**
```js
client.on('error', (err) => { ... });  // line 1537 in initTorrentSender
client.on('error', (err) => { ... });  // line 1650 in downloadTorrent
```
`client` is a shared WebTorrent instance that persists across calls. Each call to `initTorrentSender()` or `downloadTorrent()` adds a NEW `error` event listener. No `client.off('error', ...)` in cleanup paths means every use accumulates a new handler. After N uses, N error popups appear for a single error.

**Impact:** On repeated use, multiple error handlers fire simultaneously for a single event, causing confusing duplicate UI updates and memory leaks.

**Suggested Fix:** Use `client.once('error', ...)` or track and remove error listeners in the cleanup path.

---

## BUG-008 — Sender peer.on('disconnected') Calls peer.reconnect() Without Guard
**Severity:** High
**Category:** Logic Error / Infinite Loop Risk
**File:** `index.html`
**Lines:** 760–764

**Description:**
```js
peer.on('disconnected', () => {
    peer.reconnect();  // Unconditional, no backoff
});
```
If the signaling server is down or `resetSender()` calls `peer.destroy()`, this fires `reconnect()` on a destroyed peer, causing PeerJS to throw an internal error. If reconnect itself triggers a disconnect (network issues), this creates an infinite rapid reconnect loop with no backoff, flooding the signaling server.

**Impact:** After `resetSender()`, `peer.destroy()` may be followed by the disconnected event, which tries to reconnect a destroyed peer — causing an unhandled exception.

**Suggested Fix:** Add a `isDestroyed` flag checked before calling `reconnect()`, and implement exponential backoff.

---

## BUG-009 — conn.serialization and conn.reliable Set After Connection Is Open
**Severity:** Medium
**Category:** Logic Error / Ineffective Code
**File:** `index.html`
**Lines:** 728–729

**Description:**
```js
peer.on('connection', async (connection) => {
    conn = connection;
    conn.serialization = 'binary';  // Has no effect on existing connection
    conn.reliable = true;           // Has no effect on existing connection
```
In PeerJS, `serialization` and `reliable` are options specified at connection creation time. Setting them as properties on an existing connection object has no effect. The actual serialization mode is determined by the receiver's `peer.connect()` options.

**Impact:** If receiver defaults to JSON serialization, data corruption or parse errors occur silently.

---

## BUG-010 — deriveKey Uses Public Peer IDs as Key Material (Weak Key Derivation)
**Severity:** Medium
**Category:** Security / Cryptographic Weakness
**File:** `index.html`
**Lines:** 429–443

**Description:**
```js
const data = encoder.encode(sortedIds.join(''));  // Peer IDs are PUBLIC
const salt = encoder.encode('DropTransferSalt2024');  // Static hardcoded salt
```
Peer IDs are publicly observable from the signaling server. PBKDF2 is designed for passwords (high-entropy secrets), not public identifiers. The static hardcoded salt eliminates protection against precomputation. Anyone who can observe signaling (including the PeerJS cloud server) knows both peer IDs and can derive the exact same encryption key.

**Impact:** The "end-to-end encryption" claim is misleading. Encryption provides no protection against the signaling server or any observer of the connection setup.

---

## BUG-011 — copyToClipboard() Has No Error Handling
**Severity:** Medium
**Category:** Missing Error Handling / UI Bug
**File:** `index.html`
**Lines:** 422–427

**Description:**
```js
navigator.clipboard.writeText(el.textContent || el.value);  // Unhandled Promise rejection
showStatus('sendStatus', 'Copied to clipboard!', 'success');  // Always fires
```
`navigator.clipboard.writeText()` returns a Promise that can reject if the page lacks clipboard permissions, is not in a secure context, or the document is not focused. The rejection is silently ignored, but "Copied to clipboard!" is shown regardless.

**Impact:** Users on HTTP or without clipboard permissions see a false "Copied!" confirmation with no actual copy occurring.

**Suggested Fix:**
```js
navigator.clipboard.writeText(el.textContent || el.value)
    .then(() => showStatus('sendStatus', 'Copied to clipboard!', 'success'))
    .catch(() => showStatus('sendStatus', 'Copy failed — please copy manually', 'error'));
```

---

## BUG-012 — Connection Timeout Fires Even During Legitimate Long Zip Preparation
**Severity:** Medium
**Category:** Logic Error / Race Condition
**File:** `index.html`
**Lines:** 1184–1193

**Description:**
```js
localConnectionTimeout = setTimeout(() => {
    if (!conn || !conn.open || !hasReceivedData) {
        // Aborts even if connection is healthy and sender is zipping
        conn.close(); peer.destroy();
    }
}, 20000);
```
If `conn.open` is `true` but no data has been received within 20 seconds (e.g., sender is preparing a large zip file), the timeout fires, shows an error, closes the connection, and destroys the peer. Zipping a large folder can legitimately take well over 20 seconds.

**Impact:** Large folder transfers are aborted by the receiver with a false timeout error before any data transfer begins.

**Suggested Fix:** Reset the timeout whenever `conn.open` transitions to true. Only trigger the "no data" timeout after the connection has been open for 20 seconds, not the overall 20-second timer.

---

## BUG-013 — handleDataInternal Has No null Guard for fileInfo on Chunk Receipt
**Severity:** Medium
**Category:** Missing Error Handling / Crash Risk
**File:** `index.html`
**Lines:** 1249–1316

**Description:**
```js
} else if (data.type === 'chunk') {
    const expectedFileSize = fileInfo.files[data.fileIndex]?.size || 0;  // Crashes if fileInfo is null
    const progress = (receivedSize / fileInfo.totalSize) * 100;          // Crashes if fileInfo is null
```
If a `chunk` message arrives before `metadata` (possible with out-of-order delivery or malicious peer), `fileInfo` is `null`, throwing `TypeError: Cannot read properties of null`.

**Impact:** Out-of-order delivery or a malicious peer can crash the entire data processing pipeline.

**Suggested Fix:** Add `if (!fileInfo) { console.error('Chunk received before metadata'); return; }` at the top of the chunk handler.

---

## BUG-014 — Progress Bar Can Show NaN% or Infinity MB/s
**Severity:** Medium
**Category:** UI/Logic Bug
**File:** `index.html`
**Lines:** 942, 1032, 1307

**Description:**
- `(receivedSize / fileInfo.totalSize) * 100` — if `totalSize` is 0 (empty file), produces `NaN` or `Infinity`
- `(totalBytesSent / totalBytes) * 100` — same issue if sending empty files
- `const avgSpeed = totalBytes / totalTime` — if `totalTime` is 0 (instantaneous), produces `Infinity MB/s`

**Impact:** Empty file transfers produce `NaN%` or `Infinity MB/s` in progress UI and malformed CSS `width: NaN%`.

**Suggested Fix:** Guard all divisions: `totalSize > 0 ? (receivedSize / totalSize) * 100 : 100` and `totalTime > 0 ? totalBytes / totalTime : 0`.

---

## BUG-015 — Service Worker: isHardReload Flag Is Never Reset
**Severity:** Medium
**Category:** Service Worker Bug
**File:** `sw.js`
**Lines:** 8, 64

**Description:**
```js
let isHardReload = false;  // Module-level state
// Set to true on HARD_RELOAD message, never reset to false
```
After the first hard reload, `isHardReload` is permanently `true` for the lifetime of the Service Worker. Any future code that branches on this flag will always see `true`.

**Impact:** Latent bug — future code reading `isHardReload` will permanently see `true` after the first hard reload.

**Suggested Fix:** Reset `isHardReload = false` after the hard reload logic completes, or scope it to the message handler rather than module level.

---

## BUG-016 — Service Worker: CHECK_UPDATE Handler Calls skipWaiting Instead of Checking for Updates
**Severity:** Medium
**Category:** Service Worker Logic Bug
**File:** `sw.js`
**Lines:** 82–85

**Description:**
```js
if (event.data && event.data.type === 'CHECK_UPDATE') {
    // Comment says "force a check for updates" but this is wrong:
    self.skipWaiting();
}
```
`self.skipWaiting()` activates the currently waiting service worker — it does NOT check for updates. Calling it here preemptively activates any waiting worker, potentially breaking in-flight requests and causing an unintended `controllerchange` event triggering a page reload.

**Impact:** Any client sending `CHECK_UPDATE` inadvertently triggers a page reload cycle if a waiting SW is present.

**Suggested Fix:** Replace with `self.registration.update()` to actually check for updates, or remove this handler entirely and use the standard update flow.

---

## BUG-017 — Service Worker: Stale Cache With No User Notification on Update Failure
**Severity:** Medium
**Category:** Service Worker Bug
**File:** `sw.js`
**Lines:** 99–111

**Description:**
```js
const updateCache = fetch(event.request).then(fetchResponse => {
    if (fetchResponse.ok) {
        return caches.open(CACHE_NAME).then(cache => cache.put(event.request, fetchResponse.clone()));
    }
}).catch(() => { /* Ignore network errors for background fetch */ });
event.waitUntil(updateCache);
return response;  // Serves stale cache immediately
```
If the background update fetch fails (caught silently), the stale cached version is served forever with no mechanism to notify users of a stale version.

**Impact:** After a deployment, users on slow networks may continue seeing the old cached version of the app indefinitely.

**Suggested Fix:** Track cache age with a timestamp and serve a "update available" banner if the cached version is older than a threshold.

---

## BUG-018 — Manifest.json: PWA Icons Use data: URIs (Not Supported by Platforms)
**Severity:** Medium
**Category:** PWA / UI Bug
**File:** `manifest.json`
**Lines:** 12–19

**Description:**
```json
"icons": [{ "src": "data:image/svg+xml,...", "sizes": "192x192", "type": "image/svg+xml" }]
```
The PWA manifest spec requires icon `src` to be a URL (relative or absolute path), not a `data:` URI. Android Chrome, iOS Safari, and most desktop browsers do not accept `data:` URI icons in manifests.

**Impact:** PWA install prompt shows no icon or a broken icon on all platforms.

**Suggested Fix:** Save the SVG as an actual file (`/icons/icon-192.svg`) and reference it by path.

---

## BUG-019 — XSS Risk: innerHTML With Potentially Unsafe Pattern
**Severity:** Medium
**Category:** Security / XSS
**File:** `index.html`
**Lines:** 578, 1178, 1188

**Description:**
```js
folderCard.innerHTML = `...${currentFiles.length} files • ${formatSize(totalSize)}`;
document.getElementById('transferModeIndicator').innerHTML = '⚠️ WebRTC failed. <a href="#" onclick="setRecvMode(\'torrent\')"...>';
```
While current values are controlled, the pattern of using `innerHTML` is fragile. `formatSize()` output and file counts are numeric (safe today), but any future change interpolating a filename directly would introduce XSS. The onclick attribute pattern also bypasses CSP in theory.

**Impact:** Low immediate risk, but fragile code pattern that increases long-term XSS risk.

**Suggested Fix:** Use `textContent` for dynamic text and `createElement`/`appendChild` for dynamic HTML structures.

---

## BUG-020 — CSP 'unsafe-inline' on script-src Undermines XSS Protection
**Severity:** Medium
**Category:** Security
**File:** `index.html`
**Line:** 15

**Description:**
```html
<meta http-equiv="Content-Security-Policy" content="default-src 'self'; script-src 'self' 'unsafe-inline' ...">
```
`'unsafe-inline'` in `script-src` allows arbitrary inline scripts, defeating the entire purpose of CSP for XSS prevention. `connect-src *` allows connections to any origin, providing no protection against data exfiltration.

**Impact:** The CSP provides a false sense of security. It does not prevent inline XSS attacks.

**Suggested Fix:** Remove `'unsafe-inline'`, move all inline scripts to external files, and use nonces or hashes for any necessary inline scripts.

---

## BUG-021 — Missing `<link rel="manifest">` Tag in HTML Head
**Severity:** Low
**Category:** PWA / UI Bug
**File:** `index.html`
**Location:** `<head>` section

**Description:**
There is no `<link rel="manifest" href="manifest.json">` tag in `<head>`. The `manifest.json` file exists but is never referenced by the HTML. Browsers will not treat the page as a PWA, will not offer "Add to Home Screen," and the Service Worker's `beforeinstallprompt` listener will never fire.

**Impact:** PWA installation functionality is entirely broken.

**Suggested Fix:** Add `<link rel="manifest" href="manifest.json">` to the `<head>`.

---

## BUG-022 — No Accessibility Attributes on Interactive Elements
**Severity:** Low
**Category:** Accessibility
**File:** `index.html`
**Location:** Throughout HTML structure

**Description:**
- Drop zone (`<div class="drop-zone">`) has no `role="button"`, `tabindex`, or `aria-label`
- Tab content has no `aria-selected`, `aria-controls`, `role="tabpanel"` / `role="tab"` ARIA roles
- Peer ID display (`.code-value`) has no accessible label indicating it's a clickable transfer code
- Progress bar (`.progress-bar`) has no `role="progressbar"`, `aria-valuenow`, `aria-valuemin`, `aria-valuemax`

**Impact:** Application is not usable by keyboard-only or screen reader users.

---

## BUG-023 — receivedChunks Not Cleared in resetReceiver()
**Severity:** Low
**Category:** Memory Leak / State Bug
**File:** `index.html`
**Lines:** 1409–1441

**Description:**
`resetReceiver()` resets most state but never clears `receivedChunks`. After a large file transfer, `receivedChunks` holds references to potentially hundreds of MB of `ArrayBuffer` data until the next `metadata` message arrives in the next transfer.

**Impact:** On devices with limited RAM, stale ArrayBuffers persist unnecessarily between transfers.

**Suggested Fix:** Add `receivedChunks = [];` to `resetReceiver()`.

---

## BUG-024 — folderCard.innerHTML Injects Values Directly (No Escaping Pattern)
**Severity:** Low
**Category:** Code Quality / Minor XSS Pattern
**File:** `index.html`
**Line:** 578

**Description:**
```js
folderCard.innerHTML = `...(${currentFiles.length} files • ${formatSize(totalSize)})`;
```
While current values are numeric (safe), the direct interpolation into `innerHTML` is an inconsistent pattern — some file names elsewhere are escaped via `escapeHtml()`, but structural values are not. A future change adding a filename to this template could introduce XSS.

**Impact:** No immediate impact, but code quality issue increasing long-term XSS risk.

---

## Summary Table

| Bug ID  | Severity | Category                           | Primary Location              |
|---------|----------|------------------------------------|-------------------------------|
| BUG-001 | Critical | Logic/Protocol — ACK key mismatch  | index.html:802, 1304          |
| BUG-002 | Critical | Logic — Inverted chunk validation  | index.html:1251               |
| BUG-003 | Critical | Logic — Size check before decrypt  | index.html:1262–1268          |
| BUG-004 | High     | Race Condition — Null encryptionKey| index.html:731–739            |
| BUG-005 | High     | Logic — Wrong file index on save   | index.html:1241–1246          |
| BUG-006 | High     | Logic — pendingAcks cross-file     | index.html:874                |
| BUG-007 | High     | Memory Leak — Listener accumulation| index.html:1537, 1650         |
| BUG-008 | High     | Logic — Reconnect on destroyed peer| index.html:760–764            |
| BUG-009 | Medium   | Logic — Dead property assignment   | index.html:728–729            |
| BUG-010 | Medium   | Security — Weak key derivation     | index.html:429–443            |
| BUG-011 | Medium   | Error Handling — Clipboard         | index.html:422–427            |
| BUG-012 | Medium   | Race Condition — Timeout too short | index.html:1184–1193          |
| BUG-013 | Medium   | Crash — Null fileInfo on chunk     | index.html:1249–1316          |
| BUG-014 | Medium   | UI — Progress NaN/Infinity         | index.html:942, 1307, 1032    |
| BUG-015 | Medium   | SW — isHardReload never reset      | sw.js:8, 64                   |
| BUG-016 | Medium   | SW — CHECK_UPDATE calls skipWaiting| sw.js:82–85                   |
| BUG-017 | Medium   | SW — Stale cache, no notification  | sw.js:99–111                  |
| BUG-018 | Medium   | PWA — data: URI icons in manifest  | manifest.json:12–19           |
| BUG-019 | Medium   | Security — innerHTML XSS pattern   | index.html:578, 1178, 1188    |
| BUG-020 | Medium   | Security — CSP unsafe-inline       | index.html:15                 |
| BUG-021 | Low      | PWA — Missing manifest link tag    | index.html:head section       |
| BUG-022 | Low      | Accessibility — No ARIA roles      | index.html (HTML structure)   |
| BUG-023 | Low      | Memory Leak — receivedChunks       | index.html:1409–1441          |
| BUG-024 | Low      | Code Quality — innerHTML pattern   | index.html:578                |

## Priority Fix Order

**Immediate (breaks core functionality):**
1. **BUG-002** — Inverted chunk validation breaks all binary-mode reception
2. **BUG-003** — Size validation on pre-decryption data breaks all encrypted transfers
3. **BUG-001** — ACK key mismatch causes infinite retries on any packet loss

**High priority (breaks multi-file transfers):**
4. **BUG-004** — Null encryptionKey causes silent plaintext/ciphertext mismatch
5. **BUG-007** — WebTorrent listener accumulation causes duplicate errors
6. **BUG-008** — Unconditional reconnect on destroyed peer causes exceptions
7. **BUG-012** — 20s timeout kills large folder transfers before data starts

**Medium priority (security/stability):**
8. **BUG-010** — Encryption uses public peer IDs as key material (false security)
9. **BUG-020** — CSP unsafe-inline undermines XSS protection
10. **BUG-016** — SW CHECK_UPDATE accidentally triggers page reloads
