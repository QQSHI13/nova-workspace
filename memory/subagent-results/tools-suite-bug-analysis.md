# Tools-Suite Bug Analysis Report
**Date:** 2026-03-20
**Scope:** All 9 sub-tools + shared files + service workers

---

## Executive Summary

The codebase is generally well-structured with good security practices in most tools (escapeHtml usage, debounce, localStorage guards). However, significant bugs exist including critical XSS vulnerabilities, a confirmed crash bug in Color Picker, severe performance issues in Life Pattern Generator, file corruption in API Tester and JSON Viewer, deprecated API usage, and complete lack of touch/mobile support in Life Pattern Generator.

---

## Prioritized Fix List (Most Critical First)

| # | Tool | File | Issue | Severity |
|---|---|---|---|---|
| 1 | Regex Tester | index.html:396 | XSS via `e.message` injected into innerHTML without escaping | **Critical** |
| 2 | JWT Decoder | index.html:317-344 | XSS via unescaped syntaxHighlight() output in innerHTML | **Critical** |
| 3 | JWT Decoder | index.html:341 | XSS via unescaped signature in innerHTML | **Critical** |
| 4 | Color Picker | index.html:423 | querySelector crash — extra `)` in CSS selector breaks generateHarmony | **Critical** |
| 5 | Color Picker | index.html:484 | `event` ReferenceError in Firefox (not a function param) | **High** |
| 6 | API Tester | index.html:1566+ | Duplicate/corrupted HTML — `</html>` appears 3 times | **High** |
| 7 | JSON Viewer | index.html:504+ | Duplicate/corrupted HTML — content after closing `</html>` | **High** |
| 8 | Life Pattern | index.html:519-521 | O(n³) RLE generation with `cells.some()` in nested loops | **High** |
| 9 | Life Pattern | index.html:370+446 | Full DOM rebuild (`innerHTML = ''`) on every simulation step | **High** |
| 10 | Diff Viewer | app.js:98 | `btoa(String.fromCharCode(...array))` stack overflow for large inputs | **High** |
| 11 | Life Pattern | index.html | No touch event handlers — mobile drawing is completely non-functional | **High** |
| 12 | JWT Decoder | index.html | sw.js exists but is never registered | **Medium** |
| 13 | Life Pattern | — | No sw.js at all — no offline support | **Medium** |
| 14 | All tools | — | `navigator.clipboard.writeText()` calls missing `await` and `.catch()` | **Medium** |
| 15 | All tools | — | `performance.navigation` deprecated fallback still present | **Low** |

---

## Detailed Findings by Tool

---

### Shared Files

#### `shared/utils.js`

**[LOW] Deprecated API — Line 112**
```js
document.execCommand('copy')  // deprecated fallback
```
The Clipboard API path is present; this only runs as fallback, but still triggers deprecation warnings.

**[INFO] Unnecessary clearTimeout — Line 31**
```js
function later() {
    clearTimeout(timeout);  // already fired, no-op
    func(...args);
}
```
Not a bug, but misleading.

---

### Root `index.html`

**[LOW] Deprecated API — Lines 531-533**
```js
// fallback to deprecated performance.navigation
performance.navigation.type
```
The modern `performance.getEntriesByType('navigation')` path is tried first, but the fallback is still deprecated and removed in some browsers.

**[LOW] SW Hard Reload Detection — Line 530**
```js
if (navEntry.type === 'reload') { isHardReload = true; }
```
Both Ctrl+R (soft) and Ctrl+Shift+R (hard) report `type === 'reload'`. The Navigation Timing API does not distinguish between them. The SW cache bypass fires on every reload, not just hard reloads.

**[LOW] SW Infinite Reload Risk — Lines 555-558**
The `controllerchange` handler calls `window.location.reload()`. Combined with `skipWaiting()` being posted on `statechange === 'installed'`, this can create an infinite reload loop when multiple tabs are open during an SW update.

---

### 1. API Tester (`api-tester/index.html`)

**[HIGH] File Corruption — Lines 1566+**
The closing `</html>` tag appears 3 times. Lines 1567–1596 contain an orphaned, partially duplicated SW registration script outside the HTML document. Browsers are lenient, but this is technically invalid HTML and some parsers will fail.

**[HIGH] `event` Global Reliance — Line 484**
(See Color Picker for the same pattern.) Any `event.target` reference in a function that doesn't receive `event` as a parameter relies on IE-era `window.event` — throws `ReferenceError` in Firefox.

**[MEDIUM] Uncaught Clipboard Promise — Line 1401**
```js
navigator.clipboard.writeText(shareUrl)  // no await, no .catch()
```
Fails silently on permissions error or non-secure context.

