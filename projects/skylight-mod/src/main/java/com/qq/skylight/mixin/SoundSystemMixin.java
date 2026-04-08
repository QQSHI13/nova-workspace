package com.qq.skylight.mixin;

import com.qq.skylight.config.SkylightConfig;
import com.qq.skylight.state.SkylightState;
import net.minecraft.client.sound.SoundInstance;
import net.minecraft.client.sound.SoundSystem;
import net.minecraft.entity.EntityType;
import net.minecraft.sound.SoundCategory;
import net.minecraft.util.Identifier;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

import java.util.Set;

/**
 * Mixin to cancel hostile mob sounds when skylight mode is active.
 */
@Mixin(SoundSystem.class)
public class SoundSystemMixin {

    private static final Set<String> HOSTILE_MOB_PREFIXES = Set.of(
            "entity.zombie",
            "entity.skeleton",
            "entity.creeper",
            "entity.spider",
            "entity.enderman",
            "entity.witch",
            "entity.slime",
            "entity.phantom",
            "entity.drowned",
            "entity.husk",
            "entity.stray",
            "entity.cave_spider",
            "entity.silverfish",
            "entity.endermite",
            "entity.ravager",
            "entity.vindicator",
            "entity.evoker",
            "entity.vex",
            "entity.pillager",
            "entity.illusioner",
            "entity.guardian",
            "entity.elder_guardian",
            "entity.warden",
            "entity.blaze",
            "entity.ghast",
            "entity.hoglin",
            "entity.piglin",
            "entity.piglin_brute",
            "entity.zoglin",
            "entity.zombified_piglin",
            "entity.magma_cube",
            "entity.shulker",
            "entity.wither",
            "entity.wither_skeleton"
    );

    @Inject(method = "play(Lnet/minecraft/client/sound/SoundInstance;)V", at = @At("HEAD"), cancellable = true)
    private void onPlay(SoundInstance sound, CallbackInfo ci) {
        SkylightConfig config = SkylightConfig.getConfig();
        if (!config.enableSoundMute || !SkylightState.isSkylightModeActive()) {
            return;
        }

        // Check if this is a hostile mob sound
        Identifier id = sound.getId();
        String path = id.getPath();

        for (String prefix : HOSTILE_MOB_PREFIXES) {
            if (path.startsWith(prefix)) {
                ci.cancel();
                return;
            }
        }
    }
}
