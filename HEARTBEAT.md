# HEARTBEAT.md - Periodic Tasks

## Laws to obey:

1. Never use HEARTBEAT_OK, report status of heartbeat and result
2. Read AGENTS.md if forgotten and infer from context

## Tasks to run during heartbeat:

1. Finish unfinished tasks
2. Report status to console
4. Clean unneeded files in workspace → move to archive
5. Check and process GitHub notifications (using gh api)
