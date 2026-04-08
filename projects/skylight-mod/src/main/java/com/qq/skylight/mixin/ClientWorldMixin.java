package com.qq.skylight.mixin;

import com.qq.skylight.state.SkylightState;
import net.minecraft.client.world.ClientWorld;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

/**
 * Mixin to pause world updates when time pause is active.
 */
@Mixin(ClientWorld.class)
public class ClientWorldMixin {

    /**
     * Cancels world tick when time is paused.
     */
    @Inject(method = "tickEntities", at = @At("HEAD"), cancellable = true)
    private void onTickEntities(CallbackInfo ci) {
        if (SkylightState.isTimePaused()) {
            ci.cancel();
        }
    }
}