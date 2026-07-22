package info.mudbourn.kssupport.mixin;

import net.minecraft.core.component.DataComponents;
import net.minecraft.resources.Identifier;
import net.minecraft.world.item.ItemStack;
import net.yyasso.hurl.mace.MaceEntity;
import net.yyasso.hurl.render.MaceEntityModel;
import net.yyasso.hurl.render.MaceEntityRenderState;
import net.yyasso.hurl.render.MaceEntityRenderer;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.Unique;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.ModifyArg;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

/**
 * Swaps the Hurl thrown-mace entity texture to Mjolnir's when the
 * thrown item has {@code item_model="killstreak:mjolnir"}.
 */
@Mixin(value = MaceEntityRenderer.class, remap = false)
public class MaceEntityRendererMixin {

    @Unique
    private static final Identifier ks_support$MJOLNIR_ENTITY_TEXTURE =
            Identifier.tryBuild("killstreak", "textures/entity/mjolnir.png");

    @Unique
    private static final Identifier ks_support$MJOLNIR_MODEL_ID =
            Identifier.tryBuild("killstreak", "mjolnir");

    /** Set in updateRenderState, read in render. Both run sequentially on the render thread. */
    @Unique
    private boolean ks_support$isMjolnir;

    /**
     * After the normal updateRenderState, inspect the thrown item to see if it's Mjolnir.
     */
    @Inject(method = "updateRenderState", at = @At("TAIL"))
    private void ks_support$detectMjolnir(MaceEntity entity, MaceEntityRenderState state, float pt, CallbackInfo ci) {
        ks_support$isMjolnir = false;
        ItemStack stack = entity.getWeaponItem();
        if (stack != null && !stack.isEmpty()) {
            Identifier modelId = stack.get(DataComponents.ITEM_MODEL);
            if (ks_support$MJOLNIR_MODEL_ID.equals(modelId)) {
                ks_support$isMjolnir = true;
            }
        }
    }

    /**
     * Modify the texture argument to MaceEntityModel.renderType(Identifier).
     * Swaps hurl:textures/entity/mace.png → killstreak:textures/entity/mjolnir.png
     * when the thrown item is Mjolnir.
     */
    @ModifyArg(
            method = "render",
            at = @At(
                    value = "INVOKE",
                    target = "Lnet/yyasso/hurl/render/MaceEntityModel;renderType:(Lnet/minecraft/resources/Identifier;)Lnet/minecraft/client/renderer/rendertype/RenderType;"
            ),
            index = 0
    )
    private Identifier ks_support$swapTexture(Identifier texture) {
        if (ks_support$isMjolnir) {
            return ks_support$MJOLNIR_ENTITY_TEXTURE;
        }
        return texture;
    }
}
