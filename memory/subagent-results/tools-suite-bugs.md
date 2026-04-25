# Tools Suite Bug Check Report

**Date:** 2026-04-22
**Scope:** All JS and CSS source files in `/projects/tools-suite/`
**Severity Scale:** Critical / High / Medium / Low

---

## Table of Contents

- [Critical Issues](#critical-issues)
- [High Severity](#high-severity)
- [Medium Severity](#medium-severity)
- [Low Severity](#low-severity)
- [Code Smells & UX Issues](#code-smells--ux-issues)
- [File-by-File Summary](#file-by-file-summary)

---

## Critical Issues

### CRITICAL-1: Missing `resetButtons()` function in M5Timer sync pages
**Files:** `m5timer-sync.html` (~line 340), `web-sync.html` (~line 340)
**Severity:** Critical

The error handler in `connect()` calls `resetButtons()`, but this function is **never defined**:

```javascript
catch (err) {
    log('Error: ' + err.message);
    statusEl.textContent = 'Connection failed: ' + err.message;
    statusEl.className = 'status disconnected';
    connected = false;
    resetButtons();  // ← UNDEFINED FUNCTION - will throw ReferenceError
}
```

**Impact:** If serial connection fails, a secondary JavaScript error occurs, masking the original error and confusing users.

**Fix:** Define `resetButtons()` or remove the call:
```javascript
function resetButtons() {
    connectBtn.textContent = 'Connect';
    connectBtn.disabled = false;
    syncBtn.disabled = true;
    getBtn.disabled = true;
}
```

---

### CRITICAL-2: ReDoS vulnerability in CSV number parsing regex
**File:** `csv-json/index.html` (~line 400)
**Severity:** Critical

```javascript
if (parseNumbers && /^-?\d+\.?\d*$/.test(value)) {
    value = parseFloat(value);
}
```

The regex `^-?\d+\.?\d*$` can cause catastrophic backtracking on inputs with many digits followed by many dots (e.g., `"1.1.1.1.1..."`). While the CSV parser has line-length limits, this regex is still dangerous.

**Fix:** Use a safer pattern: `^-?\d+(\.\d+)?$` or use native `Number(value)` with `isNaN()` check.

---

### CRITICAL-3: Duplicate Service Worker registration in `life-pattern-generator/index.html`
**File:** `life-pattern-generator/index.html`
**Severity:** Critical

The file contains **TWO** separate `<script>` blocks that register the same service worker:

1. First block (~line 450): Simple registration
2. Second block (~line 460+): Full registration with hard-reload detection

This causes double registration, potential race conditions, and unnecessary `controllerchange` event listeners.

**Fix:** Remove the first SW registration block, keeping only the second one.

---

## High Severity

### HIGH-1: Missing clipboard API error handling across multiple tools
**Files:** `api-tester/index.html`, `color-picker-plus/index.html`, `regex-tester/index.html`
**Severity:** High

Multiple tools call `navigator.clipboard.writeText()` without `.catch()` or `try/catch`:

```javascript
// api-tester/index.html (~line 620)
navigator.clipboard.writeText(text);
showToast('Share URL copied to clipboard!');

// regex-tester/index.html (~line 380)
navigator.clipboard.writeText(text);
// No error handling

// color-picker-plus/index.html (~line 250)
const success = await Utils.copyToClipboard(text);
```

`api-tester` and `regex-tester` don't handle clipboard permission denials at all.

**Fix:** Wrap all clipboard calls in try/catch or add `.catch()` handlers.

---

### HIGH-2: `escapePath()` in `json-viewer/index.html` can produce duplicate IDs
**File:** `json-viewer/index.html` (~line 350)
**Severity:** High

```javascript
function escapePath(id) {
    return id.replace(/[^a-zA-Z0-9-_]/g, '_');
}
```

Different paths can collide to the same escaped ID (e.g., `foo.bar` and `foo-bar` both become `foo_bar`). This causes `toggleNode()` to operate on the wrong DOM element.

**Fix:** Use a counter-based unique ID instead of escaping the path:
```javascript
const nodeId = 'node-' + (nodeIdCounter++);
```

---

### HIGH-3: `getMaxDepth()` returns incorrect values for primitives
**File:** `json-viewer/index.html` (~line 430)
**Severity:** High

The `getMaxDepth` function has flawed logic:

```javascript
const currentDepth = depth + 1;
maxDepth = Math.max(maxDepth, currentDepth - 1);  // Subtracts 1 for no reason
```

For a flat object `{"a": 1}`, this returns depth `0` when it should return `1`. The `-1` adjustment makes the depth metric misleading.

**Fix:** Simply use `maxDepth = Math.max(maxDepth, depth)` for leaf nodes and `depth + 1` for recursive calls.

---

### HIGH-4: `splitLines()` removes trailing empty lines unconditionally
**File:** `diff-viewer/app.js` (~line 90)
**Severity:** High

```javascript
if (lines.length > 0 && lines[lines.length - 1] === '' && text.endsWith('\n')) {
    lines.pop();
}
```

This strips the last empty line even when it represents meaningful content (e.g., a file that intentionally ends with a newline). This causes line counts to be off by one and can misalign diffs.

**Fix:** Only strip if both original and modified have trailing newlines, or preserve trailing empties entirely.

---

### HIGH-5: Race condition in `debouncedComputeDiff` + URL update
**File:** `diff-viewer/app.js` (~line 100)
**Severity:** High

```javascript
function computeDiff() {
    // ...
    updateURL();  // Called inside computeDiff
    // ...
    const diffs = dmp.diff_main(originalText, modifiedText);
```

`updateURL()` updates the URL synchronously, but the diff computation can take seconds. If the user navigates back/forward during computation, the URL and diff output become desynchronized.

**Fix:** Update URL **after** diff computation completes, or debounce URL updates separately.

---

## Medium Severity

### MEDIUM-1: `syntaxHighlight()` in JWT decoder uses broken regex
**File:** `jwt-decoder/index.html` (~line 280)
**Severity:** Medium

```javascript
return json.replace(/(".*?"):/g, '<span class="json-key">$1</span>:')
           .replace(/: (".*?")/g, ': <span class="json-string">$1</span>')
```

The `.*?` lazy quantifiers can fail to match correctly when strings contain colons or quotes. Also, `".*?"` will match across escaped quotes incorrectly.

**Fix:** Use a proper JSON tokenizer instead of regex-based highlighting.

---

### MEDIUM-2: `atob()` error swallowed in `base64UrlDecode`
**File:** `jwt-decoder/index.html` (~line 220)
**Severity:** Medium

```javascript
try {
    return atob(str);
} catch (e) {
    throw new Error('Invalid base64 encoding in token');
}
```

While this has error handling, the error message is generic and loses the original error context. The padding calculation can also produce invalid padding for some edge cases.

---

### MEDIUM-3: Keycode logger captures both `keydown` and `keyup`
**File:** `keycode-logger/index.html` (~line 300)
**Severity:** Medium

```javascript
document.addEventListener('keydown', handleKeyEvent);
document.addEventListener('keyup', handleKeyEvent);
```

Both events add to the same history list, creating duplicate entries for every key press. The `event.type` is shown, but the history quickly fills with redundant data.

**Fix:** Only capture `keydown` events for the history, or filter duplicates.

---

### MEDIUM-4: `copyResponse()` doesn't use shared `Utils.copyToClipboard()`
**File:** `api-tester/index.html` (~line 610)
**Severity:** Medium

```javascript
async function copyResponse() {
    // ...
    try {
        await navigator.clipboard.writeText(currentResponseText);
        showToast('Response copied to clipboard!');
    } catch (err) {
        showToast('Failed to copy: ' + err.message);
    }
}
```

The shared `Utils.copyToClipboard()` provides a robust fallback for older browsers, but `copyResponse()` reimplements only the modern API without the fallback.

**Fix:** Use `Utils.copyToClipboard(currentResponseText)` instead.

---

### MEDIUM-5: `shareRequest()` creates invalid URLs for large payloads
**File:** `api-tester/index.html` (~line 580)
**Severity:** Medium

```javascript
const base64 = safeBtoa(json);
const shareUrl = `${window.location.origin}${window.location.pathname}?share=${base64}`;
```

Base64-encoded JSON can easily exceed browser URL length limits (~2000-8000 chars depending on browser). This creates unshareable URLs without warning.

**Fix:** Check URL length and show a warning if it exceeds ~4000 characters, or use a URL shortener service.

---

### MEDIUM-6: `escapeHtml()` in `shared/utils.js` creates DOM elements unnecessarily
**File:** `shared/utils.js` (~line 15)
**Severity:** Medium

```javascript
function escapeHtml(text) {
    if (text == null) return '';
    const div = document.createElement('div');
    div.textContent = String(text);
    return div.innerHTML;
}
```

This creates a DOM element on every call. For high-frequency operations (like diff rendering with thousands of lines), this is slower than a simple string-replacement approach.

**Fix:** Use string replacement for better performance:
```javascript
function escapeHtml(text) {
    if (text == null) return '';
    return String(text)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;');
}
```

---

### MEDIUM-7: `diff_cleanupSemantic()` in `diff.js` missing array bounds check
**File:** `diff-viewer/diff.js` (~line 180)
**Severity:** Medium

```javascript
equalitiesLength--;
equalitiesLength--;
pointer = equalitiesLength > 0 ? equalities[equalitiesLength - 1] : -1;
```

When `equalitiesLength` goes negative, the code attempts `equalities[-1]` which is `undefined`, but the subsequent logic treats it as a valid pointer. Can cause infinite loops on certain diff inputs.

---

### MEDIUM-8: All service workers cache `index.html` but not `../shared/utils.js`
**Files:** All `*/sw.js` files
**Severity:** Medium

Every tool's service worker caches its own `index.html` but **does NOT cache** `../shared/utils.js`. When offline, tools that depend on `Utils` will fail to load the shared utilities.

**Fix:** Add `'../shared/utils.js'` to each `urlsToCache` array.

---

## Low Severity

### LOW-1: `confirm()` dialog in `clearInputs()` breaks UX flow
**File:** `diff-viewer/app.js` (~line 260)
**Severity:** Low

```javascript
if (!confirm('Are you sure you want to clear all content? This action cannot be undone.')) {
    return;
}
```

Using native `confirm()` dialogs is jarring and blocks the main thread. A custom toast/undo pattern would be more user-friendly.

---

### LOW-2: `diff-viewer/app.js` uses `escapeHtml()` directly instead of `Utils.escapeHtml()`
**File:** `diff-viewer/app.js` (~multiple locations)
**Severity:** Low

The app references `escapeHtml()` directly (line ~160 in `showError`), but it's only available via `Utils.escapeHtml()` or as a global. This works due to the global exposure in `utils.js`, but is inconsistent with the module pattern.

---

### LOW-3: `generatePatch()` produces invalid unified diff format
**File:** `diff-viewer/app.js` (~line 320)
**Severity:** Low

```javascript
patch += `@@ -1,${(originalInput.value.match(/\n/g) || []).length + 1} +1,${(modifiedInput.value.match(/\n/g) || []).length + 1} @@\n`;
```

This is a naive line count that doesn't account for actual diff hunks. The generated patch won't work with standard `patch` command.

---

### LOW-4: CSS `line-height: 1` on emoji elements can cause clipping
**File:** `index.html` (landing page, inline CSS)
**Severity:** Low

```css
.tool-icon {
    font-size: 40px;
    line-height: 1;
}
```

Some emoji characters with diacritics or tall glyphs may clip with `line-height: 1`. `line-height: 1.2` is safer.

---

### LOW-5: `copyColor()` passes `event` parameter but handler uses `onclick`
**File:** `color-picker-plus/index.html` (~line 250)
**Severity:** Low

```html
<button class="copy-btn" onclick="copyColor('hex', event)">Copy</button>
```

The `event` passed here is the global `window.event` (deprecated) in some browsers, and `undefined` in strict mode. The function works because the button reference is found via DOM query afterward.

---

### LOW-6: `convert()` in CSV-JSON doesn't validate checkbox state before DOM access
**File:** `csv-json/index.html` (~line 420)
**Severity:** Low

```javascript
const firstRowHeaders = document.getElementById('firstRowHeaders').checked;
```

This assumes the element exists. While it does in practice, defensive coding would add a null check.

---

### LOW-7: `syntaxHighlight()` in API tester doesn't handle nested JSON structures properly
**File:** `api-tester/index.html` (~line 700)
**Severity:** Low

```javascript
function syntaxHighlight(json) {
    return json
        .replace(/(&quot;(?:[^&]|&(?!quot;))*&quot;)(?=:)/g, '<span class="json-key">$1</span>')
        .replace(/(&quot;(?:[^&]|&(?!quot;))*&quot;)/g, '<span class="json-string">$1</span>')
```

The regex for detecting keys `(&quot;...&quot;)(?=:)` uses a lookahead that fails when there's whitespace between the quote and colon. Also, numbers inside strings get highlighted as numbers.

---

## Code Smells & UX Issues

### SMELL-1: Massive code duplication in service workers
**Files:** All `*/sw.js`
**Severity:** Medium (maintenance burden)

All 10 service workers are **identical** except for the `CACHE_NAME` and `urlsToCache`. This violates DRY and makes updates error-prone. Consider generating SWs from a template or using a single SW at the root scope.

---

### SMELL-2: Hard-coded Google Analytics in every tool page
**Files:** All `index.html` files
**Severity:** Low

Each tool includes the full gtag.js snippet. This is repetitive and makes it hard to change the tracking ID across all tools. A shared include or build step would be cleaner.

---

### SMELL-3: No input sanitization in diff-viewer URL parameters
**File:** `diff-viewer/app.js` (~line 80)
**Severity:** Medium

```javascript
originalInput.value = new TextDecoder().decode(Uint8Array.from(atob(original), c => c.charCodeAt(0)));
```

While `atob()` will fail on invalid base64, there's no sanitization of the decoded content before inserting into the DOM textarea. This is safe (textarea doesn't execute JS), but good practice would use `Utils.sanitizeInput()`.

---

### SMELL-4: Floating particles animation causes continuous reflow
**File:** `index.html` (landing page)
**Severity:** Low

```css
.particle {
    animation: float 15s infinite;
}
```

20 animated particles with `translateY` and `rotate` create continuous compositor work. On low-end devices this wastes battery.

**Fix:** Use `will-change: transform` or reduce particle count on `prefers-reduced-motion`.

---

### SMELL-5: `copyJSON()` in CSV-JSON modifies button text without restoring on failure
**File:** `csv-json/index.html` (~line 480)
**Severity:** Low

```javascript
function copyJSON() {
    if (currentData.length === 0) return;  // Returns early, no feedback
    // ...
    btn.textContent = 'Copied!';
    setTimeout(() => btn.textContent = original, 1500);
}
```

When `currentData` is empty, the function returns silently without any user feedback.

---

### SMELL-6: `handleFile()` doesn't reset file input
**File:** `csv-json/index.html` (~line 320)
**Severity:** Low

```javascript
function handleFile(file) {
    // ...
    reader.readAsText(file);
}
```

After reading a file, the `fileInput.value` is not reset. Selecting the same file again won't trigger `change` event.

---

### SMELL-7: Life pattern generator doesn't debounce `speedInput` changes
**File:** `life-pattern-generator/index.html` (~line 500)
**Severity:** Low

```javascript
speedInput.addEventListener('change', () => {
    if (isPlaying) {
        clearInterval(intervalId);
        intervalId = setInterval(step, parseInt(speedInput.value));
    }
});
```

Rapidly changing speed while playing creates/destroys intervals rapidly. A debounce would be cleaner.

---

### SMELL-8: `buildGrid()` rebuilds entire DOM on every render call
**File:** `life-pattern-generator/index.html` (~line 180)
**Severity:** Medium

The `renderGrid()` function has a check `if (gridEl.children.length !== gridSize * gridSize)` that falls through to `buildGrid()`, which destroys and recreates all cell DOM elements. For an 80x80 grid, that's 6400 DOM nodes being recreated unnecessarily on every resize.

**Fix:** Separate grid creation from grid update more clearly.

---

## File-by-File Summary

| File | Critical | High | Medium | Low |
|------|----------|------|--------|-----|
| `shared/utils.js` | 0 | 0 | 1 (MEDIUM-6) | 0 |
| `sw.js` (root) | 0 | 0 | 1 (MEDIUM-8) | 0 |
| `index.html` | 0 | 0 | 0 | 2 (LOW-4, SMELL-4) |
| `m5timer-sync.html` | 1 (CRITICAL-1) | 0 | 0 | 0 |
| `web-sync.html` | 1 (CRITICAL-1) | 0 | 0 | 0 |
| `api-tester/index.html` | 0 | 2 (HIGH-1, HIGH-4*) | 3 (MEDIUM-4, MEDIUM-5, LOW-7) | 0 |
| `api-tester/sw.js` | 0 | 0 | 1 (MEDIUM-8) | 0 |
| `color-picker-plus/index.html` | 0 | 1 (HIGH-1) | 0 | 1 (LOW-5) |
| `color-picker-plus/sw.js` | 0 | 0 | 1 (MEDIUM-8) | 0 |
| `csv-json/index.html` | 1 (CRITICAL-2) | 0 | 2 (MEDIUM-6, SMELL-6) | 2 (LOW-6, SMELL-5) |
| `csv-json/sw.js` | 0 | 0 | 1 (MEDIUM-8) | 0 |
| `diff-viewer/app.js` | 0 | 2 (HIGH-4, HIGH-5) | 1 (MEDIUM-7*) | 3 (LOW-1, LOW-2, LOW-3) |
| `diff-viewer/diff.js` | 0 | 0 | 1 (MEDIUM-7) | 0 |
| `diff-viewer/style.css` | 0 | 0 | 0 | 0 |
| `diff-viewer/sw.js` | 0 | 0 | 1 (MEDIUM-8) | 0 |
| `json-viewer/index.html` | 0 | 2 (HIGH-2, HIGH-3) | 0 | 0 |
| `json-viewer/sw.js` | 0 | 0 | 1 (MEDIUM-8) | 0 |
| `jwt-decoder/index.html` | 0 | 0 | 2 (MEDIUM-1, MEDIUM-2) | 0 |
| `jwt-decoder/sw.js` | 0 | 0 | 1 (MEDIUM-8) | 0 |
| `keycode-logger/index.html` | 0 | 0 | 1 (MEDIUM-3) | 0 |
| `keycode-logger/sw.js` | 0 | 0 | 1 (MEDIUM-8) | 0 |
| `life-pattern-generator/index.html` | 1 (CRITICAL-3) | 0 | 0 | 2 (SMELL-7, SMELL-8) |
| `life-pattern-generator/sw.js` | 0 | 0 | 1 (MEDIUM-8) | 0 |
| `regex-tester/index.html` | 0 | 1 (HIGH-1) | 0 | 0 |
| `regex-tester/sw.js` | 0 | 0 | 1 (MEDIUM-8) | 0 |

---

## Recommendations Summary

1. **Fix CRITICAL-1 immediately** - undefined `resetButtons()` will crash the sync tool
2. **Fix CRITICAL-2** - ReDoS in CSV parser is a real attack vector
3. **Fix CRITICAL-3** - remove duplicate SW registration
4. **Standardize clipboard handling** - use `Utils.copyToClipboard()` everywhere
5. **Fix `escapePath()` in JSON viewer** - use counter-based IDs
6. **Add `shared/utils.js` to all SW caches** - ensures offline functionality
7. **Consider SW template generation** - reduce 10 nearly-identical files to 1 template
8. **Add `will-change: transform` to animated elements** - improves particle performance
9. **Debounce life pattern speed changes** - prevents interval thrashing
10. **Fix `getMaxDepth()` calculation** - the `-1` adjustment is incorrect

---

*Report generated by subagent for tools-suite bug check task*
