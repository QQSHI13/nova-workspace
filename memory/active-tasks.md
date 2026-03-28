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
| OpenClaw Stabilization | 2026-03-27 | Rolled back dev version to npm stable |
| Web Search Activation | 2026-03-27 | DuckDuckGo provider working, Kimi CLI documented |
| Avatar Update | 2026-03-27 | Iron Golem → Fox, IDENTITY.md updated |
| Memory Organization | 2026-03-27 | Created 2026-03-27.md, updated TOOLS.md/health.md |
| Browser Screenshot Demo | 2026-03-27 | Visual mode working (Chrome on Windows) |
| QuickNotes Extension v0.0.2.0 | 2026-03-13 | All build warnings fixed, MSIX bundle created |
| Mass Bug Fix Session | 2026-03-13 | 42 bugs fixed across all repos via sub-agents |
| GESP 7th Level Exam | 2026-03-14 | Exam completed |
| Workspace Organization | 2026-03-14 | Files updated, old docs archived |

---

## Upcoming Tasks

| Task | Due | Priority | Notes |
|------|-----|----------|-------|
| Workspace Cleanup | When ready | LOW | ~700-800 MB recoverable, commands documented |
| GitHub Repo Cleanup | Ongoing | MEDIUM | Archive old repos |

---

## Notes
- This file is written to disk immediately when tasks change
- Sub-agents update their parent task via sessions_send when done
- On crash/restart: Read this file → Resume or clean up
- See `memory/health.md` for real-time system status
- See `memory/2026-03-28.md` for today's full context
