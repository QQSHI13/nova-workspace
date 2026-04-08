# Skylight Mod Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a Minecraft Fabric 1.20.1 mod that automatically sets Peaceful difficulty and enables auto-jump when players join a world, with configurable options.

**Architecture:** Use Fabric Mixins to intercept player join events, AutoConfig/ClothConfig for configuration GUI, and standard Fabric mod lifecycle for initialization. The mod follows standard Fabric project structure with client-side mixins.

**Tech Stack:** Minecraft 1.20.1, Fabric Loader 0.14.21+, Fabric API 0.83.0+, Yarn mappings, AutoConfig 3.3.1, ClothConfig 11.0.99, Gson for config serialization

---

## File Structure

```
skylight-mod/
├── gradle/
│   └── wrapper/
├── src/
│   ├── main/
│   │   ├── java/com/qq/skylight/
│   │   │   ├── SkylightMod.java              # Main mod entry point
│   │   │   ├── config/                       # Config package
│   │   │   │   ├── ModConfig.java            # Config data class
│   │   │   │   └── ConfigManager.java        # Config loading/saving
│   │   │   └── mixin/                        # Mixin package
│   │   │       └── PlayerJoinMixin.java      # Player join event mixin
│   │   └── resources/
│   │       ├── fabric.mod.json               # Mod metadata
│   │       ├── skylight.mixins.json          # Mixin config
│   │       └── assets/skylight/
│   │           └── lang/
│   │               └── en_us.json            # Translation strings
│   └── test/                                 # (no tests for this simple mod)
├── build.gradle                              # Build configuration
├── gradle.properties                         # Version properties
├── settings.gradle                           # Gradle settings
├── LICENSE                                   # GPL-3.0 license
└── README.md                                 # Documentation
```

---

## Task 1: Set up Fabric Development Environment

**Files:**
- Create: `skylight-mod/gradle/wrapper/gradle-wrapper.properties`
- Create: `skylight-mod/gradle/wrapper/gradle-wrapper.jar` (via Gradle wrapper task)
- Create: `skylight-mod/settings.gradle`
- Create: `skylight-mod/gradle.properties`
- Create: `skylight-mod/build.gradle`

- [ ] **Step 1: Create project directory and gradle wrapper properties**

```bash
mkdir -p skylight-mod/gradle/wrapper
cd skylight-mod
```

Create `gradle/wrapper/gradle-wrapper.properties`:
```properties
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.1.1-bin.zip
networkTimeout=10000
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
```

- [ ] **Step 2: Create settings.gradle**

Create `settings.gradle`:
```gradle
rootProject.name = 'skylight'
```

- [ ] **Step 3: Create gradle.properties with version mappings**

Create `gradle.properties`:
```properties
# Mod Properties
mod_version=1.0.0
maven_group=com.qq
archives_base_name=skylight

# Minecraft & Fabric
minecraft_version=1.20.1
yarn_mappings=1.20.1+build.10
loader_version=0.14.21

# Fabric API
fabric_version=0.83.0+1.20.1

# Dependencies - Config
autoconfig_version=3.3.1
clothconfig_version=11.0.99

# Gradle
org.gradle.jvmargs=-Xmx1G
org.gradle.parallel=true
```

- [ ] **Step 4: Create build.gradle with Fabric dependencies**

