package com.qq.skylight.mixin;

import com.qq.skylight.state.SkylightState;
import net.minecraft.client.MinecraftClient;
import net.minecraft.client.render.Camera;
import net.minecraft.client.render.GameRenderer;
import net.minecraft.client.render.RenderTickCounter;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

/**
 * Mixin to handle time pause functionality.
 * Pauses entity updates and world tick when time pause is active.
 */
@Mixin(MinecraftClient.class)
public class TimePauseMixin {

    /**
     * Prevents world tick when time is paused.
     */
    @Inject(method = "tick", at = @At("HEAD"), cancellable = true)
    private void onTick(CallbackInfo ci) {
        if (SkylightState.isTimePaused()) {
            // Allow UI to update but not the world
            // We still need to process input, so we don't fully cancel
            // Instead, we'll skip the world update in WorldMixin
        }
    }
}