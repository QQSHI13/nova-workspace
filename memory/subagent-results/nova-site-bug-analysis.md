# Bug Analysis: nova-site

**Date:** 2026-03-20
**Files Analyzed:** `index.html`, `manifest.json`, `sw.js`, `style.css`

---

## Summary

| Severity | Count | Category |
|---|---|---|
| Critical | 1 | CSP blocks ALL inline scripts + Google Analytics |
| High | 4 | Service worker race condition, invalid API, flawed reload detection, state flag |
| Medium | 6 | PWA icons invalid, start_url, SRI missing, render-blocking fonts, 2x accessibility |
| Low | 6 | DOM semantics, focus styles, star nodes, error handling, manifest completeness, @font-face no-op |

**Most impactful:** The CSP on `index.html:20` blocks all inline scripts and the external GA script — the entire JavaScript layer (stars, SW registration, key listeners) is non-functional under current CSP enforcement.

---

## CRITICAL

### [SECURITY] CSP Blocks All Inline Scripts AND Google Analytics

**File:** `index.html` lines 5–12, 20, 214–302

The CSP `script-src 'self'` does two things wrong:

1. **Blocks inline scripts** — `'self'` only allows scripts loaded via `src=` from the same origin. Inline `<script>` blocks require `'unsafe-inline'` or a nonce/hash. This means:
   - The gtag config (lines 6–12) is blocked → GA never initializes
   - The star/SW registration block (lines 214–302) is blocked → stars never render, SW never registers, keydown listener never attaches

2. **Blocks external gtag script** — `https://www.googletagmanager.com` is not in `script-src`, so the external GA loader on line 5 is also blocked.

3. **Blocks GA network requests** — `connect-src 'self'` blocks outbound fetches to `https://www.google-analytics.com`.

**Fix:**
```html
<meta http-equiv="Content-Security-Policy" content="
  default-src 'self';
  script-src 'self' 'unsafe-inline' https://www.googletagmanager.com;
  style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
  font-src 'self' https://fonts.gstatic.com;
  connect-src 'self' https://www.google-analytics.com https://analytics.google.com;
  img-src 'self' data: https://www.google-analytics.com;
">
```
Or replace `'unsafe-inline'` with per-script nonces for stronger security.

---

## HIGH

### [SERVICE WORKER] `skipWaiting()` Called Outside `waitUntil` — Race Condition

**File:** `sw.js` lines 13–21

```js
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(urlsToCache))
  );
  self.skipWaiting(); // OUTSIDE the promise chain
});
```

The SW activates before `addAll` completes. Fetch events arrive with an empty cache, causing network misses. `skipWaiting()` must be inside the `.then()` after `addAll` resolves.

**Fix:**
```js
event.waitUntil(
  caches.open(CACHE_NAME)
    .then((cache) => cache.addAll(urlsToCache))
    .then(() => self.skipWaiting())
);
```

---

### [SERVICE WORKER] `event.waitUntil` Called on `MessageEvent` — TypeError

**File:** `sw.js` lines 39–53

```js
self.addEventListener('message', (event) => {
  if (event.data?.type === 'HARD_RELOAD') {
    event.waitUntil(  // TypeError: not a function on MessageEvent
      caches.delete(CACHE_NAME).then(...)
    );
  }
});
```

`waitUntil` is only valid on `InstallEvent`, `ActivateEvent`, and `FetchEvent`. This throws a `TypeError`, crashing the hard-reload cache-clearing feature entirely.

**Fix:** Replace with a standalone promise, not attached to the event.

---

### [JAVASCRIPT] Hard Reload Detection Logic is Incorrect

**File:** `index.html` lines 243–248

```js
const isHardReload = (
  navEntry &&
  navEntry.type === 'reload' &&
  navEntry.redirectCount === 0  // true for ALL reloads
);
```

`redirectCount === 0` is true for both soft (F5) and hard (Ctrl+Shift+R) reloads. This causes the SW to receive a `HARD_RELOAD` message on every soft reload, wiping the cache unnecessarily on every F5. The correct signal is checking `Cache-Control: no-cache` on the navigation request inside the fetch handler.

---

### [SERVICE WORKER] Mutable Module-Level Flag Creates Concurrency Bug

**File:** `sw.js` lines 61–63

```js
if (isHardRefresh || isHardReload) {
  isHardReload = false; // reset on first fetch, but many fetches are parallel
```

A page load triggers many concurrent fetch events. The flag may be reset by the first fetch while subsequent parallel fetches have already read it as `true` OR as `false`, resulting in a partially-refreshed cache. Module-level mutable state in a service worker is inherently unreliable across concurrent fetch events.

---

## MEDIUM

### [PWA] Icons Use `data:` URIs — App Not Installable

