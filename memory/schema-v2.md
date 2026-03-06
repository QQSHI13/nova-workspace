# Memory Schema Version 2

**Version**: 2  
**Effective Date**: 2026-03-06  
**Breaking Changes**: None (additive only)

---

## Directory Structure

```
memory/
├── .schema-version              # Current schema version (this file)
├── health.md                    # Agent health dashboard
├── README.md                    # Memory system documentation
├── active-tasks.md              # Crash recovery state
├── lessons.md                   # Curated insights
├── projects.md                  # Project-specific notes
├── skills.md                    # Skill-specific knowledge
├── code-index.md                # Searchable code index
├── tools-knowledge-base.md      # Tool documentation
├── subagent-results/            # Sub-agent outputs
│   ├── <uuid>.md               # Individual result files
│   └── README.md               # Sub-agent result index
├── YYYY-MM-DD.md               # Daily operation logs
└── _template_*.md              # Templates for new files
```

---

## Schema v2 Additions

### New Files

| File | Purpose | Auto-Generated |
|------|---------|----------------|
| `health.md` | Real-time agent status dashboard | Partial (manual + heartbeat) |
| `.schema-version` | Version tracking for future migrations | Manual |
| `subagent-results/*.md` | Persistent sub-agent outputs | Auto (on completion) |
| `subagent-results/README.md` | Index of all sub-agent results | Auto-updated |

### File Formats

#### `health.md`
- YAML frontmatter optional
- Sections: System Status, Active Tasks, Sub-Agent Activity, Pending Checks, Alerts, Stats
- Updated by: Heartbeats, task start/completion, sub-agent events

#### `subagent-results/<uuid>.md`
```markdown
# Sub-Agent Result: <uuid>

**Task**: <description>
**Spawned**: ISO timestamp
**Completed**: ISO timestamp
**Status**: success | failure | timeout | killed
**Parent Session**: <session key>

---

## Output

<summary or full output>

## Artifacts

- File: <path>
- URL: <url>
```

---

## Migration Notes

- v1 → v2: Add `health.md`, `.schema-version`, `subagent-results/` directory
- All existing files remain compatible
- Future schema changes should update `.schema-version` and document here
