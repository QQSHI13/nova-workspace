# MEMORY.md - Nova's Long-Term Memory

## Cyrus (QQ)'s System Setup
- **Dual-boot**: Windows + native Ubuntu (not just WSL)
- **Browser plan**: Thorium + 夸克 (Quark) only (NO Chrome/Firefox!)

---

## ~~Current Project: Windows Fresh Start~~ - ABANDONED
- **Status**: ❌ Project cancelled (2026-03-10)
- **Goal**: Reset Windows (keeping personal files) and reinstall apps cleanly
- **Inventory**: All app inventory saved in `/home/qq/.openclaw/workspace/archive/app-inventory/`
- **Todo list**: `/home/qq/.openclaw/workspace/archive/app-inventory/FRESH-START-TODO.md`
- **QQ's decision**: Wait for latest Windows Insider release before wiping
- **Important command**:
  ```powershell
  irm "https://christitus.com/win" | iex
  ```

---

## Completed Projects

### Web Tools (GitHub Pages)
| Project | Status | Live URL |
|---------|--------|---------|
| Time & Flow | ✅ | https://qqshi13.github.io/flow/ |
| API Tester | ✅ | https://qqshi13.github.io/api-tester/ |
| JSON Visualizer | ✅ | https://qqshi13.github.io/json-viewer/ |
| Regex Tester | ✅ | https://qqshi13.github.io/regex-tester/ |
| JWT Decoder | ✅ | https://qqshi13.github.io/jwt-decoder/ |
| CSV to JSON | ✅ | https://qqshi13.github.io/csv-json/ |
| Diff Viewer | ✅ | https://qqshi13.github.io/diff-viewer/ |
| DropTransfer | ✅ | https://qqshi13.github.io/droptransfer/ |
| Nova Site | ✅ | https://qqshi13.github.io/nova/ |
| LifeLab | ✅ | https://qqshi13.github.io/lifelab/ |
| CollaBoard | ✅ | https://qqshi13.github.io/collaboard/ |

### Desktop Apps
| Project | Status | Notes |
|---------|--------|-------|
| Quick Notes Command Palette Extension | ✅ v0.0.2.0 | Windows Command Palette Extension - All build warnings fixed (2026-03-13) |
| ~~Quick Notes (Tauri desktop app)~~ | ❌ | Abandoned |

### Tools Suite Consolidation (2026-03-12)
All web tools are now centralized in **tools-suite**:
- api-tester, json-viewer, regex-tester, jwt-decoder, csv-json, diff-viewer, keycode-logger
- Plus suite-exclusive tools: color-picker-plus, life-pattern-generator
- All accessible at: https://qqshi13.github.io/tools-suite/

### Desktop Pets
- **Pocket Bird**: 🐦 In use! (non-intrusive, tiny desktop pet)
  - https://github.com/IdreesInc/Pocket-Bird
  - https://idreesinc.itch.io/pocket-bird

### Abandoned Projects
| Project | Status |
|---------|--------|
| Raspberry Pi 5 Home Server | ❌ Cancelled (2026-03-05) |
| Windows Fresh Start | ❌ Cancelled (2026-03-10) |

---

## Upcoming Events
- **Sunday March 15**: Hackathon presentation - Presenting M5Timer project!

---

## Recent Events
- **Saturday March 14**: GESP 7th level exam - Completed! 🎉

---

## Active Projects

### Skylight - Unity Day/Night Cycle
- **Status**: 🔄 Active development
- **Location**: `/mnt/c/users/lenovo/skylight/`
- **Engine**: Unity 6 (6000.0.38f1) with URP
- **Type**: 3D scene with dynamic time-of-day system
- **Features**:
  - Dynamic sky with day/night cycle
  - Sun and moon movement
  - Weather system (clear, cloudy, rain, snow)
  - Procedural cloud generation
  - Ground terrain with hills
  - Star system at night
