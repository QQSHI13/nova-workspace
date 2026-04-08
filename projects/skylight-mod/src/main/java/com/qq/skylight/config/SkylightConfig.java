package com.qq.skylight.config;

import me.shedaniel.autoconfig.AutoConfig;
import me.shedaniel.autoconfig.ConfigData;
import me.shedaniel.autoconfig.annotation.Config;
import me.shedaniel.autoconfig.annotation.ConfigEntry;

/**
 * Configuration data class for Skylight mod.
 * Uses AutoConfig for automatic GUI generation and serialization.
 */
@Config(name = "skylight")
public class SkylightConfig implements ConfigData {

    /**
     * Automatically set difficulty to Peaceful when joining a world.
     */
    @ConfigEntry.Gui.Tooltip
    public boolean autoPeacefulEnabled = true;

    /**
     * Automatically enable auto-jump when joining a world.
     */
    @ConfigEntry.Gui.Tooltip
    public boolean autoJumpEnabled = true;

    @ConfigEntry.Gui.Tooltip
    @ConfigEntry.Gui.CollapsibleObject
    public KeybindingConfig skylightModeKey = new KeybindingConfig();

    @ConfigEntry.Gui.Tooltip
    public boolean enableHudHide = true;

    @ConfigEntry.Gui.Tooltip
    public boolean enableTimeSlow = true;

    @ConfigEntry.Gui.Tooltip
    public boolean enableSoundMute = true;

    @ConfigEntry.Gui.Tooltip
    public boolean enablePeacefulOnToggle = true;

    @ConfigEntry.Gui.Tooltip
    @ConfigEntry.Gui.RequiresRestart
    public boolean createSkylightWorld = false;

    // Photography tools
    @ConfigEntry.Gui.CollapsibleObject
    public PhotoConfig photography = new PhotoConfig();

    /**
     * Keybinding configuration for Skylight Mode toggle.
     */
    public static class KeybindingConfig {
        @ConfigEntry.Gui.Tooltip
        public int keyCode = 75; // GLFW_KEY_K
    }

    /**
     * Photography tool configuration.
     */
    public static class PhotoConfig {
        @ConfigEntry.Gui.Tooltip
        public boolean enableFreeCam = true;

        @ConfigEntry.Gui.Tooltip
        public boolean enableTimePause = true;

        @ConfigEntry.Gui.Tooltip
        public boolean enableScreenshot = true;

        @ConfigEntry.Gui.Tooltip
        public float freeCamSpeed = 0.5f;

        @ConfigEntry.Gui.Tooltip
        public float freeCamSprintSpeed = 2.0f;
    }

    /**
     * Gets the current config instance.
     */
    public static SkylightConfig getConfig() {
        return AutoConfig.getConfigHolder(SkylightConfig.class).getConfig();
    }
}