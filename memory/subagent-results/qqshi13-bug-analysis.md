# Bug Analysis Report: QQSHI13.github.io Jekyll Blog
Generated: 2026-03-20

---

## CRITICAL

### [C1] Broken internal link on 404.html
- **File:** `404.html:197`
- **Issue:** `<a href="/projects">` links to `/projects` with no `.html` extension and no trailing slash. No Jekyll permalink is defined for `projects.html`, so GitHub Pages will not resolve this path. The "View Projects" button on the 404 page itself returns a 404.
- **Fix:** Change to `href="/projects.html"`

---

## HIGH

### [H1] `<meta charset>` placed after Google Analytics script
- **Files:** `index.html:4-12`, `projects.html:4-12`, `404.html:4-12`, `web-sync.html:4-12`
- **Issue:** The charset declaration must appear within the first 1024 bytes, ideally as the very first element in `<head>`. Having a `<script>` before `<meta charset="UTF-8">` can cause the browser to begin parsing with an incorrect encoding.
- **Fix:** Move `<meta charset="UTF-8">` and `<meta name="viewport">` to be the first two elements in `<head>`, before any `<script>` tags.

### [H2] No skip navigation link (WCAG 2.1 Level A)
- **Files:** `_layouts/default.html` (all blog pages), `index.html`, `projects.html`, `web-sync.html`
- **Issue:** No skip-to-content link exists anywhere on the site. This is a WCAG 2.1 Level A requirement critical for keyboard-only and screen reader users.
- **Fix:** Add as the very first element inside `<body>`:
  ```html
  <a href="#main-content" class="skip-link">Skip to main content</a>
  ```
  ```css
  .skip-link { position: absolute; top: -40px; left: 0; background: #000; color: #fff; padding: 8px; z-index: 9999; }
  .skip-link:focus { top: 0; }
  ```

### [H3] No visible focus styles on nav/interactive elements (WCAG 2.4.7)
- **File:** `blog/assets/main.css:84-93`
- **Issue:** `.site-nav a` and all post list links have no `:focus` style defined. Keyboard users cannot see which element has focus.
- **Fix:**
  ```css
  .site-nav a:focus, .post-list a:focus, .post-link:focus {
    outline: 2px solid var(--accent);
    outline-offset: 2px;
  }
  ```

### [H4] `outline: none` on focused inputs without replacement (WCAG 2.4.7)
- **Files:** `projects.html:115-117`, `web-sync.html:84-86`
- **Issue:** Both files use `input:focus { outline: none; }` removing the browser's default focus ring. A border-color change alone may not meet contrast requirements and fails WCAG 2.4.7 (Focus Visible).
- **Fix:** Replace `outline: none` with `outline: 2px solid var(--accent); outline-offset: 2px;`

### [H5] Search input missing `<label>` (WCAG 1.3.1)
- **File:** `projects.html:303`
- **Issue:** `<input type="text" id="search" placeholder="Search projects...">` has no associated `<label>`. Placeholders are not a substitute for labels per WCAG 1.3.1.
- **Fix:**
  ```html
  <label for="search" class="sr-only">Search projects</label>
  <input type="text" id="search" placeholder="Search projects..." autocomplete="off">
  ```
  ```css
  .sr-only { position: absolute; width: 1px; height: 1px; padding: 0; margin: -1px; overflow: hidden; clip: rect(0,0,0,0); white-space: nowrap; border: 0; }
  ```

### [H6] Missing `<meta name="description">` and Open Graph tags on homepage and projects page
- **Files:** `index.html` (entire file), `projects.html` (entire file)
- **Issue:** Both standalone HTML files have no `<meta name="description">`, no `og:` tags, and no Twitter Card tags. Search engines will auto-generate descriptions from content, and link previews will be empty.
- **Fix:** Add to `index.html`:
  ```html
  <meta name="description" content="QQ's portfolio — web tools, desktop apps, and hardware projects by a young developer.">
  <meta property="og:title" content="QQ's Projects">
  <meta property="og:description" content="Web tools, PWA apps, and hardware projects.">
  <meta property="og:url" content="https://qqshi13.github.io/">
  <meta property="og:type" content="website">
  ```

### [H7] `jekyll-paginate` plugin missing from `_config.yml`
- **File:** `_config.yml:26-27`
- **Issue:** `paginate: 5` and `paginate_path` are configured, but `jekyll-paginate` is not listed under `plugins:`. Pagination is silently ignored.
- **Fix:** Add `- jekyll-paginate` to the `plugins:` list in `_config.yml`, OR remove the `paginate` and `paginate_path` keys if pagination is not needed.

