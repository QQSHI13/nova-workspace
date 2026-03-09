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

### 1. ESP32 Pomodoro Button - Hardware Project
- **Status**: completed (design phase)
- **Location**: `/home/qq/.openclaw/workspace/esp32-button/`
- **Started**: 2026-03-06T17:45:00+08:00
- **Last Update**: 2026-03-06T20:45:00+08:00
- **Success Criteria**: ✅ Complete hardware design ready for fabrication
- **Components Complete**:
  - ✅ Firmware (PlatformIO, M5Atom, USB HID)
  - ✅ Schematic (backpack mounting, GROVE 4P)
  - ✅ BOM (~¥144-184 total cost)
  - ✅ EasyEDA guide
  - ✅ 3D backpack case (OpenSCAD, no lid)
  - ✅ Assembly guide (English + Chinese)
  - ✅ Web sync interface
- **MCU Selected**: **AtomS3 Lite** (ESP32-S3FN8) — ¥49.9, same price as Atom Lite but with native USB HID, 8MB flash, better battery life
- **Next Steps**: Order parts and fabricate
  - [ ] Order **AtomS3 Lite** (¥49.9)
  - [ ] Design PCB in EasyEDA (24x24mm, single M2 hole)
  - [ ] Order PCB from JLCPCB
  - [ ] Order components from LCSC
  - [ ] Order battery
  - [ ] 3D print backpack
  - [ ] Assemble and test

### 2. LifeLab Bug Fixes
- **Status**: completed
- **Subagent**: agent:main:subagent:aa184b7e-14bd-47ee-9c9f-0805cc3bb00c
- **Started**: 2026-03-06T08:25:00+08:00
- **Completed**: 2026-03-06T08:29:00+08:00
- **Success Criteria**: ✅ Bugs identified and fixed, changes pushed
- **Result**: 9 bugs fixed (DPI rendering, touch support, zoom, shareable URLs, keyboard shortcuts, mobile UI, etc.)

### 3. CollaBoard Bug Fixes  
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
| ESP32 Pomodoro Button Design | 2026-03-06 | Complete hardware project ready for fabrication |
| AGENTS.md Architecture Improvements | 2026-03-06 | Created health.md, schema-v2, subagent-results/, embeddings/ |

---

## Notes
- This file is written to disk immediately when tasks change
- Sub-agents update their parent task via sessions_send when done
- On crash/restart: Read this file → Resume or clean up
