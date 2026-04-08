# Skylight Mod ☄️

A Minecraft Fabric 1.21 mod that creates a peaceful, relaxing gameplay experience with powerful photography tools.

## Features

### 🎮 Skylight Mode (Press 'K')

Toggle Skylight Mode anytime in-game:

| Feature | Normal Worlds | Locked Worlds (Hardcore) |
|---------|---------------|-------------------------|
| Peaceful Difficulty | ✅ Yes | ❌ No (locked) |
| Hide HUD | ✅ Yes | ✅ Yes |
| Slow Time | ✅ Yes | ✅ Yes |
| Mute Mob Sounds | ✅ Yes | ✅ Yes |

**Smart Detection**: Automatically detects if difficulty is locked (hardcore worlds) and only applies visual/audio effects.

### 📸 Photography Tools

Professional-grade tools for capturing perfect Minecraft shots:

#### Free Camera (F key)
- **Detach** from your body and fly freely
- **WASD** to move, **Shift/Ctrl** for up/down
- **Sprint** (Hold) for faster movement
- Perfect for cinematic shots and exploring builds

#### Time Pause (P key)
- **Freeze everything** - entities, particles, animations
- World stays visually intact but completely still
- Ideal for action shots or complex scenes

#### Enhanced Screenshot (C key)
- Saves to `skylight-gallery/` folder
- Auto-timestamped filenames
- Works with all Skylight effects active

### 🌅 Skylight World (Creative Mode)

Enable in config for the ultimate relaxed experience:
- **Peaceful Mode** - No hostile mobs
- **No Hunger** - Never worry about food
- **Unbreaking Elytra** - Pre-equipped with Mending + Unbreaking III
- **Infinite Fireworks** - 64 rockets in inventory
- **Free Boat** - Spawned near you

## Controls

| Key | Action |
|-----|--------|
| **K** | Toggle Skylight Mode |
| **F** | Toggle Free Camera |
| **P** | Toggle Time Pause |
| **C** | Take Skylight Screenshot |

## Installation

1. Install [Fabric Loader](https://fabricmc.net/use/) for Minecraft 1.21
2. Download `skylight-1.0.0.jar`
3. Place in `.minecraft/mods/`
4. Launch Minecraft with Fabric

Requires:
- Fabric API
- Mod Menu (optional, for config GUI)
- Cloth Config (optional, for config GUI)

## Configuration

Use **Mod Menu** (recommended) or edit `.minecraft/config/skylight.json`:

### General Settings
| Option | Default | Description |
|--------|---------|-------------|
| `autoPeacefulEnabled` | true | Auto-set peaceful on join |
| `autoJumpEnabled` | true | Auto-enable auto-jump |
| `skylightModeKey` | 75 (K) | Key to toggle Skylight Mode |
| `enableHudHide` | true | Hide HUD in Skylight Mode |
| `enableTimeSlow` | true | Slow time in Skylight Mode |
| `enableSoundMute` | true | Mute mob sounds in Skylight Mode |
| `enablePeacefulOnToggle` | true | Try to set peaceful when toggling |
| `createSkylightWorld` | false | Enable Skylight World features |

### Photography Settings
| Option | Default | Description |
|--------|---------|-------------|
| `photography.enableFreeCam` | true | Enable free camera mode |
| `photography.enableTimePause` | true | Enable time pause feature |
| `photography.enableScreenshot` | true | Enable Skylight screenshot |
| `photography.freeCamSpeed` | 0.5 | Normal flight speed |
| `photography.freeCamSprintSpeed` | 2.0 | Sprint flight speed |

## Building from Source

```bash
cd skylight-mod
./gradlew build
# JAR: build/libs/skylight-1.0.0.jar
```

## Screenshots Gallery

Screenshots taken with **C key** are saved to:
```
.minecraft/skylight-gallery/
  └── skylight_2024-04-05_12-30-45.png
  └── skylight_2024-04-05_12-31-12.png
```

## Use Cases

### 🎬 Cinematic Shots
1. Press **P** to pause time
2. Press **F** to enter free camera
3. Fly to the perfect angle
4. Press **C** to capture

### 🏠 Build Showcases
1. Enable **Skylight Mode** (K) for clean visuals
2. Use **Free Camera** (F) to show all angles
3. **Time Pause** (P) for dramatic lighting

### 🎮 Relaxed Gameplay
1. Enable **Skylight World** in config
2. Spawn with elytra and explore
3. No hunger, no mobs, pure exploration

## Mod Details

- **Mod ID**: `skylight`
- **Version**: `1.0.0`
- **Minecraft**: `1.21`
- **License**: GPL-3.0
- **Author**: QQ / Nova ☄️

## License

GPL-3.0. See [LICENSE](LICENSE) for details.