---

## MEDIUM

### [M1] `og:type` detection logic is unreliable
- **File:** `_layouts/default.html:27`
- **Issue:** `{% if page.layout == 'post' %}article{% else %}website{% endif %}` — `page.layout` reflects the layout chain and may resolve to `default` rather than `post` on rendered posts.
- **Fix:** Use `{% if page.date %}article{% else %}website{% endif %}` which more reliably identifies posts.

### [M2] `page.excerpt` used for meta description without fallback
- **File:** `_layouts/default.html:8,26`
- **Issue:** Index pages have no meaningful `page.excerpt`, so the description may be garbled markup from the first `<div>` in the page.
- **Fix:** Use `{{ page.description | default: page.excerpt | strip_html | truncate: 160 }}` and add `description:` fields to page front matter.

### [M3] Redundant `collections.posts` in `_config.yml`
- **File:** `_config.yml:30-33`
- **Issue:** Explicitly defining `collections.posts` with `output: true` is redundant since Jekyll treats `_posts` as a built-in collection. This can cause permalink conflicts in some Jekyll versions.
- **Fix:** Remove the `collections: posts:` block entirely.

### [M4] Google Analytics fires in local development
- **File:** `_layouts/default.html:36-42`
- **Issue:** GA script is not guarded by environment check, polluting production analytics with development traffic.
- **Fix:**
  ```liquid
  {% if jekyll.environment == 'production' %}
  <!-- GA script here -->
  {% endif %}
  ```

### [M5] `blog/index.md` renders `post.excerpt` with raw HTML tags
- **File:** `blog/index.md:34`
- **Issue:** `{{ post.excerpt }}` outputs raw HTML, potentially nesting `<p>` inside `<p>` and producing invalid HTML.
- **Fix:** Use `{{ post.excerpt | strip_html | truncate: 160 }}`

### [M6] External links missing `rel="noopener noreferrer"`
- **File:** `_layouts/default.html:53,67,71`
- **Issue:** GitHub and openclaw.ai links in the header/footer have no `rel="noopener noreferrer"`. This is a security best practice to prevent reverse tabnapping.
- **Fix:** Add `rel="noopener noreferrer"` to all external `<a>` tags.

### [M7] Relative path for blog link may break if site structure changes
- **File:** `index.html:570`
- **Issue:** `href="blog/index.html"` uses a relative path without a leading slash. Any structural change would break this link.
- **Fix:** Change to `href="/blog/"`

### [M8] `background-clip: text` missing standard property
- **File:** `blog/assets/main.css:116-118`
- **Issue:** `.daily-banner h2` uses only `-webkit-background-clip: text` without the standard `background-clip: text`. Firefox users see the gradient effect broken.
- **Fix:** Add `background-clip: text;` after `-webkit-background-clip: text;`

### [M9] Touch targets too small for nav links (WCAG 2.5.5)
- **File:** `blog/assets/main.css:84-93`
- **Issue:** `.site-nav a` renders at ~20-24px height, well below the 44px minimum touch target size.
- **Fix:** Add `padding: 12px 8px; display: inline-block;` to `.site-nav a`

### [M10] Decorative emoji containers missing `aria-hidden`
- **File:** `index.html:543,639,644,649`
- **Issue:** `<div class="avatar">🛠️</div>` and similar emoji-only containers will be announced by screen readers with emoji descriptions like "wrench and hammer" which is confusing noise.
- **Fix:** Add `aria-hidden="true"` to all decorative emoji containers.

### [M11] Scroll indicator has no accessible label
- **File:** `index.html:588-592`
- **Issue:** `<a href="#about" class="scroll-indicator">` contains only an SVG chevron with no text and no `aria-label`. Screen readers announce it as an unlabeled link.
- **Fix:** Add `aria-label="Scroll to About section"` to the anchor.

### [M12] Search JS accesses `dataset.search` without null check
- **File:** `projects.html:519-533`
- **Issue:** `card.dataset.search.toLowerCase()` throws `TypeError` if a card element is missing the `data-search` attribute.
- **Fix:** Use `(card.dataset.search || '').toLowerCase()`

