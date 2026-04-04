package com.skylight.state;

import net.minecraft.world.Difficulty;

public class SkylightState {
    private static final SkylightState INSTANCE = new SkylightState();

    private volatile boolean active = false;
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

    public Difficulty getOriginalDifficulty() {
        return originalDifficulty;
    }

    public void setOriginalDifficulty(Difficulty difficulty) {
        this.originalDifficulty = difficulty;
    }

    public boolean getOriginalAutoJump() {
        return originalAutoJump;
    }

    public void setOriginalAutoJump(boolean autoJump) {
        this.originalAutoJump = autoJump;
    }

    public void reset() {
        active = false;
        originalDifficulty = null;
        originalAutoJump = false;
    }
}
