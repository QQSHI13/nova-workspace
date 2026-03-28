# Battery Panic - Asset-Ready Structure Design

**Date:** 2026-03-28
**Topic:** Pixel Art Sprites, Task Buttons, Sound Effects, UI Polish
**Approved Approach:** Asset-Ready Structure (Approach 2)

---

## Overview

Build a properly structured Godot project with placeholder assets that can be easily replaced with real pixel art, sounds, and polished UI later. Focus on functional mechanics with clean architecture.

## Architecture

Scene-based architecture following Godot best practices:

```
MainGame (Node2D)
├── UI (CanvasLayer)
│   ├── BatteryDisplay (scene instance)
│   ├── TaskContainer (VBoxContainer)
│   │   └── TaskButton (scene instances, spawned dynamically)
│   └── GameOverPanel
├── Background
└── GameController (script)
```

**Autoload:**
- `SoundManager` - Global audio management

## Components

### 1. TaskButton Scene (`scenes/task_button.tscn`)

**Node Structure:**
```
TaskButton (TextureButton)
├── Icon (Sprite2D) - 16x16 placeholder
├── NameLabel (Label)
├── BatteryCostLabel (Label) - Green for save, Red for drain
└── TimeCostLabel (Label)
```

**Properties:**
- `task_id: int` - Index into TASKS array
- `task_name: String` - Display name
- `battery_cost: float` - Negative = saves battery
- `time_cost: int` - Seconds required
- `priority: int` - Score multiplier

**States:**
- Normal - Default appearance
- Hover - Highlighted
- Disabled - Grayed out when unaffordable

**Signals:**
- `task_selected(task_id: int)` - Emitted when clicked

### 2. BatteryDisplay Scene (`scenes/battery_display.tscn`)

**Node Structure:**
```
BatteryDisplay (Control)
├── BatteryIcon (Sprite2D) - 32x32 placeholder
├── BatteryBar (TextureProgressBar) - Pixel-art style
└── PercentageLabel (Label)
```

**Visual States:**
| Battery Level | Color | Effect |
|---------------|-------|--------|
| > 30% | Green (#4ecca3) | Normal |
| 10-30% | Yellow (#ffd93d) | Warning pulse |
| < 10% | Red (#e94560) | Rapid flash |

### 3. SoundManager (`scripts/sound_manager.gd`)

**Autoload singleton** managing all game audio.

**Audio Buses:**
- Master
- SFX (sound effects)
- Music

**Placeholder Sounds (to be replaced):**
| Event | Description |
|-------|-------------|
| button_click | UI interaction |
| task_complete | Successful task |
| task_fail | Battery too low |
| low_battery | Warning alarm |
| game_over_win | Victory jingle |
| game_over_lose | Defeat sound |

**API:**
```gdscript
play_sfx(sound_name: String)
play_music(track_name: String)
set_sfx_volume(volume_db: float)
set_music_volume(volume_db: float)
```

### 4. GameController Updates

**New Functionality:**
- Generate TaskButton instances from TASKS array
- Validate task affordability before execution
- Emit signals for UI updates
- Track game state changes

**Signals to Add:**
```gdscript
signal battery_changed(new_value: float, max_value: float)
signal time_changed(new_value: float, max_value: float)
signal score_changed(new_score: int)
signal task_completed(task_name: String)
signal game_over(win: bool, final_score: int)
```

## Data Flow

```
1. Player clicks TaskButton
   ↓
2. TaskButton emits task_selected(task_id)
   ↓
3. GameController._on_task_selected(task_id):
   - Check if battery/time sufficient
   - If yes: play click + success sounds
            update battery/time/score
            emit update signals
            check win/lose conditions
   - If no: play fail sound
            show error feedback
   ↓
4. UI components receive signals and update display
   ↓
5. SoundManager plays appropriate effects
```

## Asset Placeholder Specifications

### Sprites (PNG format, 32x32 base size)

| Asset | Size | Placeholder |
|-------|------|-------------|
| battery_icon_full | 32x32 | Green rectangle |
| battery_icon_med | 32x32 | Yellow rectangle |
| battery_icon_low | 32x32 | Red rectangle |
| task_icon_browser | 16x16 | Blue square |
| task_icon_display | 16x16 | Yellow square |
| task_icon_system | 16x16 | Green square |
| task_icon_hardware | 16x16 | Purple square |
| button_normal | 64x32 | Gray rectangle |
| button_hover | 64x32 | Light gray rectangle |
| button_disabled | 64x32 | Dark gray rectangle |

### Audio (WAV format, 8-bit style)

Generate simple beep tones using Godot's AudioStreamGenerator or use free placeholder SFX.

## File Structure

```
battery-panic/
├── assets/
│   ├── sprites/
│   │   ├── placeholder/
│   │   └── final/ (empty, for later)
│   └── audio/
│       ├── sfx/
│       │   ├── placeholder/
│       │   └── final/ (empty, for later)
│       └── music/
├── scenes/
│   ├── task_button.tscn
│   ├── battery_display.tscn
│   └── main_game.tscn (updated)
├── scripts/
│   ├── sound_manager.gd
│   ├── task_button.gd
│   ├── battery_display.gd
│   └── game_controller.gd (updated)
└── docs/superpowers/specs/
    └── 2026-03-28-asset-ready-structure-design.md (this file)
```

## Error Handling

- Task buttons disabled when battery < cost
- Audio playback wrapped in try/catch (null check)
- Missing texture falls back to colored rect
- Graceful degradation if SoundManager not ready

## Testing Checklist

- [ ] Task buttons spawn correctly from TASKS array
- [ ] Clicking task updates battery/time/score
- [ ] Unaffordable tasks are disabled/grayed
- [ ] Battery display shows correct color state
- [ ] All sound effects play at right times
- [ ] Game over triggers at 0% battery
- [ ] Win condition triggers on 3+ tasks completed
- [ ] UI updates respond to all signals

## Future Asset Integration

When real assets are ready:

1. Replace placeholder PNGs in `assets/sprites/final/`
2. Update Sprite2D texture references
3. Replace placeholder WAVs in `assets/audio/sfx/final/`
4. Fine-tune UI layout for new sprite sizes
5. Adjust animation timings

No code changes needed - just asset swaps.

---

**Next Step:** Write implementation plan using writing-plans skill.