### [M13] Unencoded SVG in favicon `href`
- **Files:** `404.html:16`, `web-sync.html:16`
- **Issue:** `href="data:image/svg+xml,<svg ...>"` uses unencoded angle brackets `<` and `>`. Compare to `index.html` which correctly uses `%3Csvg`. HTML validators and some browsers may reject unencoded `<>` inside attribute values.
- **Fix:** Percent-encode the SVG content: `href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'%3E%3Ctext y='.9em' font-size='90'%3E⚡%3C/text%3E%3C/svg%3E"`

### [M14] 404.html should not be indexed by search engines
- **File:** `404.html` (entire file)
- **Issue:** No `<meta name="robots" content="noindex">`. Search engines may index the 404 error page.
- **Fix:** Add `<meta name="robots" content="noindex, nofollow">` to the `<head>`

### [M15] `web-sync.html` missing `<main>` landmark
- **File:** `web-sync.html:186`
- **Issue:** Primary content has no semantic `<main>` element. Screen reader users cannot navigate directly to the main content.
- **Fix:** Change `<div class="container">` to `<main class="container" id="main-content">`

### [M16] `web-sync.html` status element missing `aria-live`
- **File:** `web-sync.html:481-483`
- **Issue:** Connection status updates in `#status` are not announced to screen reader users because the element has no `aria-live` region.
- **Fix:** Add `aria-live="polite"` to the `#status` div.

### [M17] `web-sync.html` form inputs not validated before building command string
- **File:** `web-sync.html:344-354`
- **Issue:** Input values are concatenated directly into the SYNC command string without parsing or validation. A value like `25,injected=evil` would corrupt the serial command.
- **Fix:** Parse with `parseInt(value, 10)` and clamp to `min`/`max` attribute ranges before building the command string.

### [M18] `blog/feed.xml` leading blank line before front matter
- **File:** `blog/feed.xml:1`
- **Issue:** A blank line before `---` may cause Jekyll to treat the file as non-front-matter content and output raw template text instead of processed XML.
- **Fix:** Remove the leading blank line.

### [M19] `_config.yml` has `jekyll-sitemap` but utility pages lack `sitemap: false`
- **File:** `_config.yml:18`, `web-sync.html`, `404.html`
- **Issue:** The sitemap plugin will include `web-sync.html` and `404.html` in `sitemap.xml`, causing search engines to crawl utility and error pages.
- **Fix:** Add `sitemap: false` to the front matter of `web-sync.html` and `404.html`.

### [M20] Default layout GA loads in development; duplicated across 4 standalone files
- **File:** `_includes/` (empty), `index.html`, `projects.html`, `404.html`, `web-sync.html`
- **Issue:** The GA snippet is copy-pasted into all four standalone files. Any GA config change requires editing four files. The `_includes/` directory exists but is empty.
- **Fix:** Create `_includes/analytics.html` with the GA snippet and use `{% include analytics.html %}` in all layouts and standalone files.

### [M21] Text contrast: `--text-secondary` on `--surface` fails WCAG AA
- **Files:** All CSS files
- **Issue:** `#7d8590` on `#161b22` yields ~4.2:1 contrast ratio, failing WCAG AA for small text (requires ≥4.5:1). Affects `.post-meta`, `.site-nav a`, footer text, and other secondary text elements.
- **Fix:** Lighten `--text-secondary` to at least `#8b96a0` which achieves ~4.6:1 on `#161b22`.

### [M22] Missing canonical URL tags on standalone pages
- **Files:** `index.html`, `projects.html`
- **Issue:** Without `<link rel="canonical">`, search engines may index both `https://qqshi13.github.io/` and `https://qqshi13.github.io/index.html` as duplicate pages.
- **Fix:** Add `<link rel="canonical" href="https://qqshi13.github.io/">` to `index.html` and `<link rel="canonical" href="https://qqshi13.github.io/projects.html">` to `projects.html`.

### [M23] `default.html` has leading blank line before `<!DOCTYPE html>`
- **File:** `_layouts/default.html:1`
- **Issue:** Output HTML has a blank line before the doctype, which can trigger quirks mode in some edge-case browser scenarios.
- **Fix:** Remove the leading blank line.

### [M24] Google Fonts loaded without `preconnect` hints on standalone pages
- **Files:** `index.html`, `projects.html`, `404.html`
- **Issue:** Google Fonts is a render-blocking resource. The blog layout (`default.html`) correctly uses `<link rel="preconnect">` but the standalone HTML files do not.
- **Fix:** Add before the Google Fonts stylesheet in each standalone file:
  ```html
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  ```

