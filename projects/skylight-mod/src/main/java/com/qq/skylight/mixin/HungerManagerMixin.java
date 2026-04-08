package com.qq.skylight.mixin;

import com.qq.skylight.config.SkylightConfig;
import net.minecraft.entity.player.HungerManager;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

/**
 * Mixin to disable hunger when Skylight World is enabled.
 * Keeps food level at maximum so players never get hungry.
 */
@Mixin(HungerManager.class)
public class HungerManagerMixin {

    @Inject(method = "update", at = @At("HEAD"), cancellable = true)
    private void skylight$onUpdate(CallbackInfo ci) {
        if (SkylightConfig.getConfig().createSkylightWorld) {
            HungerManager hungerManager = (HungerManager) (Object) this;
            // Keep hunger at max
            hungerManager.setFoodLevel(20);
            hungerManager.setSaturationLevel(20.0f);
            ci.cancel();
        }
    }

    @Inject(method = "addExhaustion", at = @At("HEAD"), cancellable = true)
    private void skylight$onAddExhaustion(float exhaustion, CallbackInfo ci) {
        if (SkylightConfig.getConfig().createSkylightWorld) {
            // Cancel exhaustion in skylight world
            ci.cancel();
        }
    }
}