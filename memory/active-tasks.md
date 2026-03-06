# Active Tasks - Crash Recovery

This file is the "save game" state. I read this on every session start to resume work autonomously.

## Format
- **Task**: Description
- **Status**: not_started | in_progress | waiting_on_subagent | completed | blocked
- **Subagent**: Session key if spawned (for tracking)
- **Started**: ISO timestamp
- **Last Update**: ISO timestamp
- **Success Criteria**: How to know it's done

---

## Current Tasks

### 1. LifeLab Bug Fixes
- **Status**: completed
- **Subagent**: agent:main:subagent:aa184b7e-14bd-47ee-9c9f-0805cc3bb00c
- **Started**: 2026-03-06T08:25:00+08:00
- **Completed**: 2026-03-06T08:29:00+08:00
- **Success Criteria**: ✅ Bugs identified and fixed, changes pushed
- **Result**: 9 bugs fixed (DPI rendering, touch support, zoom, shareable URLs, keyboard shortcuts, mobile UI, etc.)

### 2. CollaBoard Bug Fixes  
- **Status**: completed
- **Subagent**: agent:main:subagent:26aab5e4-0e4f-4bf7-971a-eee008c00cb2
- **Started**: 2026-03-06T08:25:00+08:00
- **Completed**: 2026-03-06T08:30:00+08:00
- **Success Criteria**: ✅ Bugs identified and fixed, changes pushed
- **Result**: 8 bugs fixed (cursor throttling, canvas quality, peer colors, timeouts, error handling, etc.)

---

## Recently Completed (last 7 days)

| Task | Completed | Notes |
|------|-----------|-------|
| AGENTS.md Architecture Improvements | 2026-03-06 | Created health.md, schema-v2, subagent-results/, embeddings/ |

---

## Notes
- This file is written to disk immediately when tasks change
- Sub-agents update their parent task via sessions_send when done
- On crash/restart: Read this file → Resume or clean up
