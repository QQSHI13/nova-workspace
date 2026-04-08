package com.qq.skylight.screenshot;

import net.minecraft.client.MinecraftClient;
import net.minecraft.client.texture.NativeImage;
import net.minecraft.client.util.ScreenshotRecorder;
import net.minecraft.text.Text;
import net.minecraft.util.Util;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Handles enhanced screenshot functionality.
 * Saves screenshots to a custom Skylight gallery folder with timestamps.
 */
public class ScreenshotHandler {
    
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd_HH-mm-ss");
    private static final String SCREENSHOTS_FOLDER = "skylight-gallery";
    
    /**
     * Takes a screenshot and saves it to the Skylight gallery folder.
     */
    public static void takeScreenshot(MinecraftClient client) {
        if (client.player == null) return;
        
        // Get screenshot directory
        Path screenshotDir = Paths.get(client.runDirectory.getAbsolutePath(), SCREENSHOTS_FOLDER);
        
        try {
            // Create directory if it doesn't exist
            if (!Files.exists(screenshotDir)) {
                Files.createDirectories(screenshotDir);
            }
            
            // Generate filename with timestamp
            String timestamp = LocalDateTime.now().format(DATE_FORMATTER);
            String filename = "skylight_" + timestamp + ".png";
            
            // Take screenshot using Minecraft's built-in method
            NativeImage screenshot = ScreenshotRecorder.takeScreenshot(client.getFramebuffer());
            File screenshotFile = new File(screenshotDir.toFile(), filename);
            
            screenshot.writeTo(screenshotFile);
            screenshot.close();
            
            // Notify player
            client.player.sendMessage(
                Text.translatable("message.skylight.screenshot.saved", filename),
                true
            );
            
        } catch (IOException e) {
            client.player.sendMessage(
                Text.translatable("message.skylight.screenshot.failed", e.getMessage()),
                true
            );
        }
    }
    
    /**
     * Opens the Skylight gallery folder in the system file explorer.
     */
    public static void openGalleryFolder(MinecraftClient client) {
        Path screenshotDir = Paths.get(client.runDirectory.getAbsolutePath(), SCREENSHOTS_FOLDER);
        
        try {
            if (!Files.exists(screenshotDir)) {
                Files.createDirectories(screenshotDir);
            }
            
            // Open folder using system default
            Util.getOperatingSystem().open(screenshotDir.toFile());
            
        } catch (IOException e) {
            if (client.player != null) {
                client.player.sendMessage(
                    Text.translatable("message.skylight.gallery.open.failed", e.getMessage()),
                    true
                );
            }
        }
    }
}