Create `build.gradle`:
```gradle
plugins {
    id 'fabric-loom' version '1.2-SNAPSHOT'
    id 'maven-publish'
}

version = project.mod_version
group = project.maven_group

base {
    archivesName = project.archives_base_name
}

repositories {
    mavenCentral()
    maven { url "https://maven.fabricmc.net/" }
    maven { url "https://maven.shedaniel.me/" }
    maven { url "https://maven.terraformersmc.com/" }
}

dependencies {
    // Minecraft and Fabric
    minecraft "com.mojang:minecraft:${project.minecraft_version}"
    mappings "net.fabricmc:yarn:${project.yarn_mappings}:v2"
    modImplementation "net.fabricmc:fabric-loader:${project.loader_version}"

    // Fabric API
    modImplementation "net.fabricmc.fabric-api:fabric-api:${project.fabric_version}"

    // Config libraries
    modApi "me.shedaniel.cloth:cloth-config-fabric:${project.clothconfig_version}"
    modApi "me.sargunvohra.mcmods:autoconfig1u:${project.autoconfig_version}"

    // Include in jar
    include "me.shedaniel.cloth:cloth-config-fabric:${project.clothconfig_version}"
    include "me.sargunvohra.mcmods:autoconfig1u:${project.autoconfig_version}"
}

processResources {
    inputs.property "version", project.version

    filesMatching("fabric.mod.json") {
        expand "version": project.version
    }
}

tasks.withType(JavaCompile).configureEach {
    options.encoding = "UTF-8"
    options.release = 17
}

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(17)
    }
    withSourcesJar()
}

jar {
    from("LICENSE") {
        rename { "${it}_${project.archives_base_name}"}
    }
}
```

- [ ] **Step 5: Download Gradle wrapper files**

```bash
cd skylight-mod
curl -L -o gradle/wrapper/gradle-wrapper.jar https://raw.githubusercontent.com/gradle/gradle/v8.1.1/gradle/wrapper/gradle-wrapper.jar
curl -L -o gradlew https://raw.githubusercontent.com/gradle/gradle/v8.1.1/gradlew
chmod +x gradlew
```

- [ ] **Step 6: Commit initial setup**

```bash
cd skylight-mod
git init
git add .
git commit -m "chore: initial Fabric mod project setup"
```

---

## Task 2: Create Mod Entry Point and Metadata

**Files:**
- Create: `src/main/java/com/qq/skylight/SkylightMod.java`
- Create: `src/main/resources/fabric.mod.json`
- Create: `src/main/resources/skylight.mixins.json`
- Create: `LICENSE`

- [ ] **Step 1: Create main mod class**

Create `src/main/java/com/qq/skylight/SkylightMod.java`:
```java
package com.qq.skylight;

import net.fabricmc.api.ModInitializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Main entry point for the Skylight mod.
 *
 * Skylight automatically configures player settings on world join:
 * - Sets difficulty to Peaceful (configurable)
 * - Enables auto-jump (configurable)
 */
public class SkylightMod implements ModInitializer {

    /** Mod ID used for identifiers and logging */
    public static final String MOD_ID = "skylight";

    /** Logger for this mod */
    public static final Logger LOGGER = LoggerFactory.getLogger(MOD_ID);

    @Override
    public void onInitialize() {
        LOGGER.info("Skylight mod initializing...");

        // Config is loaded lazily when first accessed
        LOGGER.info("Skylight mod initialized successfully!");
    }
}
```

- [ ] **Step 2: Create fabric.mod.json metadata**

Create `src/main/resources/fabric.mod.json`:
```json
{
  "schemaVersion": 1,
  "id": "skylight",
  "version": "${version}",
  "name": "Skylight",
  "description": "Automatically set Peaceful difficulty and enable auto-jump on world join",
  "authors": [
    "QQ"
  ],
  "contact": {
    "homepage": "",
    "sources": ""
  },
  "license": "GPL-3.0",
  "icon": "assets/skylight/icon.png",
  "environment": "*",
  "entrypoints": {
    "client": [
      "com.qq.skylight.SkylightMod"
    ],
    "server": [
      "com.qq.skylight.SkylightMod"
    ]
  },
  "mixins": [
    "skylight.mixins.json"
  ],
  "depends": {
    "fabricloader": ">=0.14.21",
    "fabric-api": "*",
    "minecraft": "~1.20.1",
    "java": ">=17"
  },
  "suggests": {
    "cloth-config": ">=11.0.99"
  }
}
```

- [ ] **Step 3: Create mixin configuration**

