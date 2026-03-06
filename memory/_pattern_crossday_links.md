# Cross-Day Linking Pattern

**Purpose**: Extract and maintain connections between ideas, decisions, and work across different days. This creates continuity and helps retrieve relevant context when needed.

---

## Types of Cross-Day Links

### 1. Continuation Links (Building on Past Work)

**When to use**: When today's work directly extends something from a previous day

**Pattern**:
```markdown
Building on [previous work](memory/2026-03-02.md#section):
- New feature added
- Bug fixed in prior implementation
```

**Example from real work**:
```markdown
Building on [JWT Decoder deployed yesterday](memory/2026-03-02.md):
- Added sample tokens for testing
- Fixed mobile responsiveness
```

### 2. Pattern Application Links

**When to use**: When applying a lesson or pattern from lessons.md

**Pattern**:
```markdown
Applied [mobile double-tap pattern](memory/lessons.md#mobile-web-development):
- Used 300ms threshold for detection
- Disabled keyboard shortcuts as per guideline
```

### 3. Decision Reference Links

**When to use**: When a prior decision affects current choices

**Pattern**:
```markdown
Following [decision to use Thorium](memory/2026-03-04.md#key-decisions-made):
- Evaluating extension API compatibility
```

### 4. Deferred Work Links

**When to use**: When work was started but postponed

**Pattern**:
```markdown
[Deferred from 2026-03-03](memory/2026-03-03.md#blocked):
- SSH terminal protocol handler
- Waiting for Thorium extension API research
```

---

## How to Create Links During Work

### Automatic Link Detection

When processing daily memory files, look for these signals:

| Signal Pattern | Link Type | Action |
|---------------|-----------|--------|
| "like we did before..." / "similar to..." | Continuation | Search memory files for similar work |
| "as mentioned yesterday..." | Continuation | Link to previous day's file |
| "following the pattern..." | Pattern | Link to lessons.md section |
| "remember when we..." | Continuation | Search for referenced work |
| "going back to..." | Continuation | Find original discussion |
| "deferred / postponed / later" | Deferred | Note in active-tasks.md with date |

### Manual Link Creation

When writing daily notes, add `[[Links]]` section:

```markdown
## [[Links]]

### Backlinks (References from past)
- Pattern from [lessons.md#mobile-web-development]
- Prior art in [2026-03-02.md#jwt-decoder]

### Outlinks (Sets up future)
- Should revisit when [Thorium research complete]
- Deferred: [SSH protocol handler → 2026-03-10]
```

---

## Weekly Link Extraction Process

Run this every week to maintain link integrity:

### Step 1: Gather Candidate Links

Search daily files for link signals:
```bash
grep -r -E "(yesterday|before|earlier|previous|deferred|postponed|remember when)" memory/2026-*
```

### Step 2: Resolve Ambiguous References

When you see "like the fix we did before", determine:
- Which specific day/file?
- Which specific section?
- Update with precise link

### Step 3: Update lessons.md

If a cross-day link reveals a reusable pattern:
1. Add to appropriate section in lessons.md
2. Link to source days as examples
3. Tag with categories

### Step 4: Verify Active Links

Check that links still resolve:
- Daily files exist and are readable
- lessons.md sections haven't moved
- No broken anchor references

---

## Link Maintenance Commands

```bash
# Find all cross-references in memory files
grep -rE "\[.*\]\(memory/" memory/ | sort

# Find files with no outgoing links (orphans)
for f in memory/2026-*.md; do
  if ! grep -q "memory/" "$f"; then
    echo "No links: $f"
  fi
done

# Find files that are never linked to (dangling)
# (Requires building index of all links)
```

---

## Example: Rich Cross-Day Context

Here's what good cross-linking looks like:

**In 2026-03-05.md**:
```markdown
## Browser Protocol Architecture

Building on [Thorium discussion](memory/2026-03-04-pi-dashboard-research.md):
- User wants universal protocol browser
- Applied [extension-first pattern](memory/lessons.md#browser-architecture-insights)

Following [mobile UX lesson](memory/lessons.md#mobile-web-development):
- Ensure touch-friendly protocol switcher

## [[Links]]

### Continues From
- [2026-03-04-pi-dashboard-research.md] - Thorium research
- [lessons.md#universal-protocol-browser-design] - Architecture pattern

### Sets Up
- Need to research Thorium extension API specifics
- Should test on Pi 5 when available

### Related Decisions
- [2026-02-28-wsl-wipe-update.md#phase-0] - Pi as server setup
```

---

## Anti-Patterns to Avoid

| Don't | Do Instead |
|-------|-----------|
| "We did this before..." (vague) | "As done in [2026-03-02.md#mobile-fixes]..." |
| "Similar to the other thing" | "Similar to [JWT Decoder pattern](memory/lessons.md#project-lifecycle)" |
| "Remember when..." | "[Previously](memory/2026-03-01.md) we decided..." |
| Dead links to moved sections | Update anchors when restructuring |

---

## Quick Reference: Link Syntax

```markdown
# Link to daily file
[Description](memory/2026-03-02.md)

# Link to section in daily file
[Description](memory/2026-03-02.md#section-anchor)

# Link to lessons.md section
[Description](memory/lessons.md#section-name)

# Link to active task
[Description](memory/active-tasks.md#task-name)
```

---

*This pattern ensures institutional knowledge survives across sessions and restarts.*
