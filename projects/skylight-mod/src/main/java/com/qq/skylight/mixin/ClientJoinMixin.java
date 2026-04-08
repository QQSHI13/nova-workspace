package com.qq.skylight.mixin;

import com.qq.skylight.config.SkylightConfig;
import net.minecraft.client.MinecraftClient;
import net.minecraft.client.network.ClientPlayNetworkHandler;
import net.minecraft.network.packet.s2c.play.GameJoinS2CPacket;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

/**
 * Mixin that handles client join events to automatically enable auto-jump.
 */
@Mixin(ClientPlayNetworkHandler.class)
public class ClientJoinMixin {

    /**
     * Injects into the game join handler to enable auto-jump.
     */
    @Inject(method = "onGameJoin", at = @At("TAIL"))
    private void skylight$onGameJoin(GameJoinS2CPacket packet, CallbackInfo ci) {
        if (SkylightConfig.getConfig().autoJumpEnabled) {
            MinecraftClient.getInstance().options.getAutoJump().setValue(true);
        }
    }
}
