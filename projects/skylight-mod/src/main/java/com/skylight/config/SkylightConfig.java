package com.skylight.config;

import me.shedaniel.autoconfig.ConfigData;
import me.shedaniel.autoconfig.annotation.Config;
import me.shedaniel.autoconfig.annotation.ConfigEntry;

@Config(name = "skylight")
public class SkylightConfig implements ConfigData {
    @ConfigEntry.Gui.Tooltip
    public boolean autoPeacefulEnabled = true;

    @ConfigEntry.Gui.Tooltip
    public boolean autoJumpEnabled = true;

    @ConfigEntry.Gui.Tooltip
    public boolean hotbarHideEnabled = true;
}