**[MEDIUM] Query Param Split Bug — Line 951**
```js
const parts = param.split('=');
// parts[1] drops everything after a second '='
// e.g. ?redirect=a=b loses "=b"
```
Fix: `parts.slice(1).join('=')`.

**[LOW] Deprecated `unescape()` — Line 989**
```js
unescape(encodeURIComponent(str))  // unescape is deprecated
```
The try/catch fallback using `TextEncoder` is correct but this deprecated path runs first.

**[LOW] Full innerHTML Rebuild on History — Lines 1317-1330**
`renderHistory()` replaces the entire container on every request. With 50 entries this causes unnecessary DOM churn.

---

### 2. JSON Viewer (`json-viewer/index.html`)

**[HIGH] File Corruption — Lines 504+**
Same pattern as API Tester — content appears after closing `</html>`:
```
</html>
tion.reload();
    });
}
</script>
</body>
</html>
```

**[MEDIUM] Recursive renderTree() Stack Risk — Line 253**
`renderTree()` is recursive with no depth limit. For pathologically deeply nested JSON (thousands of levels), this can cause stack overflow. The `getMaxDepth()` function uses an iterative approach but `renderTree()` does not.

**[MEDIUM] Blob for Byte Size Calculation — Line 436**
```js
new Blob([input.value]).size  // wasteful object creation
```
Prefer `new TextEncoder().encode(text).length`.

**[LOW] Deprecated `execCommand` — Line 357**
Clipboard fallback uses `document.execCommand('copy')`.

---

### 3. Regex Tester (`regex-tester/index.html`)

**[CRITICAL] XSS via `e.message` — Line 396**
```js
matchInfo.innerHTML = `<span class="error-msg">Invalid regex: ${e.message}</span>`
```
`e.message` from `new RegExp()` can contain the pattern text including `<`, `>`, `"`. A pattern like `[<img src=x onerror=alert(1)>` will inject HTML. Fix: use `Utils.escapeHtml(e.message)`.

**[HIGH] ReDoS Risk — Lines 348, 388**
No timeout or complexity limit on regex execution. Catastrophic patterns like `(a+)+` against a long string will freeze the browser tab. Mitigation: web worker with a kill timer, or a regex complexity analyzer.

**[MEDIUM] Uncaught Clipboard Promise — Line 424**
```js
navigator.clipboard.writeText(text)  // no await, no .catch()
```

---

### 4. JWT Decoder (`jwt-decoder/index.html`)

**[CRITICAL] XSS via syntaxHighlight() — Lines 317-344**
```js
jwtOutput.innerHTML = `...${syntaxHighlight(header)}...${syntaxHighlight(payload)}...`
```
`syntaxHighlight()` at lines 348-353 does raw regex replacement on JSON strings without escaping HTML characters first. A JWT with `{"name": "<img src=x onerror=alert(1)>"}` will execute the payload. Fix: escape HTML in string values within `syntaxHighlight()`.

**[CRITICAL] XSS via Signature — Line 341**
```js
<div class="jwt-part-content">${signature}</div>
```
The signature (raw third `.`-separated part) is inserted unescaped. A crafted non-standard token with `</div><script>` in the signature injects HTML. Fix: `Utils.escapeHtml(signature)`.

**[MEDIUM] SW Never Registered**
`/jwt-decoder/sw.js` exists but `index.html` has no SW registration script. The tool has no offline support despite having a manifest and sw.js file.

---

### 5. CSV to JSON (`csv-json/index.html`)

**[MEDIUM] `parseInt` Without Radix — Multiple locations**
`parseInt(value)` without base `10` as second argument. While leading-zero octal parsing was removed in ES5, it's still bad practice and ESLint will flag it.

**[LOW] Delimiter Detection on Wrong Variable — Lines 343, 346**
```js
const delimiter = text.includes('\t') ? '\t' : ',';
// ...but parsing uses normalizedText
```
Detection should run on `normalizedText` for consistency.

**[LOW] `|| ''` Coerces Falsy Values — Line 432**
```js
let value = row[i] || '';
```
`row[i]` being `undefined` (short row) is handled, but if a cell value were `0` or `false` (as strings these are truthy, so fine in practice). Low risk.

**[LOW] Filename with HTML Characters — Line 554**
Uploaded file names with `<`, `>` characters are set as `a.download` attribute without sanitization. The `download` attribute does not execute as code, but results in confusing OS filenames.

---

### 6. Diff Viewer (`diff-viewer/app.js` + `diff.js`)

**[HIGH] OOM for Large Inputs — `diff.js` Lines 97-183**
`diff_bisect` allocates two arrays of `2 * maxD` elements where `maxD ≈ (len1 + len2) / 2`. For two 5MB strings, this allocates arrays of ~10 million elements each, causing **out-of-memory**. No size limit check exists before calling `diff_main`.

