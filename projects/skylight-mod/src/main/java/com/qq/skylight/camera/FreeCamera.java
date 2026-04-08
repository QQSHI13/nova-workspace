package com.qq.skylight.camera;

import com.qq.skylight.state.SkylightState;
import net.minecraft.client.MinecraftClient;
import net.minecraft.client.network.ClientPlayerEntity;
import net.minecraft.client.option.Perspective;
import net.minecraft.client.render.Camera;
import net.minecraft.util.math.Vec3d;

/**
 * Handles free camera mode for cinematic shots.
 * Allows the camera to detach from the player and fly freely.
 */
public class FreeCamera {
    
    private static final FreeCamera INSTANCE = new FreeCamera();
    
    private boolean active = false;
    private Vec3d cameraPos = Vec3d.ZERO;
    private float yaw = 0;
    private float pitch = 0;
    private Perspective originalPerspective;
    
    private FreeCamera() {}
    
    public static FreeCamera getInstance() {
        return INSTANCE;
    }
    
    /**
     * Toggles free camera mode on/off.
     */
    public void toggle(MinecraftClient client) {
        if (active) {
            disable(client);
        } else {
            enable(client);
        }
    }
    
    /**
     * Enables free camera mode.
     */
    public void enable(MinecraftClient client) {
        if (client.player == null) return;
        
        active = true;
        SkylightState.setFreeCamActive(true);
        
        // Store current camera position and rotation
        Camera camera = client.gameRenderer.getCamera();
        cameraPos = camera.getPos();
        yaw = camera.getYaw();
        pitch = camera.getPitch();
        
        // Store original perspective and switch to first person
        originalPerspective = client.options.getPerspective();
        client.options.setPerspective(Perspective.FIRST_PERSON);
        
        // Hide player model in freecam
        client.player.setInvisible(true);
        
        if (client.player != null) {
            client.player.sendMessage(net.minecraft.text.Text.translatable("message.skylight.freecam.enabled"), true);
        }
    }
    
    /**
     * Disables free camera mode.
     */
    public void disable(MinecraftClient client) {
        if (!active) return;
        
        active = false;
        SkylightState.setFreeCamActive(false);
        
        // Restore original perspective
        if (originalPerspective != null) {
            client.options.setPerspective(originalPerspective);
        }
        
        // Show player model again
        if (client.player != null) {
            client.player.setInvisible(false);
            client.player.sendMessage(net.minecraft.text.Text.translatable("message.skylight.freecam.disabled"), true);
        }
    }
    
    /**
     * Updates the free camera position based on player input.
     * Called every tick while freecam is active.
     */
    public void update(MinecraftClient client) {
        if (!active || client.player == null) return;
        
        // Handle movement input
        float forward = 0;
        float sideways = 0;
        float vertical = 0;
        
        if (client.options.forwardKey.isPressed()) forward += 1;
        if (client.options.backKey.isPressed()) forward -= 1;
        if (client.options.leftKey.isPressed()) sideways += 1;
        if (client.options.rightKey.isPressed()) sideways -= 1;
        if (client.options.jumpKey.isPressed()) vertical += 1;
        if (client.options.sneakKey.isPressed()) vertical -= 1;
        
        // Calculate movement speed (sprint = faster)
        float speed = client.options.sprintKey.isPressed() ? 2.0f : 0.5f;
        
        // Convert yaw to radians
        float yawRad = (float) Math.toRadians(yaw);
        float cosYaw = (float) Math.cos(yawRad);
        float sinYaw = (float) Math.sin(yawRad);
        
        // Calculate movement vector
        double dx = (sideways * cosYaw - forward * sinYaw) * speed;
        double dz = (forward * cosYaw + sideways * sinYaw) * speed;
        double dy = vertical * speed;
        
        // Update camera position
        cameraPos = cameraPos.add(dx, dy, dz);
    }
    
    /**
     * Updates camera rotation from mouse input.
     */
    public void updateRotation(double deltaX, double deltaY) {
        if (!active) return;
        
        float sensitivity = 0.15f;
        yaw += deltaX * sensitivity;
        pitch = Math.max(-90, Math.min(90, pitch - (float)(deltaY * sensitivity)));
    }
    
    public boolean isActive() {
        return active;
    }
    
    public Vec3d getCameraPos() {
        return cameraPos;
    }
    
    public float getYaw() {
        return yaw;
    }
    
    public float getPitch() {
        return pitch;
    }
}