Create `src/main/resources/skylight.mixins.json`:
```json
{
  "required": true,
  "minVersion": "0.8",
  "package": "com.qq.skylight.mixin",
  "compatibilityLevel": "JAVA_17",
  "mixins": [
    "PlayerJoinMixin"
  ],
  "client": [],
  "injectors": {
    "defaultRequire": 1
  }
}
```

- [ ] **Step 4: Add GPL-3.0 LICENSE file**

Create `LICENSE` (GPL-3.0 standard license - abbreviated here, use full text):
```
GNU GENERAL PUBLIC LICENSE
Version 3, 29 June 2007

Copyright (C) 2026 QQ

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

[Full GPL-3.0 text: https://www.gnu.org/licenses/gpl-3.0.txt]
```

Use the full GPL-3.0 license text from https://www.gnu.org/licenses/gpl-3.0.txt

- [ ] **Step 5: Create package directories and verify structure**

```bash
mkdir -p src/main/java/com/qq/skylight/config
mkdir -p src/main/java/com/qq/skylight/mixin
mkdir -p src/main/resources/assets/skylight/lang
```

- [ ] **Step 6: Commit**

```bash
git add .
git commit -m "feat: add mod entry point and metadata"
```

---

## Task 3: Implement Configuration System

**Files:**
- Create: `src/main/java/com/qq/skylight/config/ModConfig.java`
- Create: `src/main/java/com/qq/skylight/config/ConfigManager.java`

- [ ] **Step 1: Create ModConfig data class**

Create `src/main/java/com/qq/skylight/config/ModConfig.java`:
```java
package com.qq.skylight.config;

import me.sargunvohra.mcmods.autoconfig1u.ConfigData;
import me.sargunvohra.mcmods.autoconfig1u.annotation.Config;
import me.sargunvohra.mcmods.autoconfig1u.annotation.ConfigEntry;

/**
 * Configuration data class for Skylight mod.
 * Uses AutoConfig for automatic GUI generation and serialization.
 */
@Config(name = "skylight")
public class ModConfig implements ConfigData {

    /**
     * Master toggle for the entire mod.
     * When false, no automatic changes are made.
     */
    @ConfigEntry.Gui.Tooltip
    public boolean enabled = true;

    /**
     * Automatically set difficulty to Peaceful when joining a world.
     */
    @ConfigEntry.Gui.Tooltip
    @ConfigEntry.Gui.CollapsibleObject
    public AutoPeacefulConfig autoPeaceful = new AutoPeacefulConfig();

    /**
     * Automatically enable auto-jump when joining a world.
     */
    @ConfigEntry.Gui.Tooltip
    @ConfigEntry.Gui.CollapsibleObject
    public AutoJumpConfig autoJump = new AutoJumpConfig();

    /**
     * Configuration for Auto-Peaceful feature.
     */
    public static class AutoPeacefulConfig {
        @ConfigEntry.Gui.Tooltip
        public boolean enabled = true;

        @ConfigEntry.Gui.Tooltip
        public boolean showChatMessage = true;
    }

    /**
     * Configuration for Auto-Jump feature.
     */
    public static class AutoJumpConfig {
        @ConfigEntry.Gui.Tooltip
        public boolean enabled = true;

        @ConfigEntry.Gui.Tooltip
        public boolean showChatMessage = true;
    }

    /**
     * Validates configuration after loading.
     * AutoConfig calls this automatically.
     */
    @Override
    public void validatePostLoad() {
        // Ensure nested configs are not null
        if (autoPeaceful == null) {
            autoPeaceful = new AutoPeacefulConfig();
        }
        if (autoJump == null) {
            autoJump = new AutoJumpConfig();
        }
    }
}
```

- [ ] **Step 2: Create ConfigManager**

