package com.qq.skylight.mixin;

import com.qq.skylight.config.SkylightConfig;
import com.qq.skylight.state.SkylightState;
import net.minecraft.client.MinecraftClient;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.ModifyVariable;

/**
 * Mixin to slow down game tick speed when skylight mode is active.
 */
@Mixin(MinecraftClient.class)
public class MinecraftClientMixin {

    @ModifyVariable(
            method = "render",
            at = @At(value = "STORE", ordinal = 0),
            ordinal = 0
    )
    private float modifyTickDelta(float tickDelta) {
        SkylightConfig config = SkylightConfig.getConfig();
        if (config.enableTimeSlow && SkylightState.isSkylightModeActive()) {
            // Slow down time by a factor of 4 (0.25 speed)
            return tickDelta * 0.25f;
        }
        return tickDelta;
    }
}