**[HIGH] btoa Stack Overflow — `app.js` Line 98**
```js
btoa(String.fromCharCode(...new TextEncoder().encode(original)))
```
Spreads a `Uint8Array` as function arguments. For inputs > ~65536 bytes, this throws `RangeError: Maximum call stack size exceeded`. The surrounding `try/catch` silently swallows this — the URL update fails with no user notification. Fix: chunk the array.

**[MEDIUM] Non-Interrupting Diff Timeout — `app.js` Line 147**
```js
const DIFF_TIMEOUT = 5000;
// ...
const result = dmp.diff_main(...);  // synchronous, can run for seconds
if (Date.now() - startTime > DIFF_TIMEOUT) { ... }  // checked AFTER completion
```
The timeout only detects overrun after the synchronous computation finishes — it cannot interrupt a running diff. The browser freezes during a long diff with no abort mechanism.

**[MEDIUM] Implicit Global Dependency — `app.js` Line 204**
`escapeHtml` is called without import — relies on global scope set by `utils.js`. If utils.js fails to load, this throws `ReferenceError`.

**[LOW] Invalid Patch Header — `app.js` Line 544**
When `ignoreWhitespace` is enabled, the diff is computed on normalized text but the patch `@@ -1,N @@` header counts lines from the original text. Produces a syntactically incorrect patch.

---

### 7. Keycode Logger (`keycode-logger/index.html`)

**[MEDIUM] `e.key` Unescaped in innerHTML — Lines 499, 549**
```js
html += `<span class="key main">${e.key === ' ' ? 'Space' : e.key}</span>`
```
`e.key` is inserted directly without escaping. In real browser events `e.key` values are standardized strings that cannot contain HTML. However, with synthetic/automated events (e.g., testing frameworks), a crafted `e.key = '<script>...</script>'` would cause XSS. Latent risk.

**[MEDIUM] No Debounce on Key Events — Lines 619+**
A held key fires `keydown` + repeat events potentially hundreds of times per second. Each event rebuilds the entire history `innerHTML` and re-attaches all click listeners. On rapid key repeat this causes significant jank.

**[MEDIUM] Full DOM Rebuild on Every Event — Lines 558-572**
```js
historyList.innerHTML = eventHistory.map(...).join('')
// then re-query and re-attach all listeners:
historyList.querySelectorAll('.history-item').forEach(item => { ... })
```
Both operations run on every keystroke. Use incremental prepend instead.

**[LOW] `parseInt` Without Radix — Line 574**
```js
parseInt(item.dataset.index)  // should be parseInt(..., 10)
```

**[LOW] `focus()` on Non-Focusable Element — Line 664**
```js
captureZone.focus()  // captureZone has no tabindex attribute
```
Silently fails. Keys are captured via `document.addEventListener` anyway, so no functional impact.

**[INFO] Displaying Deprecated `keyCode`/`which` — Lines 505-524**
`event.keyCode` and `event.which` are deprecated. The UI shows these values but does not label them as deprecated. Consider adding a "(deprecated)" label.

---

### 8. Color Picker Plus (`color-picker-plus/index.html`)

**[CRITICAL] querySelector Crash — Line 423**
```js
const btn = document.querySelector(`button[onclick*="generateHarmony('${type}')"])`);
//                                                                                   ^ extra )
```
The extra `)` after the closing `]` is a CSS selector syntax error. `querySelector` throws `SyntaxError` before returning. Since `updateColor()` calls `generateHarmony(currentHarmony)` (no event), this crash occurs on every color update. The `if (btn)` guard is never reached because the exception is thrown first.

**Fix:** Remove the trailing `)`:
```js
const btn = document.querySelector(`button[onclick*="generateHarmony('${type}')"]`);
```

**[HIGH] `event` ReferenceError in Firefox — Line 484**
```js
async function copyColor(type) {
    const btn = event.target;  // `event` is not a parameter — relies on window.event
```
`window.event` is an IE legacy feature. Firefox does not support it. This throws `ReferenceError: event is not defined` in Firefox, breaking all copy buttons.

**Fix:** Add `event` as a parameter and update the onclick attributes:
```js
async function copyColor(type, event) { ... }
// onclick="copyColor('hex', event)"
```

**[LOW] `hexToRgb` Null Dereference Risk — Lines 386-400**
If `hexToRgb(color)` returns null (invalid hex), then `rgb.r` etc. throw `TypeError`. All current callers pass validated hex values, but the function lacks a null guard.

---

### 9. Life Pattern Generator (`life-pattern-generator/index.html`)

