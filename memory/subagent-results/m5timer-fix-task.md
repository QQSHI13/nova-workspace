
# M5Timer Bug Fix Task

## Tasks to Fix (3 issues)
1. **Critical**: RTC time calculation bug (main.cpp lines 152-161) - handle min/hour/day rollovers
2. **Critical**: Preferences namespace collision (storage.cpp line 4) - change from "pomodoro" to "M5Timer"
3. **Medium**: Buzzer volume inconsistency (buzzer.cpp lines 43, 64) - apply volume changes immediately

## Instructions
- Read the full validation report first: /home/qq/.openclaw/workspace/memory/subagent-results/bug-report-validation-result.md
- Fix each issue one by one
- **DOUBLE CHECK** your changes before modifying any code
- Test your fixes (verify they compile with `pio run`)
- Commit your changes (but don't push yet)
- Save your fix report to: /home/qq/.openclaw/workspace/memory/subagent-results/m5timer-fix-result.md

## Repository Location
/home/qq/.openclaw/workspace/projects/M5Timer/
