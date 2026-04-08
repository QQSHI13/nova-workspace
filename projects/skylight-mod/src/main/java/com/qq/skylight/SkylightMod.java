package com.qq.skylight;

import com.qq.skylight.config.SkylightConfig;
import me.shedaniel.autoconfig.AutoConfig;
import me.shedaniel.autoconfig.serializer.GsonConfigSerializer;
import net.fabricmc.api.ClientModInitializer;
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
public class SkylightMod implements ModInitializer, ClientModInitializer {

    /** Mod ID used for identifiers and logging */
    public static final String MOD_ID = "skylight";

    /** Logger for this mod */
    public static final Logger LOGGER = LoggerFactory.getLogger(MOD_ID);

    @Override
    public void onInitialize() {
        LOGGER.info("Skylight mod initializing...");
        LOGGER.info("Skylight mod initialized successfully!");
    }

    @Override
    public void onInitializeClient() {
        LOGGER.info("Skylight client initializing...");

        // Register configuration (must be done before keybindings)
        AutoConfig.register(SkylightConfig.class, GsonConfigSerializer::new);

        // Register keybindings
        SkylightKeybinds.register();

        LOGGER.info("Skylight client initialized successfully!");
    }
}