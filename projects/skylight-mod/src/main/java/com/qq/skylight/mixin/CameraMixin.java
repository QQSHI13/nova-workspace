package com.qq.skylight.mixin;

import com.qq.skylight.camera.FreeCamera;
import com.qq.skylight.state.SkylightState;
import net.minecraft.client.render.Camera;
import net.minecraft.entity.Entity;
import net.minecraft.util.math.Vec3d;
import org.joml.Quaternionf;
import org.joml.Vector3f;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.Shadow;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

/**
 * Mixin to override camera position and rotation during freecam mode.
 */
@Mixin(Camera.class)
public abstract class CameraMixin {

    @Shadow
    private Entity focusedEntity;

    @Shadow
    private Vec3d pos;

    @Shadow
    private float yaw;

    @Shadow
    private float pitch;

    @Shadow
    private Quaternionf rotation;

    @Shadow
    private Vector3f horizontalPlane;

    @Shadow
    private Vector3f verticalPlane;

    @Shadow
    private Vector3f diagonalPlane;

    @Shadow
    protected abstract void setRotation(float yaw, float pitch);

    /**
     * Overrides camera position when freecam is active.
     */
    @Inject(method = "update", at = @At("TAIL"))
    private void onUpdate(CallbackInfo ci) {
        if (SkylightState.isFreeCamActive()) {
            FreeCamera freeCam = FreeCamera.getInstance();
            this.pos = freeCam.getCameraPos();
            this.yaw = freeCam.getYaw();
            this.pitch = freeCam.getPitch();
            this.setRotation(this.yaw, this.pitch);
        }
    }

    /**
     * Returns freecam position instead of player position.
     */
    @Inject(method = "getPos", at = @At("HEAD"), cancellable = true)
    private void onGetPos(CallbackInfoReturnable<Vec3d> cir) {
        if (SkylightState.isFreeCamActive()) {
            cir.setReturnValue(FreeCamera.getInstance().getCameraPos());
        }
    }
}