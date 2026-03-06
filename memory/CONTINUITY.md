# Conversation Continuity System

## Purpose
Resume interrupted conversations with full context. Never ask "what were we doing?"

## How It Works

### 1. Session Start Checklist
On every new session, automatically:
- [ ] Read `memory/active-tasks.md` — what's in progress?
- [ ] Read yesterday's and today's memory files
- [ ] Search for any mentioned but unresolved topics
- [ ] Check for follow-ups from previous sub-agents

### 2. Context Restoration Patterns

**If user says:** | **Do this:**
---|---
"Continue" / "Go on" | Pull last active task, resume
"What about X?" | Search memory for X, summarize status
"Did you finish Y?" | Check subagent completion status
"Remind me" | Surface last 3-5 significant interactions

### 3. Cross-Session Linking

When a topic spans multiple days, create links:
```markdown
## 2026-03-05 - Pi NAS Setup (continued from 2026-03-03)
Previous: [[2026-03-03-pi-nas-planning]]
Status: Waiting for hardware delivery
Next: Install when parts arrive
```

### 4. Auto-Tagging

Tag entries for easier retrieval:
- `#project-pi` — Raspberry Pi server project
- `#tool-droptransfer` — DropTransfer work
- `#decision` — Made a decision
- `#blocked` — Waiting on something
- `#idea` — Future idea to revisit

### 5. Morning Briefing Template

```markdown
## Morning Briefing - 2026-03-05

### Active Tasks
1. [Task name] - Status - Last updated [time]

### Pending Decisions
- [Decision needed]

### Calendar (next 24h)
- [Events from calendar]

### Notes from Yesterday
- [Key takeaways]
```

## Quick Reference Commands

**Find project context:**
```
Search: "Pi server setup" in memory
```

**Find code patterns:**
```
Search: "chunked file transfer implementation"
```

**Find unresolved items:**
```
Search: "#blocked OR waiting on"
```
