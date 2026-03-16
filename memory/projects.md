# Project Tracker

Active and completed projects with quick-reference info.

---

## 🔄 Active Projects

### Skylight - Unity Day/Night Cycle
- **Status**: Active development
- **Location**: `/mnt/c/users/lenovo/skylight/`
- **Type**: Unity 3D (URP)
- **Started**: 2026-03-15
- **Last Updated**: 2026-03-16
- **Features**: Dynamic sky, day/night cycle, weather system, clouds, ground terrain
- **Bugs Fixed**: Purple clouds→white, static sun→moving, purple ground→green
- **Key Scripts**: SkyManager, WeatherSystem, GroundSystem, StarSystem
- **Engine**: Unity 6000.0.38f1 with Universal Render Pipeline

---

## ✅ Recently Completed

### M5Timer - Hardware Pomodoro Timer (2026-03-16)
- **Status**: COMPLETE ✅
- **Location**: `/home/qq/.openclaw/workspace/projects/esp32-button/`
- **GitHub**: https://github.com/QQSHI13/M5Timer
- **Type**: ESP32 hardware (M5Capsule)
- **Completed**: 2026-03-16
- **Features**:
  - 4 system modes (INITIAL, TIMER, SWITCH, SYNC)
  - Hardware: LED, button, buzzer, RTC, power management
  - Pomodoro timing (Work/Break/Long Break)
  - Web Serial API configuration
  - Persistent flash storage
  - 80MHz CPU for battery savings
- **Tech**: C++, Arduino, PlatformIO, Web Serial API
- **License**: GPL-3.0

### Skylight Bug Fixes (2026-03-16)
- **Project**: Unity Skylight day/night cycle
- **Issues Fixed**:
  - Purple clouds → White clouds (URP shader compatibility)
  - Static sun → Moving sun (autoAdvance initialization fix)
  - Purple ground → Green ground (proper color values)
- **Changes**: Complete rewrite of SkyManager, WeatherSystem, GroundSystem for URP

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
| Hardware Projects | 1 ✅ |
| Unity 3D Projects | 1 🔄 |
| Total Completed | 12 |
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

### Unity 3D
- **Stack**: Unity 6 (6000.x), URP, C#
- **Platform**: PC (Windows)
- **Rendering**: Universal Render Pipeline
- **Version Control**: Unity built-in (no Git for this project)

---

*Last updated: 2026-03-16*