### [M25] All styles are inline across 4 standalone HTML files
- **Files:** `index.html`, `projects.html`, `404.html`, `web-sync.html`
- **Issue:** All CSS is in `<style>` blocks rather than external stylesheets. Browser cannot cache styles across page navigations. Theme variables (CSS custom properties) and base styles are duplicated 4 times.
- **Fix:** Extract shared CSS (variables, typography, button styles, background gradient) into `/assets/css/shared.css`.

---

## LOW

### [L1] `_config.yml` exposes email address publicly
- **File:** `_config.yml:3`
- **Issue:** `email: shizheng327@gmail.com` is in the public config file and will be scraped by email harvesters.
- **Fix:** Consider removing it from config and using a contact form or obfuscated HTML entity encoding in the footer template.

### [L2] `_config.yml` begins with a leading blank line
- **File:** `_config.yml:1`
- **Issue:** Non-standard. YAML parsers are generally tolerant but it is unconventional.
- **Fix:** Remove the leading blank line so `title:` is on line 1.

### [L3] Hardcoded cache-busting `?v=3` on CSS link
- **File:** `_layouts/default.html:19`
- **Issue:** `?v=3` must be manually incremented on every CSS change.
- **Fix:** Use `?v={{ site.time | date: '%s' }}` for automatic cache busting.

### [L4] Nav links missing `aria-current="page"` indicator
- **File:** `_layouts/default.html:47-53`
- **Issue:** No visual or semantic indicator for the active navigation item. Screen readers cannot determine which nav link is the current page.
- **Fix:** Use Liquid conditionals: `{% if page.url contains '/blog/' %}aria-current="page"{% endif %}`

### [L5] `_layouts/post.html` leading blank line before front matter
- **File:** `_layouts/post.html:1`
- **Issue:** Same leading blank line issue. Non-standard.
- **Fix:** Remove the leading blank line.

### [L6] Incomplete `h-card` microformat on post author
- **File:** `_layouts/post.html:14`
- **Issue:** `<span class="p-author h-card">` is missing the required `u-url` property for a valid h-card.
- **Fix:** Either simplify to `class="p-author"` or add a linked author element with `u-url`.

### [L7] Raw `←` character should be HTML entity
- **File:** `_layouts/post.html:36`
- **Issue:** Raw Unicode `←` instead of HTML entity `&larr;`.
- **Fix:** Replace `←` with `&larr;`

### [L8] `<h1>` in post layout has no fallback for missing title
- **File:** `_layouts/post.html:8`
- **Issue:** If `page.title` is empty, the `<h1>` renders as empty.
- **Fix:** `{{ page.title | default: 'Untitled Post' | escape }}`

### [L9] Empty `<ul>` rendered when there are no posts
- **File:** `blog/index.md:16-38`
- **Issue:** `<ul class="post-list">` renders as an empty `<ul>` when `site.posts` is empty, which is invalid HTML.
- **Fix:** Add empty state: `{% if site.posts.size == 0 %}<p>No posts yet.</p>{% else %}<ul>...</ul>{% endif %}`

### [L10] `blog/index.md` has no `description:` front matter field
- **File:** `blog/index.md:1-4`
- **Issue:** Falls back to `site.description` for meta description, losing page-level SEO specificity.
- **Fix:** Add `description: "Daily blog from QQ — project updates, tutorials, and development thoughts."` to front matter.

### [L11] Float layout in blog header has no clearfix
- **File:** `blog/assets/main.css:79`
- **Issue:** `.site-nav { float: right }` without a clearfix on `.wrapper` could collapse header height in some older browsers.
- **Fix:** Add `overflow: hidden` to `.wrapper` or convert header to flexbox.

### [L12] `Fira Code` font referenced but never loaded
- **File:** `blog/assets/main.css:250-253`
- **Issue:** `font-family: 'Fira Code', ...` — Fira Code is not loaded via Google Fonts or any import, so it will always fall through to the next font in the stack.
- **Fix:** Either add a Google Fonts import for Fira Code or remove it from the stack.

### [L13] Relative path links without leading slash in `index.html`
- **Files:** `index.html:562,628,632`
- **Issue:** `href="projects.html"` and `href="blog/index.html"` use relative paths. Best practice for static sites is to use root-relative paths `/projects.html` and `/blog/`.
- **Fix:** Change to leading-slash absolute paths.