Create `src/main/java/com/qq/skylight/config/ConfigManager.java`:
```java
package com.qq.skylight.config;

import com.qq.skylight.SkylightMod;
import me.sargunvohra.mcmods.autoconfig1u.AutoConfig;
import me.sargunvohra.mcmods.autoconfig1u.serializer.GsonConfigSerializer;

/**
 * Manages loading and saving of mod configuration.
 * Provides centralized access to config values.
 */
public class ConfigManager {

    private static ModConfig config;

    /**
     * Initializes the configuration system.
     * Must be called before any config access.
     */
    public static void init() {
        SkylightMod.LOGGER.info("Initializing config manager...");

        AutoConfig.register(ModConfig.class, GsonConfigSerializer::new);
        config = AutoConfig.getConfigHolder(ModConfig.class).getConfig();

        SkylightMod.LOGGER.info("Config loaded successfully");
    }

    /**
     * Gets the current configuration instance.
     *
     * @return The loaded ModConfig, or default config if not loaded
     */
    public static ModConfig getConfig() {
        if (config == null) {
            // Fallback to default config if not initialized
            SkylightMod.LOGGER.warn("Config accessed before initialization, using defaults");
            return new ModConfig();
        }
        return config;
    }

    /**
     * Checks if the mod is enabled.
     */
    public static boolean isEnabled() {
        return getConfig().enabled;
    }

    /**
     * Checks if Auto-Peaceful is enabled.
     */
    public static boolean isAutoPeacefulEnabled() {
        return isEnabled() && getConfig().autoPeaceful.enabled;
    }

    /**
     * Checks if Auto-Peaceful chat messages are enabled.
     */
    public static boolean showAutoPeacefulMessage() {
        return isAutoPeacefulEnabled() && getConfig().autoPeaceful.showChatMessage;
    }

    /**
     * Checks if Auto-Jump is enabled.
     */
    public static boolean isAutoJumpEnabled() {
        return isEnabled() && getConfig().autoJump.enabled;
    }

    /**
     * Checks if Auto-Jump chat messages are enabled.
     */
    public static boolean showAutoJumpMessage() {
        return isAutoJumpEnabled() && getConfig().autoJump.showChatMessage;
    }
}
```

- [ ] **Step 3: Update SkylightMod to initialize config**

Modify `src/main/java/com/qq/skylight/SkylightMod.java`:
```java
package com.qq.skylight;

import com.qq.skylight.config.ConfigManager;
import net.fabricmc.api.ModInitializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Main entry point for the Skylight mod.
 *
 * Skylight automatically configures player settings on world join:
 * - Sets difficulty to Peaceful (configurable)
 * - Enables auto-jump (configurable)
 */
public class SkylightMod implements ModInitializer {

    /** Mod ID used for identifiers and logging */
    public static final String MOD_ID = "skylight";

    /** Logger for this mod */
    public static final Logger LOGGER = LoggerFactory.getLogger(MOD_ID);

    @Override
    public void onInitialize() {
        LOGGER.info("Skylight mod initializing...");

        // Initialize configuration
        ConfigManager.init();

        LOGGER.info("Skylight mod initialized successfully!");
    }
}
```

- [ ] **Step 4: Create translation file**

Create `src/main/resources/assets/skylight/lang/en_us.json`:
```json
{
  "text.autoconfig.skylight.title": "Skylight Configuration",

  "text.autoconfig.skylight.option.enabled": "Mod Enabled",
  "text.autoconfig.skylight.option.enabled.@Tooltip": "Master toggle for the entire mod",

  "text.autoconfig.skylight.option.autoPeaceful": "Auto-Peaceful Settings",
  "text.autoconfig.skylight.option.autoPeaceful.@Tooltip": "Configure automatic difficulty setting",

  "text.autoconfig.skylight.option.autoPeaceful.enabled": "Enable Auto-Peaceful",
  "text.autoconfig.skylight.option.autoPeaceful.enabled.@Tooltip": "Automatically set difficulty to Peaceful on world join",

  "text.autoconfig.skylight.option.autoPeaceful.showChatMessage": "Show Chat Message",
  "text.autoconfig.skylight.option.autoPeaceful.showChatMessage.@Tooltip": "Notify in chat when difficulty is changed",

  "text.autoconfig.skylight.option.autoJump": "Auto-Jump Settings",
  "text.autoconfig.skylight.option.autoJump.@Tooltip": "Configure automatic auto-jump setting",

  "text.autoconfig.skylight.option.autoJump.enabled": "Enable Auto-Jump",
  "text.autoconfig.skylight.option.autoJump.enabled.@Tooltip": "Automatically enable auto-jump on world join",

  "text.autoconfig.skylight.option.autoJump.showChatMessage": "Show Chat Message",
  "text.autoconfig.skylight.option.autoJump.showChatMessage.@Tooltip": "Notify in chat when auto-jump is enabled",

  "chat.skylight.peaceful_set": "[Skylight] Difficulty set to Peaceful",
  "chat.skylight.autojump_enabled": "[Skylight] Auto-jump enabled"
}
```

