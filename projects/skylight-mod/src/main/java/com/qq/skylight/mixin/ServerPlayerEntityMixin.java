package com.qq.skylight.mixin;

import com.qq.skylight.config.SkylightConfig;
import net.minecraft.enchantment.Enchantments;
import net.minecraft.entity.EquipmentSlot;
import net.minecraft.entity.vehicle.BoatEntity;
import net.minecraft.item.ItemStack;
import net.minecraft.item.Items;
import net.minecraft.registry.RegistryKeys;
import net.minecraft.server.network.ServerPlayerEntity;
import net.minecraft.server.world.ServerWorld;
import net.minecraft.util.math.BlockPos;
import net.minecraft.util.math.Vec3d;
import net.minecraft.world.Difficulty;
import net.minecraft.world.GameRules;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

/**
 * Mixin to handle player spawning with Skylight World settings.
 * Gives the player elytra, firework rockets, and spawns a boat nearby.
 */
@Mixin(ServerPlayerEntity.class)
public class ServerPlayerEntityMixin {

    @Inject(method = "onSpawn", at = @At("TAIL"))
    private void skylight$onPlayerSpawn(CallbackInfo ci) {
        if (!SkylightConfig.getConfig().createSkylightWorld) {
            return;
        }

        ServerPlayerEntity player = (ServerPlayerEntity) (Object) this;
        ServerWorld world = player.getServerWorld();

        // Set world to peaceful
        if (world.getServer() != null) {
            world.getServer().setDifficulty(Difficulty.PEACEFUL, true);
        }

        // Enable natural regeneration (no hunger)
        world.getGameRules().get(GameRules.NATURAL_REGENERATION).set(true, world.getServer());

        // Give unbreaking elytra
        ItemStack elytra = new ItemStack(Items.ELYTRA);

        // Get enchantments from registry
        var enchantmentRegistry = world.getRegistryManager().get(RegistryKeys.ENCHANTMENT);

        enchantmentRegistry.getEntry(Enchantments.UNBREAKING).ifPresent(entry -> {
            elytra.addEnchantment(entry, 3);
        });

        enchantmentRegistry.getEntry(Enchantments.MENDING).ifPresent(entry -> {
            elytra.addEnchantment(entry, 1);
        });

        player.equipStack(EquipmentSlot.CHEST, elytra);

        // Give stack of firework rockets
        ItemStack fireworks = new ItemStack(Items.FIREWORK_ROCKET, 64);
        player.getInventory().insertStack(fireworks);

        // Spawn a boat near the player
        BlockPos playerPos = player.getBlockPos();
        Vec3d boatPos = new Vec3d(playerPos.getX() + 2, playerPos.getY(), playerPos.getZ());

        BoatEntity boat = new BoatEntity(world, boatPos.x, boatPos.y, boatPos.z);
        // Default boat type is oak
        world.spawnEntity(boat);
    }
}