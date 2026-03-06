# Memory System Documentation

This directory contains the self-improving documentation system for maintaining continuity and learning across sessions.

**Schema Version**: 2 (see `.schema-version`, `schema-v2.md`)

---

## File Organization

### System Files

| File | Purpose | When to Update |
|------|---------|----------------|
| `.schema-version` | Version tracking for format changes | Manual (on schema updates) |
| `health.md` | Agent health dashboard - real-time status | Every session + heartbeats |
| `schema-v2.md` | Schema documentation | Manual |

### Core Memory Files

| File | Purpose | When to Update |
|------|---------|----------------|
| `lessons.md` | Curated insights, patterns, mistakes | When you learn something worth remembering |
| `active-tasks.md` | Crash recovery state - the "save game" | When starting/completing tasks |
| `projects.md` | Project-specific notes and status | When project state changes |
| `skills.md` | Skill-specific knowledge | When mastering new tools/patterns |
| `code-index.md` | Searchable index of all code projects | When projects change |
| `tools-knowledge-base.md` | Comprehensive docs on deployed tools | When tools are updated |

### Daily Files

| Pattern | Purpose | Retention |
|---------|---------|-----------|
| `YYYY-MM-DD.md` | Raw daily session logs | 30 days, then archive or distill |
| `YYYY-MM-DD-topic.md` | Topic-specific deep dives | Keep if still relevant |

### Sub-Agent Results

| Pattern | Purpose |
|---------|---------|
| `subagent-results/<uuid>.md` | Individual sub-agent outputs |
| `subagent-results/README.md` | Auto-generated index |

### Semantic Search

| Directory | Purpose |
|-----------|---------|
| `embeddings/` | Nomic embedding generation scripts |
| `embeddings/vectors/` | Generated vector embeddings |

### Templates & Patterns

| File | Purpose |
|------|---------|
| `_template_daily.md` | Template for new daily entries |
| `_pattern_crossday_links.md` | How to link ideas across days |

---

## Quick Start

### Starting a New Day

1. Copy `_template_daily.md` to `2026-MM-DD.md`
2. Fill in date and session info
3. Log work as it happens
4. Add lessons to `lessons.md` immediately if significant

### During Work

- **Learn something?** → Add to `lessons.md`
- **Start a task?** → Update `active-tasks.md`
- **Reference prior work?** → Use cross-day links
- **Defer work?** → Note in active-tasks.md with target date

### Weekly Maintenance (Every 7 Days)

1. **Review recent daily files** (last 7 days)
2. **Extract lessons** → Add to `lessons.md`
3. **Clean up completed tasks** → Archive from `active-tasks.md`
4. **Verify cross-day links** → Fix any broken references
5. **Update MEMORY.md** (main session only) → Curate long-term memory

---

## Memory Lifecycle

```
┌─────────────────┐
│  Daily Session  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐     ┌─────────────────┐
│  YYYY-MM-DD.md  │────▶│   lessons.md    │ (patterns)
│   (raw notes)   │     │  (curated)      │
└────────┬────────┘     └─────────────────┘
         │
         ▼
┌─────────────────┐     ┌─────────────────┐
│ active-tasks.md │────▶│   projects.md   │ (status)
│ (crash recovery)│     │                 │
└─────────────────┘     └─────────────────┘
         │
         ▼
┌─────────────────┐
│   MEMORY.md     │ (long-term, main session only)
│ (essence only)  │
└─────────────────┘
```

---

## Cross-Day Linking

See `_pattern_crossday_links.md` for detailed patterns.

**Quick reference**:
```markdown
# Link to prior work
[previous JWT Decoder](memory/2026-03-02.md)

# Link to pattern
[mobile double-tap pattern](memory/lessons.md#mobile-web-development)

# Link to active task
[Pi research](memory/active-tasks.md#research-pi-dashboard)
```

---

## Success Criteria

This memory system is working when:

- [ ] Can resume work after crash without asking "what were we doing?"
- [ ] Can find relevant prior work within 30 seconds
- [ ] Don't repeat the same mistakes
- [ ] Patterns are documented and reused
- [ ] Cross-day connections are explicit, not implicit

---

## Anti-Patterns

| Don't | Do Instead |
|-------|-----------|
| Dump everything into MEMORY.md | Split across thematic files |
| Keep daily files forever | Archive after 30 days, keep only distilled lessons |
| Use "mental notes" | Write to appropriate file immediately |
| Vague references ("before", "earlier") | Precise links (`memory/2026-03-02.md#section`) |
| Duplicate info across files | Single source of truth with links |

---

## Maintenance Schedule

| Frequency | Task | Time |
|-----------|------|------|
| Daily | Log to daily file, update active-tasks, check health.md | 2 min |
| Every 15 min | Heartbeat check (EvoMap, sub-agent status) | 30 sec |
| Weekly | Review week, extract lessons, clean tasks, regenerate embeddings | 15 min |
| Monthly | Archive old daily files, update MEMORY.md, verify schema | 30 min |

---

*Last updated: 2026-03-06*
*System version: 2.0*