- [ ] **Step 5: Commit**

```bash
git add .
git commit -m "feat: add configuration system with AutoConfig"
```

---

## Task 4: Implement Player Join Mixin

**Files:**
- Create: `src/main/java/com/qq/skylight/mixin/PlayerJoinMixin.java`

- [ ] **Step 1: Create the PlayerJoinMixin class**

Create `src/main/java/com/qq/skylight/mixin/PlayerJoinMixin.java`:
```java
package com.qq.skylight.mixin;

import com.qq.skylight.SkylightMod;
import com.qq.skylight.config.ConfigManager;
import net.minecraft.entity.player.PlayerEntity;
import net.minecraft.server.MinecraftServer;
import net.minecraft.server.network.ServerPlayerEntity;
import net.minecraft.text.Text;
import net.minecraft.world.Difficulty;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

/**
 * Mixin that handles player join events to automatically configure game settings.
 *
 * This mixin intercepts when a player joins the world and:
 * 1. Sets the world difficulty to Peaceful (if enabled in config)
 * 2. Enables auto-jump for the player (if enabled in config)
 */
@Mixin(ServerPlayerEntity.class)
public class PlayerJoinMixin {

    /**
     * Injects into the player join logic after the player has fully joined.
     * This is called when a player connects to a server or loads into a single-player world.
     */
    @Inject(
        method = "onSpawn",
        at = @At("TAIL")
    )
    private void skylight$onPlayerJoin(CallbackInfo ci) {
        ServerPlayerEntity player = (ServerPlayerEntity) (Object) this;
        MinecraftServer server = player.getServer();

        if (server == null) {
            SkylightMod.LOGGER.warn("Player joined but server was null");
            return;
        }

        // Only apply on the server thread (handles both singleplayer and dedicated server)
        server.execute(() -> applySkylightSettings(player, server));
    }

    /**
     * Applies Skylight mod settings to the player and world.
     *
     * @param player The player who joined
     * @param server The Minecraft server instance
     */
    private void applySkylightSettings(ServerPlayerEntity player, MinecraftServer server) {
        // Check if mod is enabled
        if (!ConfigManager.isEnabled()) {
            SkylightMod.LOGGER.debug("Skylight is disabled, skipping settings application");
            return;
        }

        // Apply Auto-Peaceful
        if (ConfigManager.isAutoPeacefulEnabled()) {
            applyPeacefulDifficulty(server, player);
        }

        // Apply Auto-Jump
        if (ConfigManager.isAutoJumpEnabled()) {
            applyAutoJump(player);
        }
    }

    /**
     * Sets the world difficulty to Peaceful.
     *
     * @param server The Minecraft server
     * @param player The player (for sending feedback messages)
     */
    private void applyPeacefulDifficulty(MinecraftServer server, ServerPlayerEntity player) {
        // Check current difficulty
        if (server.getOverworld().getDifficulty() != Difficulty.PEACEFUL) {
            SkylightMod.LOGGER.info("Setting difficulty to Peaceful for player: {}", player.getName().getString());

            // Set difficulty for all dimensions
            server.setDifficulty(Difficulty.PEACEFUL, true);

            // Send feedback message if enabled
            if (ConfigManager.showAutoPeacefulMessage()) {
                player.sendMessage(Text.translatable("chat.skylight.peaceful_set"), false);
            }
        } else {
            SkylightMod.LOGGER.debug("Difficulty already Peaceful, no change needed");
        }
    }

    /**
     * Enables auto-jump for the player.
     *
     * @param player The player to enable auto-jump for
     */
    private void applyAutoJump(ServerPlayerEntity player) {
        // Auto-jump is a client-side setting stored in player abilities
        // We need to check and set it
        if (!player.getAbilities().allowFlying) {  // Check if we need to modify
            SkylightMod.LOGGER.info("Enabling auto-jump for player: {}", player.getName().getString());

            // Note: Auto-jump is actually controlled by client-side options
            // Server can only suggest this; client must enable it
            // However, we can notify the player

            if (ConfigManager.showAutoJumpMessage()) {
                player.sendMessage(Text.translatable("chat.skylight.autojump_enabled"), false);
            }
        }
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add .
git commit -m "feat: add PlayerJoinMixin for auto-peaceful and auto-jump"
```

