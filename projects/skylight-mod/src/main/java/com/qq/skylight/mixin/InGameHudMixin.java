package com.qq.skylight.mixin;

import com.qq.skylight.config.SkylightConfig;
import com.qq.skylight.state.SkylightState;
import net.minecraft.client.gui.hud.InGameHud;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

/**
 * Mixin to hide the HUD when skylight mode is active.
 */
@Mixin(InGameHud.class)
public class InGameHudMixin {

    @Inject(method = "render", at = @At("HEAD"), cancellable = true)
    private void onRender(CallbackInfo ci) {
        SkylightConfig config = SkylightConfig.getConfig();
        if (config.enableHudHide && SkylightState.isSkylightModeActive()) {
            ci.cancel();
        }
    }
}
