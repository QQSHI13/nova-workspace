package com.qq.skylight.mixin;

import com.qq.skylight.camera.FreeCamera;
import com.qq.skylight.state.SkylightState;
import net.minecraft.client.Mouse;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

/**
 * Mixin to handle mouse input for free camera rotation.
 */
@Mixin(Mouse.class)
public class MouseMixin {

    @Inject(method = "updateMouse", at = @At("HEAD"), cancellable = true)
    private void onUpdateMouse(CallbackInfo ci) {
        if (SkylightState.isFreeCamActive()) {
            // We'll handle the mouse differently in freecam
            // The actual rotation is applied in the CameraMixin
        }
    }

    @Inject(method = "updateLookDirection", at = @At("HEAD"), cancellable = true)
    private void onUpdateLookDirection(double deltaX, double deltaY, CallbackInfo ci) {
        if (SkylightState.isFreeCamActive()) {
            // Update free camera rotation instead of player rotation
            FreeCamera.getInstance().updateRotation(deltaX, deltaY);
            ci.cancel();
        }
    }
}