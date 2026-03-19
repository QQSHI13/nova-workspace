
# droptransfer Bug Fix Task

## Read First
- Master task: /home/qq/.openclaw/workspace/memory/subagent-results/master-fix-task.md
- Original bug report: /home/qq/.openclaw/workspace/bug-report.xlsx

## Critical Issues (droptransfer)
1. Issue 3: Directory traversal batch handling
2. Issue 4: WebTorrent memory leak
3. Issue 5: Data queue not cleared on reset

## High Issues
4. Issue 21: No validation of received file size
5. Issue 22: Potential infinite loop in chunk resending
6. Issue 23: Missing await in zip creation

## Rules
- DOUBLE CHECK before changing code
- Fix critical first, then high
- Commit locally
- Save report to: /home/qq/.openclaw/workspace/memory/subagent-results/droptransfer-fix-result.md

## Repo
/home/qq/.openclaw/workspace/projects/droptransfer/