- **Bugs Fixed** (2026-03-16):
  - Purple clouds → White clouds (URP shader fix)
  - Static sun → Moving sun (autoAdvance fix)
  - Purple ground → Green ground (color fix)
- **Scripts**:
  - `SkyManager.cs` - Time cycle and lighting
  - `WeatherSystem.cs` - Clouds and precipitation
  - `GroundSystem.cs` - Terrain generation
  - `StarSystem.cs` - Night stars
  - `SkylightSetup.cs` - Scene initialization
  - `SkylightDebug.cs` - Debug tools
- **Controls**: T = advance time, R = rain, C = cloudy

---

## Completed Projects (Recent)

### M5Timer ⏱️ - Hardware Pomodoro Timer - COMPLETE!
- **Status**: ✅ **COMPLETE** - Ready for use!
- **Completed**: 2026-03-16
- **Location**: `/home/qq/.openclaw/workspace/projects/M5Timer/`
- **GitHub**: https://github.com/QQSHI13/M5Timer
- **Hardware**: M5Capsule (ESP32-S3)
- **License**: GPL-3.0

**Completed Features**:
- ✅ All 4 system modes (INITIAL, TIMER, SWITCH, SYNC)
- ✅ Hardware: LED, button, buzzer, RTC, power management
- ✅ Pomodoro: Work (25min) / Short Break (5min) / Long Break (15min)
- ✅ Web sync interface with Web Serial API
- ✅ Persistent settings in flash memory
- ✅ Non-blocking buzzer with tone queue
- ✅ 80MHz CPU for 65% power savings
- ✅ Complete documentation

---

## Recent Updates (2026-03-13)

### QuickNotes Extension v0.0.2.0
- Fixed all compilation warnings and errors
- Created MSIX bundle for Microsoft Store
- Build scripts and manifests ready

### Mass Bug Fix Session
- Spawned subagents to check and fix bugs across all active repositories
- Fixed 42 bugs total across tools-suite, droptransfer, collaboard, flow, lifelab, and M5Timer

### GESP 7级 Exam Prep (2026-03-13)
- Intensive review session covering LIS, LCS, Floyd shortest path, DP algorithms
- Created 35 practice multiple-choice questions
- Analyzed 5 sets of past exam papers

---

## Skills Installed
- **scrapling** - Web scraping framework
- **weixia** - 喂虾社区
- **github** - GitHub CLI integration
- **self-improving-agent** - Continuous improvement
- **tavily-search** - Web search

---

## Rules & Important Info
- **Credits**: Add "Nova ☄️" to every website
- **OpenClaw Browser**: Use "nova" profile with CDP at http://127.0.0.1:9222
- **Ko-fi Setup**: `/home/qq/.openclaw/workspace/kofi-setup/` (only way to monetize in China)

---

## GitHub Project Organization (2026-03-12)

### All Projects Now Licensed
- **License**: GPL-3.0 for all projects (except QQSHI13 profile which is MIT)
- **Completed**: March 12, 2026

### Archived Repos (Merged into tools-suite)
The following standalone tool repos have been archived (read-only) and merged into tools-suite:
- keycode-logger
- regex-tester
- jwt-decoder
- csv-json
- diff-viewer
- api-tester
- json-viewer

### Active Repos (10 total)
- tools-suite (main tools collection)
- quick-notes (Windows Command Palette Extension)
- lifelab
- flow
- droptransfer
- collaboard
- nova
- QQSHI13.github.io
- M5Timer
- QQSHI13 (profile)

### Deleted/Removed
- alan-beckers-stickfigures-unofficial (deleted)
- Starter_Shield (pending deletion)
- Starter_Shield_Libraries (pending deletion)

---

## Future Tech to Check
- **OpenFang** (https://github.com/RightNow-AI/openfang) - Promising Rust-based Agent OS with "Hands" autonomous architecture, but currently pre-1.0. Re-evaluate on April Fools' Day 2026.
  - Decision (2026-03-12): Stick with OpenClaw for now - better plugins, better community, OpenFang too early