**File:** `manifest.json` lines 12–20

```json
"icons": [
  { "src": "data:image/svg+xml,...", "sizes": "192x192" }
]
```

PWA installability requires icons at actual file paths/URLs, not `data:` URIs. Chrome and Lighthouse will reject these. The app cannot be installed as a PWA with this configuration. Also missing: a `"purpose": "maskable"` variant for Android adaptive icons.

**Fix:** Export actual `.png` or `.svg` icon files and reference them as paths.

---

### [PWA] `start_url: "."` is Ambiguous

**File:** `manifest.json` line 5

For a site served at `/nova/`, `"."` is ambiguous. Use `"/nova/"` or `"./index.html"` explicitly to satisfy Lighthouse PWA audits.

---

### [SECURITY] No SRI on Google Fonts

**File:** `index.html` line 62

```html
<link href="https://fonts.googleapis.com/css2?..." rel="stylesheet">
```

No `integrity` attribute. If the CDN is compromised, a malicious stylesheet could be injected. (Note: SRI on dynamic Google Fonts URLs is impractical; document as an accepted risk or use a self-hosted font instead.)

---

### [PERFORMANCE] Render-Blocking Google Fonts Stylesheet

**File:** `index.html` line 62

The `<link rel="stylesheet">` for Google Fonts is render-blocking. The `preconnect` hints help with connection latency but the stylesheet download still blocks first paint.

**Fix:** Use the print-media trick or `rel="preload"` + `onload` swap:
```html
<link rel="preload" href="..." as="style" onload="this.onload=null;this.rel='stylesheet'">
<noscript><link rel="stylesheet" href="..."></noscript>
```

---

### [ACCESSIBILITY] Avatar `aria-label` Causes Double Announcement

**File:** `index.html` line 73

```html
<div class="avatar" aria-label="Nova avatar - comet emoji">☄️</div>
```

Screen readers announce the emoji's Unicode name ("comet") AND the aria-label, resulting in "Nova avatar - comet emoji comet". Since `<h1>Nova</h1>` immediately follows, the avatar is decorative. Use `aria-hidden="true"` instead.

---

### [ACCESSIBILITY] Missing `role="img"` on Avatar with `aria-label`

**File:** `index.html` line 73

Without `role="img"`, some screen readers ignore `aria-label` on a `<div>`. Either add `role="img"` or (better) `aria-hidden="true"` as noted above.

---

## LOW

### [ACCESSIBILITY] `role="list"` on `<div>` Containing `<a role="listitem">`

**File:** `index.html` line 96

Functionally correct but unconventional. A `<ul>`/`<li>` structure is the standard, avoids explicit ARIA roles, and is less fragile.

---

### [ACCESSIBILITY] No `:focus-visible` on `.about a` Links

**File:** `style.css` lines 165–173

The global `a:focus-visible` rule applies, but the outline may have low contrast against the dark background. Verify visually.

---

### [PERFORMANCE] Stars Created Even When `prefers-reduced-motion` is Set

**File:** `index.html` lines 216–231

50 `<div>` nodes are created unconditionally. When `prefers-reduced-motion: reduce` is set, CSS hides them, but the DOM nodes still exist. Add an early JS check:

```js
if (!window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
  createStars();
}
```

---

### [JAVASCRIPT] Unguarded `performance.getEntriesByType` Call

**File:** `index.html` line 243

No try/catch or feature detection. Will throw in old iOS WebViews. Wrap in a guard:
```js
const navEntry = performance?.getEntriesByType?.('navigation')?.[0];
```

---

### [PWA] Missing `screenshots` and `shortcuts` in Manifest

**File:** `manifest.json`

Optional but required for a high Lighthouse PWA score. Missing `screenshots` means the install dialog shows no preview.

---

### [PERFORMANCE] Redundant `@font-face` Declaration

**File:** `style.css` lines 23–27

```css
@font-face {
  font-family: 'Inter';
  font-display: swap;
  src: local('Inter');
}
```

This only references `local('Inter')`. The Google Fonts URL already includes `display=swap`, so this block is a no-op that adds confusion. Remove it or extend it to include the actual font file URLs.

---

## Fix Priority

1. **Fix CSP** (`index.html:20`) — restores all JS functionality
2. **Fix SW `skipWaiting` race** (`sw.js:20`) — prevents empty-cache fetches
3. **Fix `event.waitUntil` on MessageEvent** (`sw.js:46`) — fixes TypeError
4. **Fix hard reload detection** (`index.html:243`) — prevents cache wipe on every F5
5. **Replace `data:` URI icons** (`manifest.json:12`) — enables PWA install
6. **Fix avatar aria-label** (`index.html:73`) — fixes screen reader double-announcement
