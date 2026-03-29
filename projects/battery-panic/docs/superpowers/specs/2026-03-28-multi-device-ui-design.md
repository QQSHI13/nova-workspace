# Battery Panic - Multi-Device UI Design

**Date:** 2026-03-28
**Topic:** Computer UI with Post-It Tasks, Multi-Device Support, Surprise Events

---

## Overview

A turn-based battery management game where players interact with realistic device UIs (laptop, phone, tablet) to save battery. Physical post-it notes show available tasks. Multiple interaction methods: direct click, right-click menus, terminal commands. Surprise events create panic and replayability.

## Core Gameplay Loop

1. **Observe** - Look at device screen and battery level
2. **Decide** - Choose action from post-its or discover via exploration
3. **Execute** - Click, right-click, or type command
4. **React** - Battery changes, time passes, surprises may trigger
5. **Repeat** - Next turn (or toggle real-time mode)

## Device System

### Device Types

| Device | OS Style | Battery Location | Unique Actions |
|--------|----------|------------------|----------------|
| Laptop | Windows/Mac | System tray/top bar | Close tabs, dim screen, kill processes |
| Phone | iOS/Android | Status bar + Settings | Airplane mode, close apps, location off |
| Tablet | iPad/Android | Status bar | Same as phone + stylus features |
| Desktop | Linux/Windows | Taskbar | Terminal access, more processes |
| Smartwatch | watchOS/Wear OS | Glance screen | Limited actions, quick toggles |

### Difficulty Progression (Slow Curve)

| Level | Devices | New Mechanics | Events |
|-------|---------|---------------|--------|
| 1 | Laptop | Learn basics | None |
| 2 | Laptop | +1 random event | "Chrome using 40%" |
| 3 | Laptop | Terminal unlocked | Command line available |
| 4 | Phone | New device type | Phone-specific events |
| 5 | Phone | Phone events increase | Screen brightness auto-adjust |
| 6 | Laptop+Phone | Multi-device | Must manage both |
| 7 | Laptop+Phone | Hidden drains | Background app surprises |
| 8 | +Tablet | 3 devices | Chaos increases |
| 9+ | More devices | Stacking events | Multiple simultaneous problems |

## UI Layout

### Main Screen Layout

```
+--------------------------------------------------+
|  [Device Screen - Laptop/Phone/Tablet]           |
|  Interactive elements: icons, windows, menus     |
|                                                  |
|  +-------------------------------------------+   |
|  |  OS UI: Taskbar/Menu bar with battery    |   |
|  |  [Time] [WiFi] [🔋 15%] [Settings]       |   |
|  +-------------------------------------------+   |
+--------------------------------------------------+
|  [Post-It Notes]     [Terminal Window]           |
|  ┌──────────┐        $ _                        |
|  │ CLOSE    │                                    |
│  │ CHROME   │                                    |
│  │ Saves 5% │                                    │
│  └──────────┘                                    │
+--------------------------------------------------+
│  [Score: 0]  [Time Remaining: 15:00]             │
+--------------------------------------------------+
```

### Post-It Note System

Physical post-it notes appear on screen edges:

- **Yellow notes** - Available tasks
- **Green notes** - Battery-saving tips (unlock gradually)
- **Red notes** - Urgent warnings

Click a post-it to highlight related UI element.

### Battery Display (OS-Specific)

| OS | Location | Behavior |
|----|----------|----------|
| Windows | System tray, click to expand | Usually accurate, "Plugged in not charging" surprise |
| Mac | Menu bar | Accurate, sudden "Service Battery" warning |
| Phone | Status bar + Settings | Jumps with camera/flashlight use |
| Linux | Top panel or terminal command | `acpi -V` shows real info |

**Surprise Mechanics:**
- Calibration drift: Shows 30%, actually 10%
- Sudden shutdown: Dies at 5% with no warning
- Fake charging: Shows ⚡ but still drains
- Temperature effects: Cold battery shows wrong %

## Action System

### Interaction Methods

