package com.qq.skylight.state;

import net.minecraft.world.Difficulty;

/**
 * Manages the global state for Skylight mod.
 * Tracks whether skylight mode is active and stores original game settings.
 */
public class SkylightState {
    private static final SkylightState INSTANCE = new SkylightState();

    private volatile boolean active = false;
    private volatile boolean skylightModeActive = false;
    private volatile boolean freeCamActive = false;
    private volatile boolean timePaused = false;
    private volatile Difficulty originalDifficulty = null;
    private volatile boolean originalAutoJump = false;

    private SkylightState() {}

    public static SkylightState getInstance() {
        return INSTANCE;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    /**
     * Returns whether skylight mode is currently active.
     */
    public static boolean isSkylightModeActive() {
        return INSTANCE.skylightModeActive;
    }

    /**
     * Sets the skylight mode active state.
     */
    public static void setSkylightModeActive(boolean active) {
        INSTANCE.skylightModeActive = active;
    }

    /**
     * Toggles the skylight mode on/off.
     * @return The new state (true if now active, false if now inactive)
     */
    public static boolean toggle() {
        INSTANCE.skylightModeActive = !INSTANCE.skylightModeActive;
        return INSTANCE.skylightModeActive;
    }

    public static Difficulty getOriginalDifficulty() {
        return INSTANCE.originalDifficulty;
    }

    public static void setOriginalDifficulty(Difficulty difficulty) {
        INSTANCE.originalDifficulty = difficulty;
    }

    public boolean getOriginalAutoJump() {
        return originalAutoJump;
    }

    public void setOriginalAutoJump(boolean autoJump) {
        this.originalAutoJump = autoJump;
    }

    /**
     * Returns whether free camera mode is active.
     */
    public static boolean isFreeCamActive() {
        return INSTANCE.freeCamActive;
    }

    /**
     * Sets the free camera mode active state.
     */
    public static void setFreeCamActive(boolean active) {
        INSTANCE.freeCamActive = active;
    }

    /**
     * Returns whether time is paused.
     */
    public static boolean isTimePaused() {
        return INSTANCE.timePaused;
    }

    /**
     * Sets the time paused state.
     */
    public static void setTimePaused(boolean paused) {
        INSTANCE.timePaused = paused;
    }

    /**
     * Toggles time pause on/off.
     */
    public static boolean toggleTimePause() {
        INSTANCE.timePaused = !INSTANCE.timePaused;
        return INSTANCE.timePaused;
    }

    public void reset() {
        active = false;
        skylightModeActive = false;
        freeCamActive = false;
        timePaused = false;
        originalDifficulty = null;
        originalAutoJump = false;
    }
}