---

## Task 5: Fix Auto-Jump Implementation

**Note:** Auto-jump is a client-side setting. The server cannot directly modify it. We have two options:
1. Client-side mod that sets it directly
2. Server-side notification only

For this implementation, we'll add a client-side component to properly handle auto-jump.

**Files:**
- Create: `src/main/java/com/qq/skylight/SkylightClientMod.java`
- Modify: `src/main/resources/fabric.mod.json`
- Modify: `src/main/java/com/qq/skylight/mixin/PlayerJoinMixin.java`

- [ ] **Step 1: Create client-side entry point**

Create `src/main/java/com/qq/skylight/SkylightClientMod.java`:
```java
package com.qq.skylight;

import com.qq.skylight.config.ConfigManager;
import net.fabricmc.api.ClientModInitializer;
import net.fabricmc.fabric.api.client.networking.v1.ClientPlayConnectionEvents;
import net.minecraft.client.MinecraftClient;

/**
 * Client-side initialization for Skylight mod.
 *
 * Handles client-side settings like auto-jump that cannot be controlled server-side.
 */
public class SkylightClientMod implements ClientModInitializer {

    @Override
    public void onInitializeClient() {
        SkylightMod.LOGGER.info("Skylight client-side initializing...");

        // Register client join handler for auto-jump
        ClientPlayConnectionEvents.JOIN.register((handler, sender, client) -> {
            client.execute(() -> applyClientSettings(client));
        });

        SkylightMod.LOGGER.info("Skylight client-side initialized!");
    }

    /**
     * Applies client-side settings when joining a world.
     *
     * @param client The Minecraft client instance
     */
    private void applyClientSettings(MinecraftClient client) {
        // Check if mod is enabled
        if (!ConfigManager.isEnabled()) {
            return;
        }

        // Apply Auto-Jump on client side
        if (ConfigManager.isAutoJumpEnabled() && client.options != null) {
            SkylightMod.LOGGER.info("Enabling auto-jump on client");

            // Enable auto-jump
            client.options.autoJump = true;

            // Save options to persist
            client.options.write();
        }
    }
}
```

- [ ] **Step 2: Update fabric.mod.json to add client entrypoint**

Modify `src/main/resources/fabric.mod.json`:
```json
{
  "schemaVersion": 1,
  "id": "skylight",
  "version": "${version}",
  "name": "Skylight",
  "description": "Automatically set Peaceful difficulty and enable auto-jump on world join",
  "authors": [
    "QQ"
  ],
  "contact": {
    "homepage": "",
    "sources": ""
  },
  "license": "GPL-3.0",
  "icon": "assets/skylight/icon.png",
  "environment": "*",
  "entrypoints": {
    "client": [
      "com.qq.skylight.SkylightClientMod"
    ],
    "server": [
      "com.qq.skylight.SkylightMod"
    ]
  },
  "mixins": [
    "skylight.mixins.json"
  ],
  "depends": {
    "fabricloader": ">=0.14.21",
    "fabric-api": "*",
    "minecraft": "~1.20.1",
    "java": ">=17"
  },
  "suggests": {
    "cloth-config": ">=11.0.99"
  }
}
```

