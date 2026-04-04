# Skylight Fabric Mod — Design Spec

## Overview
A Fabric mod for Minecraft 1.21.1 that provides a single **master toggle keybind** called "Skylight Mode." When activated, it saves the player's original settings and applies three optional modifications. When deactivated (manually or on world disconnect), all originals are restored.

## Features (all toggled together)
1. **Auto-Peaceful** — saves the world's current difficulty, then sets it to `PEACEFUL`.
2. **Auto-Jump** — saves the player's `autoJump` game option, then enables it.
3. **Hide Hotbar** — suppresses rendering of the quick-access bar HUD while active.

## Activation Flow
- Player presses the **Skylight Mode** keybind (default: unbound).
- If currently **OFF** → save originals → apply all enabled features → mode is ON.
- If currently **ON** → restore originals → mode is OFF.
- On disconnect from a world → if mode is ON, automatically restore originals.

## State Management
- `SkylightState` singleton tracks:
  - `active: boolean`
  - `originalDifficulty: Difficulty`
  - `originalAutoJump: boolean`
- It lives in the main mod class and is accessed by handlers and mixins.

## Architecture
- **Client-side keybind** registered via Fabric Client Tick Events.
- **Server-side difficulty change** sent via client-to-server custom packet or via the integrated server command path when on single-player. Simpler approach: use server command execution (`/difficulty peaceful`) when toggling on client in single-player; for multiplayer, a custom C2S packet is required because clients cannot directly change server difficulty.
- **AutoConfig + ClothConfig** for a small GUI config (which features participate).
- **Mixin** on `InGameHud.renderHotbar` to conditionally cancel hotbar rendering.

## Config
Managed by AutoConfig (`SkylightConfig`):
- `autoPeacefulEnabled: boolean` (default: `true`)
- `autoJumpEnabled: boolean` (default: `true`)
- `hotbarHideEnabled: boolean` (default: `true`)

## Files
- `gradle.properties`
- `build.gradle`
- `src/main/resources/fabric.mod.json`
- `src/main/resources/skylight.mixins.json`
- `src/main/java/com/skylight/SkylightMod.java`
- `src/main/java/com/skylight/config/SkylightConfig.java`
- `src/main/java/com/skylight/state/SkylightState.java`
- `src/main/java/com/skylight/mixin/InGameHudMixin.java`
- `src/main/java/com/skylight/network/TogglePacket.java`

## Versions
- Minecraft: 1.21.1
- Fabric Loader: 0.16.7
- Fabric API: 0.102.0+
- Yarn: 1.21.1+build.3
- Java: 21
