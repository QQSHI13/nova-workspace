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

*(none active)*

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
