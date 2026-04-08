package com.qq.skylight.mixin;

import com.qq.skylight.camera.FreeCamera;
import com.qq.skylight.state.SkylightState;
import net.minecraft.client.render.Camera;
import net.minecraft.client.render.GameRenderer;
import net.minecraft.client.render.RenderTickCounter;
import org.joml.Quaternionf;
import org.joml.Vector3f;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

/**
 * Mixin to handle free camera rendering.
 * Overrides camera position and rotation when freecam is active.
 */
@Mixin(GameRenderer.class)
public class GameRendererMixin {

    /**
     * Updates the camera for freecam mode.
     */
    @Inject(method = "renderWorld", at = @At("HEAD"))
    private void onRenderWorld(RenderTickCounter tickCounter, CallbackInfo ci) {
        // Free camera position is handled in CameraMixin
    }
}