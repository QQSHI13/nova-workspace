package com.qq.skylight;

import com.qq.skylight.config.SkylightConfig;
import com.qq.skylight.screenshot.ScreenshotHandler;
import com.qq.skylight.state.SkylightState;
import net.fabricmc.fabric.api.client.event.lifecycle.v1.ClientTickEvents;
import net.fabricmc.fabric.api.client.keybinding.v1.KeyBindingHelper;
import net.minecraft.client.MinecraftClient;
import net.minecraft.client.option.KeyBinding;
import net.minecraft.client.util.InputUtil;
import net.minecraft.text.Text;
import net.minecraft.world.Difficulty;
import org.lwjgl.glfw.GLFW;

/**
 * Handles keybinding registration and input processing for Skylight mod.
 */
public class SkylightKeybinds {

    private static KeyBinding skylightModeKey;
    private static KeyBinding screenshotKey;

    /**
     * Registers all keybindings for the mod.
     */
    public static void register() {
        SkylightConfig config = SkylightConfig.getConfig();

        // Main skylight mode toggle (K key)
        skylightModeKey = KeyBindingHelper.registerKeyBinding(new KeyBinding(
                "key.skylight.mode",
                InputUtil.Type.KEYSYM,
                config.skylightModeKey.keyCode,
                "category.skylight.general"
        ));

        // Screenshot key (C key)
        screenshotKey = KeyBindingHelper.registerKeyBinding(new KeyBinding(
                "key.skylight.screenshot",
                InputUtil.Type.KEYSYM,
                GLFW.GLFW_KEY_C,
                "category.skylight.general"
        ));

        ClientTickEvents.END_CLIENT_TICK.register(client -> {
            if (skylightModeKey.wasPressed()) {
                toggleSkylightMode(client);
            }
            if (screenshotKey.wasPressed()) {
                takeScreenshot(client);
            }
        });
    }

    /**
     * Toggles skylight mode on/off.
     * In normal games: toggles peaceful + HUD + sound mute
     * In locked games (hardcore/locked difficulty): only toggles HUD + sound mute
     */
    private static void toggleSkylightMode(MinecraftClient client) {
        SkylightConfig config = SkylightConfig.getConfig();
        boolean nowActive = SkylightState.toggle();

        if (client.player == null) return;

        if (nowActive) {
            // Activating skylight mode
            boolean difficultyChanged = false;

            // Only change difficulty if enabled in config AND difficulty can be changed
            if (config.enablePeacefulOnToggle && canChangeDifficulty(client)) {
                if (client.getServer() != null) {
                    client.getServer().setDifficulty(Difficulty.PEACEFUL, false);
                    SkylightState.setOriginalDifficulty(client.world.getDifficulty());
                    difficultyChanged = true;
                }
            }

            // Show appropriate message
            if (difficultyChanged) {
                client.player.sendMessage(Text.translatable("message.skylight.mode.enabled"), true);
            } else {
                client.player.sendMessage(Text.translatable("message.skylight.mode.enabled_no_difficulty"), true);
            }
        } else {
            // Deactivating skylight mode
            // Restore original difficulty if we changed it
            if (SkylightState.getOriginalDifficulty() != null && canChangeDifficulty(client)) {
                if (client.getServer() != null) {
                    client.getServer().setDifficulty(SkylightState.getOriginalDifficulty(), false);
                }
            }

            client.player.sendMessage(Text.translatable("message.skylight.mode.disabled"), true);
        }

        SkylightMod.LOGGER.info("Skylight mode {} by player {}",
                nowActive ? "enabled" : "disabled",
                client.player.getName().getString());
    }

    /**
     * Takes a screenshot using Skylight's enhanced screenshot handler.
     */
    private static void takeScreenshot(MinecraftClient client) {
        if (!SkylightConfig.getConfig().photography.enableScreenshot) {
            if (client.player != null) {
                client.player.sendMessage(Text.translatable("message.skylight.screenshot.disabled_config"), true);
            }
            return;
        }
        ScreenshotHandler.takeScreenshot(client);
    }

    /**
     * Checks if the current world allows difficulty changes.
     * Returns false for hardcore worlds or locked difficulty.
     */
    private static boolean canChangeDifficulty(MinecraftClient client) {
        if (client.world == null) return false;

        // Check if hardcore (difficulty locked)
        if (client.world.getLevelProperties().isHardcore()) {
            return false;
        }

        // Check if difficulty is explicitly locked
        if (client.world.getLevelProperties().isDifficultyLocked()) {
            return false;
        }

        return true;
    }
}