
# atoms3-rainbow Bug Fix Task

## Read First
- Master task: /home/qq/.openclaw/workspace/memory/subagent-results/master-fix-task.md
- Original bug report: /home/qq/.openclaw/workspace/bug-report.xlsx

## Critical Issues (atoms3-rainbow)
1. Issue 1: Board mismatch - uses esp32-s3-devkitc-1 instead of m5stack-atoms3
2. Issue 2: Missing lib_compat_mode - M5Unified has no version pinning

## High Issues
3. Issue 18: Missing randomSeed()
4. Issue 19: Unused M5Unified library
5. Issue 20: No button debouncing

## Rules
- DOUBLE CHECK before changing code
- Fix critical first, then high
- Verify with pio run after fixes
- Commit locally
- Save report to: /home/qq/.openclaw/workspace/memory/subagent-results/atoms3-rainbow-fix-result.md

## Repo
/home/qq/.openclaw/workspace/projects/atoms3-rainbow/