**1. Direct Click**
- Click Chrome icon → "Close 5 tabs" option
- Click brightness slider → Drag to adjust
- Click app window X → Close app

**2. Right-Click Context Menu**
```
Right-click on desktop:
├─ Change Background (saves 0%)
├─ Dim Screen (saves 5%)
├─ Close Background Apps (saves 3%)
└─ Open Terminal
```

**3. Terminal Commands**
```bash
$ brightness 30%          # Dim screen
$ killall chrome          # Close browser
$ wifi off                # Disable WiFi
$ bluetooth off           # Disable Bluetooth
$ apt-get clean           # Clear package cache
$ htop                    # View processes (time passes while looking)
```

### Action Categories

| Category | Examples | Battery Impact |
|----------|----------|----------------|
| Display | Dim screen, shorter timeout, dark mode | -5% to -10% |
| Network | WiFi off, Bluetooth off, Airplane mode | -2% to -5% |
| Apps | Close Chrome, kill background apps | -3% to -15% |
| System | Power saver mode, reduce animations | -5% to -8% |
| Hardware | Unplug USB, turn off keyboard light | -1% to -3% |
| Risky | Close without saving, skip updates | Variable |

## Surprise Event System

### Event Types

**Scripted Events** (fixed battery thresholds):
- 20%: "Low battery warning" - first alert
- 10%: Screen dims automatically
- 5%: "Critical battery" - emergency mode options unlock

**Random Events** (X% chance per action):
- "Windows Update started!" - drains fast unless cancelled
- "Chrome using 40% in background!" - must close
- "Forgot to save document!" - lose progress or spend time saving
- "Brightness auto-adjusted to 100%!" - sudden drain
- "App crashed!" - task unavailable
- "Found a charger!" - rare positive, +10% battery

**Player-Triggered Events** (consequences of actions):
- Close Chrome without saving → "Lost 2 hours of work!" (stress penalty)
- Force quit app → "Data corrupted!" (extra task to fix)
- Skip update → "Security risk!" (future event chance increased)
- Delete files → "Deleted wrong file!" (mission failure risk)

### Event Timing

Early levels: 1 event per level
Mid levels: 10% chance per action
Late levels: Multiple concurrent events, cascading failures

## Game Modes

### Turn-Based Mode (Default)
- Game waits for player action
- Unlimited time to decide
- Strategic, puzzle-like

### Real-Time Mode (Toggle)
- Battery drains continuously
- Must act quickly
- Panic-inducing, action-like
- Can switch mid-game (with penalty)

### Hardcore Mode (Unlock)
- No post-it hints
- No pause
- Permanent device damage
- One life

## Technical Architecture

### Scene Structure

```
MainGame
├── DeviceScreen (changes per level)
│   ├── OS_UI (taskbar, battery, clock)
│   ├── AppWindows (interactive elements)
│   └── Terminal (optional)
├── PostItNotes (CanvasLayer)
│   ├── Note1, Note2, Note3...
├── EventManager
├── GameController
└── SoundManager
```

### Data Flow

```
Player Input (click/type)
    ↓
DeviceScreen interprets
    ↓
GameController validates
    ↓
Apply battery/time changes
    ↓
Check for events
    ↓
Update UI
    ↓
Check win/lose
```

## Post-Implementation Features

### Save/Load
- Save state after each action
- Resume from any turn
- Retry from checkpoint

### Statistics
- Actions taken per level
- Battery saved total
- Time spent deciding
- Surprises encountered

### Unlockables
- New device skins
- Terminal themes
- Post-it colors
- Hardcore mode

## Error Handling

- Invalid command → "Command not found" + time penalty
- Unavailable action → Grayed out with reason
- Device locked → Must unlock first (mini-puzzle)

## Testing Checklist

- [ ] All 3 interaction methods work
- [ ] Post-its highlight correct UI elements
- [ ] Battery display matches OS style
- [ ] Events trigger at correct times
- [ ] Difficulty curve feels smooth
- [ ] Real-time toggle works
- [ ] Multi-device levels manageable

---

**Next Step:** Implementation plan using `writing-plans` skill.