- [ ] **Step 3: Update PlayerJoinMixin to remove auto-jump (now client-side)**

Modify `src/main/java/com/qq/skylight/mixin/PlayerJoinMixin.java`:
```java
package com.qq.skylight.mixin;

import com.qq.skylight.SkylightMod;
import com.qq.skylight.config.ConfigManager;
import net.minecraft.server.MinecraftServer;
import net.minecraft.server.network.ServerPlayerEntity;
import net.minecraft.text.Text;
import net.minecraft.world.Difficulty;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

/**
 * Mixin that handles player join events to automatically configure game settings.
 *
 * This mixin intercepts when a player joins the world and:
 * 1. Sets the world difficulty to Peaceful (if enabled in config)
 *
 * Note: Auto-jump is handled client-side in SkylightClientMod since it's a client setting.
 */
@Mixin(ServerPlayerEntity.class)
public class PlayerJoinMixin {

    /**
     * Injects into the player join logic after the player has fully joined.
     * This is called when a player connects to a server or loads into a single-player world.
     */
    @Inject(
        method = "onSpawn",
        at = @At("TAIL")
    )
    private void skylight$onPlayerJoin(CallbackInfo ci) {
        ServerPlayerEntity player = (ServerPlayerEntity) (Object) this;
        MinecraftServer server = player.getServer();

        if (server == null) {
            SkylightMod.LOGGER.warn("Player joined but server was null");
            return;
        }

        // Only apply on the server thread (handles both singleplayer and dedicated server)
        server.execute(() -> applySkylightSettings(player, server));
    }

    /**
     * Applies Skylight mod settings to the player and world.
     *
     * @param player The player who joined
     * @param server The Minecraft server instance
     */
    private void applySkylightSettings(ServerPlayerEntity player, MinecraftServer server) {
        // Check if mod is enabled
        if (!ConfigManager.isEnabled()) {
            SkylightMod.LOGGER.debug("Skylight is disabled, skipping settings application");
            return;
        }

        // Apply Auto-Peaceful
        if (ConfigManager.isAutoPeacefulEnabled()) {
            applyPeacefulDifficulty(server, player);
        }
    }

    /**
     * Sets the world difficulty to Peaceful.
     *
     * @param server The Minecraft server
     * @param player The player (for sending feedback messages)
     */
    private void applyPeacefulDifficulty(MinecraftServer server, ServerPlayerEntity player) {
        // Check current difficulty
        if (server.getOverworld().getDifficulty() != Difficulty.PEACEFUL) {
            SkylightMod.LOGGER.info("Setting difficulty to Peaceful for player: {}", player.getName().getString());

            // Set difficulty for all dimensions
            server.setDifficulty(Difficulty.PEACEFUL, true);

            // Send feedback message if enabled
            if (ConfigManager.showAutoPeacefulMessage()) {
                player.sendMessage(Text.translatable("chat.skylight.peaceful_set"), false);
            }
        } else {
            SkylightMod.LOGGER.debug("Difficulty already Peaceful, no change needed");
        }
    }
}
```

- [ ] **Step 4: Commit**

```bash
git add .
git commit -m "fix: move auto-jump to client-side implementation"
```

---

## Task 6: Build and Verify

**Files:**
- Create: `README.md`

- [ ] **Step 1: Run Gradle build**

```bash
cd skylight-mod
./gradlew build
```

Expected: BUILD SUCCESSFUL

- [ ] **Step 2: Verify the JAR was created**

```bash
ls -la build/libs/
```

Expected: `skylight-1.0.0.jar` exists (without -sources or -dev suffix for the main jar)

- [ ] **Step 3: Check JAR contents**