**[HIGH] O(n³) RLE Generation — Lines 519-521**
```js
for (let y = minY; y <= maxY; y++) {
    for (let x = minX; x <= maxX; x++) {
        const isAlive = cells.some(c => c.x === x && c.y === y);  // O(cells) per cell
```
For an 80×80 grid at 50ms intervals: ~20 million comparisons per RLE export/step. Fix: use a `Set` with string keys `"${x},${y}"` for O(1) lookup:
```js
const cellSet = new Set(cells.map(c => `${c.x},${c.y}`));
const isAlive = cellSet.has(`${x},${y}`);
```

**[HIGH] Full DOM Rebuild Per Step — Lines 370, 446**
```js
// renderGrid():
gridEl.innerHTML = '';
// rebuilds all gridSize*gridSize cells from scratch
```
`step()` calls `renderGrid()` on every iteration. At 50ms intervals with an 80×80 grid: 6400 elements destroyed and recreated 20×/second = 128,000 DOM operations/second. Use Canvas API or incremental cell updates.

**[HIGH] No Touch Events — Lines 381-393**
Only `mousedown` and `mouseenter` are handled for cell drawing. No `touchstart`, `touchmove`, or `touchend` handlers. Drawing is completely non-functional on mobile/tablet.

**Fix example:**
```js
cell.addEventListener('touchstart', (e) => {
    e.preventDefault();
    isDrawing = true;
    toggleCell(x, y, true);
});
```

**[MEDIUM] Fixed Cell Size on Mobile — CSS Line 128-129**
Cells are 18×18px. An 80×80 grid = 1520px wide. On a 375px mobile screen this overflows. The `.grid-container` has `overflow: auto` so it scrolls, but no pinch-to-zoom or responsive grid sizing is implemented.

**[MEDIUM] No Service Worker**
No `sw.js` file and no registration. Unlike all other tools, Life Pattern Generator has no offline support.

**[LOW] `parseInt` Without Radix — Lines 613, 642, 652**
```js
parseInt(speedInput.value)    // should be parseInt(..., 10)
parseInt(gridSizeInput.value) // same
```

---

## Service Workers — Cross-Cutting Issues

### Race Condition in isHardReload Flag (All tools)
The `isHardReload` module-level variable persists across all fetch events. When `HARD_RELOAD` message is received and concurrent requests come in, the first request clears `isHardReload = false` which may affect the second request's cache-bypass decision. Benign race condition, low probability.

### SW Cache Miss Returns undefined (All tools)
In the stale-while-revalidate fetch handler, when `cachedResponse` is undefined AND fetch fails:
```js
// catch block:
return cachedResponse;  // undefined — invalid respondWith() value
```
This causes the request to fail with a generic network error instead of a proper fallback. Fix: return a synthetic `Response` with a 503 or an offline page.

### JWT Decoder — sw.js Exists But Never Registered
`/jwt-decoder/sw.js` is present but `index.html` has no SW registration script. The PWA manifest is referenced but offline functionality is broken.

### Life Pattern Generator — No sw.js
No SW file exists for this tool. Add `sw.js` and register it for parity with other tools.

---

## Deprecated API Summary

| API | Location | Status |
|---|---|---|
| `document.execCommand('copy')` | shared/utils.js:112, json-viewer:357, life-pattern:683 | Deprecated |
| `performance.navigation.type` | index.html:533, all sub-tools SW scripts | Deprecated |
| `event.keyCode` / `event.which` | keycode-logger:509-510 | Deprecated |
| `unescape()` | api-tester:989 | Deprecated |
| `window.event` (implicit) | color-picker:484, api-tester:484 | Non-standard |

---

## Security Summary

| Vulnerability | Tool | File:Line | Exploitability |
|---|---|---|---|
| XSS via regex error message | Regex Tester | index.html:396 | Medium — requires user to type a malicious pattern |
| XSS via JWT payload | JWT Decoder | index.html:317-344 | High — attacker provides crafted JWT |
| XSS via JWT signature | JWT Decoder | index.html:341 | Medium — requires non-standard/malformed JWT |
| Latent XSS via e.key | Keycode Logger | index.html:499,549 | Low — only with synthetic events |

---

## Mobile Responsiveness Summary

| Tool | Issue | Impact |
|---|---|---|
| Life Pattern Generator | No touch events for drawing | Drawing completely non-functional on mobile |
| Life Pattern Generator | Fixed 18px cells, 80×80 = 1520px wide | Horizontal overflow on mobile, poor UX |
| Diff Viewer | `max-height: 80vh` reduced with virtual keyboard | Output area shrinks when keyboard shown |
| Keycode Logger | No `touchstart` for key visualization | Limited mobile testing utility |