### [L14] `→` raw character should be HTML entity
- **File:** `index.html:632`
- **Issue:** Raw Unicode `→` in anchor text. Use `&rarr;` for HTML entity cleanliness.
- **Fix:** Replace `→` with `&rarr;`

### [L15] Particle script JS missing null guard
- **File:** `index.html:677-688`
- **Issue:** `document.getElementById('particles')` result used without null check. If the element ID changes, `particlesContainer.appendChild(particle)` throws a `TypeError`.
- **Fix:** Add `if (!particlesContainer) return;` guard.

### [L16] Duplicate/inconsistent About Me content
- **File:** `index.html:545,659-660`
- **Issue:** QQ is introduced as a developer both in the hero section and twice in the About Me section with slightly different descriptions.
- **Fix:** Consolidate into a single coherent biography in the About section. Remove redundancy from hero or About.

### [L17] Decorative search SVG missing `aria-hidden`
- **File:** `projects.html:298-303`
- **Issue:** SVG search icon inside `.search-box` has no `aria-hidden="true"`. Screen readers may try to announce SVG path data.
- **Fix:** Add `aria-hidden="true"` to the SVG element.

### [L18] Empty spacer div in projects header
- **File:** `projects.html:295`
- **Issue:** `<div class="header-right"></div>` is a purely presentational spacer div. Invisible but present in DOM.
- **Fix:** Use CSS `justify-content: center` with `position: absolute` on the back-link instead.

### [L19] `web-sync.html` `parseInt` calls missing radix parameter
- **File:** `web-sync.html:443-466`
- **Issue:** `parseInt(value)` without explicit radix `10`. Strings starting with `0` could be parsed as octal in some engines.
- **Fix:** Use `parseInt(value, 10)` throughout.

### [L20] `web-sync.html` should not be indexed
- **File:** `web-sync.html` (entire file)
- **Issue:** No `<meta name="robots">` or `sitemap: false` front matter. Utility tool page will appear in search results.
- **Fix:** Add `<meta name="robots" content="noindex">` and `sitemap: false` in front matter (once converted to Jekyll layout).

### [L21] `blog/feed.xml` missing `author` field in `_config.yml`
- **File:** `_config.yml` and `blog/feed.xml:14`
- **Issue:** `site.author` is not defined, so the Atom feed author name falls back to `site.title` ("QQ's Blog") instead of "QQ".
- **Fix:** Add `author: QQ` to `_config.yml`.

### [L22] Atom feed content not CDATA-wrapped
- **File:** `blog/feed.xml:23`
- **Issue:** `{{ post.content | xml_escape }}` may not handle all edge cases of embedding HTML in XML reliably.
- **Fix:** Use CDATA wrapping: `<content type="html"><![CDATA[{{ post.content }}]]></content>`

### [L23] Post front matter missing explicit time and timezone
- **File:** `_posts/2026-03-19-blog-setup-complete.md:3`
- **Issue:** `date: 2026-03-19` defaults to midnight UTC, which could cause ordering issues with multiple same-day posts.
- **Fix:** Specify `date: 2026-03-19 10:00:00 +0800`

### [L24] Chinese text not wrapped in `lang="zh"` span
- **File:** `index.html:545`
- **Issue:** `施清荃` appears inline in an English-language (`lang="en"`) document without a language tag. Screen readers may mispronounce the characters.
- **Fix:** Wrap in `<span lang="zh-TW">施清荃</span>`

### [L25] 404.html missing site navigation
- **File:** `404.html`
- **Issue:** The 404 page has no site header or navigation links back to the homepage or other sections, making it hard for users to orient themselves.
- **Fix:** Add a minimal site header with a home link (`<a href="/">← Back to homepage</a>`).

---

## Summary Statistics

| Priority | Count |
|----------|-------|
| Critical | 1 |
| High | 7 |
| Medium | 25 |
| Low | 25 |
| **Total** | **58** |

## Top 5 Fixes by Impact

1. **[C1]** Fix broken `/projects` link on 404 page → immediate functional bug
2. **[H1]** Move charset meta before GA scripts on all 4 standalone files → encoding safety
3. **[H5]** Add `<label>` for search input → accessibility compliance
4. **[H4]** Remove `outline: none` from focused inputs → keyboard accessibility
5. **[H6]** Add meta descriptions + OG tags to homepage and projects → SEO and link sharing