```bash
jar tf build/libs/skylight-1.0.0.jar | head -30
```

Expected: Contains fabric.mod.json, class files, mixins config

- [ ] **Step 4: Create README.md**

Create `README.md`:
```markdown
# Skylight Mod

A Minecraft Fabric 1.20.1 mod that automatically configures game settings when you join a world.

## Features

- **Auto-Peaceful**: Automatically sets the world difficulty to Peaceful when you join
- **Auto-Jump**: Automatically enables auto-jump when you join

Both features are configurable and can be disabled individually or globally.

## Installation

1. Install [Fabric Loader](https://fabricmc.net/use/) for Minecraft 1.20.1
2. Download the latest `skylight-1.0.0.jar` from the releases page
3. Place the JAR file in your `.minecraft/mods/` folder
4. Launch Minecraft with Fabric

## Configuration

The mod uses [Mod Menu](https://modrinth.com/mod/modmenu) and [Cloth Config](https://modrinth.com/mod/cloth-config) for in-game configuration.

Configuration options:
- **Mod Enabled**: Master toggle for all features
- **Auto-Peaceful**:
  - Enable/disable automatic peaceful difficulty
  - Show/hide chat message when difficulty changes
- **Auto-Jump**:
  - Enable/disable automatic auto-jump
  - Show/hide chat message when auto-jump is enabled

Config file location: `.minecraft/config/skylight.json`

## Building from Source

### Requirements
- JDK 17 or higher
- Gradle 8.x (wrapper included)

### Build Instructions

```bash
# Clone or extract the source code
cd skylight-mod

# Build the mod
./gradlew build

# The compiled JAR will be in build/libs/
ls build/libs/skylight-1.0.0.jar
```

## Development

### Project Structure
```
src/main/java/com/qq/skylight/
├── SkylightMod.java              # Main mod entry point
├── SkylightClientMod.java        # Client-side entry point
├── config/
│   ├── ModConfig.java            # Configuration data class
│   └── ConfigManager.java        # Config loading/saving
└── mixin/
    └── PlayerJoinMixin.java      # Player join event handler
```

### License

This mod is licensed under GPL-3.0. See [LICENSE](LICENSE) for details.

### Author

Created by QQ
```

- [ ] **Step 5: Final commit and verify git status**

```bash
git add .
git commit -m "docs: add README with build instructions"
git log --oneline
```

Expected output showing commits:
- docs: add README with build instructions
- fix: move auto-jump to client-side implementation
- feat: add PlayerJoinMixin for auto-peaceful and auto-jump
- feat: add configuration system with AutoConfig
- feat: add mod entry point and metadata
- chore: initial Fabric mod project setup

- [ ] **Step 6: Copy final JAR to root for easy access**

```bash
cp build/libs/skylight-1.0.0.jar .
ls -la skylight-1.0.0.jar
```

---

## Summary

**What was built:**
1. Complete Fabric 1.20.1 mod development environment
2. Auto-Peaceful feature (server-side via Mixins)
3. Auto-Jump feature (client-side via Fabric API events)
4. Configuration system using AutoConfig + ClothConfig
5. In-game config GUI support
6. Chat message notifications for both features
7. Full GPL-3.0 license compliance

**How to test:**
1. Copy `skylight-1.0.0.jar` to your `.minecraft/mods/` folder
2. Ensure Fabric Loader 0.14.21+ and Fabric API are installed
3. Launch Minecraft 1.20.1
4. Join any world - difficulty should change to Peaceful
5. Auto-jump should be enabled automatically
6. Install Mod Menu + Cloth Config to verify in-game settings work

**Key files:**
- Main entry: `src/main/java/com/qq/skylight/SkylightMod.java`
- Client entry: `src/main/java/com/qq/skylight/SkylightClientMod.java`
- Config: `src/main/java/com/qq/skylight/config/`
- Mixin: `src/main/java/com/qq/skylight/mixin/PlayerJoinMixin.java`
- Build output: `build/libs/skylight-1.0.0.jar`
