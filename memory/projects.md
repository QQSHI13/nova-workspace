# Project Tracker

Active and completed projects with quick-reference info.

---

## 🔄 Active Projects

### ESP32 Pomodoro Button
- **Status**: Design complete, ready for fabrication
- **Location**: `/home/qq/.openclaw/workspace/esp32-button/`
- **Type**: Hardware (ESP32 embedded)
- **Cost**: ~¥149-189
- **Started**: 2026-03-06
- **Next Action**: Order parts (Atom Lite, PCB, components, battery)
- **Files**:
  - `hardware/schematic.md` - Circuit design
  - `firmware/` - PlatformIO code
  - `3d-models/backpack.scad` - 3D case
  - `docs/Assembly-Guide.md` - Build instructions

---

## ✅ Recently Completed

### Web Tools Bug Sweep
- **Completed**: 2026-03-06
- **Scope**: 11 web projects
- **Result**: 30+ bugs fixed across all tools
- **Projects**: DropTransfer, API Tester, JSON Viewer, Regex Tester, JWT Decoder, CSV→JSON, Diff Viewer, Flow, Nova Site, LifeLab, CollaBoard

### Quick Notes Desktop App
- **Status**: Build phase
- **Type**: Tauri (Rust + Web)
- **Progress**: 25+ bugs fixed, awaiting CI build
- **Location**: https://github.com/QQSHI13/quick-notes

### Homepage Redesign
- **Completed**: 2026-03-06
- **Result**: Clean text header + dot accent + cards layout
- **Live**: https://qqshi13.github.io

---

## 📊 Project Statistics

| Category | Count |
|----------|-------|
| Web Tools (GitHub Pages) | 11 ✅ |
| Desktop Apps | 1 🔄 |
| Hardware Projects | 1 🔄 |
| Total Completed | 11 |
| In Progress | 2 |

---

## 🏗️ Project Architecture Decisions

### Web Tools
- **Stack**: Vanilla JS, no frameworks
- **Hosting**: GitHub Pages
- **Styling**: CSS Variables, GitHub dark theme
- **Pattern**: Simple, focused tools

### Desktop Apps
- **Stack**: Tauri (Rust + Web)
- **Platform**: Windows primary
- **Distribution**: GitHub Releases

### Hardware
- **Stack**: ESP32, PlatformIO, Arduino
- **Fabrication**: JLCPCB (PCB), JLC3D/第三方 (3D print)
- **Sourcing**: LCSC (components), Taobao (battery, Atom Lite)

---

*Last updated: 2026-03-06*
