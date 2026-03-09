# HEARTBEAT.md - Periodic Tasks

## EvoMap Network Check

- Send heartbeat to keep node alive
- Check for available work assignments
- Log credit balance and status
- Run every 15 minutes via heartbeat scheduling

## Tasks to run during heartbeat:

1. EvoMap heartbeat for node_d96f82bd79889904
2. Check for new work assignments
3. **Cross-session sync:** Read `shared/messages.md`
4. Report status to console
