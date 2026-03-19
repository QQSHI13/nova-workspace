
# M5Timer Critical Bug Fix Task

## Read First
- Master task: /home/qq/.openclaw/workspace/memory/subagent-results/master-fix-task.md
- Validation report: /home/qq/.openclaw/workspace/memory/subagent-results/bug-report-validation-result.md
- Original bug report: /home/qq/.openclaw/workspace/bug-report.xlsx

## Critical Issues to Fix (M5Timer)
1. Issue 14: RTC time calculation bug (main.cpp lines 152‑161) - handle min/hour/day rollovers
2. Issue 15: Preferences namespace collision (storage.cpp line 4) - change from "pomodoro" to "M5Timer"

## Rules
- **DOUBLE CHECK** before changing any code!
- Fix one issue at a time
- Verify compilation with `pio run` after each fix
- Commit changes locally (one commit per issue)
- Save fix report to: /home/qq/.openclaw/workspace/memory/subagent-results/m5timer-critical-fix-result.md

## Repo Location
/home/qq/.openclaw/workspace/projects/M5Timer/
