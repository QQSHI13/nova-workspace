package com.qq.skylight.mixin;

import com.qq.skylight.config.SkylightConfig;
import net.minecraft.network.ClientConnection;
import net.minecraft.server.PlayerManager;
import net.minecraft.server.network.ConnectedClientData;
import net.minecraft.server.network.ServerPlayerEntity;
import net.minecraft.world.Difficulty;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

/**
 * Mixin that handles player join events to automatically set Peaceful difficulty.
 */
@Mixin(PlayerManager.class)
public class PlayerJoinMixin {

    /**
     * Injects into the player connect method to set difficulty to Peaceful.
     * Note: 1.21.1+ requires ConnectedClientData as the third parameter.
     */
    @Inject(method = "onPlayerConnect", at = @At("TAIL"))
    private void skylight$onPlayerConnect(ClientConnection connection, ServerPlayerEntity player, ConnectedClientData clientData, CallbackInfo ci) {
        if (SkylightConfig.getConfig().autoPeacefulEnabled && player.getServer() != null) {
            player.getServer().setDifficulty(Difficulty.PEACEFUL, true);
        }
    }
}
